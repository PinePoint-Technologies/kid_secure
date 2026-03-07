import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatter.dart';
import '../../../shared/models/child_model.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/kid_avatar.dart';
import '../providers/teacher_provider.dart';

final _childDetailProvider =
    Provider.family<ChildModel?, String>((ref, childId) {
  final children = ref.watch(teacherChildrenProvider).valueOrNull ?? [];
  return children.cast<ChildModel?>().firstWhere(
        (c) => c?.id == childId,
        orElse: () => null,
      );
});

class KidDetailScreen extends ConsumerWidget {
  final String childId;
  const KidDetailScreen({super.key, required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(_childDetailProvider(childId));

    return Scaffold(
      floatingActionButton: child == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () =>
                  context.go(AppRoutes.teacherLinkParentPath(childId)),
              icon: const Icon(Icons.link_rounded),
              label: Text(
                child.parentIds.isEmpty
                    ? 'Link Parent'
                    : '${child.parentIds.length} Parent${child.parentIds.length == 1 ? '' : 's'}',
              ),
              backgroundColor: AppColors.parent,
            ),
      body: child == null
            ? const Center(child: Text('Child not found'))
            : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: true,
                    title: Text(child.fullName),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 60),
                              KidAvatar(
                                photoUrl: child.photoUrl,
                                initials: child.initials,
                                size: 72,
                                backgroundColor:
                                    Colors.white.withAlpha(51),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                child.fullName,
                                style: AppTextStyles.headline3
                                    .copyWith(color: Colors.white),
                              ),
                              Text(
                                'Age: ${Formatter.age(child.dateOfBirth)}',
                                style: AppTextStyles.body
                                    .copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList.list(
                      children: [
                        // QR Code card
                        if (child.qrCode != null)
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Sign-In QR Code',
                                    style: AppTextStyles.title),
                                const SizedBox(height: 4),
                                Text(
                                    'Guardians scan this to sign in/out',
                                    style: AppTextStyles.bodySmall),
                                const SizedBox(height: 16),
                                Center(
                                  child: QrImageView(
                                    data: child.qrCode!,
                                    version: QrVersions.auto,
                                    size: 160,
                                    eyeStyle: const QrEyeStyle(
                                      eyeShape: QrEyeShape.square,
                                      color: AppColors.primary,
                                    ),
                                    dataModuleStyle: const QrDataModuleStyle(
                                      dataModuleShape:
                                          QrDataModuleShape.square,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 400.ms),
                        const SizedBox(height: 16),
                        // Medical info
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Medical Information',
                                  style: AppTextStyles.title),
                              const SizedBox(height: 12),
                              _InfoRow(
                                label: 'Allergies',
                                value: child.allergies ?? 'None',
                                icon: Icons.warning_amber_rounded,
                                highlight: child.allergies != null,
                              ),
                              const Divider(height: 20),
                              _InfoRow(
                                label: 'Medical Notes',
                                value: child.medicalNotes ?? 'None',
                                icon: Icons.medical_information_rounded,
                              ),
                              const Divider(height: 20),
                              _InfoRow(
                                label: 'Dietary',
                                value:
                                    child.dietaryRequirements ?? 'No restrictions',
                                icon: Icons.restaurant_rounded,
                              ),
                            ],
                          ),
                        ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
                        const SizedBox(height: 16),
                        // Enrollment info
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Enrollment', style: AppTextStyles.title),
                              const SizedBox(height: 12),
                              _InfoRow(
                                label: 'Enrolled',
                                value: Formatter.date(child.enrollmentDate),
                                icon: Icons.event_rounded,
                              ),
                              if (child.classGroup != null) ...[
                                const Divider(height: 20),
                                _InfoRow(
                                  label: 'Class',
                                  value: child.classGroup!,
                                  icon: Icons.menu_book_rounded,
                                ),
                              ],
                              const Divider(height: 20),
                              _InfoRow(
                                label: 'Status',
                                value: child.status.name,
                                icon: Icons.info_outline_rounded,
                              ),
                            ],
                          ),
                        ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool highlight;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon,
            size: 18,
            color: highlight ? AppColors.warning : AppColors.textHint),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: highlight ? AppColors.warning : null,
                  fontWeight: highlight ? FontWeight.w700 : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
