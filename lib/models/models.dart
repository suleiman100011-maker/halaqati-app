import 'dart:convert';

class Student {
  final String id, name, phone, joinDate;
  bool active;
  int totalPoints;

  Student({required this.id, required this.name, this.phone = '', this.active = true, this.totalPoints = 0, required this.joinDate});

  factory Student.fromMap(Map<String, dynamic> m) => Student(
    id: m['id'], name: m['name'], phone: m['phone'] ?? '',
    active: m['active'] == 1, totalPoints: m['total_points'] ?? 0,
    joinDate: m['join_date'] ?? '',
  );
  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'phone': phone, 'active': active ? 1 : 0, 'total_points': totalPoints, 'join_date': joinDate};
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'phone': phone, 'active': active, 'total_points': totalPoints, 'join_date': joinDate};
  factory Student.fromJson(Map<String, dynamic> j) => Student(
    id: j['id'], name: j['name'], phone: j['phone'] ?? '',
    active: j['active'] == true || j['active'] == 1,
    totalPoints: j['total_points'] ?? 0,
    joinDate: j['join_date'] ?? DateTime.now().toIso8601String(),
  );
}

class Session {
  final String id, studentId, studentName, date;
  String status; // present | absent | absent_excused | none
  double hifzAmount;
  String hifzNote;
  bool hifzCompleted;
  double reviewAmount;
  String reviewNote;
  bool reviewCompleted;
  String rating;

  Session({required this.id, required this.studentId, required this.studentName,
    required this.date, this.status = 'none', this.hifzAmount = 0, this.hifzNote = '',
    this.hifzCompleted = false, this.reviewAmount = 0, this.reviewNote = '',
    this.reviewCompleted = false, this.rating = 'جيد'});

  factory Session.fromMap(Map<String, dynamic> m) => Session(
    id: m['id'], studentId: m['student_id'], studentName: m['student_name'] ?? '',
    date: m['date'], status: m['status'] ?? 'none',
    hifzAmount: (m['hifz_amount'] ?? 0).toDouble(), hifzNote: m['hifz_note'] ?? '',
    hifzCompleted: m['hifz_completed'] == 1,
    reviewAmount: (m['review_amount'] ?? 0).toDouble(), reviewNote: m['review_note'] ?? '',
    reviewCompleted: m['review_completed'] == 1, rating: m['rating'] ?? 'جيد',
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'student_id': studentId, 'student_name': studentName, 'date': date,
    'status': status, 'hifz_amount': hifzAmount, 'hifz_note': hifzNote,
    'hifz_completed': hifzCompleted ? 1 : 0, 'review_amount': reviewAmount,
    'review_note': reviewNote, 'review_completed': reviewCompleted ? 1 : 0, 'rating': rating,
  };

  Map<String, dynamic> toJson() => {
    'id': id, 'student_id': studentId, 'student_name': studentName, 'date': date,
    'status': status, 'hifz_amount': hifzAmount, 'hifz_note': hifzNote,
    'hifz_completed': hifzCompleted, 'review_amount': reviewAmount,
    'review_note': reviewNote, 'review_completed': reviewCompleted, 'rating': rating,
  };

  factory Session.fromJson(Map<String, dynamic> j) => Session(
    id: j['id'], studentId: j['student_id'], studentName: j['student_name'] ?? '',
    date: j['date'], status: j['status'] ?? 'none',
    hifzAmount: (j['hifz_amount'] ?? 0).toDouble(), hifzNote: j['hifz_note'] ?? '',
    hifzCompleted: j['hifz_completed'] == true || j['hifz_completed'] == 1,
    reviewAmount: (j['review_amount'] ?? 0).toDouble(), reviewNote: j['review_note'] ?? '',
    reviewCompleted: j['review_completed'] == true || j['review_completed'] == 1,
    rating: j['rating'] ?? 'جيد',
  );
}

class PointTx {
  final String id, studentId, studentName, type, note, createdDate;
  final int pointsChange;

  PointTx({required this.id, required this.studentId, required this.studentName,
    required this.pointsChange, required this.type, this.note = '', required this.createdDate});

  factory PointTx.fromMap(Map<String, dynamic> m) => PointTx(
    id: m['id'], studentId: m['student_id'], studentName: m['student_name'] ?? '',
    pointsChange: m['points_change'], type: m['type'], note: m['note'] ?? '',
    createdDate: m['created_date'],
  );
  Map<String, dynamic> toMap() => {'id': id, 'student_id': studentId, 'student_name': studentName, 'points_change': pointsChange, 'type': type, 'note': note, 'created_date': createdDate};
  factory PointTx.fromJson(Map<String, dynamic> j) => PointTx(
    id: j['id'], studentId: j['student_id'], studentName: j['student_name'] ?? '',
    pointsChange: j['points_change'], type: j['type'], note: j['note'] ?? '',
    createdDate: j['created_date'],
  );
  Map<String, dynamic> toJson() => toMap();
}

class HalaqaSetting {
  final String id;
  String halakaName, teacherName;
  HalaqaSetting({required this.id, this.halakaName = 'حلقة الإيمان', this.teacherName = 'الشيخ محمد'});
  factory HalaqaSetting.fromMap(Map<String, dynamic> m) => HalaqaSetting(id: m['id'], halakaName: m['halaka_name'] ?? 'حلقة الإيمان', teacherName: m['teacher_name'] ?? 'الشيخ محمد');
  Map<String, dynamic> toMap() => {'id': id, 'halaka_name': halakaName, 'teacher_name': teacherName};
  factory HalaqaSetting.fromJson(Map<String, dynamic> j) => HalaqaSetting(id: j['id'], halakaName: j['halaka_name'] ?? 'حلقة الإيمان', teacherName: j['teacher_name'] ?? 'الشيخ محمد');
  Map<String, dynamic> toJson() => toMap();
}
