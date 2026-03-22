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
import '../providers/link_parent_provider.dart';
import '../providers/super_admin_provider.dart';

class LinkParentScreen extends ConsumerStatefulWidget {
  final String childId;

  const LinkParentScreen({super.key, required this.childId});

  @override
  ConsumerState<LinkParentScreen> createState() => _LinkParentScreenState();
}

class _LinkParentScreenState extends ConsumerState<LinkParentScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final childAsync = ref.watch(childByIdProvider(widget.childId));
    final parentsAsync = ref.watch(allParentsProvider);

    final location = GoRouterState.of(context).uri.toString();
    final addParentPath = location.startsWith('/teacher')
        ? AppRoutes.teacherAddParent
        : AppRoutes.superAdminAddParent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Link Parent'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(addParentPath),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Parent'),
        backgroundColor: AppColors.parent,
      ),
      body: childAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (child) {
          if (child == null) {
            return const Center(child: Text('Child not found'));
          }
          final linkedIds = child.parentIds.toSet();

          return Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.fullName,
                      style: AppTextStyles.headline2,
                    ),
                    Text(
                      '${linkedIds.length} parent${linkedIds.length == 1 ? '' : 's'} linked',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    // Search bar
                    TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search by name or email…',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _query = '');
                                },
                              )
                            : null,
                      ),
                      onChanged: (v) => setState(() => _query = v.toLowerCase()),
                    ),
                  ],
                ),
              ),

              // Parent list
              Expanded(
                child: parentsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (parents) {
                    final filtered = _query.isEmpty
                        ? parents
                        : parents
                            .where((p) =>
                                p.displayName
                                    .toLowerCase()
                                    .contains(_query) ||
                                p.email
                                    .toLowerCase()
                                    .contains(_query))
                            .toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person_search_rounded,
                                size: 64, color: AppColors.textHint),
                            const SizedBox(height: 12),
                            Text(
                              _query.isEmpty
                                  ? 'No parent accounts yet.\nCreate parent accounts first.'
                                  : 'No parents match "$_query".',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.body,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final parent = filtered[i];
                        final isLinked = linkedIds.contains(parent.uid);
                        return _ParentLinkTile(
                          parent: parent,
                          isLinked: isLinked,
                          onToggle: () async {
                            if (isLinked) {
                              await ref
                                  .read(linkParentProvider.notifier)
                                  .unlink(
                                    childId: widget.childId,
                                    parentUid: parent.uid,
                                  );
                            } else {
                              await ref
                                  .read(linkParentProvider.notifier)
                                  .link(
                                    childId: widget.childId,
                                    parentUid: parent.uid,
                                    crecheId: child.crecheId,
                                  );
                            }
                            final linkState =
                                ref.read(linkParentProvider);
                            if (linkState.error != null &&
                                context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(linkState.error!),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          },
                        )
                            .animate(delay: (i * 40).ms)
                            .fadeIn(duration: 350.ms)
                            .slideX(begin: 0.15);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ParentLinkTile extends StatelessWidget {
  final UserModel parent;
  final bool isLinked;
  final VoidCallback onToggle;

  const _ParentLinkTile({
    required this.parent,
    required this.isLinked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: isLinked
                ? AppColors.parent.withAlpha(26)
                : AppColors.surfaceVariant,
            child: Text(
              Formatter.initials(parent.displayName),
              style: AppTextStyles.titleMedium.copyWith(
                color: isLinked ? AppColors.parent : AppColors.textHint,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(parent.displayName, style: AppTextStyles.bodyMedium),
                Text(parent.email, style: AppTextStyles.caption),
                if (parent.phoneNumber != null &&
                    parent.phoneNumber!.isNotEmpty)
                  Text(
                    Formatter.phone(parent.phoneNumber!),
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              gradient: isLinked ? AppColors.parentGradient : null,
              color: isLinked ? null : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  child: Text(
                    isLinked ? 'Unlink' : 'Link',
                    style: AppTextStyles.label.copyWith(
                      color: isLinked
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
