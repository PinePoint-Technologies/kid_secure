import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/child_model.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../providers/teacher_provider.dart';

class AddKidScreen extends ConsumerStatefulWidget {
  const AddKidScreen({super.key});

  @override
  ConsumerState<AddKidScreen> createState() => _AddKidScreenState();
}

class _AddKidScreenState extends ConsumerState<AddKidScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _medicalCtrl = TextEditingController();
  final _dietCtrl = TextEditingController();
  final _classCtrl = TextEditingController();
  final _parentEmailCtrl = TextEditingController();
  DateTime _dob = DateTime(2021, 1, 1);
  DateTime _enrollment = DateTime.now();

  static const _classes = [
    'Infants (0–1)',
    'Toddlers (1–2)',
    'Twos',
    'Pre-K (3–4)',
    'Kindergarten (4–5)',
  ];

  @override
  void dispose() {
    for (final c in [
      _firstNameCtrl, _lastNameCtrl, _allergiesCtrl,
      _medicalCtrl, _dietCtrl, _classCtrl, _parentEmailCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final crecheId = ref.read(teacherCrecheIdProvider);
    if (crecheId == null) return;
    final child = ChildModel(
      id: '',
      crecheId: crecheId,
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      dateOfBirth: _dob,
      allergies: _allergiesCtrl.text.trim().isEmpty
          ? null
          : _allergiesCtrl.text.trim(),
      medicalNotes: _medicalCtrl.text.trim().isEmpty
          ? null
          : _medicalCtrl.text.trim(),
      dietaryRequirements: _dietCtrl.text.trim().isEmpty
          ? null
          : _dietCtrl.text.trim(),
      classGroup: _classCtrl.text.trim().isEmpty ? null : _classCtrl.text.trim(),
      enrollmentDate: _enrollment,
      qrCode: const Uuid().v4(),
    );
    await ref.read(childFormProvider.notifier).saveChild(child);
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(childFormProvider);

    ref.listen(childFormProvider, (_, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Child added successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go(AppRoutes.teacherKids);
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
        title: const Text('Enrol New Child'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.teacherKids),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section('Child Details'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Required'
                          : null,
                    ).animate().fadeIn(duration: 400.ms),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Required'
                          : null,
                    ).animate(delay: 50.ms).fadeIn(duration: 400.ms),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Date of birth picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.cake_rounded,
                    color: AppColors.textHint),
                title: Text('Date of Birth',
                    style: AppTextStyles.label),
                subtitle: Text(
                  '${_dob.day}/${_dob.month}/${_dob.year}',
                  style: AppTextStyles.bodyMedium,
                ),
                trailing: const Icon(Icons.edit_calendar_rounded,
                    color: AppColors.primary),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dob,
                    firstDate: DateTime(2018),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _dob = picked);
                },
              ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 10),
              // Class group dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Class Group',
                  prefixIcon: Icon(Icons.menu_book_rounded),
                ),
                items: _classes
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => _classCtrl.text = v ?? '',
              ).animate(delay: 120.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 24),
              _section('Medical Information'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _allergiesCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Allergies (optional)',
                  prefixIcon: Icon(Icons.warning_amber_rounded),
                  alignLabelWithHint: true,
                ),
              ).animate(delay: 160.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 14),
              TextFormField(
                controller: _medicalCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Medical Notes (optional)',
                  prefixIcon: Icon(Icons.medical_information_rounded),
                  alignLabelWithHint: true,
                ),
              ).animate(delay: 180.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 14),
              TextFormField(
                controller: _dietCtrl,
                decoration: const InputDecoration(
                  labelText: 'Dietary Requirements (optional)',
                  prefixIcon: Icon(Icons.restaurant_rounded),
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 24),
              _section('Enrollment'),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_rounded,
                    color: AppColors.textHint),
                title: Text('Enrollment Date', style: AppTextStyles.label),
                subtitle: Text(
                  '${_enrollment.day}/${_enrollment.month}/${_enrollment.year}',
                  style: AppTextStyles.bodyMedium,
                ),
                trailing: const Icon(Icons.edit_calendar_rounded,
                    color: AppColors.primary),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _enrollment,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _enrollment = picked);
                },
              ).animate(delay: 220.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 32),
              GradientButton(
                label: 'Enrol Child',
                onPressed: _save,
                isLoading: formState.isLoading,
                icon: Icons.child_care_rounded,
              ).animate(delay: 280.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title) =>
      Text(title, style: AppTextStyles.title);
}
