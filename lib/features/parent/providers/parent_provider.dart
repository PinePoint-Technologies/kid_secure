import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../shared/models/attendance_model.dart';
import '../../../shared/models/child_model.dart';
import '../../../shared/models/guardian_model.dart';
import '../../../shared/models/sick_leave_model.dart';
import '../../../shared/services/firestore_service.dart';
import '../../../shared/utils/pin_hasher.dart';
import '../../auth/providers/auth_provider.dart';

// Parent's children
final parentChildrenProvider = StreamProvider<List<ChildModel>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  return ref
      .watch(firestoreServiceProvider)
      .watchChildrenForParent(user.uid);
});

// Guardians for a child
final childGuardiansProvider =
    StreamProvider.family<List<GuardianModel>, String>((ref, childId) {
  return ref
      .watch(firestoreServiceProvider)
      .watchGuardiansForChild(childId);
});

// Today's attendance for a child
final childAttendanceProvider =
    StreamProvider.family<AttendanceRecord?, String>((ref, childId) {
  return ref
      .watch(firestoreServiceProvider)
      .watchTodayAttendance(childId, DateTime.now());
});

// Parent's sick leave history
final parentSickLeaveProvider = StreamProvider<List<SickLeaveModel>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  return ref
      .watch(firestoreServiceProvider)
      .watchSickLeaveForParent(user.uid);
});

// ─── Sign In/Out Notifier ────────────────────────────────────────────────────
class SignInOutState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  final String? message;

  const SignInOutState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
    this.message,
  });

  SignInOutState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
    String? message,
  }) =>
      SignInOutState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        isSuccess: isSuccess ?? this.isSuccess,
        message: message ?? this.message,
      );
}

class SignInOutNotifier extends Notifier<SignInOutState> {
  @override
  SignInOutState build() => const SignInOutState();

  FirestoreService get _service => ref.read(firestoreServiceProvider);

  Future<void> signIn({
    required String childId,
    required String crecheId,
    required String byUid,
    required String byName,
    String method = 'manual',
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final now = DateTime.now();
      final record = AttendanceRecord(
        id: '',
        childId: childId,
        crecheId: crecheId,
        date: now,
        status: AttendanceStatus.signedIn,
        signInTime: now,
        signInByUid: byUid,
        signInByName: byName,
        signInMethod: method,
      );
      await _service.createAttendanceRecord(record);
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        message: 'Signed in successfully at ${_formatTime(now)}',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Sign-in failed.');
    }
  }

  Future<void> signOut({
    required String recordId,
    required String byUid,
    required String byName,
    String method = 'manual',
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final now = DateTime.now();
      await _service.updateAttendanceRecord(recordId, {
        'status': AttendanceStatus.signedOut.value,
        'signOutTime': Timestamp.fromDate(now),
        'signOutByUid': byUid,
        'signOutByName': byName,
        'signOutMethod': method,
      });
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        message: 'Signed out at ${_formatTime(now)}',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Sign-out failed.');
    }
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  void reset() => state = const SignInOutState();
}

final signInOutProvider = NotifierProvider<SignInOutNotifier, SignInOutState>(
  SignInOutNotifier.new,
);

// ─── Guardian Notifier ───────────────────────────────────────────────────────
class GuardianFormState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  const GuardianFormState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });
  GuardianFormState copyWith({bool? isLoading, String? error, bool? isSuccess}) =>
      GuardianFormState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        isSuccess: isSuccess ?? this.isSuccess,
      );
}

class GuardianFormNotifier extends Notifier<GuardianFormState> {
  @override
  GuardianFormState build() => const GuardianFormState();

  FirestoreService get _service => ref.read(firestoreServiceProvider);

  Future<void> addGuardian(GuardianModel guardian) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.createGuardian(guardian);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Failed to add guardian.');
    }
  }

  Future<void> removeGuardian(String guardianId, String childId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.deactivateGuardian(guardianId, childId);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Failed to remove guardian.');
    }
  }
}

final guardianFormProvider =
    NotifierProvider<GuardianFormNotifier, GuardianFormState>(
  GuardianFormNotifier.new,
);

// ─── Guardian Sign In/Out Notifier ───────────────────────────────────────────
class GuardianSignInOutNotifier extends Notifier<SignInOutState> {
  @override
  SignInOutState build() => const SignInOutState();

  FirestoreService get _service => ref.read(firestoreServiceProvider);

  Future<void> signIn({
    required String childId,
    required String crecheId,
    required GuardianModel guardian,
    required String enteredPin,
  }) async {
    if (guardian.pin == null || !PinHasher.verify(enteredPin, guardian.pin!)) {
      state = state.copyWith(error: 'Incorrect PIN. Please try again.');
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
      final record = AttendanceRecord(
        id: '',
        childId: childId,
        crecheId: crecheId,
        date: now,
        status: AttendanceStatus.signedIn,
        signInTime: now,
        signInByUid: guardian.id,
        signInByName: guardian.fullName,
        signInMethod: 'pin',
      );
      await _service.createAttendanceRecord(record);
      await _service.updateGuardian(guardian.id,
          {'lastUsed': FieldValue.serverTimestamp()});
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        message:
            'Signed in by ${guardian.fullName} at ${_fmt(now)}',
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Sign-in failed.');
    }
  }

  Future<void> signOut({
    required String recordId,
    required GuardianModel guardian,
    required String enteredPin,
  }) async {
    if (guardian.pin == null || !PinHasher.verify(enteredPin, guardian.pin!)) {
      state = state.copyWith(error: 'Incorrect PIN. Please try again.');
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
      await _service.updateGuardian(guardian.id,
          {'lastUsed': FieldValue.serverTimestamp()});
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        message: 'Signed out by ${guardian.fullName} at ${_fmt(now)}',
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Sign-out failed.');
    }
  }

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  void reset() => state = const SignInOutState();
}

final guardianSignInOutProvider =
    NotifierProvider<GuardianSignInOutNotifier, SignInOutState>(
  GuardianSignInOutNotifier.new,
);

// ─── Sick Leave Notifier ─────────────────────────────────────────────────────
class SickLeaveFormState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  const SickLeaveFormState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });
  SickLeaveFormState copyWith(
          {bool? isLoading, String? error, bool? isSuccess}) =>
      SickLeaveFormState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        isSuccess: isSuccess ?? this.isSuccess,
      );
}

class SickLeaveFormNotifier extends Notifier<SickLeaveFormState> {
  @override
  SickLeaveFormState build() => const SickLeaveFormState();

  FirestoreService get _service => ref.read(firestoreServiceProvider);

  Future<void> logSickLeave(SickLeaveModel leave) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.createSickLeave(leave);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Failed to log sick leave.');
    }
  }
}

final sickLeaveFormProvider =
    NotifierProvider<SickLeaveFormNotifier, SickLeaveFormState>(
  SickLeaveFormNotifier.new,
);
