import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatter.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/kid_avatar.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/parent_provider.dart';

class ParentHomeScreen extends ConsumerWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final childrenAsync = ref.watch(parentChildrenProvider);
    final now = DateTime.now();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${user?.displayName.split(' ').first ?? 'Parent'} 👋',
                  style: AppTextStyles.headline2,
                ).animate().fadeIn(duration: 400.ms),
                Text(Formatter.date(now), style: AppTextStyles.caption)
                    .animate(delay: 50.ms)
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 24),
                // Quick actions
                Row(
                  children: [
                    _QuickBtn(
                      label: 'Sign In/Out',
                      icon: Icons.login_rounded,
                      gradient: AppColors.primaryGradient,
                      onTap: () => context.go(AppRoutes.parentSignInOut),
                    ),
                    const SizedBox(width: 10),
                    _QuickBtn(
                      label: 'Guardians',
                      icon: Icons.people_rounded,
                      gradient: AppColors.teacherGradient,
                      onTap: () => context.go(AppRoutes.parentGuardians),
                    ),
                    const SizedBox(width: 10),
                    _QuickBtn(
                      label: 'Sick Leave',
                      icon: Icons.local_hospital_rounded,
                      gradient: AppColors.superAdminGradient,
                      onTap: () => context.go(AppRoutes.parentSickLeave),
                    ),
                  ],
                ).animate(delay: 100.ms).fadeIn(duration: 500.ms),
                const SizedBox(height: 28),
                Text("My Children", style: AppTextStyles.title)
                    .animate(delay: 150.ms)
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        // Children cards
        childrenAsync.when(
          loading: () => const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) =>
              SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
          data: (children) => children.isEmpty
              ? const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.child_care_outlined,
                              size: 64, color: AppColors.textHint),
                          SizedBox(height: 12),
                          Text('No children linked yet.\nContact your teacher.',
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList.separated(
                    itemCount: children.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final child = children[i];
                      return _ChildStatusCard(childId: child.id)
                          .animate(delay: (i * 80 + 200).ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.2);
                    },
                  ),
                ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _ChildStatusCard extends ConsumerWidget {
  final String childId;
  const _ChildStatusCard({required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(parentChildrenProvider);
    final attendanceAsync = ref.watch(childAttendanceProvider(childId));

    final child = childrenAsync.valueOrNull?.firstWhere(
      (c) => c.id == childId,
      orElse: () => throw StateError('not found'),
    );

    if (child == null) return const SizedBox();

    return AppCard(
      onTap: () => context.go(AppRoutes.parentSignInOut),
      child: Row(
        children: [
          KidAvatar(
            photoUrl: child.photoUrl,
            initials: child.initials,
            size: 56,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(child.fullName, style: AppTextStyles.titleMedium),
                Text('Age: ${Formatter.age(child.dateOfBirth)}',
                    style: AppTextStyles.bodySmall),
                const SizedBox(height: 6),
                attendanceAsync.when(
                  loading: () => const SizedBox(
                    width: 80,
                    height: 12,
                    child: LinearProgressIndicator(),
                  ),
                  error: (_, __) => const SizedBox(),
                  data: (record) => record != null
                      ? StatusChip(status: record.status)
                      : Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('Not yet signed in',
                              style: AppTextStyles.caption),
                        ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
        ],
      ),
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _QuickBtn({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontSize: 9,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
