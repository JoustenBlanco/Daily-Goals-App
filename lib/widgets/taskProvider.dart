import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasks_list/service/dataBaseHelper.dart';
import 'package:tasks_list/service/taskService.dart';
import 'package:tasks_list/models/task.dart';

class TaskProvider extends ChangeNotifier {
  final _taskService = TaskService();
  final _uuid = Uuid();
  ConnectivityResult? _previousResult;
  bool _initialized = false;
  bool _needsSync = false;
  List<Task> _tasks = [];
  String? _userId;

  List<Task> get tasks => _tasks;
  String? get userId => _userId;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await _loadNeedsSync();
    _setupConnectivityListener();

    if (await _isConnected() && _needsSync) {
      await syncTask();
    }
  }

  Future<void> _setNeedsSync(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('_needsSync', value);
    _needsSync = value;
  }

  Future<void> _loadNeedsSync() async {
    final prefs = await SharedPreferences.getInstance();
    _needsSync = prefs.getBool('_needsSync') ?? false;
  }

  void _setupConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((result) async {
      final wasConnected = _previousResult != ConnectivityResult.none;
      final isConnected = result != ConnectivityResult.none;

      // Solo si antes NO había conexión y ahora SÍ hay conexión
      if (!wasConnected && isConnected && _needsSync) {
        await syncTask();
      }

      // Si pasamos a estar sin conexión
      if (!isConnected) {
        await _setNeedsSync(true);
      }

      _previousResult = result; // Actualizamos estado anterior
    });
  }

  Future<void> syncTask() async {
    if (_userId == null) return;
    await _setNeedsSync(false);
    
    // 1. Obtener tareas locales y remotas
    List<Task> localTasks = await DataBaseHelper().getTasks(_userId!);
    List<Task> remoteTasks = await _taskService.fetchTasks(_userId!);

    // Convertir listas a mapas para fácil acceso por ID
    final localMap = {for (var task in localTasks) task.id!: task};
    final remoteMap = {for (var task in remoteTasks) task.id!: task};

    // 2. Tareas locales con remote == false → subirlas a Supabase
    for (var task in localTasks.where((t) => !t.remote)) {
      final createdTask = await _taskService.addTask(task); // subir
      await DataBaseHelper().deleteTask(task.id!);         // borrar tarea local vieja (sin ID remoto)
      remoteTasks.add(createdTask);
    }

    // 3. Tareas que están en remoto pero NO están en local → eliminar en remoto
    List<Task> localDeleteTasks = await DataBaseHelper().getDeleteTasks(_userId!);
    final localDeleteMap = {for (var task in localDeleteTasks) task.id!: task};

    // Recopilar IDs de tareas a eliminar en Supabase
    final idsToDelete = remoteTasks
        .where((task) => localDeleteMap.containsKey(task.id))
        .map((task) => task.id!)
        .toList();

    // Eliminar tareas en Supabase
    for (var id in idsToDelete) {
      remoteTasks.removeWhere((task) => task.id == id);
      await _taskService.deleteTask(id);
      await DataBaseHelper().deleteTask(id);
    }

    // 4. Tareas locales (con mismo ID) → actualizar en Supabase
    for (var task in localTasks) {
      if (remoteMap.containsKey(task.id)) {
        await _taskService.updateTask(task);
      }
    }

    // 5. Tareas que están en remoto pero NO están en local → agregarlas localmente
    for (var remoteTask in remoteTasks) {
      if (!localMap.containsKey(remoteTask.id)) {
        remoteTask.remote = true;
        await DataBaseHelper().insertTask(remoteTask);
      }
    }

    // 6. Cargar tareas actualizadas
    await loadTasks();
  }

  Future<bool> _isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> setUser(String userId) async {
    _userId = userId;
    if (await _isConnected()) {
      await syncTask();
    }
    await loadTasks();
  }

  Future<void> loadTasks() async {
    if (_userId != null){
      _tasks = await DataBaseHelper().getTasks(_userId!);
      notifyListeners();
    } 
  }

  Future<void> addTask(String title) async {
    final task = Task(name: title, complete: 0, userId: _userId!);
    if (await _isConnected()) {
      Task resTask = await _taskService.addTask(task);
      await DataBaseHelper().insertTask(resTask);
    }else{
      task.id = _uuid.v4();
      await DataBaseHelper().insertTask(task);
    }
    await loadTasks();
  }

  Future<void> toggleTask(Task task) async {
    task.complete = task.complete == 1 ? 0 : 1;
    await DataBaseHelper().updateTask(task);
    if (await _isConnected()) await _taskService.updateTask(task);
    await loadTasks();
  }

  Future<void> deleteTask(Task task) async {
    if (await _isConnected()){
      await DataBaseHelper().deleteTask(task.id!);
      await _taskService.deleteTask(task.id!);
    }else if (!task.remote){
      await DataBaseHelper().deleteTask(task.id!);
    }else{
      task.to_delete = true;
      await DataBaseHelper().updateTask(task);
    }
    await loadTasks();
  }

  Future<void> editTask(Task task, String newTitle) async {
    task.name = newTitle;
    await DataBaseHelper().updateTask(task);
    if (await _isConnected()) await _taskService.updateTask(task);
    await loadTasks();
  }

  Future<void> deleteCompletedTasks() async {
    final completed = _tasks.where((task) => task.complete == 1).toList();
    for (var task in completed) {
      if (await _isConnected()){
        await DataBaseHelper().deleteTask(task.id!);
        await _taskService.deleteTask(task.id!);
      }else if (!task.remote){
        await DataBaseHelper().deleteTask(task.id!);
      }else{
        task.to_delete = true;
        await DataBaseHelper().updateTask(task);
      }
    }
    await loadTasks();
  }

  Future<void> completeAllPendingTasks() async {
    final pending = _tasks.where((task) => task.complete == 0).toList();
    for (var task in pending) {
      task.complete = 1;
      await DataBaseHelper().updateTask(task);
      if (await _isConnected()) await _taskService.updateTask(task);
    }
    await loadTasks();
  }
}
