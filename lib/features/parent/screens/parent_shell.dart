import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';

class ParentShell extends ConsumerStatefulWidget {
  final Widget child;
  const ParentShell({super.key, required this.child});

  @override
  ConsumerState<ParentShell> createState() => _ParentShellState();
}

class _ParentShellState extends ConsumerState<ParentShell> {
  int _currentIndex = 0;

  static const _tabRoutes = [
    (AppRoutes.parent, Icons.home_rounded),
    (AppRoutes.parentSignInOut, Icons.login_rounded),
    (AppRoutes.parentGuardians, Icons.people_rounded),
    (AppRoutes.parentSickLeave, Icons.local_hospital_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider).valueOrNull;
    final tabLabels = [l10n.navHome, l10n.navSignInOut, l10n.navGuardians, l10n.navSickLeave];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo2.png', width: 32, height: 32),
            const SizedBox(width: 10),
            Text(l10n.appName),
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
          context.go(_tabRoutes[i].$1);
        },
        destinations: List.generate(
          _tabRoutes.length,
          (i) => NavigationDestination(
            icon: Icon(_tabRoutes[i].$2),
            label: tabLabels[i],
          ),
        ),
      ),
    );
  }
}
