import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatter.dart';
import '../../../shared/models/creche_model.dart';
import '../../../shared/models/sick_leave_model.dart';
import '../providers/super_admin_provider.dart';

// ─── Providers scoped to this screen ─────────────────────────────────────────

final _allSickLeaveProvider = StreamProvider<List<SickLeaveModel>>(
  (ref) => ref.watch(firestoreServiceProvider).watchAllSickLeave(),
);

// ─── Screen ───────────────────────────────────────────────────────────────────

class AdminReportsScreen extends ConsumerStatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  ConsumerState<AdminReportsScreen> createState() =>
      _AdminReportsScreenState();
}

class _AdminReportsScreenState extends ConsumerState<AdminReportsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reports', style: AppTextStyles.headline2)
                    .animate()
                    .fadeIn(duration: 350.ms),
                Text('Data across all schools',
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.textSecondary))
                    .animate()
                    .fadeIn(duration: 350.ms),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tab,
                  tabs: const [
                    Tab(text: 'Sick Leave'),
                    Tab(text: 'Enrollment'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _SickLeaveTab(),
                _EnrollmentTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sick-leave tab ───────────────────────────────────────────────────────────

class _SickLeaveTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sickAsync = ref.watch(_allSickLeaveProvider);
    final crechesAsync = ref.watch(allCrechesProvider);

    return sickAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (records) {
        if (records.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sick_rounded, size: 64, color: AppColors.textHint),
                SizedBox(height: 12),
                Text('No sick-leave records'),
              ],
            ),
          );
        }

        final crecheMap = <String, CrecheModel>{};
        crechesAsync.valueOrNull?.forEach((c) => crecheMap[c.id] = c);

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          itemCount: records.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final r = records[i];
            final creche = crecheMap[r.crecheId];
            return _SickLeaveCard(record: r, crecheName: creche?.name)
                .animate(delay: (i * 40).ms)
                .fadeIn(duration: 300.ms);
          },
        );
      },
    );
  }
}

class _SickLeaveCard extends StatelessWidget {
  final SickLeaveModel record;
  final String? crecheName;
  const _SickLeaveCard({required this.record, this.crecheName});

  Color get _statusColor => switch (record.status) {
        SickLeaveStatus.approved => AppColors.success,
        SickLeaveStatus.rejected => AppColors.error,
        SickLeaveStatus.pending => AppColors.warning,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.sickLeave.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.sick_rounded,
                color: AppColors.sickLeave, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.childName,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(record.reason,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (crecheName != null)
                  Text(crecheName!,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.primary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(record.status.name,
                    style: AppTextStyles.caption.copyWith(
                      color: _statusColor,
                      fontWeight: FontWeight.w700,
                    )),
              ),
              const SizedBox(height: 4),
              Text(Formatter.date(record.createdAt),
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textHint)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Enrollment tab ───────────────────────────────────────────────────────────

class _EnrollmentTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crechesAsync = ref.watch(allCrechesProvider);
    final childrenAsync = ref.watch(allChildrenProvider);

    return crechesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (creches) {
        final allChildren = childrenAsync.valueOrNull ?? [];

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          itemCount: creches.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final creche = creches[i];
            final enrolled =
                allChildren.where((c) => c.crecheId == creche.id).length;
            final pct = creche.capacity > 0
                ? (enrolled / creche.capacity).clamp(0.0, 1.0)
                : 0.0;

            return _EnrollmentCard(
              creche: creche,
              enrolled: enrolled,
              pct: pct,
            )
                .animate(delay: (i * 60).ms)
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.1);
          },
        );
      },
    );
  }
}

class _EnrollmentCard extends StatelessWidget {
  final CrecheModel creche;
  final int enrolled;
  final double pct;
  const _EnrollmentCard({
    required this.creche,
    required this.enrolled,
    required this.pct,
  });

  Color get _fill {
    if (pct >= 0.9) return AppColors.error;
    if (pct >= 0.75) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(creche.name,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              Text('$enrolled / ${creche.capacity}',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: _fill)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              color: _fill,
              backgroundColor: AppColors.surfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(pct * 100).toStringAsFixed(0)}% capacity used',
            style: AppTextStyles.caption
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
