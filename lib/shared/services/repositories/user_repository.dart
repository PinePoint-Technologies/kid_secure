part of '../firestore_service.dart';

extension UserRepository on FirestoreService {
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

  Future<void> saveFcmToken(String uid, String token) => _db
      .collection(AppConstants.colUsers)
      .doc(uid)
      .update({'fcmToken': token});

  Stream<List<UserModel>> watchTeachers() => _db
      .collection(AppConstants.colUsers)
      .where('role', isEqualTo: AppConstants.roleTeacher)
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((s) => s.docs.map(UserModel.fromFirestore).toList());

  Stream<List<UserModel>> watchAllParents() => _db
      .collection(AppConstants.colUsers)
      .where('role', isEqualTo: AppConstants.roleParent)
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((s) => s.docs.map(UserModel.fromFirestore).toList());

  Future<void> deactivateUser(String uid) =>
      _db.collection(AppConstants.colUsers).doc(uid).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
}
