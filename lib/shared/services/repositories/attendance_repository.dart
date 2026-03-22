part of '../firestore_service.dart';

extension AttendanceRepository on FirestoreService {
  Stream<AttendanceRecord?> watchTodayAttendance(
      String childId, DateTime date) {
    return _db
        .collection(AppConstants.colAttendance)
        .where('childId', isEqualTo: childId)
        .where('dateStr', isEqualTo: FirestoreService._dateStr(date))
        .limit(1)
        .snapshots()
        .map((s) => s.docs.isEmpty
            ? null
            : AttendanceRecord.fromFirestore(s.docs.first));
  }

  Stream<List<AttendanceRecord>> watchAttendanceForCreche(
      String crecheId, DateTime date) {
    return _db
        .collection(AppConstants.colAttendance)
        .where('crecheId', isEqualTo: crecheId)
        .where('dateStr', isEqualTo: FirestoreService._dateStr(date))
        .snapshots()
        .map((s) => s.docs.map(AttendanceRecord.fromFirestore).toList());
  }

  Future<String> createAttendanceRecord(AttendanceRecord record) async {
    final ref = await _db
        .collection(AppConstants.colAttendance)
        .add(record.toFirestore());
    return ref.id;
  }

  Future<void> updateAttendanceRecord(String id, Map<String, dynamic> data) =>
      _db.collection(AppConstants.colAttendance).doc(id).update(data);

  /// Creates a `sickLeave` attendance record for every day in [leave]'s range
  /// that does not already have a record for that child.
  Future<void> createSickLeaveAttendanceRecords(SickLeaveModel leave) async {
    final days = leave.daysCount;
    for (int i = 0; i < days; i++) {
      final day = DateTime(
        leave.startDate.year,
        leave.startDate.month,
        leave.startDate.day + i,
      );
      final dateStr = FirestoreService._dateStr(day);
      final existing = await _db
          .collection(AppConstants.colAttendance)
          .where('childId', isEqualTo: leave.childId)
          .where('dateStr', isEqualTo: dateStr)
          .limit(1)
          .get();
      if (existing.docs.isEmpty) {
        await createAttendanceRecord(AttendanceRecord(
          id: '',
          childId: leave.childId,
          crecheId: leave.crecheId,
          date: day,
          status: AttendanceStatus.sickLeave,
          notes: leave.reason,
        ));
      }
    }
  }
}
