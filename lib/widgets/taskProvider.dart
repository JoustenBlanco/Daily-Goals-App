import 'package:flutter/material.dart';
import 'package:tasks_list/service/dataBaseHelper.dart';
import 'package:tasks_list/service/taskService.dart';
import 'package:tasks_list/models/task.dart';

class TaskProvider extends ChangeNotifier {
  final _taskService = TaskService();
  List<Task> _tasks = [];
  String? _userId;

  List<Task> get tasks => _tasks;
  String? get userId => _userId;

  Future<void> setUser(String userId) async {
    _userId = userId;
    final remoteTasks = await _taskService.fetchTasks(userId);
    await DataBaseHelper().clearTasks(userId);
    for (final task in remoteTasks) {
      await DataBaseHelper().insertTask(task);
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
    Task resTask = await _taskService.addTask(task);
    await DataBaseHelper().insertTask(resTask);
    await loadTasks();
  }

  Future<void> toggleTask(Task task) async {
    task.complete = task.complete == 1 ? 0 : 1;
    await DataBaseHelper().updateTask(task);
    await _taskService.updateTask(task);
    await loadTasks();
  }

  Future<void> deleteTask(Task task) async {
    await DataBaseHelper().deleteTask(task.id!);
    await _taskService.deleteTask(task.id!);
    await loadTasks();
  }

  Future<void> editTask(Task task, String newTitle) async {
    task.name = newTitle;
    await DataBaseHelper().updateTask(task);
    await _taskService.updateTask(task);
    await loadTasks();
  }

  Future<void> deleteCompletedTasks() async {
    final completed = _tasks.where((task) => task.complete == 1).toList();
    for (var task in completed) {
      await DataBaseHelper().deleteTask(task.id!);
      await _taskService.deleteTask(task.id!);
    }
    await loadTasks();
  }

  Future<void> completeAllPendingTasks() async {
    final pending = _tasks.where((task) => task.complete == 0).toList();
    for (var task in pending) {
      task.complete = 1;
      await DataBaseHelper().updateTask(task);
      await _taskService.updateTask(task);
    }
    await loadTasks();
  }
}
