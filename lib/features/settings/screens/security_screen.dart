import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../providers/settings_provider.dart';

class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Security'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Biometric login
          AppCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(26),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.fingerprint_rounded,
                        color: AppColors.success, size: 22),
                  ),
                  title: Text('Biometric Login', style: AppTextStyles.bodyMedium),
                  subtitle: Text(
                    'Use fingerprint or face ID to unlock',
                    style: AppTextStyles.caption,
                  ),
                  value: settings.biometricEnabled,
                  onChanged: (v) => notifier.setBiometric(v),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning.withAlpha(80)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.warning, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Biometric login requires the local_auth plugin. '
                    'Enable this setting once biometric support is configured '
                    'on your device.',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.warning),
                  ),
                ),
              ],
            ),
          ).animate(delay: 80.ms).fadeIn(duration: 300.ms),

          const SizedBox(height: 24),

          // Session timeout
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text('Session Timeout', style: AppTextStyles.label),
          ),

          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withAlpha(26),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.timer_rounded,
                          color: AppColors.secondary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Auto Lock', style: AppTextStyles.bodyMedium),
                          Text(
                            'Lock app after period of inactivity',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<int>(
                  value: settings.sessionTimeoutMinutes,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: kTimeoutOptions
                      .map((t) => DropdownMenuItem(
                            value: t.minutes,
                            child: Text(t.label),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) notifier.setSessionTimeout(v);
                  },
                ),
              ],
            ),
          ).animate(delay: 150.ms).fadeIn(duration: 300.ms),

          const SizedBox(height: 24),

          // Role visibility info
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text('Role & Access', style: AppTextStyles.label),
          ),

          AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.superAdmin.withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.admin_panel_settings_rounded,
                    color: AppColors.superAdmin, size: 22),
              ),
              title: Text('Access Level', style: AppTextStyles.bodyMedium),
              subtitle: Text(
                'Your role permissions are managed by your administrator.',
                style: AppTextStyles.caption,
              ),
              trailing: const Icon(Icons.lock_outline_rounded,
                  color: AppColors.textHint, size: 18),
            ),
          ).animate(delay: 220.ms).fadeIn(duration: 300.ms),
        ],
      ),
    );
  }
}
