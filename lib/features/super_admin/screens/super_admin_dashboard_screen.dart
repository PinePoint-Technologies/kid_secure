import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/super_admin_provider.dart';

class SuperAdminDashboardScreen extends ConsumerWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.overview, style: AppTextStyles.headline2)
                .animate()
                .fadeIn(duration: 350.ms),
            const SizedBox(height: 4),
            Text(l10n.liveCountsAllSchools,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                )).animate().fadeIn(duration: 350.ms),
            const SizedBox(height: 24),
            statsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Center(child: Text(l10n.errorMessage(e.toString()))),
              data: (stats) => Column(
                children: [
                  Row(
                    children: [
                      _StatCard(
                        label: l10n.schools,
                        value: '${stats.crecheCount}',
                        icon: Icons.school_rounded,
                        gradient: AppColors.superAdminGradient,
                        onTap: () => context.go(AppRoutes.superAdminCreches),
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: l10n.teachers,
                        value: '${stats.teacherCount}',
                        icon: Icons.person_rounded,
                        gradient: AppColors.teacherGradient,
                      ),
                    ],
                  ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.15),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _StatCard(
                        label: l10n.kids,
                        value: '${stats.kidCount}',
                        icon: Icons.child_care_rounded,
                        gradient: AppColors.accentGradient,
                        onTap: () => context.go(AppRoutes.superAdminKids),
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: l10n.parents,
                        value: '${stats.parentCount}',
                        icon: Icons.family_restroom_rounded,
                        gradient: AppColors.parentGradient,
                        onTap: () => context.go(AppRoutes.superAdminParents),
                      ),
                    ],
                  ).animate(delay: 180.ms).fadeIn(duration: 400.ms).slideY(begin: 0.15),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _StatCard(
                        label: l10n.guardians,
                        value: '${stats.guardianCount}',
                        icon: Icons.shield_rounded,
                        gradient: AppColors.primaryGradient,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(child: SizedBox()),
                    ],
                  ).animate(delay: 240.ms).fadeIn(duration: 400.ms).slideY(begin: 0.15),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(l10n.quickActions, style: AppTextStyles.title)
                .animate(delay: 300.ms)
                .fadeIn(duration: 350.ms),
            const SizedBox(height: 14),
            _QuickAction(
              icon: Icons.school_rounded,
              label: l10n.manageCreches,
              subtitle: 'Add, edit or deactivate schools',
              gradient: AppColors.superAdminGradient,
              onTap: () => context.go(AppRoutes.superAdminCreches),
            ).animate(delay: 340.ms).fadeIn(duration: 400.ms).slideX(begin: 0.15),
            const SizedBox(height: 10),
            _QuickAction(
              icon: Icons.family_restroom_rounded,
              label: l10n.navParents,
              subtitle: 'View and manage all parents',
              gradient: AppColors.parentGradient,
              onTap: () => context.go(AppRoutes.superAdminParents),
            ).animate(delay: 380.ms).fadeIn(duration: 400.ms).slideX(begin: 0.15),
            const SizedBox(height: 10),
            _QuickAction(
              icon: Icons.child_care_rounded,
              label: l10n.navKids,
              subtitle: 'Browse children across all schools',
              gradient: AppColors.accentGradient,
              onTap: () => context.go(AppRoutes.superAdminKids),
            ).animate(delay: 420.ms).fadeIn(duration: 400.ms).slideX(begin: 0.15),
            const SizedBox(height: 10),
            _QuickAction(
              icon: Icons.bar_chart_rounded,
              label: l10n.navReports,
              subtitle: 'Attendance & sick-leave across all schools',
              gradient: AppColors.primaryGradient,
              onTap: () => context.go(AppRoutes.superAdminReports),
            ).animate(delay: 460.ms).fadeIn(duration: 400.ms).slideX(begin: 0.15),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value,
                        style: AppTextStyles.headline3
                            .copyWith(color: Colors.white),
                        overflow: TextOverflow.ellipsis),
                    Text(label,
                        style: AppTextStyles.caption
                            .copyWith(color: Colors.white70),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTextStyles.bodyMedium),
                    Text(subtitle,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}
