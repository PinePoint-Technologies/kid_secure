import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/user_model.dart';
import '../providers/invite_register_provider.dart';

class InviteRegisterScreen extends ConsumerStatefulWidget {
  final String initialToken;
  const InviteRegisterScreen({super.key, required this.initialToken});

  @override
  ConsumerState<InviteRegisterScreen> createState() =>
      _InviteRegisterScreenState();
}

class _InviteRegisterScreenState extends ConsumerState<InviteRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  // Cached once token is validated — survives through Registering / Error states
  InviteValid? _validState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(inviteRegisterProvider.notifier)
          .validateToken(widget.initialToken);
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_validState == null) return;
    if (!_formKey.currentState!.validate()) return;
    ref.read(inviteRegisterProvider.notifier).register(
          email: _emailCtrl.text,
          password: _passCtrl.text,
          displayName: _nameCtrl.text,
          phoneNumber: _phoneCtrl.text.trim().isEmpty
              ? null
              : _phoneCtrl.text.trim(),
          role: _validState!.role,
          crecheId: _validState!.crecheId,
          tokenId: _validState!.tokenId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(inviteRegisterProvider);

    // Cache valid state and handle success
    ref.listen<InviteRegisterStatus>(inviteRegisterProvider, (_, next) {
      if (next is InviteValid) {
        setState(() => _validState = next);
      }
      if (next is InviteSuccess) {
        final route = switch (next.user.role) {
          UserRole.teacher => AppRoutes.teacher,
          UserRole.parent => AppRoutes.parent,
          UserRole.superAdmin => AppRoutes.superAdmin,
        };
        context.go(route);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: switch (status) {
          InviteIdle() || InviteValidating() => _buildValidating(),
          InviteInvalid(:final message) => _buildInvalid(message),
          InviteSuccess() => _buildValidating(), // brief flash before navigation
          _ => _validState != null
              ? _buildForm(status)
              : _buildValidating(),
        },
      ),
    );
  }

  // ── Validating ─────────────────────────────────────────────────────────────

  Widget _buildValidating() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text('Verifying invite…', style: AppTextStyles.body),
        ],
      ),
    );
  }

  // ── Invalid / Expired ─────────────────────────────────────────────────────

  Widget _buildInvalid(String message) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.error.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.link_off_rounded,
              size: 48,
              color: AppColors.error,
            ),
          ).animate().scale(duration: 400.ms),
          const SizedBox(height: 24),
          Text('Invite Unavailable',
              style: AppTextStyles.headline2, textAlign: TextAlign.center)
              .animate(delay: 100.ms)
              .fadeIn(),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ).animate(delay: 200.ms).fadeIn(),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => context.go(AppRoutes.login),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Back to Login'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ).animate(delay: 300.ms).fadeIn(),
        ],
      ),
    );
  }

  // ── Registration Form ─────────────────────────────────────────────────────

  Widget _buildForm(InviteRegisterStatus status) {
    final valid = _validState!;
    final isLoading = status is InviteRegistering;
    final errorMsg = status is InviteError ? (status).message : null;
    final roleLabel = valid.role == 'teacher' ? 'Teacher' : 'Parent';
    final roleColor =
        valid.role == 'teacher' ? AppColors.teacher : AppColors.parent;
    final roleGradient = valid.role == 'teacher'
        ? AppColors.teacherGradient
        : AppColors.parentGradient;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                gradient: roleGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Invited as $roleLabel',
                style:
                    AppTextStyles.label.copyWith(color: Colors.white),
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 16),

            Text('Create your account', style: AppTextStyles.headline2)
                .animate(delay: 50.ms)
                .fadeIn(),
            const SizedBox(height: 4),
            _CrecheNameLabel(crecheId: valid.crecheId)
                .animate(delay: 100.ms)
                .fadeIn(),
            const SizedBox(height: 28),

            // Full Name
            _Field(
              controller: _nameCtrl,
              label: 'Full Name',
              icon: Icons.person_rounded,
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Name is required'
                  : null,
            ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.2),
            const SizedBox(height: 16),

            // Email
            _Field(
              controller: _emailCtrl,
              label: 'Email',
              icon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  v == null || !v.contains('@') ? 'Enter a valid email' : null,
            ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
            const SizedBox(height: 16),

            // Phone (optional)
            _Field(
              controller: _phoneCtrl,
              label: 'Phone (optional)',
              icon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
            ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.2),
            const SizedBox(height: 16),

            // Password
            TextFormField(
              controller: _passCtrl,
              obscureText: _obscurePass,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_rounded),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePass
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded),
                  onPressed: () =>
                      setState(() => _obscurePass = !_obscurePass),
                ),
              ),
              validator: (v) => v == null || v.length < 8
                  ? 'Password must be at least 8 characters'
                  : null,
            ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
            const SizedBox(height: 16),

            // Confirm Password
            TextFormField(
              controller: _confirmCtrl,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              validator: (v) =>
                  v != _passCtrl.text ? 'Passwords do not match' : null,
            ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.2),
            const SizedBox(height: 28),

            // Error message
            if (errorMsg != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.error.withAlpha(80)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(errorMsg,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.error)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Submit
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isLoading ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: roleColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Create Account',
                        style: TextStyle(fontSize: 16)),
              ),
            ).animate(delay: 400.ms).fadeIn(),
            const SizedBox(height: 16),

            Center(
              child: TextButton(
                onPressed: () => context.go(AppRoutes.login),
                child: const Text('Already have an account? Sign in'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Creche Name ───────────────────────────────────────────────────────────────

final _crecheNameProvider =
    FutureProvider.family<String, String>((ref, crecheId) async {
  final db = ref.read(firestoreProvider);
  final snap = await db.collection('creches').doc(crecheId).get();
  return snap.data()?['name'] as String? ?? 'KidSecure Crèche';
});

class _CrecheNameLabel extends ConsumerWidget {
  final String crecheId;
  const _CrecheNameLabel({required this.crecheId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final future = ref.watch(_crecheNameProvider(crecheId));
    return future.when(
      loading: () => Text('Loading crèche…',
          style: AppTextStyles.body
              .copyWith(color: AppColors.textSecondary)),
      error: (_, __) => const SizedBox(),
      data: (name) => Row(
        children: [
          const Icon(Icons.school_rounded,
              size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(name,
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ── Field helper ──────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }
}
