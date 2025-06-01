import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tasks_list/models/task.dart';

class DataBaseHelper {
  static final DataBaseHelper _instance = DataBaseHelper._internal();
  factory DataBaseHelper() => _instance;
  static Database? _database;

  DataBaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String path = join(await getDatabasesPath(), filePath);

    //await deleteDatabase(path);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE tasks(
            id TEXT PRIMARY KEY,
            name TEXT,
            complete INTEGER DEFAULT 0,
            user_id TEXT,
            remote INTEGER DEFAULT 0,
            to_delete INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<int> insertTask(Task task) async {
    final db = await database;
    return db.insert(
      'tasks',
      task.toMap()
    );
  }

  Future<List<Task>> getDeleteTasks(String userId) async {
    final db = await database;
    final task = await db.query(
      'tasks',
      where: 'user_id = ? AND to_delete = ?',
      whereArgs: [userId, 1],
    );
    return task.map((task) => Task.fromMap(task)).toList();
  }

  Future<List<Task>> getTasks(String userId) async {
    final db = await database;
    final task = await db.query(
      'tasks',
      where: 'user_id = ? AND to_delete = ?',
      whereArgs: [userId, 0],
    );
    return task.map((task) => Task.fromMap(task)).toList();
  }

  Future<int> deleteTask(String id) async {
    final db = await database;
    return db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearTasks(String userId) async {
    final db = await database;
    await db.delete('tasks', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }
}


