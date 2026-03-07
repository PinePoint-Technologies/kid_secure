import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../providers/settings_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final pushEnabled = settings.pushNotificationsEnabled;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Master toggle
          AppCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.notifications_rounded,
                    color: AppColors.primary, size: 20),
              ),
              title: Text('Push Notifications',
                  style: AppTextStyles.bodyMedium),
              subtitle: Text('Allow all push notifications',
                  style: AppTextStyles.caption),
              value: pushEnabled,
              onChanged: (v) => notifier.setPushNotifications(v),
            ),
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 20),

          // Granular options
          AnimatedOpacity(
            opacity: pushEnabled ? 1.0 : 0.4,
            duration: const Duration(milliseconds: 250),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 10),
                  child: Text('Alert Types', style: AppTextStyles.label),
                ),
                AppCard(
                  child: Column(
                    children: [
                      _NotifTile(
                        icon: Icons.checklist_rounded,
                        iconColor: AppColors.success,
                        title: 'Attendance Alerts',
                        subtitle: 'Sign-in and sign-out notifications',
                        value: settings.attendanceAlerts && pushEnabled,
                        enabled: pushEnabled,
                        onChanged: (v) => notifier.setAttendanceAlerts(v),
                      ),
                      const Divider(height: 1),
                      _NotifTile(
                        icon: Icons.chat_bubble_outline_rounded,
                        iconColor: AppColors.secondary,
                        title: 'Teacher–Parent Messages',
                        subtitle: 'Classroom updates and notes',
                        value: settings.teacherParentMessages && pushEnabled,
                        enabled: pushEnabled,
                        onChanged: (v) => notifier.setTeacherParentMessages(v),
                      ),
                      const Divider(height: 1),
                      _NotifTile(
                        icon: Icons.system_update_rounded,
                        iconColor: AppColors.accent,
                        title: 'System Updates',
                        subtitle: 'App and policy changes',
                        value: settings.systemUpdates && pushEnabled,
                        enabled: pushEnabled,
                        onChanged: (v) => notifier.setSystemUpdates(v),
                        isLast: true,
                      ),
                    ],
                  ),
                ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withAlpha(80)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.info, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You can also manage notification permissions '
                    'in your device Settings → Apps → KidSecure.',
                    style: AppTextStyles.caption.copyWith(color: AppColors.info),
                  ),
                ),
              ],
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 300.ms),
        ],
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const _NotifTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 0),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        title: Text(title, style: AppTextStyles.body),
        subtitle: Text(subtitle, style: AppTextStyles.caption),
        value: value,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }
}
