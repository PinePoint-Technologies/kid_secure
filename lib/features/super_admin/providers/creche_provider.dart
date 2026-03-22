import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../shared/models/creche_model.dart';
import '../../../shared/models/user_model.dart';
import 'super_admin_provider.dart';

// ─── Creche teachers (derived reactively) ────────────────────────────────────

final crecheTeachersProvider =
    Provider.family<AsyncValue<List<UserModel>>, String>((ref, crecheId) {
  final crechesAsync = ref.watch(allCrechesProvider);
  final teachersAsync = ref.watch(allTeachersProvider);

  if (crechesAsync.isLoading || teachersAsync.isLoading) {
    return const AsyncValue.loading();
  }
  if (crechesAsync.hasError) {
    return AsyncValue.error(
        crechesAsync.error!, crechesAsync.stackTrace ?? StackTrace.current);
  }
  if (teachersAsync.hasError) {
    return AsyncValue.error(
        teachersAsync.error!, teachersAsync.stackTrace ?? StackTrace.current);
  }

  final creche = crechesAsync.value!.cast<CrecheModel?>().firstWhere(
        (c) => c?.id == crecheId,
        orElse: () => null,
      );
  if (creche == null) return const AsyncValue.data([]);

  final assigned = teachersAsync.value!
      .where((t) => creche.teacherIds.contains(t.uid))
      .toList();
  return AsyncValue.data(assigned);
});

// ─── Creche Form Notifier ─────────────────────────────────────────────────────

class CrecheFormState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const CrecheFormState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  CrecheFormState copyWith({bool? isLoading, String? error, bool? isSuccess}) =>
      CrecheFormState(
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
        isSuccess: isSuccess ?? this.isSuccess,
      );
}

class CrecheFormNotifier extends Notifier<CrecheFormState> {
  @override
  CrecheFormState build() => const CrecheFormState();

  FirestoreService get _service => ref.read(firestoreServiceProvider);

  Future<void> save(CrecheModel creche, {String? existingId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (existingId != null) {
        final data = creche.toFirestore()..remove('teacherIds');
        await _service.updateCreche(existingId, data);
      } else {
        await _service.createCreche(creche);
      }
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Failed to save creche. Please try again.');
    }
  }

  Future<void> assignTeacher(String crecheId, String teacherUid) async {
    try {
      await _service.addTeacherToCreche(crecheId, teacherUid);
      await _service.updateUser(teacherUid, {
        'crecheIds': [crecheId],
      });
    } catch (e) {
      state = state.copyWith(error: 'Failed to assign teacher.');
    }
  }

  Future<void> removeTeacher(String crecheId, String teacherUid) async {
    try {
      await _service.removeTeacherFromCreche(crecheId, teacherUid);
      await _service.updateUser(teacherUid, {'crecheIds': []});
    } catch (e) {
      state = state.copyWith(error: 'Failed to remove teacher.');
    }
  }

  Future<void> deactivateCreche(String id) async {
    try {
      await _service.deactivateCreche(id);
    } catch (e) {
      state = state.copyWith(error: 'Failed to deactivate crèche.');
    }
  }

  Future<void> deactivateUser(String uid) async {
    try {
      await _service.deactivateUser(uid);
    } catch (e) {
      state = state.copyWith(error: 'Failed to deactivate user.');
    }
  }

  Future<void> deactivateChild(String id) async {
    try {
      await _service.deactivateChild(id);
    } catch (e) {
      state = state.copyWith(error: 'Failed to deactivate child.');
    }
  }
}

final crecheFormProvider =
    NotifierProvider<CrecheFormNotifier, CrecheFormState>(
  CrecheFormNotifier.new,
);
