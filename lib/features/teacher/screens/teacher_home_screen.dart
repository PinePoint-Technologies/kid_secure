import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/invite_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatter.dart';
import '../../../shared/models/attendance_model.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/invite_link_dialog.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/teacher_provider.dart';

class TeacherHomeScreen extends ConsumerStatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  ConsumerState<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends ConsumerState<TeacherHomeScreen> {
  final _scrollCtrl = ScrollController();
  bool _nameVisible = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    final shouldShow = _scrollCtrl.offset > 1;
    if (shouldShow != _nameVisible) {
      setState(() => _nameVisible = shouldShow);
    }
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _generateParentInvite(
      BuildContext context, String crecheId) async {
    try {
      final deepLink = await ref
          .read(inviteServiceProvider)
          .generateInvite(role: 'parent', crecheId: crecheId);
      if (context.mounted) {
        await showInviteLinkSheet(context, deepLink: deepLink, role: 'parent');
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to generate invite. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final childrenAsync = ref.watch(teacherChildrenProvider);
    final attendanceAsync = ref.watch(todayAttendanceProvider);
    final sickLeaveAsync = ref.watch(pendingSickLeaveProvider);

    final now = DateTime.now();
    final greeting = switch (now.hour) {
      < 12 => 'Good morning',
      < 17 => 'Good afternoon',
      _ => 'Good evening',
    };
    final firstName = user?.displayName.split(' ').first ?? 'Teacher';

    return CustomScrollView(
      controller: _scrollCtrl,
      slivers: [
        // ─── Collapsing header ──────────────────────────────────────────────
        SliverAppBar(
          automaticallyImplyLeading: false,
          expandedHeight: 130,
          pinned: true,
          // Logo always visible; name fades in once the user scrolls
          title: Row(
            children: [
              Image.asset('assets/images/logo.png', width: 32, height: 32),
              const SizedBox(width: 10),
              AnimatedOpacity(
                opacity: _nameVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  user?.displayName ?? 'Teacher',
                  style: AppTextStyles.titleMedium,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => context.push(AppRoutes.settings),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: user.photoUrl!,
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Text(
                          user != null
                              ? Formatter.initials(user.displayName)
                              : '?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        ),
                ),
              ),
            ),
          ],
          // Expanded area: greeting + first name at the bottom
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            background: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('$greeting,', style: AppTextStyles.body),
                  Text(firstName, style: AppTextStyles.headline1),
                ],
              ),
            ),
          ),
        ),

        // ─── Stats row ──────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Formatter.dateTime(now),
                  style: AppTextStyles.caption,
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 24),
                childrenAsync.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const SizedBox(),
                  data: (children) => attendanceAsync.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const SizedBox(),
                    data: (attendance) {
                      final signedIn = attendance
                          .where((a) =>
                              a.status == AttendanceStatus.signedIn)
                          .length;
                      final absent = attendance
                          .where((a) =>
                              a.status == AttendanceStatus.absent)
                          .length;
                      return Row(
                        children: [
                          _DashStat(
                            label: 'Total Kids',
                            value: '${children.length}',
                            icon: Icons.child_care_rounded,
                            gradient: AppColors.primaryGradient,
                          ),
                          const SizedBox(width: 10),
                          _DashStat(
                            label: 'Present',
                            value: '$signedIn',
                            icon: Icons.check_circle_rounded,
                            gradient: AppColors.parentGradient,
                          ),
                          const SizedBox(width: 10),
                          _DashStat(
                            label: 'Absent',
                            value: '$absent',
                            icon: Icons.person_off_rounded,
                            gradient: const LinearGradient(colors: [
                              AppColors.warning,
                              AppColors.secondary,
                            ]),
                          ),
                        ],
                      ).animate(delay: 150.ms).fadeIn(duration: 500.ms);
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // ─── Pending sick leave ─────────────────────────────────────────────
        sickLeaveAsync.when(
          loading: () => const SliverToBoxAdapter(child: SizedBox()),
          error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
          data: (sickLeaves) => sickLeaves.isEmpty
              ? const SliverToBoxAdapter(child: SizedBox())
              : SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AppCard(
                      color: AppColors.warning.withAlpha(20),
                      border: BorderSide(
                          color: AppColors.warning.withAlpha(128), width: 1),
                      child: Row(
                        children: [
                          const Icon(Icons.local_hospital_rounded,
                              color: AppColors.warning, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${sickLeaves.length} sick leave pending',
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: AppColors.warning,
                                  ),
                                ),
                                Text('Review and approve below.',
                                    style: AppTextStyles.caption),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                  ),
                ),
        ),

        // ─── Quick actions ──────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text('Quick Actions', style: AppTextStyles.title)
                .animate(delay: 250.ms)
                .fadeIn(duration: 400.ms),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid.count(
            crossAxisCount: 2,
            childAspectRatio: 1.4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _QuickAction(
                label: 'View Kids',
                icon: Icons.child_care_rounded,
                gradient: AppColors.primaryGradient,
                onTap: () => context.go(AppRoutes.teacherKids),
              ),
              _QuickAction(
                label: 'Attendance',
                icon: Icons.checklist_rounded,
                gradient: AppColors.teacherGradient,
                onTap: () => context.go(AppRoutes.teacherAttendance),
              ),
              _QuickAction(
                label: 'Add Kid',
                icon: Icons.person_add_rounded,
                gradient: AppColors.parentGradient,
                onTap: () => context.go(AppRoutes.teacherAddKid),
              ),
              _QuickAction(
                label: 'Sick Leave',
                icon: Icons.local_hospital_rounded,
                gradient: const LinearGradient(
                    colors: [AppColors.superAdmin, AppColors.error]),
                onTap: () => context.go(AppRoutes.teacherSickLeave),
              ),
              _QuickAction(
                label: 'Guardian Check-In',
                icon: Icons.badge_rounded,
                gradient: AppColors.accentGradient,
                onTap: () =>
                    context.go(AppRoutes.teacherGuardianCheckin),
              ),
              _QuickAction(
                label: 'Invite Parent',
                icon: Icons.person_add_alt_1_rounded,
                gradient: AppColors.accentGradient,
                onTap: () {
                  final crecheId = user?.crecheIds.firstOrNull ?? '';
                  if (crecheId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No crèche assigned to your account.'),
                      ),
                    );
                    return;
                  }
                  _generateParentInvite(context, crecheId);
                },
              ),
            ]
                .asMap()
                .entries
                .map((e) => e.value
                    .animate(delay: ((e.key + 4) * 60).ms)
                    .fadeIn(duration: 400.ms)
                    .scale(begin: const Offset(0.9, 0.9)))
                .toList(),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _DashStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Gradient gradient;

  const _DashStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: AppTextStyles.headline3.copyWith(color: Colors.white)),
            Text(label,
                style: AppTextStyles.caption.copyWith(
                    color: Colors.white70, fontSize: 10),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Colors.white, size: 26),
                Text(label,
                    style: AppTextStyles.titleMedium
                        .copyWith(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
