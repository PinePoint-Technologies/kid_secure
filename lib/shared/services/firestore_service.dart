import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/child_model.dart';
import '../models/creche_model.dart';
import '../models/guardian_model.dart';
import '../models/attendance_model.dart';
import '../models/sick_leave_model.dart';
import '../../core/constants/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService(this._db);

  // ─── Users ───────────────────────────────────────────────────────────────
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection(AppConstants.colUsers).doc(uid).get();
    return doc.exists ? UserModel.fromFirestore(doc) : null;
  }

  Stream<UserModel?> watchUser(String uid) => _db
      .collection(AppConstants.colUsers)
      .doc(uid)
      .snapshots()
      .map((d) => d.exists ? UserModel.fromFirestore(d) : null);

  Future<void> createUser(UserModel user) => _db
      .collection(AppConstants.colUsers)
      .doc(user.uid)
      .set(user.toFirestore());

  Future<void> updateUser(String uid, Map<String, dynamic> data) => _db
      .collection(AppConstants.colUsers)
      .doc(uid)
      .update({...data, 'updatedAt': FieldValue.serverTimestamp()});

  // ─── Creches ──────────────────────────────────────────────────────────────
  Stream<List<CrecheModel>> watchAllCreches() => _db
      .collection(AppConstants.colCreches)
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((s) => s.docs.map(CrecheModel.fromFirestore).toList());

  Stream<List<CrecheModel>> watchCrechesByIds(List<String> ids) {
    if (ids.isEmpty) return Stream.value([]);
    return _db
        .collection(AppConstants.colCreches)
        .where(FieldPath.documentId, whereIn: ids)
        .snapshots()
        .map((s) => s.docs.map(CrecheModel.fromFirestore).toList());
  }

  Future<String> createCreche(CrecheModel creche) async {
    final ref = await _db
        .collection(AppConstants.colCreches)
        .add(creche.toFirestore());
    return ref.id;
  }

  Future<void> updateCreche(String id, Map<String, dynamic> data) => _db
      .collection(AppConstants.colCreches)
      .doc(id)
      .update({...data, 'updatedAt': FieldValue.serverTimestamp()});

  Future<void> addTeacherToCreche(String crecheId, String teacherUid) =>
      _db.collection(AppConstants.colCreches).doc(crecheId).update({
        'teacherIds': FieldValue.arrayUnion([teacherUid]),
      });

  Future<void> removeTeacherFromCreche(String crecheId, String teacherUid) =>
      _db.collection(AppConstants.colCreches).doc(crecheId).update({
        'teacherIds': FieldValue.arrayRemove([teacherUid]),
      });

  // ─── Children ────────────────────────────────────────────────────────────
  Stream<List<ChildModel>> watchChildrenForCreche(String crecheId) => _db
      .collection(AppConstants.colChildren)
      .where('crecheId', isEqualTo: crecheId)
      .where('status', isEqualTo: 'active')
      .snapshots()
      .map((s) => s.docs.map(ChildModel.fromFirestore).toList());

  Stream<List<ChildModel>> watchChildrenForParent(String parentUid) => _db
      .collection(AppConstants.colChildren)
      .where('parentIds', arrayContains: parentUid)
      .snapshots()
      .map((s) => s.docs.map(ChildModel.fromFirestore).toList());

  Future<String> createChild(ChildModel child) async {
    final ref = await _db
        .collection(AppConstants.colChildren)
        .add(child.toFirestore());
    return ref.id;
  }

  Future<void> updateChild(String id, Map<String, dynamic> data) => _db
      .collection(AppConstants.colChildren)
      .doc(id)
      .update(data);

  Stream<ChildModel?> watchChildById(String id) => _db
      .collection(AppConstants.colChildren)
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? ChildModel.fromFirestore(d) : null);

  /// Links a parent account to a child.
  /// Updates both the child's [parentIds] and the parent's [crecheIds].
  Future<void> linkParentToChild({
    required String childId,
    required String parentUid,
    required String crecheId,
  }) =>
      Future.wait([
        _db.collection(AppConstants.colChildren).doc(childId).update({
          'parentIds': FieldValue.arrayUnion([parentUid]),
        }),
        _db.collection(AppConstants.colUsers).doc(parentUid).update({
          'crecheIds': FieldValue.arrayUnion([crecheId]),
        }),
      ]);

  /// Removes a parent link from a child.
  Future<void> unlinkParentFromChild({
    required String childId,
    required String parentUid,
  }) =>
      _db.collection(AppConstants.colChildren).doc(childId).update({
        'parentIds': FieldValue.arrayRemove([parentUid]),
      });

  // ─── Guardians ───────────────────────────────────────────────────────────
  Stream<List<GuardianModel>> watchGuardiansForChild(String childId) => _db
      .collection(AppConstants.colGuardians)
      .where('childId', isEqualTo: childId)
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((s) => s.docs.map(GuardianModel.fromFirestore).toList());

  Future<String> createGuardian(GuardianModel guardian) async {
    final ref = await _db
        .collection(AppConstants.colGuardians)
        .add(guardian.toFirestore());
    // Update child's guardianIds
    await _db
        .collection(AppConstants.colChildren)
        .doc(guardian.childId)
        .update({
      'guardianIds': FieldValue.arrayUnion([ref.id]),
    });
    return ref.id;
  }

  Future<void> updateGuardian(String id, Map<String, dynamic> data) => _db
      .collection(AppConstants.colGuardians)
      .doc(id)
      .update(data);

  Future<GuardianModel?> getGuardianByQrCode(String qrCode) async {
    final snap = await _db
        .collection(AppConstants.colGuardians)
        .where('qrCode', isEqualTo: qrCode)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    return snap.docs.isEmpty
        ? null
        : GuardianModel.fromFirestore(snap.docs.first);
  }

  Future<void> deactivateGuardian(String guardianId, String childId) =>
      Future.wait([
        _db
            .collection(AppConstants.colGuardians)
            .doc(guardianId)
            .update({'isActive': false}),
        _db.collection(AppConstants.colChildren).doc(childId).update({
          'guardianIds': FieldValue.arrayRemove([guardianId]),
        }),
      ]);

  // ─── Attendance ──────────────────────────────────────────────────────────
  Stream<AttendanceRecord?> watchTodayAttendance(
      String childId, DateTime date) {
    return _db
        .collection(AppConstants.colAttendance)
        .where('childId', isEqualTo: childId)
        .where('dateStr', isEqualTo: _dateStr(date))
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
        .where('dateStr', isEqualTo: _dateStr(date))
        .snapshots()
        .map((s) => s.docs.map(AttendanceRecord.fromFirestore).toList());
  }

  static String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';


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
      final dateStr = _dateStr(day);
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

  // ─── Sick Leave ──────────────────────────────────────────────────────────
  Stream<List<SickLeaveModel>> watchSickLeaveForParent(String parentUid) => _db
      .collection(AppConstants.colSickLeave)
      .where('parentUid', isEqualTo: parentUid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(SickLeaveModel.fromFirestore).toList());

  Stream<List<SickLeaveModel>> watchSickLeaveForCreche(String crecheId) => _db
      .collection(AppConstants.colSickLeave)
      .where('crecheId', isEqualTo: crecheId)
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((s) {
        final leaves = s.docs.map(SickLeaveModel.fromFirestore).toList();
        leaves.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return leaves;
      });

  /// All non-rejected sick leave for a crèche, newest first.
  Stream<List<SickLeaveModel>> watchAllSickLeaveForCreche(String crecheId) =>
      _db
          .collection(AppConstants.colSickLeave)
          .where('crecheId', isEqualTo: crecheId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((s) => s.docs
              .map(SickLeaveModel.fromFirestore)
              .where((l) => l.status != SickLeaveStatus.rejected)
              .toList());

  Future<String> createSickLeave(SickLeaveModel sickLeave) async {
    final ref = await _db
        .collection(AppConstants.colSickLeave)
        .add(sickLeave.toFirestore());
    return ref.id;
  }

  Future<void> updateSickLeave(String id, Map<String, dynamic> data) => _db
      .collection(AppConstants.colSickLeave)
      .doc(id)
      .update({...data, 'updatedAt': FieldValue.serverTimestamp()});

  // ─── Bootstrap ───────────────────────────────────────────────────────────
  Stream<bool> watchBootstrapped() => _db
      .collection('config')
      .doc('bootstrapped')
      .snapshots()
      .map((d) => d.exists);

  Future<void> markBootstrapped() =>
      _db.collection('config').doc('bootstrapped').set({
        'createdAt': FieldValue.serverTimestamp(),
      });

  // ─── Teachers list ────────────────────────────────────────────────────────
  Stream<List<UserModel>> watchTeachers() => _db
      .collection(AppConstants.colUsers)
      .where('role', isEqualTo: AppConstants.roleTeacher)
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((s) => s.docs.map(UserModel.fromFirestore).toList());

  // ─── Super-admin: cross-creche queries ───────────────────────────────────

  /// All active children across every crèche.
  Stream<List<ChildModel>> watchAllChildren() => _db
      .collection(AppConstants.colChildren)
      .where('status', isEqualTo: 'active')
      .snapshots()
      .map((s) => s.docs.map(ChildModel.fromFirestore).toList());

  /// All active parent accounts.
  Stream<List<UserModel>> watchAllParents() => _db
      .collection(AppConstants.colUsers)
      .where('role', isEqualTo: AppConstants.roleParent)
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((s) => s.docs.map(UserModel.fromFirestore).toList());

  /// All active guardians across every crèche.
  Stream<List<GuardianModel>> watchAllGuardians() => _db
      .collection(AppConstants.colGuardians)
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((s) => s.docs.map(GuardianModel.fromFirestore).toList());

  /// All sick-leave records across every crèche, newest first.
  Stream<List<SickLeaveModel>> watchAllSickLeave() => _db
      .collection(AppConstants.colSickLeave)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(SickLeaveModel.fromFirestore).toList());

  // ─── Super-admin: deactivate / delete helpers ─────────────────────────────

  /// Soft-deletes a crèche by marking it inactive.
  Future<void> deactivateCreche(String id) =>
      _db.collection(AppConstants.colCreches).doc(id).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  /// Soft-deletes a child by setting status to 'inactive'.
  Future<void> deactivateChild(String id) =>
      _db.collection(AppConstants.colChildren).doc(id).update({
        'status': 'inactive',
        'updatedAt': FieldValue.serverTimestamp(),
      });

  /// Deactivates any user account (teacher, parent, etc.).
  Future<void> deactivateUser(String uid) =>
      _db.collection(AppConstants.colUsers).doc(uid).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
}
