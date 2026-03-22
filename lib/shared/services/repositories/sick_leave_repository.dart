part of '../firestore_service.dart';

extension SickLeaveRepository on FirestoreService {
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

  /// All sick-leave records across every crèche, newest first.
  Stream<List<SickLeaveModel>> watchAllSickLeave() => _db
      .collection(AppConstants.colSickLeave)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(SickLeaveModel.fromFirestore).toList());

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
}
