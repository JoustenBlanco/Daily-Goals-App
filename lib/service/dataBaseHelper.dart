import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/task.dart';

class DataBaseHelper {
  static final DataBaseHelper _instance = DataBaseHelper._internal();
  factory DataBaseHelper() => _instance;
  static Database? _database;

  DataBaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('task.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String path = join(await getDatabasesPath(), filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE task(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT,
            completada INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<int> insertTask(Task tarea) async {
    final db = await database;
    return db.insert(
      'task',
      tarea.toMap()
    );
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final task = await db.query('task');
    return task.map((tarea) => Task.fromMap(tarea)).toList();
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return db.delete(
      'task',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateTask(Task tarea) async {
    final db = await database;
    return db.update(
      'task',
      tarea.toMap(),
      where: 'id = ?',
      whereArgs: [tarea.id],
    );
  }
}


