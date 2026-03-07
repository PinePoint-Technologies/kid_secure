import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/attendance_model.dart';
import '../../../shared/models/child_model.dart';
import '../../../shared/models/guardian_model.dart';
import '../../../shared/services/firestore_service.dart';
import '../../../shared/utils/pin_hasher.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/guardian_pin_dialog.dart';
import '../../parent/providers/parent_provider.dart';
import '../providers/teacher_provider.dart';

// ─── Teacher-side guardian sign-in/out state ─────────────────────────────────
class _TeacherGuardianState {
  final bool isLoading;
  final String? error;
  final String? message;
  const _TeacherGuardianState(
      {this.isLoading = false, this.error, this.message});
  _TeacherGuardianState copyWith(
          {bool? isLoading, String? error, String? message}) =>
      _TeacherGuardianState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        message: message,
      );
}

class _TeacherGuardianNotifier
    extends StateNotifier<_TeacherGuardianState> {
  _TeacherGuardianNotifier(this._service) : super(const _TeacherGuardianState());

  final FirestoreService _service;

  Future<void> signIn({
    required String childId,
    required String crecheId,
    required GuardianModel guardian,
    required String enteredPin,
  }) async {
    if (guardian.pin == null ||
        !PinHasher.verify(enteredPin, guardian.pin!)) {
      state = state.copyWith(error: 'Incorrect PIN.');
      return;
    }
    if (!guardian.canSignIn) {
      state = state.copyWith(
          error: '${guardian.fullName} does not have sign-in permission.');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final now = DateTime.now();
      await _service.createAttendanceRecord(AttendanceRecord(
        id: '',
        childId: childId,
        crecheId: crecheId,
        date: now,
        status: AttendanceStatus.signedIn,
        signInTime: now,
        signInByUid: guardian.id,
        signInByName: guardian.fullName,
        signInMethod: 'pin',
      ));
      await _service.updateGuardian(
          guardian.id, {'lastUsed': FieldValue.serverTimestamp()});
      state = state.copyWith(
          isLoading: false,
          message:
              '${guardian.fullName} signed in the child at ${_fmt(now)}');
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Sign-in failed.');
    }
  }

  Future<void> signInByQr({
    required String childId,
    required String crecheId,
    required GuardianModel guardian,
  }) async {
    if (!guardian.canSignIn) {
      state = state.copyWith(
          error: '${guardian.fullName} does not have sign-in permission.');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final now = DateTime.now();
      await _service.createAttendanceRecord(AttendanceRecord(
        id: '',
        childId: childId,
        crecheId: crecheId,
        date: now,
        status: AttendanceStatus.signedIn,
        signInTime: now,
        signInByUid: guardian.id,
        signInByName: guardian.fullName,
        signInMethod: 'qr',
      ));
      await _service.updateGuardian(
          guardian.id, {'lastUsed': FieldValue.serverTimestamp()});
      state = state.copyWith(
          isLoading: false,
          message:
              '${guardian.fullName} signed in the child (QR) at ${_fmt(now)}');
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Sign-in failed.');
    }
  }

  Future<void> signOut({
    required String recordId,
    required GuardianModel guardian,
    required String enteredPin,
  }) async {
    if (guardian.pin == null ||
        !PinHasher.verify(enteredPin, guardian.pin!)) {
      state = state.copyWith(error: 'Incorrect PIN.');
      return;
    }
    if (!guardian.canSignOut) {
      state = state.copyWith(
          error: '${guardian.fullName} does not have sign-out permission.');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final now = DateTime.now();
      await _service.updateAttendanceRecord(recordId, {
        'status': AttendanceStatus.signedOut.value,
        'signOutTime': Timestamp.fromDate(now),
        'signOutByUid': guardian.id,
        'signOutByName': guardian.fullName,
        'signOutMethod': 'pin',
      });
      await _service.updateGuardian(
          guardian.id, {'lastUsed': FieldValue.serverTimestamp()});
      state = state.copyWith(
          isLoading: false,
          message:
              '${guardian.fullName} signed out the child at ${_fmt(now)}');
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Sign-out failed.');
    }
  }

  Future<void> signOutByQr({
    required String recordId,
    required GuardianModel guardian,
  }) async {
    if (!guardian.canSignOut) {
      state = state.copyWith(
          error: '${guardian.fullName} does not have sign-out permission.');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final now = DateTime.now();
      await _service.updateAttendanceRecord(recordId, {
        'status': AttendanceStatus.signedOut.value,
        'signOutTime': Timestamp.fromDate(now),
        'signOutByUid': guardian.id,
        'signOutByName': guardian.fullName,
        'signOutMethod': 'qr',
      });
      await _service.updateGuardian(
          guardian.id, {'lastUsed': FieldValue.serverTimestamp()});
      state = state.copyWith(
          isLoading: false,
          message:
              '${guardian.fullName} signed out the child (QR) at ${_fmt(now)}');
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Sign-out failed.');
    }
  }

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  void reset() => state = const _TeacherGuardianState();
}

final _teacherGuardianProvider = StateNotifierProvider<
    _TeacherGuardianNotifier, _TeacherGuardianState>((ref) {
  return _TeacherGuardianNotifier(ref.read(firestoreServiceProvider));
});

// ─── Screen ──────────────────────────────────────────────────────────────────
class TeacherGuardianCheckinScreen extends ConsumerStatefulWidget {
  const TeacherGuardianCheckinScreen({super.key});

  @override
  ConsumerState<TeacherGuardianCheckinScreen> createState() =>
      _TeacherGuardianCheckinScreenState();
}

class _TeacherGuardianCheckinScreenState
    extends ConsumerState<TeacherGuardianCheckinScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(_teacherGuardianProvider, (_, next) {
      if (next.message != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.message!),
          backgroundColor: AppColors.success,
        ));
        ref.read(_teacherGuardianProvider.notifier).reset();
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.error!),
          backgroundColor: AppColors.error,
        ));
        ref.read(_teacherGuardianProvider.notifier).reset();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guardian Check-In'),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(icon: Icon(Icons.pin_rounded), text: 'By PIN'),
            Tab(icon: Icon(Icons.qr_code_scanner_rounded), text: 'By QR'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _ByPinTab(),
          _ByQrTab(),
        ],
      ),
    );
  }
}

// ─── By PIN tab ───────────────────────────────────────────────────────────────
class _ByPinTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ByPinTab> createState() => _ByPinTabState();
}

class _ByPinTabState extends ConsumerState<_ByPinTab> {
  ChildModel? _selectedChild;

  @override
  Widget build(BuildContext context) {
    final childrenAsync = ref.watch(teacherChildrenProvider);
    final notifierState = ref.watch(_teacherGuardianProvider);

    return childrenAsync.when(
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
            DropdownButtonFormField<String>(
              initialValue: _selectedChild?.id,
              hint: const Text('Choose a child'),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.child_care_rounded),
              ),
              items: children
                  .map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.fullName),
                      ))
                  .toList(),
              onChanged: (id) => setState(() {
                _selectedChild =
                    children.firstWhere((c) => c.id == id);
              }),
            ),
            if (_selectedChild != null) ...[
              const SizedBox(height: 24),
              Text('Guardians', style: AppTextStyles.title)
                  .animate(delay: 100.ms)
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: 12),
              _GuardianPinList(
                child: _selectedChild!,
                isLoading: notifierState.isLoading,
              ).animate(delay: 150.ms).fadeIn(duration: 400.ms),
            ],
          ],
        ),
      ),
    );
  }
}

class _GuardianPinList extends ConsumerWidget {
  final ChildModel child;
  final bool isLoading;

  const _GuardianPinList({required this.child, required this.isLoading});

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
            child: Text('No guardians for this child.',
                style: AppTextStyles.bodyMedium),
          );
        }
        final record = attendanceAsync.valueOrNull;
        return Column(
          children: guardians.asMap().entries.map((e) {
            final g = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _GuardianActionCard(
                guardian: g,
                child: child,
                record: record,
                isLoading: isLoading,
              ).animate(delay: (e.key * 60).ms).fadeIn(duration: 400.ms),
            );
          }).toList(),
        );
      },
    );
  }
}

class _GuardianActionCard extends ConsumerWidget {
  final GuardianModel guardian;
  final ChildModel child;
  final AttendanceRecord? record;
  final bool isLoading;

  const _GuardianActionCard({
    required this.guardian,
    required this.child,
    required this.record,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(_teacherGuardianProvider.notifier);
    final canSignIn = guardian.canSignIn &&
        (record == null ||
            record!.status == AttendanceStatus.signedOut ||
            record!.status == AttendanceStatus.absent);
    final canSignOut = guardian.canSignOut &&
        record?.status == AttendanceStatus.signedIn;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.accent.withAlpha(26),
                child: Text(
                  guardian.fullName.isNotEmpty
                      ? guardian.fullName[0].toUpperCase()
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
                    Text(guardian.fullName,
                        style: AppTextStyles.bodyMedium),
                    Text(guardian.relationship.displayName,
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
          if (canSignIn || canSignOut) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (canSignIn)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: isLoading
                          ? null
                          : () async {
                              final pin = await showGuardianPinDialog(
                                context,
                                guardian: guardian,
                                childName: child.firstName,
                                isSignIn: true,
                              );
                              if (pin != null && context.mounted) {
                                await notifier.signIn(
                                  childId: child.id,
                                  crecheId: child.crecheId,
                                  guardian: guardian,
                                  enteredPin: pin,
                                );
                              }
                            },
                      icon: const Icon(Icons.login_rounded, size: 16),
                      label: const Text('Sign In'),
                      style: FilledButton.styleFrom(
                          backgroundColor: AppColors.success),
                    ),
                  ),
                if (canSignIn && canSignOut) const SizedBox(width: 8),
                if (canSignOut)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: isLoading
                          ? null
                          : () async {
                              final pin = await showGuardianPinDialog(
                                context,
                                guardian: guardian,
                                childName: child.firstName,
                                isSignIn: false,
                              );
                              if (pin != null && context.mounted) {
                                await notifier.signOut(
                                  recordId: record!.id,
                                  guardian: guardian,
                                  enteredPin: pin,
                                );
                              }
                            },
                      icon:
                          const Icon(Icons.logout_rounded, size: 16),
                      label: const Text('Sign Out'),
                      style: FilledButton.styleFrom(
                          backgroundColor: AppColors.error),
                    ),
                  ),
              ],
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'No action available',
                style:
                    AppTextStyles.caption.copyWith(color: AppColors.textHint),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── By QR tab ────────────────────────────────────────────────────────────────
class _ByQrTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ByQrTab> createState() => _ByQrTabState();
}

class _ByQrTabState extends ConsumerState<_ByQrTab> {
  final MobileScannerController _scanCtrl = MobileScannerController();
  bool _scanning = false;
  GuardianModel? _scannedGuardian;
  ChildModel? _scannedChild;

  @override
  void dispose() {
    _scanCtrl.dispose();
    super.dispose();
  }

  Future<void> _onQrDetected(String code) async {
    if (_scanning) return;
    setState(() => _scanning = true);

    final service = ref.read(firestoreServiceProvider);
    final guardian = await service.getGuardianByQrCode(code);
    if (guardian == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Guardian QR not recognised.'),
          backgroundColor: AppColors.error,
        ));
      }
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _scanning = false);
      return;
    }

    // Load the child linked to this guardian
    final childSnap = await service.watchChildById(guardian.childId).first;
    if (mounted) {
      setState(() {
        _scannedGuardian = guardian;
        _scannedChild = childSnap;
        _scanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifierState = ref.watch(_teacherGuardianProvider);

    if (_scannedGuardian != null && _scannedChild != null) {
      return _QrConfirmCard(
        guardian: _scannedGuardian!,
        child: _scannedChild!,
        isLoading: notifierState.isLoading,
        onReset: () => setState(() {
          _scannedGuardian = null;
          _scannedChild = null;
        }),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Scan guardian\'s QR code to identify them',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              MobileScanner(
                controller: _scanCtrl,
                onDetect: (capture) {
                  final code = capture.barcodes.firstOrNull?.rawValue;
                  if (code != null) _onQrDetected(code);
                },
              ),
              Center(
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 3),
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
                onPressed: () => _scanCtrl.toggleTorch(),
                icon: const Icon(Icons.flashlight_on_rounded),
              ),
              const SizedBox(width: 16),
              IconButton.filled(
                onPressed: () => _scanCtrl.switchCamera(),
                icon: const Icon(Icons.flip_camera_ios_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QrConfirmCard extends ConsumerWidget {
  final GuardianModel guardian;
  final ChildModel child;
  final bool isLoading;
  final VoidCallback onReset;

  const _QrConfirmCard({
    required this.guardian,
    required this.child,
    required this.isLoading,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(childAttendanceProvider(child.id));
    final notifier = ref.read(_teacherGuardianProvider.notifier);
    final record = attendanceAsync.valueOrNull;

    final canSignIn = guardian.canSignIn &&
        (record == null ||
            record.status == AttendanceStatus.signedOut ||
            record.status == AttendanceStatus.absent);
    final canSignOut =
        guardian.canSignOut && record?.status == AttendanceStatus.signedIn;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Guardian Identified', style: AppTextStyles.headline3)
              .animate()
              .fadeIn(duration: 400.ms),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.accent.withAlpha(26),
                    child: Text(
                      guardian.fullName.isNotEmpty
                          ? guardian.fullName[0].toUpperCase()
                          : '?',
                      style: AppTextStyles.titleMedium
                          .copyWith(color: AppColors.accent),
                    ),
                  ),
                  title: Text(guardian.fullName,
                      style: AppTextStyles.bodyMedium),
                  subtitle: Text(
                      '${guardian.relationship.displayName} of ${child.fullName}',
                      style: AppTextStyles.caption),
                ),
                const Divider(),
                const SizedBox(height: 8),
                if (canSignIn || canSignOut)
                  Row(
                    children: [
                      if (canSignIn)
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    await notifier.signInByQr(
                                      childId: child.id,
                                      crecheId: child.crecheId,
                                      guardian: guardian,
                                    );
                                    onReset();
                                  },
                            icon: const Icon(Icons.login_rounded,
                                size: 16),
                            label: const Text('Sign In'),
                            style: FilledButton.styleFrom(
                                backgroundColor: AppColors.success),
                          ),
                        ),
                      if (canSignIn && canSignOut)
                        const SizedBox(width: 8),
                      if (canSignOut)
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    await notifier.signOutByQr(
                                      recordId: record!.id,
                                      guardian: guardian,
                                    );
                                    onReset();
                                  },
                            icon: const Icon(Icons.logout_rounded,
                                size: 16),
                            label: const Text('Sign Out'),
                            style: FilledButton.styleFrom(
                                backgroundColor: AppColors.error),
                          ),
                        ),
                    ],
                  )
                else
                  Text(
                    'No action available for current status.',
                    style:
                        AppTextStyles.caption.copyWith(color: AppColors.textHint),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label: const Text('Scan Another'),
          ),
        ],
      ),
    );
  }
}
