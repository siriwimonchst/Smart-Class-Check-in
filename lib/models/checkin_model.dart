// =============================================================================
// models/checkin_model.dart
// โมเดลข้อมูลสำหรับ CheckinRecord และ FinishClassRecord
// เพิ่มฟิลด์: fullName, studentId, photoPath
// Backward compatible: ถ้าไม่มีใน JSON จะใช้ค่าว่างเป็นค่าเริ่มต้น
// =============================================================================

import 'dart:convert';

/// บันทึกการเช็คชื่อก่อนเรียน (Before Class)
class CheckinRecord {
  final String id;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final bool qrScanned;
  final String previousTopic;
  final String expectedTopic;
  final int mood;
  // ฟิลด์ใหม่ — ข้อมูลนักศึกษาและรูปถ่าย
  final String fullName;
  final String studentId;
  final String photoPath;

  CheckinRecord({
    required this.id,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.qrScanned,
    required this.previousTopic,
    required this.expectedTopic,
    required this.mood,
    this.fullName = '',
    this.studentId = '',
    this.photoPath = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'qrScanned': qrScanned,
        'previousTopic': previousTopic,
        'expectedTopic': expectedTopic,
        'mood': mood,
        'fullName': fullName,
        'studentId': studentId,
        'photoPath': photoPath,
      };

  factory CheckinRecord.fromMap(Map<String, dynamic> map) => CheckinRecord(
        id: map['id'] as String,
        timestamp: DateTime.parse(map['timestamp'] as String),
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        qrScanned: map['qrScanned'] as bool,
        previousTopic: map['previousTopic'] as String,
        expectedTopic: map['expectedTopic'] as String,
        mood: map['mood'] as int,
        fullName: map['fullName'] as String? ?? '',
        studentId: map['studentId'] as String? ?? '',
        photoPath: map['photoPath'] as String? ?? '',
      );

  String toJson() => jsonEncode(toMap());
  factory CheckinRecord.fromJson(String source) =>
      CheckinRecord.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

// =============================================================================

/// บันทึกหลังเรียน (After Class)
class FinishClassRecord {
  final String id;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final bool qrScanned;
  final String learnedToday;
  final String feedback;
  // ฟิลด์ใหม่ — ข้อมูลนักศึกษาและรูปถ่าย
  final String fullName;
  final String studentId;
  final String photoPath;

  FinishClassRecord({
    required this.id,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.qrScanned,
    required this.learnedToday,
    required this.feedback,
    this.fullName = '',
    this.studentId = '',
    this.photoPath = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'qrScanned': qrScanned,
        'learnedToday': learnedToday,
        'feedback': feedback,
        'fullName': fullName,
        'studentId': studentId,
        'photoPath': photoPath,
      };

  factory FinishClassRecord.fromMap(Map<String, dynamic> map) =>
      FinishClassRecord(
        id: map['id'] as String,
        timestamp: DateTime.parse(map['timestamp'] as String),
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        qrScanned: map['qrScanned'] as bool,
        learnedToday: map['learnedToday'] as String,
        feedback: map['feedback'] as String,
        fullName: map['fullName'] as String? ?? '',
        studentId: map['studentId'] as String? ?? '',
        photoPath: map['photoPath'] as String? ?? '',
      );

  String toJson() => jsonEncode(toMap());
  factory FinishClassRecord.fromJson(String source) =>
      FinishClassRecord.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
