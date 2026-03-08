import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/formatter.dart';
import '../../auth/providers/auth_provider.dart';

class TeacherShell extends ConsumerStatefulWidget {
  final Widget child;
  const TeacherShell({super.key, required this.child});

  @override
  ConsumerState<TeacherShell> createState() => _TeacherShellState();
}

class _TeacherShellState extends ConsumerState<TeacherShell> {
  int _currentIndex = 0;

  static const _tabs = [
    (AppRoutes.teacher, Icons.dashboard_rounded, 'Home'),
    (AppRoutes.teacherKids, Icons.child_care_rounded, 'Kids'),
    (AppRoutes.teacherAttendance, Icons.checklist_rounded, 'Attendance'),
    (AppRoutes.teacherSickLeave, Icons.local_hospital_rounded, 'Sick Leave'),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      appBar: _currentIndex == 0
          ? null
          : AppBar(
              title: Row(
                children: [
                  Image.asset('assets/images/logo2.png', width: 32, height: 32),
                  const SizedBox(width: 10),
                  const Text('KidSecure'),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => context.push(AppRoutes.settings),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: (user?.photoUrl != null &&
                              user!.photoUrl!.isNotEmpty)
                          ? ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: user.photoUrl!,
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Text(
                              user != null
                                  ? Formatter.initials(user.displayName)
                                  : '?',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) {
          setState(() => _currentIndex = i);
          context.go(_tabs[i].$1);
        },
        destinations: _tabs
            .map((t) => NavigationDestination(
                  icon: Icon(t.$2),
                  label: t.$3,
                ))
            .toList(),
      ),
    );
  }
}
