part of '../firestore_service.dart';

extension CrecheRepository on FirestoreService {
  Stream<List<CrecheModel>> watchAllCreches() => _db
      .collection(AppConstants.colCreches)
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((s) => s.docs.map(CrecheModel.fromFirestore).toList());

  Stream<CrecheModel?> watchCrecheById(String id) => _db
      .collection(AppConstants.colCreches)
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? CrecheModel.fromFirestore(d) : null);

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

  Future<void> deactivateCreche(String id) =>
      _db.collection(AppConstants.colCreches).doc(id).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
}
