import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/formatter.dart';
import '../../auth/providers/auth_provider.dart';

class SuperAdminShell extends ConsumerWidget {
  final Widget child;
  const SuperAdminShell({super.key, required this.child});

  static const _tabs = [
    (route: AppRoutes.superAdmin, icon: Icons.dashboard_rounded, label: 'Dashboard'),
    (route: AppRoutes.superAdminCreches, icon: Icons.school_rounded, label: 'Crèches'),
    (route: AppRoutes.superAdminParents, icon: Icons.family_restroom_rounded, label: 'Parents'),
    (route: AppRoutes.superAdminKids, icon: Icons.child_care_rounded, label: 'Kids'),
    (route: AppRoutes.superAdminReports, icon: Icons.bar_chart_rounded, label: 'Reports'),
  ];

  int _tabIndex(String location) {
    if (location.startsWith(AppRoutes.superAdminReports)) return 4;
    if (location.startsWith(AppRoutes.superAdminKids)) return 3;
    if (location.startsWith(AppRoutes.superAdminParents)) return 2;
    if (location.startsWith(AppRoutes.superAdminCreches)) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final location = GoRouterState.of(context).uri.toString();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', width: 32, height: 32),
            const SizedBox(width: 10),
            const Text('KidSecure Admin'),
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
                child: (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
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
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex(location),
        onDestinationSelected: (i) => context.go(_tabs[i].route),
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}
