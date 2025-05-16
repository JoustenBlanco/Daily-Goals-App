import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'tarea.dart';

class DataBaseHelper {
  static final DataBaseHelper _instance = DataBaseHelper._internal();
  factory DataBaseHelper() => _instance;
  static Database? _database;

  DataBaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tareas.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String path = join(await getDatabasesPath(), filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE tareas(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT,
            completada INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<int> insertTarea(Tarea tarea) async {
    final db = await database;
    return db.insert(
      'tareas',
      tarea.toMap()
    );
  }

  Future<List<Tarea>> getTareas() async {
    final db = await database;
    final tareas = await db.query('tareas');
    return tareas.map((tarea) => Tarea.fromMap(tarea)).toList();
  }

  Future<int> deleteTarea(int id) async {
    final db = await database;
    return db.delete(
      'tareas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateTarea(Tarea tarea) async {
    final db = await database;
    return db.update(
      'tareas',
      tarea.toMap(),
      where: 'id = ?',
      whereArgs: [tarea.id],
    );
  }
}


