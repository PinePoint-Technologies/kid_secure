import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/creche_model.dart';
import '../../../shared/services/places_service.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../providers/super_admin_provider.dart';

class CrecheFormScreen extends ConsumerStatefulWidget {
  final String? crecheId;
  const CrecheFormScreen({super.key, this.crecheId});

  @override
  ConsumerState<CrecheFormScreen> createState() => _CrecheFormScreenState();
}

class _CrecheFormScreenState extends ConsumerState<CrecheFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _provinceCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _regCtrl = TextEditingController();
  final _addressFocus = FocusNode();
  final _placesService = PlacesService();
  int _capacity = 30;

  double? _latitude;
  double? _longitude;
  double _geofenceRadius = 200;
  bool _fetchingLocation = false;
  bool _fetchingDetails = false;

  bool get isEditing => widget.crecheId != null;

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _addressCtrl, _cityCtrl, _provinceCtrl,
      _postalCtrl, _phoneCtrl, _emailCtrl, _regCtrl,
    ]) {
      c.dispose();
    }
    _addressFocus.dispose();
    super.dispose();
  }

  // ── Places autocomplete selection ─────────────────────────────────────────

  Future<void> _onPlaceSelected(PlacePrediction prediction) async {
    setState(() => _fetchingDetails = true);
    final details = await _placesService.getDetails(prediction.placeId);
    if (!mounted) return;
    if (details != null) {
      _addressCtrl.text = details.streetAddress ?? details.formattedAddress;
      if (details.city != null) _cityCtrl.text = details.city!;
      if (details.province != null) _provinceCtrl.text = details.province!;
      if (details.postalCode != null) _postalCtrl.text = details.postalCode!;
      setState(() {
        _latitude = details.latitude;
        _longitude = details.longitude;
        _fetchingDetails = false;
      });
    } else {
      setState(() => _fetchingDetails = false);
    }
    _addressFocus.unfocus();
  }

  // ── Device GPS ────────────────────────────────────────────────────────────

  Future<void> _fetchLocation() async {
    setState(() => _fetchingLocation = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Location permission denied. Enable it in settings.'),
            backgroundColor: AppColors.error,
          ));
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (mounted) {
        setState(() {
          _latitude = pos.latitude;
          _longitude = pos.longitude;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not get location: $e'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _fetchingLocation = false);
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final creche = CrecheModel(
      id: widget.crecheId ?? '',
      name: _nameCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
      province:
          _provinceCtrl.text.trim().isEmpty ? null : _provinceCtrl.text.trim(),
      postalCode:
          _postalCtrl.text.trim().isEmpty ? null : _postalCtrl.text.trim(),
      phoneNumber:
          _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      registrationNumber:
          _regCtrl.text.trim().isEmpty ? null : _regCtrl.text.trim(),
      capacity: _capacity,
      latitude: _latitude,
      longitude: _longitude,
      geofenceRadiusMeters: _geofenceRadius,
      createdAt: DateTime.now(),
    );

    await ref.read(crecheFormProvider.notifier).save(
          creche,
          existingId: widget.crecheId,
        );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(crecheFormProvider);

    ref.listen(crecheFormProvider, (_, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isEditing ? 'Creche updated!' : 'Creche created!'),
          backgroundColor: AppColors.success,
        ));
        context.go(AppRoutes.superAdminCreches);
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.error!),
          backgroundColor: AppColors.error,
        ));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Creche' : 'New Creche'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.superAdminCreches),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Basic info ───────────────────────────────────────────────
              _sectionHeader('Basic Information'),
              const SizedBox(height: 12),
              _field(
                controller: _nameCtrl,
                label: 'School Name',
                icon: Icons.school_rounded,
                required: true,
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 14),
              _field(
                controller: _regCtrl,
                label: 'Registration Number (optional)',
                icon: Icons.numbers_rounded,
              ).animate(delay: 50.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 24),

              // ── Location ─────────────────────────────────────────────────
              _sectionHeader('Location'),
              const SizedBox(height: 4),
              Text(
                'Search an address to auto-fill fields and capture coordinates.',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),

              // Address autocomplete
              RawAutocomplete<PlacePrediction>(
                textEditingController: _addressCtrl,
                focusNode: _addressFocus,
                displayStringForOption: (p) => p.description,
                optionsBuilder: (value) async {
                  if (value.text.length < 3) return const [];
                  return _placesService.autocomplete(value.text);
                },
                onSelected: _onPlaceSelected,
                fieldViewBuilder: (_, controller, focusNode, __) =>
                    TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Search Address',
                    prefixIcon: _fetchingDetails
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : const Icon(Icons.search_rounded),
                    suffixIcon: _addressCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _addressCtrl.clear();
                              setState(() {
                                _latitude = null;
                                _longitude = null;
                              });
                            },
                          )
                        : null,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Address is required'
                      : null,
                ),
                optionsViewBuilder: (_, onSelected, options) => Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(14),
                    color: Theme.of(context).colorScheme.surface,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shrinkWrap: true,
                        itemCount: options.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 48),
                        itemBuilder: (_, i) {
                          final opt = options.elementAt(i);
                          return ListTile(
                            leading: const Icon(
                              Icons.location_on_outlined,
                              color: AppColors.primary,
                            ),
                            title: Text(
                              opt.description,
                              style: AppTextStyles.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => onSelected(opt),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

              // Google attribution (required by ToS)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Powered by Google',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textHint),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _field(
                      controller: _cityCtrl,
                      label: 'City',
                      icon: Icons.location_city_rounded,
                    ).animate(delay: 120.ms).fadeIn(duration: 400.ms),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      controller: _provinceCtrl,
                      label: 'Province',
                      icon: Icons.map_outlined,
                    ).animate(delay: 140.ms).fadeIn(duration: 400.ms),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _field(
                controller: _postalCtrl,
                label: 'Postal Code',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.number,
              ).animate(delay: 160.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 20),

              // ── GPS ──────────────────────────────────────────────────────
              _sectionHeader('GPS Coordinates'),
              const SizedBox(height: 12),
              _GpsCard(
                latitude: _latitude,
                longitude: _longitude,
                isFetching: _fetchingLocation,
                onFetch: _fetchLocation,
                geofenceRadius: _geofenceRadius,
                onRadiusChanged: (v) => setState(() => _geofenceRadius = v),
              ).animate(delay: 180.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 24),

              // ── Contact ──────────────────────────────────────────────────
              _sectionHeader('Contact'),
              const SizedBox(height: 12),
              _field(
                controller: _phoneCtrl,
                label: 'Phone Number (optional)',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 14),
              _field(
                controller: _emailCtrl,
                label: 'Email Address (optional)',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ).animate(delay: 220.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 24),

              // ── Capacity ─────────────────────────────────────────────────
              _sectionHeader('Capacity'),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.people_rounded,
                      color: AppColors.textHint, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Slider(
                      value: _capacity.toDouble(),
                      min: 10,
                      max: 200,
                      divisions: 38,
                      label: '$_capacity kids',
                      onChanged: (v) => setState(() => _capacity = v.round()),
                    ),
                  ),
                  Text('$_capacity', style: AppTextStyles.titleMedium),
                ],
              ).animate(delay: 260.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 36),

              GradientButton(
                label: isEditing ? 'Update Creche' : 'Create Creche',
                onPressed: _save,
                isLoading: formState.isLoading,
                gradient: AppColors.superAdminGradient,
                icon: Icons.check_rounded,
              ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) => Text(
        title,
        style: AppTextStyles.title.copyWith(color: AppColors.textPrimary),
      );

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty)
                ? '$label is required'
                : null
            : null,
      );
}

// ─── GPS card ─────────────────────────────────────────────────────────────────

class _GpsCard extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final bool isFetching;
  final VoidCallback onFetch;
  final double geofenceRadius;
  final ValueChanged<double> onRadiusChanged;

  const _GpsCard({
    required this.latitude,
    required this.longitude,
    required this.isFetching,
    required this.onFetch,
    required this.geofenceRadius,
    required this.onRadiusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasFix = latitude != null && longitude != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasFix
            ? AppColors.success.withAlpha(15)
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              hasFix ? AppColors.success.withAlpha(80) : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasFix
                    ? Icons.gps_fixed_rounded
                    : Icons.gps_not_fixed_rounded,
                color: hasFix ? AppColors.success : AppColors.textHint,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: hasFix
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lat: ${latitude!.toStringAsFixed(6)}',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.textPrimary),
                          ),
                          Text(
                            'Lng: ${longitude!.toStringAsFixed(6)}',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.textPrimary),
                          ),
                        ],
                      )
                    : Text(
                        'No coordinates yet — search an address above\nor use device GPS',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textHint),
                      ),
              ),
              const SizedBox(width: 8),
              isFetching
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : TextButton.icon(
                      onPressed: onFetch,
                      icon: const Icon(Icons.my_location_rounded, size: 16),
                      label: Text(hasFix ? 'Use GPS' : 'Use GPS'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
            ],
          ),
          if (hasFix) ...[
            const SizedBox(height: 16),
            Text(
              'Geofence Radius: ${geofenceRadius.round()} m',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            Slider(
              value: geofenceRadius,
              min: 50,
              max: 1000,
              divisions: 19,
              label: '${geofenceRadius.round()} m',
              onChanged: onRadiusChanged,
            ),
          ],
        ],
      ),
    );
  }
}
