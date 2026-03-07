import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:uuid/uuid.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/guardian_model.dart';
import '../../../shared/utils/pin_hasher.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/parent_provider.dart';

class AddGuardianScreen extends ConsumerStatefulWidget {
  const AddGuardianScreen({super.key});

  @override
  ConsumerState<AddGuardianScreen> createState() => _AddGuardianScreenState();
}

class _AddGuardianScreenState extends ConsumerState<AddGuardianScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  GuardianRelationship _relationship = GuardianRelationship.other;
  bool _canSignIn = true;
  bool _canSignOut = true;
  String? _selectedChildId;

  @override
  void dispose() {
    for (final c in [
      _firstCtrl, _lastCtrl, _phoneCtrl, _emailCtrl, _idCtrl, _pinCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedChildId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a child.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    final user = ref.read(currentUserProvider).valueOrNull;
    final children = ref.read(parentChildrenProvider).valueOrNull ?? [];
    final child = children.firstWhere((c) => c.id == _selectedChildId!);

    final pin = _pinCtrl.text.trim();
    final guardian = GuardianModel(
      id: '',
      parentUid: user?.uid ?? '',
      childId: _selectedChildId!,
      crecheId: child.crecheId,
      firstName: _firstCtrl.text.trim(),
      lastName: _lastCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      idNumber: _idCtrl.text.trim().isEmpty ? null : _idCtrl.text.trim(),
      relationship: _relationship,
      pin: pin.isNotEmpty ? PinHasher.hash(pin) : null,
      qrCode: const Uuid().v4(),
      canSignIn: _canSignIn,
      canSignOut: _canSignOut,
      createdAt: DateTime.now(),
    );
    await ref.read(guardianFormProvider.notifier).addGuardian(guardian);
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(guardianFormProvider);
    final childrenAsync = ref.watch(parentChildrenProvider);

    ref.listen(guardianFormProvider, (_, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Guardian added successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go(AppRoutes.parentGuardians);
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
        title: const Text('Add Guardian'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.parentGuardians),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Select child
              Text('For which child?', style: AppTextStyles.title)
                  .animate()
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: 10),
              childrenAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const SizedBox(),
                data: (children) => DropdownButtonFormField<String>(
                  initialValue: _selectedChildId,
                  hint: const Text('Select child'),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.child_care_rounded),
                  ),
                  items: children
                      .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.fullName),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedChildId = v),
                  validator: (v) => v == null ? 'Select a child' : null,
                ),
              ).animate(delay: 50.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 24),
              Text('Guardian Details', style: AppTextStyles.title)
                  .animate(delay: 100.ms)
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Required'
                          : null,
                    ).animate(delay: 120.ms).fadeIn(duration: 400.ms),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lastCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Required'
                          : null,
                    ).animate(delay: 140.ms).fadeIn(duration: 400.ms),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Phone is required'
                    : null,
              ).animate(delay: 160.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email (optional)',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ).animate(delay: 180.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 14),
              TextFormField(
                controller: _idCtrl,
                decoration: const InputDecoration(
                  labelText: 'ID Number (optional)',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 20),
              Text('Guardian PIN', style: AppTextStyles.title)
                  .animate(delay: 210.ms)
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: 4),
              Text(
                'The guardian will use this PIN to sign a child in or out.',
                style: AppTextStyles.bodySmall,
              ).animate(delay: 215.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 12),
              FormField<String>(
                validator: (_) {
                  final v = _pinCtrl.text.trim();
                  if (v.isEmpty) return 'PIN is required';
                  if (v.length < 4) return 'PIN must be at least 4 digits';
                  return null;
                },
                builder: (field) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Pinput(
                      controller: _pinCtrl,
                      length: 6,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => field.didChange(_pinCtrl.text),
                      defaultPinTheme: PinTheme(
                        width: 48,
                        height: 56,
                        textStyle: AppTextStyles.titleMedium,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 48,
                        height: 56,
                        textStyle: AppTextStyles.titleMedium,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(
                              color: AppColors.primary, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    if (field.errorText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 4),
                        child: Text(
                          field.errorText!,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.error),
                        ),
                      ),
                  ],
                ),
              ).animate(delay: 220.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 14),
              DropdownButtonFormField<GuardianRelationship>(
                initialValue: _relationship,
                decoration: const InputDecoration(
                  labelText: 'Relationship',
                  prefixIcon: Icon(Icons.family_restroom_rounded),
                ),
                items: GuardianRelationship.values
                    .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(r.displayName),
                        ))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _relationship = v ?? GuardianRelationship.other),
              ).animate(delay: 220.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 24),
              Text('Permissions', style: AppTextStyles.title)
                  .animate(delay: 260.ms)
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: 8),
              SwitchListTile(
                value: _canSignIn,
                onChanged: (v) => setState(() => _canSignIn = v),
                title: const Text('Can sign child in'),
                secondary:
                    const Icon(Icons.login_rounded, color: AppColors.success),
                activeThumbColor: AppColors.success,
              ).animate(delay: 280.ms).fadeIn(duration: 400.ms),
              SwitchListTile(
                value: _canSignOut,
                onChanged: (v) => setState(() => _canSignOut = v),
                title: const Text('Can sign child out'),
                secondary:
                    const Icon(Icons.logout_rounded, color: AppColors.error),
                activeThumbColor: AppColors.error,
              ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 32),
              GradientButton(
                label: 'Add Guardian',
                onPressed: _save,
                isLoading: formState.isLoading,
                gradient: AppColors.parentGradient,
                icon: Icons.person_add_rounded,
              ).animate(delay: 340.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
