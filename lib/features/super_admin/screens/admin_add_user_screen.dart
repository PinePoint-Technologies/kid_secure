import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/creche_model.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../providers/admin_user_provider.dart';
import '../providers/super_admin_provider.dart';

class AdminAddUserScreen extends ConsumerStatefulWidget {
  final UserRole role;

  /// When adding a teacher, the crèche they will be immediately assigned to.
  final String? initialCrecheId;

  /// Optional override for post-success navigation.
  /// If provided, called instead of the default super-admin redirect.
  final void Function(BuildContext context)? onSuccess;

  const AdminAddUserScreen({
    super.key,
    required this.role,
    this.initialCrecheId,
    this.onSuccess,
  });

  @override
  ConsumerState<AdminAddUserScreen> createState() => _AdminAddUserScreenState();
}

class _AdminAddUserScreenState extends ConsumerState<AdminAddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _obscure = true;

  String? _selectedCrecheId;

  bool get _isTeacher => widget.role == UserRole.teacher;

  @override
  void initState() {
    super.initState();
    _selectedCrecheId = widget.initialCrecheId;
    // Reset form state when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminUserFormProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final crecheIds = <String>[];
    if (_isTeacher && _selectedCrecheId != null) {
      crecheIds.add(_selectedCrecheId!);
    }

    await ref.read(adminUserFormProvider.notifier).createUser(
          email: _emailCtrl.text,
          password: _passCtrl.text,
          displayName: _nameCtrl.text,
          role: widget.role,
          phoneNumber: _phoneCtrl.text.isEmpty ? null : _phoneCtrl.text,
          crecheIds: crecheIds,
        );
  }

  String get _title =>
      _isTeacher ? 'Add Teacher Account' : 'Add Parent Account';

  String get _successMsg =>
      _isTeacher ? 'Teacher account created!' : 'Parent account created!';

  Color get _roleColor =>
      _isTeacher ? AppColors.teacher : AppColors.parent;

  LinearGradient get _gradient =>
      _isTeacher ? AppColors.teacherGradient : AppColors.parentGradient;

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(adminUserFormProvider);
    final crechesAsync = ref.watch(allCrechesProvider);

    ref.listen(adminUserFormProvider, (_, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_successMsg),
            backgroundColor: AppColors.success,
          ),
        );
        if (widget.onSuccess != null) {
          widget.onSuccess!(context);
        } else if (_isTeacher && widget.initialCrecheId != null) {
          context.go(AppRoutes.superAdminTeacherAssignPath(widget.initialCrecheId!));
        } else if (_isTeacher) {
          context.go(AppRoutes.superAdminCreches);
        } else {
          context.go(AppRoutes.superAdminParents);
        }
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
        title: Text(_title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Role badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: _gradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isTeacher
                          ? Icons.school_rounded
                          : Icons.family_restroom_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.role.displayName,
                      style: AppTextStyles.label
                          .copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 24),

              _section('Personal Details'),
              const SizedBox(height: 12),

              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 14),

              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number (optional)',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ).animate(delay: 40.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 24),

              _section('Login Credentials'),
              const SizedBox(height: 12),

              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email is required';
                  if (!v.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ).animate(delay: 80.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 14),

              TextFormField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Temporary Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  helperText: 'Share this with the ${widget.role.displayName.toLowerCase()} so they can sign in.',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password is required';
                  if (v.length < 8) return 'Password must be at least 8 characters';
                  return null;
                },
              ).animate(delay: 120.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 24),

              // Crèche assignment — only for teachers
              if (_isTeacher) ...[
                _section('Crèche Assignment'),
                const SizedBox(height: 4),
                Text(
                  'Select the school this teacher will be assigned to.',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                crechesAsync.when(
                  loading: () => const Center(
                      child: CircularProgressIndicator()),
                  error: (e, _) =>
                      Text('Error loading schools: $e'),
                  data: (creches) => _CrecheDropdown(
                    creches: creches,
                    selectedId: _selectedCrecheId,
                    onChanged: (id) =>
                        setState(() => _selectedCrecheId = id),
                    roleColor: _roleColor,
                  ).animate(delay: 160.ms).fadeIn(duration: 400.ms),
                ),
                const SizedBox(height: 24),
              ],

              GradientButton(
                label: _isTeacher ? 'Create Teacher' : 'Create Parent',
                onPressed: _save,
                isLoading: formState.isLoading,
                gradient: _gradient,
                icon: Icons.person_add_rounded,
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title) =>
      Text(title, style: AppTextStyles.title.copyWith(color: AppColors.textPrimary));
}

class _CrecheDropdown extends StatelessWidget {
  final List<CrecheModel> creches;
  final String? selectedId;
  final ValueChanged<String?> onChanged;
  final Color roleColor;

  const _CrecheDropdown({
    required this.creches,
    required this.selectedId,
    required this.onChanged,
    required this.roleColor,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedId,
      decoration: const InputDecoration(
        labelText: 'School (optional)',
        prefixIcon: Icon(Icons.school_outlined),
      ),
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('No school assigned yet'),
        ),
        for (final c in creches)
          DropdownMenuItem(value: c.id, child: Text(c.name)),
      ],
      onChanged: onChanged,
    );
  }
}
