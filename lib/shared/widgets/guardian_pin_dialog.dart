import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../models/guardian_model.dart';

/// Shows a bottom sheet asking the guardian to enter their PIN.
/// Returns the entered PIN string, or null if cancelled.
Future<String?> showGuardianPinDialog(
  BuildContext context, {
  required GuardianModel guardian,
  required String childName,
  required bool isSignIn,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _GuardianPinSheet(
      guardian: guardian,
      childName: childName,
      isSignIn: isSignIn,
    ),
  );
}

class _GuardianPinSheet extends StatefulWidget {
  final GuardianModel guardian;
  final String childName;
  final bool isSignIn;

  const _GuardianPinSheet({
    required this.guardian,
    required this.childName,
    required this.isSignIn,
  });

  @override
  State<_GuardianPinSheet> createState() => _GuardianPinSheetState();
}

class _GuardianPinSheetState extends State<_GuardianPinSheet> {
  final _pinCtrl = TextEditingController();

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final action = widget.isSignIn ? 'Sign In' : 'Sign Out';

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withAlpha(26),
              child: const Icon(Icons.person_rounded,
                  color: AppColors.primary, size: 30),
            ),
            const SizedBox(height: 12),
            Text(widget.guardian.fullName, style: AppTextStyles.headline3),
            Text(
              widget.guardian.relationship.displayName,
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 8),
            Text(
              '$action ${widget.childName}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: widget.isSignIn ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Enter your PIN to confirm',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 16),
            Pinput(
              controller: _pinCtrl,
              length: 6,
              obscureText: true,
              keyboardType: TextInputType.number,
              autofocus: true,
              onCompleted: (pin) =>
                  Navigator.of(context, rootNavigator: true).pop(pin),
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
                  border:
                      Border.all(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(null),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true)
                            .pop(_pinCtrl.text),
                    style: FilledButton.styleFrom(
                      backgroundColor: widget.isSignIn
                          ? AppColors.success
                          : AppColors.error,
                    ),
                    child: Text(action),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
