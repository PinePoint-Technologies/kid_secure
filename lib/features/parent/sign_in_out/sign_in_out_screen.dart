import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatter.dart';
import '../../../shared/models/attendance_model.dart';
import '../../../shared/models/child_model.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/guardian_pin_dialog.dart';
import '../../../shared/widgets/kid_avatar.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/parent_provider.dart';

class SignInOutScreen extends ConsumerStatefulWidget {
  const SignInOutScreen({super.key});

  @override
  ConsumerState<SignInOutScreen> createState() => _SignInOutScreenState();
}

class _SignInOutScreenState extends ConsumerState<SignInOutScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MobileScannerController _scannerCtrl = MobileScannerController();
  bool _scannerActive = false;
  ChildModel? _selectedChild;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scannerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final childrenAsync = ref.watch(parentChildrenProvider);
    final signState = ref.watch(signInOutProvider);
    final user = ref.watch(currentUserProvider).valueOrNull;

    ref.listen(signInOutProvider, (_, next) {
      if (next.isSuccess && next.message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message!),
            backgroundColor: AppColors.success,
          ),
        );
        ref.read(signInOutProvider.notifier).reset();
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(signInOutProvider.notifier).reset();
      }
    });

    ref.listen(guardianSignInOutProvider, (_, next) {
      if (next.isSuccess && next.message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message!),
            backgroundColor: AppColors.success,
          ),
        );
        ref.read(guardianSignInOutProvider.notifier).reset();
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(guardianSignInOutProvider.notifier).reset();
      }
    });

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.touch_app_rounded), text: 'Manual'),
            Tab(icon: Icon(Icons.qr_code_scanner_rounded), text: 'QR Scan'),
            Tab(icon: Icon(Icons.badge_rounded), text: 'Guardian'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // ─── Manual Tab ────────────────────────────────────────────
              childrenAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (children) => SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select Child', style: AppTextStyles.title)
                          .animate()
                          .fadeIn(duration: 400.ms),
                      const SizedBox(height: 12),
                      ...children.asMap().entries.map((e) {
                        final child = e.value;
                        final isSelected = _selectedChild?.id == child.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedChild = child),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                color: isSelected
                                    ? AppColors.primary.withAlpha(13)
                                    : null,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    KidAvatar(
                                      photoUrl: child.photoUrl,
                                      initials: child.initials,
                                      size: 48,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(child.fullName,
                                              style:
                                                  AppTextStyles.titleMedium),
                                          Text(
                                              'Age: ${Formatter.age(child.dateOfBirth)}',
                                              style: AppTextStyles.bodySmall),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(Icons.check_circle_rounded,
                                          color: AppColors.primary),
                                  ],
                                ),
                              ),
                            ),
                          ).animate(delay: (e.key * 60).ms).fadeIn(
                              duration: 400.ms),
                        );
                      }),
                      if (_selectedChild != null) ...[
                        const SizedBox(height: 16),
                        _AttendanceActions(
                          child: _selectedChild!,
                          isLoading: signState.isLoading,
                          user: user,
                        ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                      ],
                    ],
                  ),
                ),
              ),

              // ─── QR Tab ────────────────────────────────────────────────
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Scan a child\'s QR code to sign in or out',
                      style: AppTextStyles.body,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        MobileScanner(
                          controller: _scannerCtrl,
                          onDetect: (capture) {
                            if (_scannerActive) return;
                            final barcode = capture.barcodes.firstOrNull;
                            if (barcode?.rawValue != null) {
                              _onQRDetected(
                                  barcode!.rawValue!, childrenAsync.valueOrNull ?? []);
                            }
                          },
                        ),
                        // Overlay
                        Center(
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.primary,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.filled(
                          onPressed: () => _scannerCtrl.toggleTorch(),
                          icon: const Icon(Icons.flashlight_on_rounded),
                        ),
                        const SizedBox(width: 16),
                        IconButton.filled(
                          onPressed: () => _scannerCtrl.switchCamera(),
                          icon: const Icon(Icons.flip_camera_ios_rounded),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ─── Guardian Tab ──────────────────────────────────────────
              _GuardianTab(
                childrenAsync: childrenAsync,
                guardianSignState: ref.watch(guardianSignInOutProvider),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onQRDetected(String qrCode, List<ChildModel> children) {
    setState(() => _scannerActive = true);
    final child = children.cast<ChildModel?>().firstWhere(
          (c) => c?.qrCode == qrCode,
          orElse: () => null,
        );
    if (child == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR code not recognised.'),
          backgroundColor: AppColors.error,
        ),
      );
      Future.delayed(const Duration(seconds: 2),
          () => setState(() => _scannerActive = false));
      return;
    }
    setState(() => _selectedChild = child);
    _tabController.animateTo(0);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${child.fullName} identified! Tap sign in/out below.'),
        backgroundColor: AppColors.success,
      ),
    );
    Future.delayed(const Duration(seconds: 2),
        () => setState(() => _scannerActive = false));
  }
}

class _AttendanceActions extends ConsumerWidget {
  final ChildModel child;
  final bool isLoading;
  final dynamic user;

  const _AttendanceActions({
    required this.child,
    required this.isLoading,
    this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(childAttendanceProvider(child.id));

    return attendanceAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e', style: AppTextStyles.bodySmall),
      data: (record) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${child.firstName}\'s Status', style: AppTextStyles.title),
            const SizedBox(height: 10),
            if (record != null) ...[
              StatusChip(status: record.status),
              if (record.signInTime != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Signed in at ${Formatter.time(record.signInTime!)}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ] else
              Text('Not yet signed in today', style: AppTextStyles.bodySmall),
            const SizedBox(height: 16),
            if (record == null ||
                record.status == AttendanceStatus.signedOut ||
                record.status == AttendanceStatus.absent)
              GradientButton(
                label: 'Sign In',
                onPressed: () async {
                  await ref.read(signInOutProvider.notifier).signIn(
                        childId: child.id,
                        crecheId: child.crecheId,
                        byUid: user?.uid ?? '',
                        byName: user?.displayName ?? 'Parent',
                      );
                },
                isLoading: isLoading,
                gradient: AppColors.parentGradient,
                icon: Icons.login_rounded,
              )
            else if (record.status == AttendanceStatus.signedIn)
              GradientButton(
                label: 'Sign Out',
                onPressed: () async {
                  await ref.read(signInOutProvider.notifier).signOut(
                        recordId: record.id,
                        byUid: user?.uid ?? '',
                        byName: user?.displayName ?? 'Parent',
                      );
                },
                isLoading: isLoading,
                gradient: const LinearGradient(
                    colors: [AppColors.error, AppColors.warning]),
                icon: Icons.logout_rounded,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Guardian Tab ─────────────────────────────────────────────────────────────
class _GuardianTab extends ConsumerStatefulWidget {
  final AsyncValue<List<ChildModel>> childrenAsync;
  final SignInOutState guardianSignState;

  const _GuardianTab({
    required this.childrenAsync,
    required this.guardianSignState,
  });

  @override
  ConsumerState<_GuardianTab> createState() => _GuardianTabState();
}

class _GuardianTabState extends ConsumerState<_GuardianTab> {
  ChildModel? _selectedChild;

  @override
  Widget build(BuildContext context) {
    return widget.childrenAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (children) => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Child', style: AppTextStyles.title)
                .animate()
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 12),
            ...children.asMap().entries.map((e) {
              final child = e.value;
              final isSelected = _selectedChild?.id == child.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedChild = child),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      color: isSelected
                          ? AppColors.primary.withAlpha(13)
                          : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          KidAvatar(
                            photoUrl: child.photoUrl,
                            initials: child.initials,
                            size: 48,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(child.fullName,
                                    style: AppTextStyles.titleMedium),
                                Text(
                                    'Age: ${Formatter.age(child.dateOfBirth)}',
                                    style: AppTextStyles.bodySmall),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                ).animate(delay: (e.key * 60).ms).fadeIn(duration: 400.ms),
              );
            }),
            if (_selectedChild != null) ...[
              const SizedBox(height: 20),
              Text('Guardians', style: AppTextStyles.title)
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: 12),
              _GuardianActionList(
                child: _selectedChild!,
                isLoading: widget.guardianSignState.isLoading,
              ).animate(delay: 250.ms).fadeIn(duration: 400.ms),
            ],
          ],
        ),
      ),
    );
  }
}

class _GuardianActionList extends ConsumerWidget {
  final ChildModel child;
  final bool isLoading;

  const _GuardianActionList({required this.child, required this.isLoading});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guardiansAsync = ref.watch(childGuardiansProvider(child.id));
    final attendanceAsync = ref.watch(childAttendanceProvider(child.id));

    return guardiansAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
      data: (guardians) {
        if (guardians.isEmpty) {
          return AppCard(
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.textHint),
                const SizedBox(width: 10),
                Text('No guardians added yet',
                    style: AppTextStyles.bodyMedium),
              ],
            ),
          );
        }
        final record = attendanceAsync.valueOrNull;
        return Column(
          children: guardians.asMap().entries.map((e) {
            final g = e.value;
            final canAct = g.canSignIn || g.canSignOut;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              AppColors.accent.withAlpha(26),
                          child: Text(
                            g.fullName.isNotEmpty
                                ? g.fullName[0].toUpperCase()
                                : '?',
                            style: AppTextStyles.titleMedium
                                .copyWith(color: AppColors.accent),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(g.fullName,
                                  style: AppTextStyles.bodyMedium),
                              Text(g.relationship.displayName,
                                  style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                        if (!canAct)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.textHint.withAlpha(26),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('No permission',
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.textHint)),
                          ),
                      ],
                    ),
                    if (canAct) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (g.canSignIn &&
                              (record == null ||
                                  record.status ==
                                      AttendanceStatus.signedOut ||
                                  record.status ==
                                      AttendanceStatus.absent))
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: isLoading
                                    ? null
                                    : () async {
                                        final pin =
                                            await showGuardianPinDialog(
                                          context,
                                          guardian: g,
                                          childName: child.firstName,
                                          isSignIn: true,
                                        );
                                        if (pin != null && context.mounted) {
                                          await ref
                                              .read(guardianSignInOutProvider
                                                  .notifier)
                                              .signIn(
                                                childId: child.id,
                                                crecheId: child.crecheId,
                                                guardian: g,
                                                enteredPin: pin,
                                              );
                                        }
                                      },
                                icon: const Icon(Icons.login_rounded,
                                    size: 16),
                                label: const Text('Sign In'),
                                style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.success),
                              ),
                            ),
                          if (g.canSignIn && g.canSignOut &&
                              record?.status == AttendanceStatus.signedIn)
                            const SizedBox(width: 8),
                          if (g.canSignOut &&
                              record?.status == AttendanceStatus.signedIn)
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: isLoading
                                    ? null
                                    : () async {
                                        final pin =
                                            await showGuardianPinDialog(
                                          context,
                                          guardian: g,
                                          childName: child.firstName,
                                          isSignIn: false,
                                        );
                                        if (pin != null && context.mounted) {
                                          await ref
                                              .read(guardianSignInOutProvider
                                                  .notifier)
                                              .signOut(
                                                recordId: record!.id,
                                                guardian: g,
                                                enteredPin: pin,
                                              );
                                        }
                                      },
                                icon: const Icon(Icons.logout_rounded,
                                    size: 16),
                                label: const Text('Sign Out'),
                                style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.error),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ).animate(delay: (e.key * 60).ms).fadeIn(duration: 400.ms),
            );
          }).toList(),
        );
      },
    );
  }
}
