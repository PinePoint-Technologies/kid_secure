part of '../firestore_service.dart';

extension ChildRepository on FirestoreService {
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

  Stream<List<ChildModel>> watchAllChildren() => _db
      .collection(AppConstants.colChildren)
      .where('status', isEqualTo: 'active')
      .snapshots()
      .map((s) => s.docs.map(ChildModel.fromFirestore).toList());

  Stream<ChildModel?> watchChildById(String id) => _db
      .collection(AppConstants.colChildren)
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? ChildModel.fromFirestore(d) : null);

  Future<String> createChild(ChildModel child) async {
    final ref = await _db
        .collection(AppConstants.colChildren)
        .add(child.toFirestore());
    return ref.id;
  }

  Future<void> updateChild(String id, Map<String, dynamic> data) =>
      _db.collection(AppConstants.colChildren).doc(id).update(data);

  Future<void> deactivateChild(String id) =>
      _db.collection(AppConstants.colChildren).doc(id).update({
        'status': 'inactive',
        'updatedAt': FieldValue.serverTimestamp(),
      });

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

  /// Sets or clears the tracker device linked to a child.
  Future<void> assignTrackerToChild(String childId, String? trackerId) => _db
      .collection(AppConstants.colChildren)
      .doc(childId)
      .update({'trackerId': trackerId});
}
