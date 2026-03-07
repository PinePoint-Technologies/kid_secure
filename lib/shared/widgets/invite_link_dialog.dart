import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Shows a bottom sheet with the invite deep link, a copy button, and a QR code.
/// Call via [showInviteLinkSheet].
class InviteLinkSheet extends StatefulWidget {
  final String deepLink;
  final String role; // 'teacher' or 'parent'

  const InviteLinkSheet({
    super.key,
    required this.deepLink,
    required this.role,
  });

  @override
  State<InviteLinkSheet> createState() => _InviteLinkSheetState();
}

class _InviteLinkSheetState extends State<InviteLinkSheet> {
  bool _showQr = false;
  bool _copied = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.deepLink));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final roleLabel = widget.role == 'teacher' ? 'Teacher' : 'Parent';
    final roleColor = widget.role == 'teacher' ? AppColors.teacher : AppColors.parent;
    final roleGradient = widget.role == 'teacher'
        ? AppColors.teacherGradient
        : AppColors.parentGradient;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: roleGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.link_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$roleLabel Invite Link', style: AppTextStyles.title),
                    Text('Valid for 7 days · One-time use',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        )),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Link box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.deepLink,
                      style: AppTextStyles.caption.copyWith(
                        fontFamily: 'monospace',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _copy,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        _copied ? Icons.check_rounded : Icons.copy_rounded,
                        key: ValueKey(_copied),
                        size: 20,
                        color: _copied ? AppColors.success : roleColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Copy button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _copy,
                style: FilledButton.styleFrom(
                  backgroundColor: roleColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(
                  _copied ? Icons.check_rounded : Icons.copy_rounded,
                  size: 18,
                ),
                label: Text(_copied ? 'Copied!' : 'Copy Link'),
              ),
            ),
            const SizedBox(height: 10),

            // QR toggle
            TextButton.icon(
              onPressed: () => setState(() => _showQr = !_showQr),
              icon: Icon(
                _showQr ? Icons.qr_code_2_rounded : Icons.qr_code_rounded,
                size: 18,
              ),
              label: Text(_showQr ? 'Hide QR Code' : 'Show QR Code'),
            ),

            // QR code
            if (_showQr) ...[
              const SizedBox(height: 12),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: QrImageView(
                    data: widget.deepLink,
                    size: 180,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Scan to open invite on another device',
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shows the invite link sheet as a modal bottom sheet.
Future<void> showInviteLinkSheet(
  BuildContext context, {
  required String deepLink,
  required String role,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => InviteLinkSheet(deepLink: deepLink, role: role),
  );
}
