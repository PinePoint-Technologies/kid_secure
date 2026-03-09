import 'package:cloud_firestore/cloud_firestore.dart';

class TrackerLocation {
  final String deviceId;
  final double lat;
  final double lon;
  final DateTime recordedAt;
  final double? speed; // m/s, optional
  final int? batteryLevel; // percent, optional

  const TrackerLocation({
    required this.deviceId,
    required this.lat,
    required this.lon,
    required this.recordedAt,
    this.speed,
    this.batteryLevel,
  });

  factory TrackerLocation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TrackerLocation(
      deviceId: doc.id,
      lat: (data['lat'] as num).toDouble(),
      lon: (data['lon'] as num).toDouble(),
      recordedAt:
          (data['recordedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      speed: (data['speed'] as num?)?.toDouble(),
      batteryLevel: data['batteryLevel'] as int?,
    );
  }
}
