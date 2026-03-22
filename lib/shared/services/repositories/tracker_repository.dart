part of '../firestore_service.dart';

extension TrackerRepository on FirestoreService {
  /// Streams the latest location snapshot for [deviceId].
  Stream<TrackerLocation?> watchLatestTrackerLocation(String deviceId) => _db
      .collection(AppConstants.colTrackers)
      .doc(deviceId)
      .snapshots()
      .map((d) => d.exists ? TrackerLocation.fromFirestore(d) : null);
}
