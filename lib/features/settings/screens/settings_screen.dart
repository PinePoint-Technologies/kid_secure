import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/utils/formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/widgets/app_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider).valueOrNull;
    final settings = ref.watch(settingsProvider);
    final versionAsync = ref.watch(appVersionProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── Collapsing header ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            leading: BackButton(onPressed: () => context.pop()),
            title: Text(l10n.settings),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _ProfileHeader(user: user),
            ),
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // ─── Profile section ──────────────────────────────────
                    _Section(
                      delay: 0,
                      title: l10n.editProfile,
                      icon: Icons.person_rounded,
                      iconColor: AppColors.primary,
                      children: [
                        _Tile(
                          icon: Icons.edit_rounded,
                          iconColor: AppColors.primary,
                          title: l10n.editProfile,
                          subtitle: user?.displayName ?? '',
                          onTap: () =>
                              context.push(AppRoutes.settingsEditProfile),
                        ),
                        _Tile(
                          icon: Icons.lock_rounded,
                          iconColor: AppColors.secondary,
                          title: l10n.changePassword,
                          onTap: () =>
                              context.push(AppRoutes.settingsChangePassword),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ─── Language section ─────────────────────────────────
                    _Section(
                      delay: 60,
                      title: l10n.language,
                      icon: Icons.language_rounded,
                      iconColor: AppColors.accent,
                      children: [
                        _Tile(
                          icon: Icons.translate_rounded,
                          iconColor: AppColors.accent,
                          title: l10n.appLanguage,
                          subtitle: languageDisplayName(settings.languageCode),
                          trailing: _Arrow(),
                          onTap: () =>
                              context.push(AppRoutes.settingsLanguage),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ─── Notifications section ────────────────────────────
                    _Section(
                      delay: 120,
                      title: l10n.pushNotifications,
                      icon: Icons.notifications_rounded,
                      iconColor: AppColors.warning,
                      children: [
                        SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4),
                          secondary: _IconBadge(
                              Icons.notifications_active_rounded,
                              AppColors.warning),
                          title: Text(l10n.pushNotifications,
                              style: AppTextStyles.body),
                          subtitle: Text(
                            settings.pushNotificationsEnabled
                                ? l10n.enabled
                                : l10n.disabled,
                            style: AppTextStyles.caption,
                          ),
                          value: settings.pushNotificationsEnabled,
                          onChanged: (v) => ref
                              .read(settingsProvider.notifier)
                              .setPushNotifications(v),
                        ),
                        const Divider(height: 1),
                        _Tile(
                          icon: Icons.tune_rounded,
                          iconColor: AppColors.warning,
                          title: l10n.alertPreferences,
                          subtitle: l10n.alertPreferencesSubtitle,
                          onTap: () =>
                              context.push(AppRoutes.settingsNotifications),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ─── Appearance section ───────────────────────────────
                    _Section(
                      delay: 180,
                      title: l10n.theme,
                      icon: Icons.palette_rounded,
                      iconColor: AppColors.success,
                      children: [
                        _Tile(
                          icon: _themeIcon(ref.watch(themeProvider)),
                          iconColor: AppColors.success,
                          title: l10n.theme,
                          subtitle: _themeLabel(ref.watch(themeProvider), l10n),
                          onTap: () =>
                              context.push(AppRoutes.settingsAppearance),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ─── Security section ─────────────────────────────────
                    _Section(
                      delay: 240,
                      title: l10n.biometricSession,
                      icon: Icons.security_rounded,
                      iconColor: AppColors.error,
                      children: [
                        _Tile(
                          icon: Icons.fingerprint_rounded,
                          iconColor: AppColors.error,
                          title: l10n.biometricSession,
                          subtitle: settings.biometricEnabled
                              ? l10n.biometricOnTimeout(timeoutLabel(settings.sessionTimeoutMinutes))
                              : l10n.autoLockTimeout(timeoutLabel(settings.sessionTimeoutMinutes)),
                          onTap: () =>
                              context.push(AppRoutes.settingsSecurity),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ─── Backup & sync ────────────────────────────────────
                    _Section(
                      delay: 300,
                      title: l10n.syncPreferences,
                      icon: Icons.cloud_sync_rounded,
                      iconColor: AppColors.info,
                      children: [
                        SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4),
                          secondary:
                              _IconBadge(Icons.backup_rounded, AppColors.info),
                          title: Text(l10n.syncPreferences,
                              style: AppTextStyles.body),
                          subtitle: Text(
                            l10n.syncSubtitle,
                            style: AppTextStyles.caption,
                          ),
                          value: settings.backupEnabled,
                          onChanged: (v) => ref
                              .read(settingsProvider.notifier)
                              .setBackup(v),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ─── Legal section ────────────────────────────────────
                    _Section(
                      delay: 360,
                      title: l10n.policyConsent,
                      icon: Icons.gavel_rounded,
                      iconColor: AppColors.superAdmin,
                      children: [
                        _Tile(
                          icon: Icons.description_rounded,
                          iconColor: AppColors.superAdmin,
                          title: l10n.termsOfUse,
                          onTap: () => context.push(AppRoutes.settingsTerms),
                        ),
                        const Divider(height: 1),
                        _Tile(
                          icon: Icons.privacy_tip_rounded,
                          iconColor: AppColors.superAdmin,
                          title: l10n.dataPrivacyPolicy,
                          onTap: () =>
                              context.push(AppRoutes.settingsPrivacy),
                        ),
                        const Divider(height: 1),
                        _ConsentRow(
                          consent: settings.policyConsent,
                          onChanged: (v) => ref
                              .read(settingsProvider.notifier)
                              .setPolicyConsent(v),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ─── Help & support ───────────────────────────────────
                    _Section(
                      delay: 420,
                      title: l10n.faqsSupport,
                      icon: Icons.help_rounded,
                      iconColor: AppColors.secondary,
                      children: [
                        _Tile(
                          icon: Icons.quiz_rounded,
                          iconColor: AppColors.secondary,
                          title: l10n.faqsSupport,
                          onTap: () => context.push(AppRoutes.settingsHelp),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ─── About ────────────────────────────────────────────
                    _Section(
                      delay: 480,
                      title: l10n.appVersion,
                      icon: Icons.info_rounded,
                      iconColor: AppColors.textHint,
                      children: [
                        versionAsync.when(
                          loading: () => _Tile(
                            icon: Icons.tag_rounded,
                            iconColor: AppColors.textHint,
                            title: l10n.appVersion,
                            subtitle: l10n.loading,
                          ),
                          error: (_, __) => _Tile(
                            icon: Icons.tag_rounded,
                            iconColor: AppColors.textHint,
                            title: l10n.appVersion,
                            subtitle: l10n.error,
                          ),
                          data: (info) => _Tile(
                            icon: Icons.tag_rounded,
                            iconColor: AppColors.textHint,
                            title: l10n.appVersion,
                            subtitle: '${info.version} (build ${info.buildNumber})',
                          ),
                        ),
                        if (user != null && user.isSuperAdmin) ...[
                          const Divider(height: 1),
                          _Tile(
                            icon: Icons.admin_panel_settings_rounded,
                            iconColor: AppColors.superAdmin,
                            title: l10n.role,
                            subtitle: _roleLabel(user.role, l10n),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ─── Logout ───────────────────────────────────────────
                    _Section(
                      delay: 540,
                      title: l10n.logOut,
                      icon: Icons.logout_rounded,
                      iconColor: AppColors.error,
                      children: [
                        _Tile(
                          icon: Icons.logout_rounded,
                          iconColor: AppColors.error,
                          title: l10n.logOut,
                          onTap: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(l10n.logOut),
                                content: Text(l10n.logOutConfirm),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, false),
                                    child: Text(l10n.cancel),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, true),
                                    child: Text(l10n.logOut,
                                        style: TextStyle(
                                            color: AppColors.error)),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              await ref
                                  .read(authNotifierProvider.notifier)
                                  .signOut();
                            }
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  IconData _themeIcon(ThemeMode mode) => switch (mode) {
        ThemeMode.dark => Icons.dark_mode_rounded,
        ThemeMode.system => Icons.settings_suggest_rounded,
        _ => Icons.light_mode_rounded,
      };

  String _themeLabel(ThemeMode mode, AppLocalizations l10n) => switch (mode) {
        ThemeMode.dark => l10n.dark,
        ThemeMode.system => l10n.systemDefault,
        _ => l10n.light,
      };

  String _roleLabel(UserRole role, AppLocalizations l10n) => switch (role) {
        UserRole.superAdmin => l10n.superAdministrator,
        UserRole.teacher => l10n.teacherRole,
        UserRole.parent => l10n.parentRole,
      };
}

// ─── Profile header ───────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final UserModel? user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppColors.primaryGradient),
      padding: const EdgeInsets.fromLTRB(24, 90, 24, 20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withAlpha(40),
            child: (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: user!.photoUrl!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  )
                : Text(
                    user != null ? Formatter.initials(user!.displayName) : '?',
                    style: AppTextStyles.titleMedium
                        .copyWith(color: Colors.white),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  user?.displayName ?? AppLocalizations.of(context)!.userFallback,
                  style: AppTextStyles.titleMedium
                      .copyWith(color: Colors.white),
                ),
                Text(
                  user?.email ?? '',
                  style:
                      AppTextStyles.caption.copyWith(color: Colors.white70),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Settings section ─────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final int delay;
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  const _Section({
    required this.delay,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 6),
              Text(title,
                  style: AppTextStyles.label.copyWith(color: iconColor)),
            ],
          ),
        ),
        AppCard(
          child: Column(children: children),
        ),
      ],
    ).animate(delay: delay.ms).fadeIn(duration: 350.ms).slideY(begin: 0.1);
  }
}

// ─── Tile ─────────────────────────────────────────────────────────────────────

class _Tile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _Tile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: _IconBadge(icon, iconColor),
      title: Text(title, style: AppTextStyles.body),
      subtitle: subtitle != null
          ? Text(subtitle!, style: AppTextStyles.caption)
          : null,
      trailing: trailing ?? (onTap != null ? _Arrow() : null),
      onTap: onTap,
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBadge(this.icon, this.color);

  @override
  Widget build(BuildContext context) => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, color: color, size: 18),
      );
}

class _Arrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: AppColors.textHint,
      );
}

// ─── Consent row ──────────────────────────────────────────────────────────────

class _ConsentRow extends StatelessWidget {
  final bool consent;
  final ValueChanged<bool> onChanged;

  const _ConsentRow({required this.consent, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: _IconBadge(
        consent ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
        consent ? AppColors.success : AppColors.textHint,
      ),
      title: Text(l10n.policyConsent, style: AppTextStyles.body),
      subtitle: Text(
        consent ? l10n.policyAgreed : l10n.policyTapToReview,
        style: AppTextStyles.caption,
      ),
      onTap: () => onChanged(!consent),
    );
  }
}
