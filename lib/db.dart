import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'school.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Создание таблицы уроков
        await db.execute('''
          CREATE TABLE lessons (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            day TEXT,
            subject TEXT,
            className TEXT,
            room TEXT
          )
        ''');
        // Создание таблицы учеников
        await db.execute('''
          CREATE TABLE students (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            status TEXT,
            lessonId INTEGER,
            FOREIGN KEY (lessonId) REFERENCES lessons (id)
          )
        ''');
      },
    );
  }

  static Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await initDB();
    return await db.insert(table, data);
  }

  static Future<List<Map<String, dynamic>>> query(String table) async {
    final db = await initDB();
    return await db.query(table);
  }

  static Future<int> update(String table, Map<String, dynamic> data, String where, List<dynamic> whereArgs) async {
    final db = await initDB();
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }
}