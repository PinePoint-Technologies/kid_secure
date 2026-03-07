import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../shared/models/child_model.dart';
import '../../../shared/models/attendance_model.dart';
import '../../../shared/models/sick_leave_model.dart';
import '../../../shared/services/firestore_service.dart';
import '../../auth/providers/auth_provider.dart';

// The teacher's current creche id (first assigned creche, or own UID as fallback)
final teacherCrecheIdProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return null;
  return user.crecheIds.isNotEmpty ? user.crecheIds.first : user.uid;
});

// Children for teacher's creche
final teacherChildrenProvider = StreamProvider<List<ChildModel>>((ref) {
  final crecheId = ref.watch(teacherCrecheIdProvider);
  if (crecheId == null) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).watchChildrenForCreche(crecheId);
});

// Today's attendance for creche
final todayAttendanceProvider =
    StreamProvider<List<AttendanceRecord>>((ref) {
  final crecheId = ref.watch(teacherCrecheIdProvider);
  if (crecheId == null) return Stream.value([]);
  return ref
      .watch(firestoreServiceProvider)
      .watchAttendanceForCreche(crecheId, DateTime.now());
});

// Pending sick leave for creche
final pendingSickLeaveProvider =
    StreamProvider<List<SickLeaveModel>>((ref) {
  final crecheId = ref.watch(teacherCrecheIdProvider);
  if (crecheId == null) return Stream.value([]);
  return ref
      .watch(firestoreServiceProvider)
      .watchSickLeaveForCreche(crecheId);
});

// All sick leave (pending + approved) for creche
final teacherSickLeaveProvider =
    StreamProvider<List<SickLeaveModel>>((ref) {
  final crecheId = ref.watch(teacherCrecheIdProvider);
  if (crecheId == null) return Stream.value([]);
  return ref
      .watch(firestoreServiceProvider)
      .watchAllSickLeaveForCreche(crecheId);
});

// ─── Child management ────────────────────────────────────────────────────────
class ChildFormState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  const ChildFormState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });
  ChildFormState copyWith({bool? isLoading, String? error, bool? isSuccess}) =>
      ChildFormState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        isSuccess: isSuccess ?? this.isSuccess,
      );
}

class ChildFormNotifier extends Notifier<ChildFormState> {
  @override
  ChildFormState build() => const ChildFormState();

  FirestoreService get _service => ref.read(firestoreServiceProvider);

  Future<void> saveChild(ChildModel child) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.createChild(child);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Failed to save child. Please try again.');
    }
  }

  Future<void> updateChild(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.updateChild(id, data);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Update failed.');
    }
  }

  Future<void> approveSickLeave(
      String sickLeaveId, SickLeaveModel leave, String teacherUid) async {
    try {
      await _service.updateSickLeave(sickLeaveId, {
        'status': 'approved',
        'approvedByUid': teacherUid,
      });
      await _service.createSickLeaveAttendanceRecords(leave);
    } catch (e) {
      state = state.copyWith(error: 'Failed to approve sick leave.');
    }
  }
}

final childFormProvider =
    NotifierProvider<ChildFormNotifier, ChildFormState>(
  ChildFormNotifier.new,
);
