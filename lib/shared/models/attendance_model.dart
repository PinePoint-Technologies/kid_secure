import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';

enum AttendanceStatus {
  signedIn,
  signedOut,
  absent,
  sickLeave;

  static AttendanceStatus fromString(String v) => switch (v) {
        AppConstants.attendanceSignedIn => AttendanceStatus.signedIn,
        AppConstants.attendanceSignedOut => AttendanceStatus.signedOut,
        AppConstants.attendanceSickLeave => AttendanceStatus.sickLeave,
        _ => AttendanceStatus.absent,
      };

  String get value => switch (this) {
        AttendanceStatus.signedIn => AppConstants.attendanceSignedIn,
        AttendanceStatus.signedOut => AppConstants.attendanceSignedOut,
        AttendanceStatus.absent => AppConstants.attendanceAbsent,
        AttendanceStatus.sickLeave => AppConstants.attendanceSickLeave,
      };

  String get displayName => switch (this) {
        AttendanceStatus.signedIn => 'Signed In',
        AttendanceStatus.signedOut => 'Signed Out',
        AttendanceStatus.absent => 'Absent',
        AttendanceStatus.sickLeave => 'Sick Leave',
      };
}

class AttendanceRecord {
  final String id;
  final String childId;
  final String crecheId;
  final DateTime date;
  final AttendanceStatus status;
  // Sign-in
  final DateTime? signInTime;
  final String? signInByUid; // parent or guardian uid
  final String? signInByName;
  final String? signInMethod; // 'qr', 'pin', 'manual'
  // Sign-out
  final DateTime? signOutTime;
  final String? signOutByUid;
  final String? signOutByName;
  final String? signOutMethod;
  // Location at sign in/out
  final double? signInLatitude;
  final double? signInLongitude;
  final double? signOutLatitude;
  final double? signOutLongitude;
  // Notes
  final String? notes;
  final String? teacherNotes;

  const AttendanceRecord({
    required this.id,
    required this.childId,
    required this.crecheId,
    required this.date,
    required this.status,
    this.signInTime,
    this.signInByUid,
    this.signInByName,
    this.signInMethod,
    this.signOutTime,
    this.signOutByUid,
    this.signOutByName,
    this.signOutMethod,
    this.signInLatitude,
    this.signInLongitude,
    this.signOutLatitude,
    this.signOutLongitude,
    this.notes,
    this.teacherNotes,
  });

  Duration? get timeAtCreche =>
      (signInTime != null && signOutTime != null)
          ? signOutTime!.difference(signInTime!)
          : null;

  factory AttendanceRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AttendanceRecord(
      id: doc.id,
      childId: data['childId'] as String? ?? '',
      crecheId: data['crecheId'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: AttendanceStatus.fromString(data['status'] as String? ?? ''),
      signInTime: (data['signInTime'] as Timestamp?)?.toDate(),
      signInByUid: data['signInByUid'] as String?,
      signInByName: data['signInByName'] as String?,
      signInMethod: data['signInMethod'] as String?,
      signOutTime: (data['signOutTime'] as Timestamp?)?.toDate(),
      signOutByUid: data['signOutByUid'] as String?,
      signOutByName: data['signOutByName'] as String?,
      signOutMethod: data['signOutMethod'] as String?,
      signInLatitude: (data['signInLatitude'] as num?)?.toDouble(),
      signInLongitude: (data['signInLongitude'] as num?)?.toDouble(),
      signOutLatitude: (data['signOutLatitude'] as num?)?.toDouble(),
      signOutLongitude: (data['signOutLongitude'] as num?)?.toDouble(),
      notes: data['notes'] as String?,
      teacherNotes: data['teacherNotes'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'childId': childId,
        'crecheId': crecheId,
        'date': Timestamp.fromDate(date),
        'dateStr':
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'status': status.value,
        'signInTime':
            signInTime != null ? Timestamp.fromDate(signInTime!) : null,
        'signInByUid': signInByUid,
        'signInByName': signInByName,
        'signInMethod': signInMethod,
        'signOutTime':
            signOutTime != null ? Timestamp.fromDate(signOutTime!) : null,
        'signOutByUid': signOutByUid,
        'signOutByName': signOutByName,
        'signOutMethod': signOutMethod,
        'signInLatitude': signInLatitude,
        'signInLongitude': signInLongitude,
        'signOutLatitude': signOutLatitude,
        'signOutLongitude': signOutLongitude,
        'notes': notes,
        'teacherNotes': teacherNotes,
      };

  AttendanceRecord copyWith({
    AttendanceStatus? status,
    DateTime? signInTime,
    String? signInByUid,
    String? signInByName,
    String? signInMethod,
    DateTime? signOutTime,
    String? signOutByUid,
    String? signOutByName,
    String? signOutMethod,
    double? signInLatitude,
    double? signInLongitude,
    double? signOutLatitude,
    double? signOutLongitude,
    String? notes,
    String? teacherNotes,
  }) =>
      AttendanceRecord(
        id: id,
        childId: childId,
        crecheId: crecheId,
        date: date,
        status: status ?? this.status,
        signInTime: signInTime ?? this.signInTime,
        signInByUid: signInByUid ?? this.signInByUid,
        signInByName: signInByName ?? this.signInByName,
        signInMethod: signInMethod ?? this.signInMethod,
        signOutTime: signOutTime ?? this.signOutTime,
        signOutByUid: signOutByUid ?? this.signOutByUid,
        signOutByName: signOutByName ?? this.signOutByName,
        signOutMethod: signOutMethod ?? this.signOutMethod,
        signInLatitude: signInLatitude ?? this.signInLatitude,
        signInLongitude: signInLongitude ?? this.signInLongitude,
        signOutLatitude: signOutLatitude ?? this.signOutLatitude,
        signOutLongitude: signOutLongitude ?? this.signOutLongitude,
        notes: notes ?? this.notes,
        teacherNotes: teacherNotes ?? this.teacherNotes,
      );
}
