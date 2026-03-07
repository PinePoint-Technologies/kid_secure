import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/invite_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/invite_link_dialog.dart';
import '../../../core/utils/formatter.dart';
import '../providers/super_admin_provider.dart';


class TeacherAssignmentScreen extends ConsumerStatefulWidget {
  final String crecheId;
  const TeacherAssignmentScreen({super.key, required this.crecheId});

  @override
  ConsumerState<TeacherAssignmentScreen> createState() =>
      _TeacherAssignmentScreenState();
}

class _TeacherAssignmentScreenState
    extends ConsumerState<TeacherAssignmentScreen> {
  bool _showAll = false;

  Future<void> _showTeacherOptions(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.teacherGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.link_rounded,
                    color: Colors.white, size: 20),
              ),
              title: const Text('Invite via Link'),
              subtitle:
                  const Text('Generate a secure invite link for a teacher'),
              onTap: () async {
                Navigator.pop(context);
                await _generateTeacherInvite(context);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person_add_rounded,
                    color: AppColors.textSecondary, size: 20),
              ),
              title: const Text('Create Manually'),
              subtitle: const Text('Create a teacher account directly'),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRoutes.superAdminAddTeacherPath(widget.crecheId));
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _generateTeacherInvite(BuildContext context) async {
    try {
      final deepLink = await ref
          .read(inviteServiceProvider)
          .generateInvite(role: 'teacher', crecheId: widget.crecheId);
      if (context.mounted) {
        await showInviteLinkSheet(context, deepLink: deepLink, role: 'teacher');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate invite: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _generateParentInvite(BuildContext context) async {
    try {
      final deepLink = await ref
          .read(inviteServiceProvider)
          .generateInvite(role: 'parent', crecheId: widget.crecheId);
      if (context.mounted) {
        await showInviteLinkSheet(context, deepLink: deepLink, role: 'parent');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate invite: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allTeachersAsync = ref.watch(allTeachersProvider);
    final crecheTeachersAsync =
        ref.watch(crecheTeachersProvider(widget.crecheId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Teachers'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.superAdminCreches),
        ),
        actions: [
          IconButton(
            tooltip: 'Invite Parent to this Crèche',
            icon: const Icon(Icons.family_restroom_rounded),
            onPressed: () => _generateParentInvite(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTeacherOptions(context),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Teacher'),
        backgroundColor: AppColors.teacher,
      ),
      body: allTeachersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (allTeachers) => crecheTeachersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (assignedTeachers) {
            final assignedIds = assignedTeachers.map((t) => t.uid).toSet();

            // Teachers assigned to a different crèche entirely
            final assignedElsewhere = allTeachers
                .where((t) =>
                    t.crecheIds.isNotEmpty && !assignedIds.contains(t.uid))
                .toSet();

            // Build the display list
            final List<UserModel> displayList;
            if (_showAll) {
              // Assigned to this crèche first, then unassigned, then elsewhere
              displayList = [
                ...allTeachers.where((t) => assignedIds.contains(t.uid)),
                ...allTeachers.where((t) => t.crecheIds.isEmpty),
                ...allTeachers.where((t) => assignedElsewhere.contains(t)),
              ];
            } else {
              // Only available (unassigned) + already assigned to this crèche
              displayList = allTeachers
                  .where((t) =>
                      assignedIds.contains(t.uid) || t.crecheIds.isEmpty)
                  .toList();
            }

            final availableCount =
                allTeachers.where((t) => t.crecheIds.isEmpty).length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Manage Teachers',
                                style: AppTextStyles.headline2),
                            Text(
                              '${assignedTeachers.length} assigned · $availableCount available',
                              style: AppTextStyles.body,
                            ),
                          ],
                        ),
                      ),
                      if (assignedElsewhere.isNotEmpty)
                        TextButton.icon(
                          onPressed: () =>
                              setState(() => _showAll = !_showAll),
                          icon: Icon(
                            _showAll
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            size: 16,
                          ),
                          label: Text(_showAll ? 'Hide assigned' : 'Show all'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            textStyle: AppTextStyles.caption,
                          ),
                        ),
                    ],
                  ),
                ),
                if (displayList.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_search_rounded,
                              size: 64, color: AppColors.textHint),
                          const SizedBox(height: 12),
                          Text(
                            allTeachers.isEmpty
                                ? 'No teachers found.\nRegister teacher accounts first.'
                                : 'All teachers are already\nassigned to other crèches.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: displayList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final teacher = displayList[i];
                        final isAssigned = assignedIds.contains(teacher.uid);
                        final isAssignedElsewhere =
                            assignedElsewhere.contains(teacher);
                        return _TeacherTile(
                          teacher: teacher,
                          isAssigned: isAssigned,
                          isAssignedElsewhere: isAssignedElsewhere,
                          onToggle: isAssignedElsewhere
                              ? null
                              : () async {
                                  if (isAssigned) {
                                    await ref
                                        .read(crecheFormProvider.notifier)
                                        .removeTeacher(
                                            widget.crecheId, teacher.uid);
                                  } else {
                                    await ref
                                        .read(crecheFormProvider.notifier)
                                        .assignTeacher(
                                            widget.crecheId, teacher.uid);
                                  }
                                },
                        )
                            .animate(delay: (i * 60).ms)
                            .fadeIn(duration: 400.ms)
                            .slideX(begin: 0.2);
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TeacherTile extends StatelessWidget {
  final UserModel teacher;
  final bool isAssigned;
  final bool isAssignedElsewhere;
  final VoidCallback? onToggle;

  const _TeacherTile({
    required this.teacher,
    required this.isAssigned,
    required this.isAssignedElsewhere,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isAssignedElsewhere ? 0.55 : 1.0,
      child: AppCard(
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: isAssigned
                  ? AppColors.teacher.withAlpha(26)
                  : AppColors.surfaceVariant,
              child: Text(
                Formatter.initials(teacher.displayName),
                style: AppTextStyles.titleMedium.copyWith(
                  color: isAssigned ? AppColors.teacher : AppColors.textHint,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(teacher.displayName, style: AppTextStyles.bodyMedium),
                  Text(teacher.email, style: AppTextStyles.caption),
                ],
              ),
            ),
            if (isAssignedElsewhere)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Already Assigned',
                  style:
                      AppTextStyles.label.copyWith(color: AppColors.textHint),
                ),
              )
            else
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  gradient: isAssigned ? AppColors.teacherGradient : null,
                  color: isAssigned ? null : AppColors.surfaceVariant,
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
                        isAssigned ? 'Remove' : 'Assign',
                        style: AppTextStyles.label.copyWith(
                          color: isAssigned
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
      ),
    );
  }
}
