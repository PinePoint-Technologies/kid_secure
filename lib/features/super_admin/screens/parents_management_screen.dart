import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatter.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/widgets/app_card.dart';
import '../providers/creche_provider.dart';
import '../providers/super_admin_provider.dart';

class ParentsManagementScreen extends ConsumerWidget {
  const ParentsManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentsAsync = ref.watch(allParentsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.superAdminAddParent),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Parent'),
        backgroundColor: AppColors.parent,
      ),
      body: parentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (parents) => parents.isEmpty
            ? _EmptyState()
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Parent Accounts',
                              style: AppTextStyles.headline2),
                          const SizedBox(height: 4),
                          Text(
                            '${parents.length} active parent${parents.length == 1 ? '' : 's'}',
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
                      itemCount: parents.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (_, i) =>
                          _ParentCard(parent: parents[i])
                              .animate(delay: (i * 50).ms)
                              .fadeIn(duration: 350.ms)
                              .slideY(begin: 0.15),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
      ),
    );
  }
}

class _ParentCard extends ConsumerWidget {
  final UserModel parent;
  const _ParentCard({required this.parent});

  Future<void> _confirmDeactivate(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Deactivate Parent'),
        content: Text(
            'Deactivate ${parent.displayName}? They will no longer be able to sign in.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(crecheFormProvider.notifier).deactivateUser(parent.uid);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.parent.withAlpha(26),
            child: Text(
              Formatter.initials(parent.displayName),
              style: AppTextStyles.titleMedium
                  .copyWith(color: AppColors.parent),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(parent.displayName,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(parent.email,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (parent.phoneNumber != null &&
                    parent.phoneNumber!.isNotEmpty)
                  Text(Formatter.phone(parent.phoneNumber!),
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.block_rounded),
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
          Icon(Icons.family_restroom_rounded,
              size: 80, color: AppColors.textHint),
          SizedBox(height: 16),
          Text('No parent accounts yet'),
        ],
      ),
    );
  }
}
