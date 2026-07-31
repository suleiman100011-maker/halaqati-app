import 'dart:convert';
import 'package:flutter/material.dart';
import 'models.dart';
import '../db/db_helper.dart';

class AppState extends ChangeNotifier {
  List<Student> students = [];
  List<Session> sessions = [];
  List<PointTx> transactions = [];
  HalaqaSetting settings = HalaqaSetting(id: 'main');
  bool isReady = false;

  Future<void> load() async {
    students = await DBHelper.getStudents();
    sessions = await DBHelper.getSessions();
    transactions = await DBHelper.getTransactions();
    final s = await DBHelper.getSettings();
    if (s != null) settings = s;
    isReady = true;
    notifyListeners();
  }

  String get todayKey => DateTime.now().toIso8601String().split('T')[0];

  // ── Points ──────────────────────────────────────────────
  int getPoints(String id) => students.firstWhere((s) => s.id == id, orElse: () => Student(id: id, name: '', joinDate: '')).totalPoints;
  int getStars(int pts) => pts > 0 ? pts ~/ 10 : 0;
  int getTodayPoints(String studentId) => transactions.where((t) => t.studentId == studentId && t.createdDate.startsWith(todayKey)).fold(0, (s, t) => s + t.pointsChange);

  // ── Today session ────────────────────────────────────────
  Session? getTodaySession(String studentId) {
    try { return sessions.firstWhere((s) => s.studentId == studentId && s.date == todayKey); }
    catch (_) { return null; }
  }

  // ── Stats ────────────────────────────────────────────────
  int get totalActive => students.where((s) => s.active).length;
  int get presentToday => sessions.where((s) => s.date == todayKey && s.status == 'present').length;
  int get absentToday => sessions.where((s) => s.date == todayKey && (s.status == 'absent' || s.status == 'absent_excused')).length;

  // ── Add Student ───────────────────────────────────────────
  Future<void> addStudent(String name, String phone) async {
    final s = Student(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name, phone: phone, joinDate: DateTime.now().toIso8601String());
    await DBHelper.insertStudent(s);
    students = [...students, s]..sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  Future<void> toggleActive(String id) async {
    final idx = students.indexWhere((s) => s.id == id); if (idx == -1) return;
    students[idx].active = !students[idx].active;
    await DBHelper.updateStudent(students[idx]); notifyListeners();
  }

  Future<void> deleteStudent(String id) async {
    await DBHelper.deleteStudent(id);
    students = students.where((s) => s.id != id).toList();
    sessions = sessions.where((s) => s.studentId != id).toList();
    transactions = transactions.where((t) => t.studentId != id).toList();
    notifyListeners();
  }

  // ── Session ───────────────────────────────────────────────
  Future<Session> getOrCreateSession(String studentId) async {
    final existing = getTodaySession(studentId);
    if (existing != null) return existing;
    final student = students.firstWhere((s) => s.id == studentId);
    final sess = Session(id: '${studentId}_$todayKey', studentId: studentId, studentName: student.name, date: todayKey);
    await DBHelper.upsertSession(sess);
    sessions = [sess, ...sessions];
    notifyListeners();
    return sess;
  }

  Future<void> updateSessionField(String studentId, String field, dynamic value) async {
    final sess = await getOrCreateSession(studentId);
    switch (field) {
      case 'status': sess.status = value as String;
      case 'hifz_amount': sess.hifzAmount = (value as num).toDouble();
      case 'hifz_note': sess.hifzNote = value as String;
      case 'hifz_completed': sess.hifzCompleted = value as bool;
      case 'review_amount': sess.reviewAmount = (value as num).toDouble();
      case 'review_note': sess.reviewNote = value as String;
      case 'review_completed': sess.reviewCompleted = value as bool;
      case 'rating': sess.rating = value as String;
    }
    await DBHelper.upsertSession(sess);
    notifyListeners();
  }

  // ── Points Tx ─────────────────────────────────────────────
  Future<void> addTx(String studentId, int delta, String type, String note) async {
    final student = students.firstWhere((s) => s.id == studentId);
    final t = PointTx(id: DateTime.now().millisecondsSinceEpoch.toString(), studentId: studentId, studentName: student.name, pointsChange: delta, type: type, note: note, createdDate: DateTime.now().toIso8601String());
    await DBHelper.insertTx(t);
    transactions = [t, ...transactions];
    final idx = students.indexWhere((s) => s.id == studentId);
    if (idx != -1) {
      students[idx].totalPoints += delta;
      await DBHelper.updateStudent(students[idx]);
    }
    notifyListeners();
  }

  // ── Settings ─────────────────────────────────────────────
  Future<void> saveSettings(String halakaName, String teacherName) async {
    settings.halakaName = halakaName; settings.teacherName = teacherName;
    await DBHelper.upsertSettings(settings); notifyListeners();
  }

  // ── Reports helpers ──────────────────────────────────────
  List<Session> getSessionsInPeriod(String from, String to) =>
      sessions.where((s) => s.date >= from && s.date <= to).toList();

  Map<String, dynamic> getStudentStats(String studentId, List<Session> periodSessions) {
    final ss = periodSessions.where((s) => s.studentId == studentId).toList();
    final present = ss.where((s) => s.status == 'present').length;
    final absent = ss.where((s) => s.status == 'absent').length;
    final excused = ss.where((s) => s.status == 'absent_excused').length;
    final total = present + absent + excused;
    final rate = total > 0 ? ((present / total) * 100).round() : 0;
    final hifzPages = ss.where((s) => s.hifzCompleted && s.hifzAmount > 0).fold(0.0, (sum, s) => sum + s.hifzAmount);
    final reviewPages = ss.where((s) => s.reviewCompleted && s.reviewAmount > 0).fold(0.0, (sum, s) => sum + s.reviewAmount);
    final hifzList = ss.where((s) => s.hifzCompleted && (s.hifzAmount > 0 || s.hifzNote.isNotEmpty)).map((s) {
      var line = ''; if (s.hifzAmount > 0) line += '${s.hifzAmount} صفحة'; if (s.hifzNote.isNotEmpty) line += '. ${s.hifzNote}'; return line;
    }).toList();
    final reviewList = ss.where((s) => s.reviewCompleted && (s.reviewAmount > 0 || s.reviewNote.isNotEmpty)).map((s) {
      var line = ''; if (s.reviewAmount > 0) line += '${s.reviewAmount} صفحة'; if (s.reviewNote.isNotEmpty) line += '. ${s.reviewNote}'; return line;
    }).toList();
    return {'present': present, 'absent': absent, 'excused': excused, 'total': total, 'rate': rate, 'hifzPages': hifzPages, 'reviewPages': reviewPages, 'hifzList': hifzList, 'reviewList': reviewList};
  }

  // ── Backup ────────────────────────────────────────────────
  String exportJson() => jsonEncode({
    'app': 'halaqati', 'version': 2, 'exported_at': DateTime.now().toIso8601String(),
    'students': students.map((s) => s.toJson()).toList(),
    'sessions': sessions.map((s) => s.toJson()).toList(),
    'transactions': transactions.map((t) => t.toJson()).toList(),
    'settings': settings.toJson(),
  });

  Future<void> importJson(String raw) async {
    final d = jsonDecode(raw);
    await DBHelper.clearAll();
    for (final s in (d['students'] ?? [])) await DBHelper.insertStudent(Student.fromJson(s));
    for (final s in (d['sessions'] ?? [])) await DBHelper.upsertSession(Session.fromJson(s));
    for (final t in (d['transactions'] ?? [])) await DBHelper.insertTx(PointTx.fromJson(t));
    if (d['settings'] != null) await DBHelper.upsertSettings(HalaqaSetting.fromJson(d['settings']));
    await load();
  }

  Future<void> clearAll() async {
    await DBHelper.clearAll();
    students = []; sessions = []; transactions = [];
    settings = HalaqaSetting(id: 'main'); notifyListeners();
  }
}
