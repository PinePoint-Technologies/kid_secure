import 'dart:math';

abstract final class GeofenceUtils {
  static const double _earthRadiusMeters = 6371000.0;

  /// Returns the distance in metres between two GPS coordinates using the
  /// Haversine formula.
  static double distanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return _earthRadiusMeters * c;
  }

  /// Returns `true` when [lat]/[lon] is within [radiusMeters] of the crèche
  /// centre at [crecheLat]/[crecheLon].
  static bool isWithinGeofence({
    required double lat,
    required double lon,
    required double crecheLat,
    required double crecheLon,
    required double radiusMeters,
  }) =>
      distanceMeters(lat, lon, crecheLat, crecheLon) <= radiusMeters;

  static double _toRad(double deg) => deg * pi / 180;
}
