import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatter.dart';
import '../../../shared/models/sick_leave_model.dart';
import '../../../shared/widgets/app_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/teacher_provider.dart';

class TeacherSickLeaveScreen extends ConsumerWidget {
  const TeacherSickLeaveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sickLeaveAsync = ref.watch(teacherSickLeaveProvider);

    return sickLeaveAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (leaves) {
        final pending =
            leaves.where((l) => l.status == SickLeaveStatus.pending).toList();
        final approved =
            leaves.where((l) => l.status == SickLeaveStatus.approved).toList();

        if (leaves.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_hospital_outlined,
                    size: 80, color: AppColors.textHint),
                const SizedBox(height: 16),
                Text('No sick leave submitted',
                    style: AppTextStyles.headline3),
                const SizedBox(height: 8),
                Text('Parents can log sick leave from their app.',
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Text('Sick Leave', style: AppTextStyles.headline2)
                    .animate()
                    .fadeIn(duration: 400.ms),
              ),
            ),

            // ── Pending ──────────────────────────────────────────────────
            if (pending.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.warning,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Pending (${pending.length})',
                        style: AppTextStyles.title
                            .copyWith(color: AppColors.warning),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.separated(
                  itemCount: pending.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _PendingSickLeaveCard(
                    leave: pending[i],
                    onApprove: () async {
                      final user =
                          ref.read(currentUserProvider).valueOrNull;
                      if (user != null) {
                        await ref
                            .read(childFormProvider.notifier)
                            .approveSickLeave(
                                pending[i].id, pending[i], user.uid);
                      }
                    },
                  )
                      .animate(delay: (i * 60).ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1),
                ),
              ),
            ],

            // ── Approved ─────────────────────────────────────────────────
            if (approved.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Approved (${approved.length})',
                        style: AppTextStyles.title
                            .copyWith(color: AppColors.success),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.separated(
                  itemCount: approved.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) =>
                      _ApprovedSickLeaveCard(leave: approved[i])
                          .animate(delay: (i * 60).ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.1),
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }
}

// ─── Pending card (with approve button) ──────────────────────────────────────

class _PendingSickLeaveCard extends StatelessWidget {
  final SickLeaveModel leave;
  final VoidCallback onApprove;

  const _PendingSickLeaveCard(
      {required this.leave, required this.onApprove});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      border: BorderSide(color: AppColors.warning.withAlpha(100), width: 1),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.warning.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_hospital_rounded,
                    color: AppColors.warning, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(leave.childName, style: AppTextStyles.bodyMedium),
                    Text(
                      _dateRange(leave),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Pending',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w700,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(leave.reason, style: AppTextStyles.bodySmall),
          if (leave.symptoms != null) ...[
            const SizedBox(height: 4),
            Text('Symptoms: ${leave.symptoms}',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary)),
          ],
          const SizedBox(height: 4),
          Text('Submitted ${Formatter.relativeTime(leave.createdAt)}',
              style:
                  AppTextStyles.caption.copyWith(color: AppColors.textHint)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onApprove,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                minimumSize: const Size(double.infinity, 40),
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

// ─── Approved card (read-only) ────────────────────────────────────────────────

class _ApprovedSickLeaveCard extends StatelessWidget {
  final SickLeaveModel leave;
  const _ApprovedSickLeaveCard({required this.leave});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_hospital_rounded,
                color: AppColors.success, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(leave.childName, style: AppTextStyles.bodyMedium),
                Text(_dateRange(leave), style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(leave.reason,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('Approved',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                )),
          ),
        ],
      ),
    );
  }
}

String _dateRange(SickLeaveModel leave) => leave.daysCount == 1
    ? Formatter.date(leave.startDate)
    : '${Formatter.date(leave.startDate)} – ${Formatter.date(leave.endDate!)}';
