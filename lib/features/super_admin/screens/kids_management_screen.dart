import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatter.dart';
import '../../../shared/models/child_model.dart';
import '../../../shared/models/creche_model.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../core/providers/firebase_providers.dart';
import '../providers/creche_provider.dart';
import '../providers/super_admin_provider.dart';

class KidsManagementScreen extends ConsumerWidget {
  const KidsManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(allChildrenProvider);
    final crechesAsync = ref.watch(allCrechesProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.superAdminAddKid),
        icon: const Icon(Icons.child_care_rounded),
        label: const Text('Enrol Kid'),
        backgroundColor: AppColors.accentDark,
      ),
      body: childrenAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (children) {
          final crecheMap = <String, CrecheModel>{};
          crechesAsync.valueOrNull
              ?.forEach((c) => crecheMap[c.id] = c);

          return children.isEmpty
              ? _EmptyState()
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('All Kids', style: AppTextStyles.headline2),
                            const SizedBox(height: 4),
                            Text(
                              '${children.length} active kid${children.length == 1 ? '' : 's'} across all schools',
                              style: AppTextStyles.body.copyWith(
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList.separated(
                        itemCount: children.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (_, i) => _KidCard(
                          child: children[i],
                          creche: crecheMap[children[i].crecheId],
                        )
                            .animate(delay: (i * 50).ms)
                            .fadeIn(duration: 350.ms)
                            .slideY(begin: 0.15),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                );
        },
      ),
    );
  }
}

class _KidCard extends ConsumerWidget {
  final ChildModel child;
  final CrecheModel? creche;
  const _KidCard({required this.child, this.creche});

  Future<void> _showAssignTrackerDialog(
      BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: child.trackerId ?? '');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Tracker for ${child.firstName}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Device ID',
            hintText: 'e.g. DEVICE_001',
            prefixIcon: Icon(Icons.gps_fixed_rounded),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          if (child.trackerId != null)
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Remove Tracker'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (confirmed == true) {
      final id = controller.text.trim();
      await ref
          .read(firestoreServiceProvider)
          .assignTrackerToChild(child.id, id.isEmpty ? null : id);
    } else if (confirmed == false) {
      // "Remove Tracker" tapped
      await ref
          .read(firestoreServiceProvider)
          .assignTrackerToChild(child.id, null);
    }
    controller.dispose();
  }

  Future<void> _confirmDeactivate(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Kid'),
        content: Text(
            'Mark ${child.fullName} as inactive? This will remove them from attendance lists.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(crecheFormProvider.notifier).deactivateChild(child.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.accent.withAlpha(38),
            child: Text(
              child.initials,
              style: AppTextStyles.titleMedium
                  .copyWith(color: AppColors.accentDark),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(child.fullName,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(Formatter.age(child.dateOfBirth),
                    style: AppTextStyles.caption),
                if (creche != null)
                  Text(creche!.name,
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                if (child.classGroup != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(child.classGroup!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.link_rounded),
            color: AppColors.parent,
            tooltip: 'Link Parent',
            onPressed: () => context.go(
                AppRoutes.superAdminLinkParentPath(child.id)),
          ),
          IconButton(
            icon: Icon(
              Icons.gps_fixed_rounded,
              color: child.trackerId != null
                  ? Colors.blue
                  : AppColors.textHint,
            ),
            tooltip: child.trackerId != null
                ? 'Tracker: ${child.trackerId}'
                : 'Assign Tracker',
            onPressed: () => _showAssignTrackerDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline_rounded),
            color: AppColors.error,
            tooltip: 'Deactivate',
            onPressed: () => _confirmDeactivate(context, ref),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.child_care_rounded, size: 80, color: AppColors.textHint),
          SizedBox(height: 16),
          Text('No kids enrolled yet'),
        ],
      ),
    );
  }
}
