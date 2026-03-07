import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/sick_leave_model.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/parent_provider.dart';

class LogSickLeaveScreen extends ConsumerStatefulWidget {
  const LogSickLeaveScreen({super.key});

  @override
  ConsumerState<LogSickLeaveScreen> createState() =>
      _LogSickLeaveScreenState();
}

class _LogSickLeaveScreenState extends ConsumerState<LogSickLeaveScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonCtrl = TextEditingController();
  final _symptomsCtrl = TextEditingController();
  String? _selectedChildId;
  String? _selectedChildName;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _multiDay = false;
  final List<String> _attachmentPaths = [];

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _symptomsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _attachmentPaths.add(result.files.single.path!));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedChildId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a child'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    final user = ref.read(currentUserProvider).valueOrNull;
    final children = ref.read(parentChildrenProvider).valueOrNull ?? [];
    final child = children.firstWhere((c) => c.id == _selectedChildId!);

    // In production, upload files to Firebase Storage first
    final leave = SickLeaveModel(
      id: '',
      childId: _selectedChildId!,
      childName: _selectedChildName ?? '',
      parentUid: user?.uid ?? '',
      crecheId: child.crecheId,
      startDate: _startDate,
      endDate: _multiDay ? _endDate : null,
      reason: _reasonCtrl.text.trim(),
      symptoms: _symptomsCtrl.text.trim().isEmpty
          ? null
          : _symptomsCtrl.text.trim(),
      createdAt: DateTime.now(),
    );
    await ref.read(sickLeaveFormProvider.notifier).logSickLeave(leave);
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(sickLeaveFormProvider);
    final childrenAsync = ref.watch(parentChildrenProvider);

    ref.listen(sickLeaveFormProvider, (_, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sick leave logged! Teacher will be notified.'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go(AppRoutes.parentSickLeave);
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
        title: const Text('Log Sick Leave'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.parentSickLeave),
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
              childrenAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const SizedBox(),
                data: (children) => DropdownButtonFormField<String>(
                  initialValue: _selectedChildId,
                  hint: const Text('Select child'),
                  decoration: const InputDecoration(
                    labelText: 'Child',
                    prefixIcon: Icon(Icons.child_care_rounded),
                  ),
                  items: children
                      .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.fullName),
                          ))
                      .toList(),
                  onChanged: (v) {
                    final child = children.firstWhere((c) => c.id == v);
                    setState(() {
                      _selectedChildId = v;
                      _selectedChildName = child.fullName;
                    });
                  },
                  validator: (v) => v == null ? 'Select a child' : null,
                ).animate().fadeIn(duration: 400.ms),
              ),
              const SizedBox(height: 16),
              // Start date
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_rounded,
                    color: AppColors.textHint),
                title: Text('Start Date', style: AppTextStyles.label),
                subtitle: Text(
                  '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                  style: AppTextStyles.bodyMedium,
                ),
                trailing: const Icon(Icons.edit_calendar_rounded,
                    color: AppColors.primary),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime.now()
                        .subtract(const Duration(days: 30)),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _startDate = picked);
                },
              ).animate(delay: 80.ms).fadeIn(duration: 400.ms),
              // Multi-day toggle
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _multiDay,
                onChanged: (v) => setState(() => _multiDay = v),
                title: const Text('Multiple days'),
                secondary: const Icon(Icons.date_range_rounded,
                    color: AppColors.textHint),
              ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
              if (_multiDay)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_available_rounded,
                      color: AppColors.textHint),
                  title: Text('End Date', style: AppTextStyles.label),
                  subtitle: Text(
                    _endDate != null
                        ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                        : 'Not set',
                    style: AppTextStyles.bodyMedium,
                  ),
                  trailing: const Icon(Icons.edit_calendar_rounded,
                      color: AppColors.primary),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? _startDate,
                      firstDate: _startDate,
                      lastDate:
                          DateTime.now().add(const Duration(days: 14)),
                    );
                    if (picked != null) setState(() => _endDate = picked);
                  },
                ).animate(delay: 120.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Reason for absence',
                  prefixIcon: Icon(Icons.edit_note_rounded),
                  alignLabelWithHint: true,
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Reason is required'
                    : null,
              ).animate(delay: 150.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 14),
              TextFormField(
                controller: _symptomsCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Symptoms (optional)',
                  prefixIcon: Icon(Icons.sick_rounded),
                  alignLabelWithHint: true,
                ),
              ).animate(delay: 180.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 20),
              // Attachments
              Text('Attachments', style: AppTextStyles.title)
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: 6),
              Text("Attach doctor's notes (PDF, JPG, PNG)",
                      style: AppTextStyles.bodySmall)
                  .animate(delay: 220.ms)
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: 10),
              ..._attachmentPaths.map((path) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.attach_file_rounded,
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            path.split('/').last,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.primary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              size: 16, color: AppColors.error),
                          onPressed: () =>
                              setState(() => _attachmentPaths.remove(path)),
                        ),
                      ],
                    ),
                  )),
              OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Attachment'),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48)),
              ).animate(delay: 240.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 32),
              GradientButton(
                label: 'Submit Sick Leave',
                onPressed: _save,
                isLoading: formState.isLoading,
                gradient: AppColors.superAdminGradient,
                icon: Icons.send_rounded,
              ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
