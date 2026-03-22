part of '../firestore_service.dart';

extension BootstrapRepository on FirestoreService {
  Stream<bool> watchBootstrapped() => _db
      .collection('config')
      .doc('bootstrapped')
      .snapshots()
      .map((d) => d.exists);

  Future<void> markBootstrapped() =>
      _db.collection('config').doc('bootstrapped').set({
        'createdAt': FieldValue.serverTimestamp(),
      });
}
