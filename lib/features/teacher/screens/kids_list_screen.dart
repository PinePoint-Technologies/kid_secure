import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatter.dart';
import '../../../shared/models/child_model.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/kid_avatar.dart';
import '../providers/teacher_provider.dart';

class KidsListScreen extends ConsumerStatefulWidget {
  const KidsListScreen({super.key});

  @override
  ConsumerState<KidsListScreen> createState() => _KidsListScreenState();
}

class _KidsListScreenState extends ConsumerState<KidsListScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final childrenAsync = ref.watch(teacherChildrenProvider);

    return Scaffold(
      body: childrenAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (children) {
          final filtered = _search.isEmpty
              ? children
              : children
                  .where((c) => c.fullName
                      .toLowerCase()
                      .contains(_search.toLowerCase()))
                  .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${children.length} Kids Enrolled',
                        style: AppTextStyles.headline2)
                        .animate()
                        .fadeIn(duration: 400.ms),
                    const SizedBox(height: 14),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search kids...',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                      onChanged: (v) => setState(() => _search = v),
                    ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off_rounded,
                                size: 64, color: AppColors.textHint),
                            const SizedBox(height: 12),
                            Text(
                                _search.isEmpty
                                    ? 'No kids enrolled yet'
                                    : 'No results for "$_search"',
                                style: AppTextStyles.body),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (_, i) =>
                            _KidCard(child: filtered[i])
                                .animate(delay: (i * 50).ms)
                                .fadeIn(duration: 400.ms)
                                .slideY(begin: 0.15),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.teacherAddKid),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Kid'),
      ),
    );
  }
}

class _KidCard extends StatelessWidget {
  final ChildModel child;
  const _KidCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.go(
        AppRoutes.teacherKidDetail.replaceFirst(':childId', child.id),
      ),
      child: Row(
        children: [
          KidAvatar(
            photoUrl: child.photoUrl,
            initials: child.initials,
            size: 52,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(child.fullName, style: AppTextStyles.titleMedium),
                const SizedBox(height: 2),
                Text('Age: ${Formatter.age(child.dateOfBirth)}',
                    style: AppTextStyles.bodySmall),
                if (child.classGroup != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withAlpha(51),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (child.allergies != null)
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.warning, size: 18),
              const SizedBox(height: 4),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textHint),
            ],
          ),
        ],
      ),
    );
  }
}
