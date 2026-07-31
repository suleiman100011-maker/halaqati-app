import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class DBHelper {
  static Database? _db;
  static Future<Database> get db async { _db ??= await _initDB(); return _db!; }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'halaqati_v2.db');
    return openDatabase(path, version: 1, onCreate: (db, v) async {
      await db.execute('''CREATE TABLE students(id TEXT PRIMARY KEY, name TEXT, phone TEXT,
        active INTEGER DEFAULT 1, total_points INTEGER DEFAULT 0, join_date TEXT)''');
      await db.execute('''CREATE TABLE sessions(id TEXT PRIMARY KEY, student_id TEXT,
        student_name TEXT, date TEXT, status TEXT DEFAULT 'none',
        hifz_amount REAL DEFAULT 0, hifz_note TEXT, hifz_completed INTEGER DEFAULT 0,
        review_amount REAL DEFAULT 0, review_note TEXT, review_completed INTEGER DEFAULT 0,
        rating TEXT DEFAULT 'جيد')''');
      await db.execute('''CREATE TABLE point_transactions(id TEXT PRIMARY KEY,
        student_id TEXT, student_name TEXT, points_change INTEGER, type TEXT,
        note TEXT, created_date TEXT)''');
      await db.execute('''CREATE TABLE settings(id TEXT PRIMARY KEY,
        halaka_name TEXT, teacher_name TEXT)''');
    });
  }

  // Students
  static Future<List<Student>> getStudents({bool? active}) async {
    final d = await db;
    final rows = active != null
      ? await d.query('students', where: 'active=?', whereArgs: [active ? 1 : 0], orderBy: 'name')
      : await d.query('students', orderBy: 'name');
    return rows.map(Student.fromMap).toList();
  }
  static Future<void> insertStudent(Student s) async => (await db).insert('students', s.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  static Future<void> updateStudent(Student s) async => (await db).update('students', s.toMap(), where: 'id=?', whereArgs: [s.id]);
  static Future<void> deleteStudent(String id) async {
    final d = await db;
    await d.delete('students', where: 'id=?', whereArgs: [id]);
    await d.delete('point_transactions', where: 'student_id=?', whereArgs: [id]);
  }

  // Sessions
  static Future<List<Session>> getSessions({String? date, String? studentId}) async {
    final d = await db;
    String? where; List<dynamic>? args;
    if (date != null && studentId != null) { where = 'date=? AND student_id=?'; args = [date, studentId]; }
    else if (date != null) { where = 'date=?'; args = [date]; }
    else if (studentId != null) { where = 'student_id=?'; args = [studentId]; }
    final rows = await d.query('sessions', where: where, whereArgs: args, orderBy: 'date DESC');
    return rows.map(Session.fromMap).toList();
  }
  static Future<List<Session>> getSessionsInRange(String from, String to) async {
    final rows = await (await db).query('sessions', where: 'date>=? AND date<=?', whereArgs: [from, to], orderBy: 'date DESC');
    return rows.map(Session.fromMap).toList();
  }
  static Future<void> upsertSession(Session s) async => (await db).insert('sessions', s.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  static Future<void> updateSessionField(String id, String field, dynamic value) async {
    await (await db).update('sessions', {field: value}, where: 'id=?', whereArgs: [id]);
  }

  // Transactions
  static Future<List<PointTx>> getTransactions({String? studentId}) async {
    final d = await db;
    final rows = studentId != null
      ? await d.query('point_transactions', where: 'student_id=?', whereArgs: [studentId], orderBy: 'created_date DESC', limit: 200)
      : await d.query('point_transactions', orderBy: 'created_date DESC', limit: 500);
    return rows.map(PointTx.fromMap).toList();
  }
  static Future<void> insertTx(PointTx t) async => (await db).insert('point_transactions', t.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

  // Settings
  static Future<HalaqaSetting?> getSettings() async {
    final rows = await (await db).query('settings', limit: 1);
    return rows.isEmpty ? null : HalaqaSetting.fromMap(rows.first);
  }
  static Future<void> upsertSettings(HalaqaSetting s) async => (await db).insert('settings', s.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

  // Clear
  static Future<void> clearAll() async {
    final d = await db;
    await d.delete('students'); await d.delete('sessions');
    await d.delete('point_transactions'); await d.delete('settings');
  }
}
