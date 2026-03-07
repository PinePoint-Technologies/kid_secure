import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _currentVisible = false;
  bool _newVisible = false;
  bool _confirmVisible = false;
  bool _loading = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        _showError('No authenticated user found.');
        return;
      }

      // Re-authenticate before changing password
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentCtrl.text,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(_newCtrl.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated successfully.'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } on FirebaseAuthException catch (e) {
      _showError(_authErrorMessage(e.code));
    } catch (e) {
      _showError('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
      ),
    );
  }

  String _authErrorMessage(String code) => switch (code) {
        'wrong-password' => 'Current password is incorrect.',
        'weak-password' => 'New password is too weak (min 6 characters).',
        'requires-recent-login' =>
          'Please sign out and sign back in, then try again.',
        _ => 'Failed to update password. Please try again.',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Change Password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Illustration / icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_reset_rounded,
                      color: Colors.white, size: 40),
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOut),

              const SizedBox(height: 28),

              Text('Update your password', style: AppTextStyles.headline3),
              const SizedBox(height: 6),
              Text(
                'Enter your current password, then choose a new one.',
                style: AppTextStyles.body,
              ),

              const SizedBox(height: 28),

              // Current password
              _PasswordField(
                controller: _currentCtrl,
                label: 'Current Password',
                visible: _currentVisible,
                onToggle: () =>
                    setState(() => _currentVisible = !_currentVisible),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2),

              const SizedBox(height: 16),

              // New password
              _PasswordField(
                controller: _newCtrl,
                label: 'New Password',
                visible: _newVisible,
                onToggle: () => setState(() => _newVisible = !_newVisible),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (v.length < 6) return 'Minimum 6 characters';
                  return null;
                },
              ).animate(delay: 160.ms).fadeIn().slideY(begin: 0.2),

              const SizedBox(height: 16),

              // Confirm new password
              _PasswordField(
                controller: _confirmCtrl,
                label: 'Confirm New Password',
                visible: _confirmVisible,
                onToggle: () =>
                    setState(() => _confirmVisible = !_confirmVisible),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (v != _newCtrl.text) return 'Passwords do not match';
                  return null;
                },
              ).animate(delay: 220.ms).fadeIn().slideY(begin: 0.2),

              const SizedBox(height: 32),

              // Submit
              FilledButton(
                onPressed: _loading ? null : _submit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Update Password'),
              ).animate(delay: 280.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool visible;
  final VoidCallback onToggle;
  final String? Function(String?) validator;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.visible,
    required this.onToggle,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: !visible,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        suffixIcon: IconButton(
          icon: Icon(visible
              ? Icons.visibility_off_rounded
              : Icons.visibility_rounded),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
