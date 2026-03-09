import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatter.dart';
import '../../../core/utils/geofence_utils.dart';
import '../../../shared/models/attendance_model.dart';
import '../../../shared/models/child_model.dart';
import '../../../shared/models/creche_model.dart';
import '../../../shared/models/tracker_location_model.dart';
import '../../../shared/widgets/app_card.dart';
import '../providers/parent_provider.dart';

class GpsTrackingScreen extends ConsumerStatefulWidget {
  const GpsTrackingScreen({super.key});

  @override
  ConsumerState<GpsTrackingScreen> createState() => _GpsTrackingScreenState();
}

class _GpsTrackingScreenState extends ConsumerState<GpsTrackingScreen> {
  GoogleMapController? _mapController;
  ChildModel? _selectedChild;

  static const _defaultLocation = LatLng(-26.2041, 28.0473); // Johannesburg

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _moveCameraTo(LatLng target) {
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, 16));
  }

  @override
  Widget build(BuildContext context) {
    final childrenAsync = ref.watch(parentChildrenProvider);

    final crecheAsync = _selectedChild != null
        ? ref.watch(crecheProvider(_selectedChild!.crecheId))
        : const AsyncValue<CrecheModel?>.data(null);

    final attendanceAsync = _selectedChild != null
        ? ref.watch(childAttendanceProvider(_selectedChild!.id))
        : const AsyncValue<AttendanceRecord?>.data(null);

    // Live tracker location (null if no tracker assigned)
    final trackerId = _selectedChild?.trackerId;
    final trackerAsync = trackerId != null
        ? ref.watch(trackerLocationProvider(trackerId))
        : const AsyncValue<TrackerLocation?>.data(null);

    final creche = crecheAsync.valueOrNull;
    final attendance = attendanceAsync.valueOrNull;
    final trackerLocation = trackerAsync.valueOrNull;

    // ── Determine last known child position (from attendance) ─────────────────
    double? childLat;
    double? childLon;
    if (attendance != null) {
      if (attendance.signOutLatitude != null) {
        childLat = attendance.signOutLatitude;
        childLon = attendance.signOutLongitude;
      } else if (attendance.signInLatitude != null) {
        childLat = attendance.signInLatitude;
        childLon = attendance.signInLongitude;
      }
    }

    // ── Geofence status (prefer live tracker; fall back to attendance) ─────────
    final double? geofenceLat = trackerLocation?.lat ?? childLat;
    final double? geofenceLon = trackerLocation?.lon ?? childLon;
    bool? withinGeofence;
    if (geofenceLat != null &&
        geofenceLon != null &&
        creche?.latitude != null &&
        creche?.longitude != null) {
      withinGeofence = GeofenceUtils.isWithinGeofence(
        lat: geofenceLat,
        lon: geofenceLon,
        crecheLat: creche!.latitude!,
        crecheLon: creche.longitude!,
        radiusMeters: creche.geofenceRadiusMeters,
      );
    }

    // ── Is the tracker data recent (within 5 minutes)? ────────────────────────
    final bool isTrackerLive = trackerLocation != null &&
        DateTime.now().difference(trackerLocation.recordedAt).inMinutes < 5;

    // ── Map elements ──────────────────────────────────────────────────────────
    final markers = <Marker>{};
    final circles = <Circle>{};

    if (creche?.latitude != null) {
      markers.add(Marker(
        markerId: const MarkerId('creche'),
        position: LatLng(creche!.latitude!, creche.longitude!),
        infoWindow: InfoWindow(title: creche.name, snippet: 'Crèche location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
      circles.add(Circle(
        circleId: const CircleId('geofence'),
        center: LatLng(creche.latitude!, creche.longitude!),
        radius: creche.geofenceRadiusMeters,
        fillColor: Colors.blue.withAlpha(40),
        strokeColor: Colors.blue,
        strokeWidth: 2,
      ));
    }

    // Last known position from attendance (green marker)
    if (childLat != null) {
      markers.add(Marker(
        markerId: const MarkerId('child'),
        position: LatLng(childLat, childLon!),
        infoWindow: InfoWindow(
          title: _selectedChild?.fullName ?? 'Child',
          snippet: attendance?.status == AttendanceStatus.signedIn
              ? 'Signed in at ${attendance?.signInTime != null ? Formatter.time(attendance!.signInTime!) : ''}'
              : 'Last seen at ${attendance?.signOutTime != null ? Formatter.time(attendance!.signOutTime!) : ''}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    }

    // Live tracker position (blue marker)
    if (trackerLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId('tracker'),
        position: LatLng(trackerLocation.lat, trackerLocation.lon),
        infoWindow: InfoWindow(
          title: 'Tracker — ${_selectedChild?.firstName ?? 'Child'}',
          snippet: isTrackerLive
              ? 'Live · ${Formatter.time(trackerLocation.recordedAt)}'
              : 'Last seen at ${Formatter.time(trackerLocation.recordedAt)}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));
    }

    return Column(
      children: [
        // ── Child selector ────────────────────────────────────────────────────
        childrenAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (children) => children.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.child_care_rounded),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    ),
                    child: DropdownButton<ChildModel>(
                      value: _selectedChild,
                      hint: const Text('Select child to track'),
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      items: children
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c.fullName),
                              ))
                          .toList(),
                      onChanged: (child) {
                        setState(() => _selectedChild = child);
                        if (child != null) {
                          final c = crecheAsync.valueOrNull;
                          if (c?.latitude != null) {
                            _moveCameraTo(LatLng(c!.latitude!, c.longitude!));
                          }
                        }
                      },
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                ),
        ),

        // ── Geofence status card ──────────────────────────────────────────────
        if (_selectedChild != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: _GeofenceStatusCard(
              childName: _selectedChild!.firstName,
              attendance: attendance,
              withinGeofence: withinGeofence,
              creche: creche,
              isTrackerLive: isTrackerLive,
              trackerLocation: trackerLocation,
            ).animate().fadeIn(duration: 400.ms),
          ),

        // ── Google Map ────────────────────────────────────────────────────────
        Expanded(
          child: GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _defaultLocation,
              zoom: 14,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              final c = creche;
              if (c?.latitude != null) {
                _moveCameraTo(LatLng(c!.latitude!, c.longitude!));
              }
            },
            markers: markers,
            circles: circles,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
          ),
        ),

        // ── Last activity card ────────────────────────────────────────────────
        if (attendance != null && _selectedChild != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    attendance.status == AttendanceStatus.signedIn
                        ? Icons.login_rounded
                        : Icons.logout_rounded,
                    color: attendance.status == AttendanceStatus.signedIn
                        ? AppColors.success
                        : AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attendance.status == AttendanceStatus.signedIn
                              ? 'Signed in by ${attendance.signInByName ?? 'Unknown'}'
                              : 'Signed out by ${attendance.signOutByName ?? 'Unknown'}',
                          style: AppTextStyles.bodySmall,
                        ),
                        if (attendance.signInTime != null)
                          Text(
                            Formatter.time(attendance.status ==
                                        AttendanceStatus.signedOut &&
                                    attendance.signOutTime != null
                                ? attendance.signOutTime!
                                : attendance.signInTime!),
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.textHint),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
          ),
      ],
    );
  }
}

// ── Geofence Status Card ───────────────────────────────────────────────────────

class _GeofenceStatusCard extends StatelessWidget {
  final String childName;
  final AttendanceRecord? attendance;
  final bool? withinGeofence;
  final CrecheModel? creche;
  final bool isTrackerLive;
  final TrackerLocation? trackerLocation;

  const _GeofenceStatusCard({
    required this.childName,
    required this.attendance,
    required this.withinGeofence,
    required this.creche,
    required this.isTrackerLive,
    required this.trackerLocation,
  });

  @override
  Widget build(BuildContext context) {
    final isSignedIn = attendance?.status == AttendanceStatus.signedIn;

    Color cardColor;
    IconData icon;
    String title;
    String subtitle;

    if (trackerLocation != null) {
      // Status driven by live tracker
      if (withinGeofence == true) {
        cardColor = Colors.green.shade50;
        icon = Icons.home_work_rounded;
        title = 'At Crèche';
        subtitle = '$childName is within the crèche boundary.';
      } else if (withinGeofence == false) {
        cardColor = Colors.orange.shade50;
        icon = Icons.warning_amber_rounded;
        title = 'Outside Crèche';
        subtitle = '$childName\'s tracker is outside the crèche boundary.';
      } else {
        cardColor = Colors.amber.shade50;
        icon = Icons.gps_not_fixed_rounded;
        title = 'Tracker Active';
        subtitle = 'Crèche location not set — cannot determine geofence status.';
      }
    } else if (attendance == null) {
      cardColor = Colors.grey.shade100;
      icon = Icons.help_outline_rounded;
      title = 'No data for today';
      subtitle = '$childName has not been signed in yet today.';
    } else if (!isSignedIn && attendance!.status != AttendanceStatus.signedOut) {
      cardColor = Colors.grey.shade100;
      icon = Icons.help_outline_rounded;
      title = 'No location data';
      subtitle = 'Location is only recorded at sign-in and sign-out.';
    } else if (withinGeofence == null) {
      cardColor = Colors.amber.shade50;
      icon = Icons.location_off_rounded;
      title = isSignedIn ? 'Signed In' : 'Signed Out';
      subtitle = 'Location not available for this event.';
    } else if (withinGeofence == true) {
      cardColor = Colors.green.shade50;
      icon = Icons.home_work_rounded;
      title = isSignedIn ? 'At Crèche' : 'Left from Crèche';
      subtitle = isSignedIn
          ? '$childName is within the crèche boundary.'
          : '$childName was within the crèche boundary when signed out.';
    } else {
      cardColor = Colors.orange.shade50;
      icon = Icons.warning_amber_rounded;
      title = isSignedIn ? 'Outside Crèche' : 'Left from Outside';
      subtitle = isSignedIn
          ? '$childName was signed in outside the crèche boundary.'
          : '$childName was signed out outside the crèche boundary.';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: withinGeofence == true
              ? Colors.green.shade200
              : withinGeofence == false
                  ? Colors.orange.shade200
                  : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(icon,
              color: withinGeofence == true
                  ? AppColors.success
                  : withinGeofence == false
                      ? Colors.orange
                      : AppColors.textHint,
              size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: AppTextStyles.titleMedium),
                    if (isTrackerLive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(subtitle,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
