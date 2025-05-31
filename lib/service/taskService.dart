import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tasks_list/models/task.dart';

class TaskService {
  final supabase = Supabase.instance.client;

  Future<Task> addTask(Task task) async {
    final response = await supabase.from('tasks').insert({
      'name': task.name,
      'complete': task.complete == 1,
      'user_id': task.userId,
    }).select();

    Task resTask = Task.fromJson(response.first);
    resTask.remote = true;
    return resTask;
  }

  Future<void> updateTask(Task task) async {
    await supabase.from('tasks').update({
      'name': task.name,
      'complete': task.complete == 1,
    }).match({'id': task.userId});
  }

  Future<void> deleteTask(String taskId) async {
    await supabase.from('tasks').delete().match({'id': taskId});
  }

  Future<List<Task>> fetchTasks(String userId) async {
    final response = await supabase
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .order('name');

    return (response as List).map((map) {
      return Task(
        id: map['id'],
        name: map['name'],
        complete: map['complete'] ? 1 : 0,
        userId: map['user_id'],
      );
    }).toList();
  }
}
