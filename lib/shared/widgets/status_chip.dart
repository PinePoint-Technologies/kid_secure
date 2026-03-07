import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../models/attendance_model.dart';

class StatusChip extends StatelessWidget {
  final AttendanceStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (status) {
      AttendanceStatus.signedIn => (
          AppColors.success.withAlpha(26),
          AppColors.success,
          Icons.login_rounded,
        ),
      AttendanceStatus.signedOut => (
          AppColors.error.withAlpha(26),
          AppColors.error,
          Icons.logout_rounded,
        ),
      AttendanceStatus.absent => (
          AppColors.warning.withAlpha(26),
          AppColors.warning,
          Icons.person_off_rounded,
        ),
      AttendanceStatus.sickLeave => (
          AppColors.superAdmin.withAlpha(26),
          AppColors.superAdmin,
          Icons.local_hospital_rounded,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 14),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: AppTextStyles.caption.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
