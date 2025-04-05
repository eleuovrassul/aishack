import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Future<Database> initDB() async {
    // Инициализация для Windows, macOS или Linux
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'school.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE lessons (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            day TEXT,
            subject TEXT,
            className TEXT,
            room TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE students (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            status TEXT,
            lessonId INTEGER,
            FOREIGN KEY (lessonId) REFERENCES lessons (id)
          )
        ''');

        await db.execute('''
          CREATE TABLE schedule (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            lessonId INTEGER,
            studentId INTEGER,
            isPresent INTEGER DEFAULT 0,
            FOREIGN KEY (lessonId) REFERENCES lessons (id),
            FOREIGN KEY (studentId) REFERENCES students (id)
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

  static Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? args]) async {
    final db = await initDB();
    return await db.rawQuery(sql, args);
  }
}