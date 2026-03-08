import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatter.dart';
import '../../../shared/models/sick_leave_model.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/parent_provider.dart';

class SickLeaveScreen extends ConsumerWidget {
  const SickLeaveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final sickLeaveAsync = ref.watch(parentSickLeaveProvider);

    return Scaffold(
      body: sickLeaveAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorMessage(e.toString()))),
        data: (leaves) => leaves.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.local_hospital_outlined,
                        size: 80, color: AppColors.textHint),
                    const SizedBox(height: 16),
                    Text(l10n.noSickLeaveLogged, style: AppTextStyles.headline3),
                    const SizedBox(height: 8),
                    Text(l10n.tapToLogSickDay, style: AppTextStyles.body),
                    const SizedBox(height: 24)
                  ],
                ),
              )
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Text(l10n.sickLeaveHistory,
                              style: AppTextStyles.headline2)
                          .animate()
                          .fadeIn(duration: 400.ms),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList.separated(
                      itemCount: leaves.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (_, i) => _SickLeaveCard(leave: leaves[i])
                          .animate(delay: (i * 60).ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.15),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.parentLogSickLeave),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.logSickLeave),
        backgroundColor: AppColors.superAdmin,
      ),
    );
  }
}

class _SickLeaveCard extends StatelessWidget {
  final SickLeaveModel leave;
  const _SickLeaveCard({required this.leave});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (statusColor, statusText) = switch (leave.status) {
      SickLeaveStatus.pending => (AppColors.warning, l10n.pending),
      SickLeaveStatus.approved => (AppColors.success, l10n.approved),
      SickLeaveStatus.rejected => (AppColors.error, l10n.rejected),
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.superAdmin.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_hospital_rounded,
                    color: AppColors.superAdmin, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(leave.childName, style: AppTextStyles.bodyMedium),
                    Text(
                      leave.daysCount == 1
                          ? Formatter.date(leave.startDate)
                          : '${Formatter.date(leave.startDate)} – ${Formatter.date(leave.endDate!)}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(statusText,
                    style: AppTextStyles.caption.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(leave.reason, style: AppTextStyles.bodyMedium),
          if (leave.symptoms != null) ...[
            const SizedBox(height: 4),
            Text(l10n.symptoms(leave.symptoms!),
                style: AppTextStyles.bodySmall),
          ],
          if (leave.attachmentUrls.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
                l10n.attachmentCount(leave.attachmentUrls.length),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                )),
          ],
          const SizedBox(height: 8),
          Text(l10n.loggedTime(Formatter.relativeTime(leave.createdAt)),
              style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
