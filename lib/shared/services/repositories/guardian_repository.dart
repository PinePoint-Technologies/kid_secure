part of '../firestore_service.dart';

extension GuardianRepository on FirestoreService {
  Stream<List<GuardianModel>> watchGuardiansForChild(String childId) => _db
      .collection(AppConstants.colGuardians)
      .where('childId', isEqualTo: childId)
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((s) => s.docs.map(GuardianModel.fromFirestore).toList());

  Stream<List<GuardianModel>> watchAllGuardians() => _db
      .collection(AppConstants.colGuardians)
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((s) => s.docs.map(GuardianModel.fromFirestore).toList());

  Future<String> createGuardian(GuardianModel guardian) async {
    final ref = await _db
        .collection(AppConstants.colGuardians)
        .add(guardian.toFirestore());
    await _db.collection(AppConstants.colChildren).doc(guardian.childId).update({
      'guardianIds': FieldValue.arrayUnion([ref.id]),
    });
    return ref.id;
  }

  Future<void> updateGuardian(String id, Map<String, dynamic> data) =>
      _db.collection(AppConstants.colGuardians).doc(id).update(data);

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
}
