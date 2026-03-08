import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/creche_model.dart';
import '../../../shared/widgets/app_card.dart';
import '../providers/super_admin_provider.dart';

class CrecheListScreen extends ConsumerWidget {
  const CrecheListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final crechesAsync = ref.watch(allCrechesProvider);

    return Scaffold(
      body: crechesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorMessage(e.toString()))),
        data: (creches) => creches.isEmpty
            ? _EmptyState(onAdd: () => context.go(AppRoutes.superAdminCrecheNew))
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.manageCreches, style: AppTextStyles.headline2),
                          const SizedBox(height: 4),
                          Text(
                            l10n.schoolsRegistered(creches.length),
                            style: AppTextStyles.body,
                          ),
                          const SizedBox(height: 16),
                          // Stats row
                          Row(
                            children: [
                              _StatCard(
                                label: l10n.totalSchools,
                                value: '${creches.length}',
                                icon: Icons.school_rounded,
                                gradient: AppColors.primaryGradient,
                              ),
                              const SizedBox(width: 12),
                              _StatCard(
                                label: l10n.capacity,
                                value:
                                    '${creches.fold(0, (s, c) => s + c.capacity)}',
                                icon: Icons.people_rounded,
                                gradient: AppColors.teacherGradient,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList.separated(
                      itemCount: creches.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _CrecheCard(creche: creches[i])
                          .animate(delay: (i * 60).ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.2),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.superAdminCrecheNew),
        icon: const Icon(Icons.add_rounded),
        label: Text(AppLocalizations.of(context)!.manageCreches),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Gradient gradient;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
    );
  }
}

class _CrecheCard extends StatelessWidget {
  final CrecheModel creche;
  const _CrecheCard({required this.creche});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.go(
          AppRoutes.superAdminCrecheEdit.replaceFirst(':crecheId', creche.id)),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.superAdminGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.school_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(creche.name,
                    style: AppTextStyles.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(creche.fullAddress,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _Tag(
                        label:
                            '${creche.teacherIds.length} teacher${creche.teacherIds.length == 1 ? '' : 's'}',
                        color: AppColors.teacher),
                    const SizedBox(width: 6),
                    _Tag(
                        label: 'Cap. ${creche.capacity}',
                        color: AppColors.accent),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.people_alt_rounded),
                color: AppColors.primary,
                tooltip: AppLocalizations.of(context)!.manageTeachers,
                onPressed: () => context.go(
                  AppRoutes.superAdminTeacherAssign
                      .replaceFirst(':crecheId', creche.id),
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textHint),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: AppTextStyles.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          )),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.school_outlined, size: 80, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(l10n.manageCreches, style: AppTextStyles.headline3),
          const SizedBox(height: 8),
          Text(l10n.addYourFirstSchool, style: AppTextStyles.body),
          const SizedBox(height: 24)
        ],
      ),
    );
  }
}
