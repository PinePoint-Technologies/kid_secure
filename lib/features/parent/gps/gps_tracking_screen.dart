import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatter.dart';
import '../../../shared/models/child_model.dart';
import '../../../shared/widgets/app_card.dart';
import '../providers/parent_provider.dart';

class GpsTrackingScreen extends ConsumerStatefulWidget {
  const GpsTrackingScreen({super.key});

  @override
  ConsumerState<GpsTrackingScreen> createState() => _GpsTrackingScreenState();
}

class _GpsTrackingScreenState extends ConsumerState<GpsTrackingScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionSubscription;
  bool _isTracking = false;
  bool _permissionGranted = false;
  ChildModel? _selectedChild;

  static const _defaultLocation = LatLng(-26.2041, 28.0473); // Johannesburg

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    setState(() {
      _permissionGranted = permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    });
    if (_permissionGranted) {
      await _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    setState(() => _currentPosition = pos);
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(LatLng(pos.latitude, pos.longitude)),
    );
  }

  void _startTracking() {
    setState(() => _isTracking = true);
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((pos) {
      setState(() => _currentPosition = pos);
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(LatLng(pos.latitude, pos.longitude)),
      );
    });
  }

  void _stopTracking() {
    _positionSubscription?.cancel();
    setState(() => _isTracking = false);
  }

  @override
  Widget build(BuildContext context) {
    final childrenAsync = ref.watch(parentChildrenProvider);

    final markers = _currentPosition != null
        ? <Marker>{
            Marker(
              markerId: const MarkerId('current'),
              position: LatLng(
                  _currentPosition!.latitude, _currentPosition!.longitude),
              infoWindow: InfoWindow(
                title: _selectedChild?.fullName ?? 'Current Location',
                snippet: Formatter.relativeTime(DateTime.now()),
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure),
            ),
          }
        : <Marker>{};

    return Column(
      children: [
        // Child selector
        childrenAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (children) => children.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: DropdownButtonFormField<ChildModel>(
                    initialValue: _selectedChild,
                    hint: const Text('Select child to track'),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.child_care_rounded),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    items: children
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.fullName),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedChild = v),
                  ).animate().fadeIn(duration: 400.ms),

                ),
        ),
        // Map
        Expanded(
          child: _permissionGranted
              ? GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: _defaultLocation,
                    zoom: 14,
                  ),
                  onMapCreated: (c) => _mapController = c,
                  markers: markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapType: MapType.normal,
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_off_rounded,
                            size: 80, color: AppColors.textHint),
                        const SizedBox(height: 16),
                        Text('Location Permission Required',
                            style: AppTextStyles.headline3,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        Text(
                          'KidSecure needs location access for GPS tracking.',
                          style: AppTextStyles.body,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _checkPermission,
                          icon: const Icon(Icons.my_location_rounded),
                          label: const Text('Grant Permission'),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        // Controls
        if (_permissionGranted)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_currentPosition != null)
                  AppCard(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Lat: ${_currentPosition!.latitude.toStringAsFixed(5)}, '
                          'Lon: ${_currentPosition!.longitude.toStringAsFixed(5)}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _getCurrentLocation,
                        icon: const Icon(Icons.my_location_rounded),
                        label: const Text('Update Location'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            _isTracking ? _stopTracking : _startTracking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isTracking
                              ? AppColors.error
                              : AppColors.primary,
                        ),
                        icon: Icon(_isTracking
                            ? Icons.stop_rounded
                            : Icons.play_arrow_rounded),
                        label: Text(
                            _isTracking ? 'Stop Tracking' : 'Live Track'),
                      ),
                    ),
                  ],
                ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
                if (_isTracking)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('Live tracking active',
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.success)),
                      ],
                    ).animate(onPlay: (c) => c.repeat())
                        .fadeIn(duration: 600.ms)
                        .then()
                        .fadeOut(duration: 600.ms),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
