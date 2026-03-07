import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatter.dart';
import '../../../shared/models/guardian_model.dart';
import '../../../shared/widgets/app_card.dart';
import '../providers/parent_provider.dart';

class GuardianListScreen extends ConsumerWidget {
  const GuardianListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(parentChildrenProvider);

    return Scaffold(
      body: childrenAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (children) => children.isEmpty
            ? const Center(child: Text('No children linked yet.'))
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Text('Trusted Guardians',
                              style: AppTextStyles.headline2)
                          .animate()
                          .fadeIn(duration: 400.ms),
                    ),
                  ),
                  for (final child in children) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child:
                            Text(child.fullName, style: AppTextStyles.title),
                      ),
                    ),
                    _GuardianList(childId: child.id),
                  ],
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.parentAddGuardian),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Guardian'),
      ),
    );
  }
}

class _GuardianList extends ConsumerWidget {
  final String childId;
  const _GuardianList({required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guardiansAsync = ref.watch(childGuardiansProvider(childId));

    return guardiansAsync.when(
      loading: () =>
          const SliverToBoxAdapter(child: CircularProgressIndicator()),
      error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
      data: (guardians) => guardians.isEmpty
          ? SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppCard(
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppColors.textHint),
                      const SizedBox(width: 10),
                      Text('No guardians added yet',
                          style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
              ),
            )
          : SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.separated(
                itemCount: guardians.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _GuardianCard(
                  guardian: guardians[i],
                  onRemove: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      useRootNavigator: true,
                      builder: (dialogCtx) => AlertDialog(
                        title: const Text('Remove Guardian'),
                        content: Text(
                            'Remove ${guardians[i].fullName} as a guardian?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.of(dialogCtx,
                                  rootNavigator: true).pop(false),
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () => Navigator.of(dialogCtx,
                                  rootNavigator: true).pop(true),
                              child: const Text('Remove',
                                  style:
                                      TextStyle(color: AppColors.error))),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await ref
                          .read(guardianFormProvider.notifier)
                          .removeGuardian(guardians[i].id, childId);
                    }
                  },
                )
                    .animate(delay: (i * 60).ms)
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: 0.15),
              ),
            ),
    );
  }
}

class _GuardianCard extends StatelessWidget {
  final GuardianModel guardian;
  final VoidCallback onRemove;

  const _GuardianCard({required this.guardian, required this.onRemove});

  void _showQr(BuildContext context) {
    if (guardian.qrCode == null) return;
    showDialog<void>(
      context: context,
      useRootNavigator: true,
      builder: (dialogCtx) => AlertDialog(
        title: Text(guardian.fullName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Show this QR to the teacher for gate check-in',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 200,
              height: 200,
              child: QrImageView(
                data: guardian.qrCode!,
                version: QrVersions.auto,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx, rootNavigator: true).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.accent.withAlpha(26),
            child: Text(
              Formatter.initials(guardian.fullName),
              style: AppTextStyles.titleMedium
                  .copyWith(color: AppColors.accent),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(guardian.fullName, style: AppTextStyles.bodyMedium),
                Text(guardian.relationship.displayName,
                    style: AppTextStyles.caption),
                Text(Formatter.phone(guardian.phoneNumber),
                    style: AppTextStyles.bodySmall),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (guardian.canSignIn)
                      _pill('Sign In', AppColors.success),
                    if (guardian.canSignIn && guardian.canSignOut)
                      const SizedBox(width: 4),
                    if (guardian.canSignOut)
                      _pill('Sign Out', AppColors.primary),
                    if (guardian.isVerified) ...[
                      const SizedBox(width: 4),
                      _pill('Verified ✓', AppColors.accent),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (guardian.qrCode != null)
            IconButton(
              icon: const Icon(Icons.qr_code_rounded,
                  color: AppColors.primary),
              tooltip: 'Show QR',
              onPressed: () => _showQr(context),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.error),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            )),
      );
}
