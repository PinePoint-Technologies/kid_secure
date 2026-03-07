import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/creche_model.dart';
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
  int _capacity = 30;

  bool get isEditing => widget.crecheId != null;

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _addressCtrl, _cityCtrl, _provinceCtrl,
      _postalCtrl, _phoneCtrl, _emailCtrl, _regCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

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
      createdAt: DateTime.now(),
    );

    await ref.read(crecheFormProvider.notifier).save(
          creche,
          existingId: widget.crecheId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(crecheFormProvider);

    ref.listen(crecheFormProvider, (_, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(isEditing ? 'Creche updated!' : 'Creche created!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go(AppRoutes.superAdminCreches);
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
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
              _sectionHeader('Location'),
              const SizedBox(height: 12),
              _field(
                controller: _addressCtrl,
                label: 'Street Address',
                icon: Icons.location_on_outlined,
                required: true,
              ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
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
              const SizedBox(height: 24),
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
                      onChanged: (v) =>
                          setState(() => _capacity = v.round()),
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
            ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null
            : null,
      );
}
