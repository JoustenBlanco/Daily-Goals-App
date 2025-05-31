import 'package:flutter/material.dart';
import 'package:tasks_list/models/task.dart';
import 'package:tasks_list/service/dataBaseHelper.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  Future<void> loadTasks() async {
    _tasks = await DataBaseHelper().getTasks();
    notifyListeners();
  }

  Future<void> addTask(String title) async {
    final task = Task(name: title, complete: 0);
    await DataBaseHelper().insertTask(task);
    await loadTasks();
  }

  Future<void> toggleTask(Task tarea) async {
    tarea.complete = tarea.complete == 1 ? 0 : 1;
    await DataBaseHelper().updateTask(tarea);
    await loadTasks();
  }

  Future<void> deleteTask(Task tarea) async {
    await DataBaseHelper().deleteTask(tarea.id!);
    await loadTasks();
  }

  Future<void> editTask(Task tarea, String newTitle) async {
    tarea.name = newTitle;
    await DataBaseHelper().updateTask(tarea);
    await loadTasks();
  }

  Future<void> deleteCompletedTasks() async {
    final completed = _tasks.where((task) => task.complete == 1).toList();
    for (var task in completed) {
      await DataBaseHelper().deleteTask(task.id!);
    }
    await loadTasks();
  }

  Future<void> completeAllPendingTasks() async {
    final pending = _tasks.where((task) => task.complete == 0).toList();
    for (var task in pending) {
      task.complete = 1;
      await DataBaseHelper().updateTask(task);
    }
    await loadTasks();
  }
}
