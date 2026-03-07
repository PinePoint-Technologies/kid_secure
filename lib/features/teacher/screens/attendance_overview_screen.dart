import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatter.dart';
import '../../../shared/models/attendance_model.dart';
import '../../../shared/models/sick_leave_model.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/teacher_provider.dart';

class AttendanceOverviewScreen extends ConsumerWidget {
  const AttendanceOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(teacherChildrenProvider);
    final attendanceAsync = ref.watch(todayAttendanceProvider);
    final sickLeaveAsync = ref.watch(pendingSickLeaveProvider);
    final allSickLeaveAsync = ref.watch(teacherSickLeaveProvider);

    // Child IDs with pending/approved sick leave covering today (date-only).
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final todaySickChildIds = allSickLeaveAsync.valueOrNull
            ?.where((l) {
              final start = DateTime(
                  l.startDate.year, l.startDate.month, l.startDate.day);
              final end = l.endDate == null
                  ? start
                  : DateTime(
                      l.endDate!.year, l.endDate!.month, l.endDate!.day);
              return !start.isAfter(todayDate) && !end.isBefore(todayDate);
            })
            .map((l) => l.childId)
            .toSet() ??
        const <String>{};

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Today's Attendance", style: AppTextStyles.headline2)
                    .animate()
                    .fadeIn(duration: 400.ms),
                Text(Formatter.dateTime(DateTime.now()),
                        style: AppTextStyles.caption)
                    .animate(delay: 50.ms)
                    .fadeIn(duration: 400.ms),
              ],
            ),
          ),
        ),
        // Attendance summary
        SliverToBoxAdapter(
          child: attendanceAsync.when(
            loading: () => const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SizedBox(),
            data: (records) => childrenAsync.when(
              loading: () => const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SizedBox(),
              data: (children) {
              final recordedChildIds = records.map((r) => r.childId).toSet();
              final counts = {
                for (var s in AttendanceStatus.values)
                  s: records.where((r) => r.status == s).length,
              };
              for (final child in children) {
                if (recordedChildIds.contains(child.id)) continue;
                if (todaySickChildIds.contains(child.id)) {
                  counts[AttendanceStatus.sickLeave] =
                      (counts[AttendanceStatus.sickLeave] ?? 0) + 1;
                } else {
                  counts[AttendanceStatus.absent] =
                      (counts[AttendanceStatus.absent] ?? 0) + 1;
                }
              }
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: AttendanceStatus.values.map((status) {
                    final (bg, fg) = switch (status) {
                      AttendanceStatus.signedIn => (
                          AppColors.success.withAlpha(26),
                          AppColors.success,
                        ),
                      AttendanceStatus.signedOut => (
                          AppColors.error.withAlpha(26),
                          AppColors.error,
                        ),
                      AttendanceStatus.absent => (
                          AppColors.warning.withAlpha(26),
                          AppColors.warning,
                        ),
                      AttendanceStatus.sickLeave => (
                          AppColors.superAdmin.withAlpha(26),
                          AppColors.superAdmin,
                        ),
                    };
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 4),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${counts[status] ?? 0}',
                              style: AppTextStyles.headline3
                                  .copyWith(color: fg),
                            ),
                            Text(
                              status.displayName,
                              style: AppTextStyles.caption
                                  .copyWith(color: fg, fontSize: 9),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ).animate(delay: 100.ms).fadeIn(duration: 500.ms),
              );
            },
          ),
        ),
        ),
        // Attendance list
        childrenAsync.when(
          loading: () =>
              const SliverToBoxAdapter(child: CircularProgressIndicator()),
          error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
          data: (children) => attendanceAsync.when(
            loading: () =>
                const SliverToBoxAdapter(child: CircularProgressIndicator()),
            error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
            data: (records) {
              final recordMap = {
                for (var r in records) r.childId: r,
              };
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.separated(
                  itemCount: children.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final child = children[i];
                    final record = recordMap[child.id];
                    return AppCard(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                AppColors.primaryLight.withAlpha(51),
                            child: Text(child.initials,
                                style: AppTextStyles.label.copyWith(
                                    color: AppColors.primary)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(child.fullName,
                                    style: AppTextStyles.bodyMedium),
                                if (record?.signInTime != null)
                                  Text(
                                    'In: ${Formatter.time(record!.signInTime!)}${record.signOutTime != null ? ' • Out: ${Formatter.time(record.signOutTime!)}' : ''}',
                                    style: AppTextStyles.caption,
                                  ),
                              ],
                            ),
                          ),
                          StatusChip(
                            status: record?.status ??
                                (todaySickChildIds.contains(child.id)
                                    ? AttendanceStatus.sickLeave
                                    : AttendanceStatus.absent),
                          ),
                        ],
                      ),
                    )
                        .animate(delay: (i * 40).ms)
                        .fadeIn(duration: 300.ms);
                  },
                ),
              );
            },
          ),
        ),
        // Pending sick leave section
        SliverToBoxAdapter(
          child: sickLeaveAsync.when(
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
            data: (leaves) => leaves.isEmpty
                ? const SizedBox()
                : Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pending Sick Leave', style: AppTextStyles.title),
                        const SizedBox(height: 12),
                        ...leaves.asMap().entries.map((e) {
                          final leave = e.value;
                          return _SickLeaveCard(
                            leave: leave,
                            onApprove: () async {
                              final user = ref
                                  .read(currentUserProvider)
                                  .valueOrNull;
                              if (user != null) {
                                await ref
                                    .read(childFormProvider.notifier)
                                    .approveSickLeave(leave.id, leave, user.uid);
                              }
                            },
                          )
                              .animate(delay: (e.key * 60).ms)
                              .fadeIn(duration: 400.ms);
                        }),
                      ],
                    ),
                  ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _SickLeaveCard extends StatelessWidget {
  final SickLeaveModel leave;
  final VoidCallback onApprove;

  const _SickLeaveCard({required this.leave, required this.onApprove});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      border: BorderSide(
          color: AppColors.superAdmin.withAlpha(128), width: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_hospital_rounded,
                  color: AppColors.superAdmin, size: 18),
              const SizedBox(width: 6),
              Text(leave.childName, style: AppTextStyles.bodyMedium),
              const Spacer(),
              Text(Formatter.date(leave.startDate),
                  style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 8),
          Text(leave.reason, style: AppTextStyles.bodySmall),
          if (leave.symptoms != null) ...[
            const SizedBox(height: 4),
            Text('Symptoms: ${leave.symptoms}',
                style: AppTextStyles.caption),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onApprove,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                minimumSize: const Size(double.infinity, 38),
              ),
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Approve'),
            ),
          ),
        ],
      ),
    );
  }
}
