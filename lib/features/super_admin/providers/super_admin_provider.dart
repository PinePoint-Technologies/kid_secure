import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../shared/models/child_model.dart';
import '../../../shared/models/creche_model.dart';
import '../../../shared/models/guardian_model.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/services/admin_user_service.dart';
import '../../../shared/services/firestore_service.dart';

// ─── Basic entity streams ─────────────────────────────────────────────────────

// All creches stream
final allCrechesProvider = StreamProvider<List<CrecheModel>>(
  (ref) => ref.watch(firestoreServiceProvider).watchAllCreches(),
);

// All teachers stream
final allTeachersProvider = StreamProvider<List<UserModel>>(
  (ref) => ref.watch(firestoreServiceProvider).watchTeachers(),
);

// All children across every crèche
final allChildrenProvider = StreamProvider<List<ChildModel>>(
  (ref) => ref.watch(firestoreServiceProvider).watchAllChildren(),
);

// All parent accounts
final allParentsProvider = StreamProvider<List<UserModel>>(
  (ref) => ref.watch(firestoreServiceProvider).watchAllParents(),
);

// All guardians across every crèche
final allGuardiansProvider = StreamProvider<List<GuardianModel>>(
  (ref) => ref.watch(firestoreServiceProvider).watchAllGuardians(),
);

// ─── Aggregated stats ─────────────────────────────────────────────────────────

class AdminStats {
  final int crecheCount;
  final int teacherCount;
  final int kidCount;
  final int parentCount;
  final int guardianCount;

  const AdminStats({
    required this.crecheCount,
    required this.teacherCount,
    required this.kidCount,
    required this.parentCount,
    required this.guardianCount,
  });
}

/// Derives live counts from the individual stream providers.
final adminStatsProvider = Provider<AsyncValue<AdminStats>>((ref) {
  final creches = ref.watch(allCrechesProvider);
  final teachers = ref.watch(allTeachersProvider);
  final children = ref.watch(allChildrenProvider);
  final parents = ref.watch(allParentsProvider);
  final guardians = ref.watch(allGuardiansProvider);

  if (creches.isLoading ||
      teachers.isLoading ||
      children.isLoading ||
      parents.isLoading ||
      guardians.isLoading) {
    return const AsyncValue.loading();
  }

  final err = creches.error ?? teachers.error ?? children.error ??
      parents.error ?? guardians.error;
  if (err != null) {
    return AsyncValue.error(err, StackTrace.current);
  }

  return AsyncValue.data(AdminStats(
    crecheCount: creches.valueOrNull?.length ?? 0,
    teacherCount: teachers.valueOrNull?.length ?? 0,
    kidCount: children.valueOrNull?.length ?? 0,
    parentCount: parents.valueOrNull?.length ?? 0,
    guardianCount: guardians.valueOrNull?.length ?? 0,
  ));
});

// Creche teachers (filtered by creche teacherIds)
final crecheTeachersProvider =
    StreamProvider.family<List<UserModel>, String>((ref, crecheId) async* {
  final creches = await ref
      .watch(firestoreServiceProvider)
      .watchAllCreches()
      .first;
  final creche = creches.firstWhere((c) => c.id == crecheId,
      orElse: () => CrecheModel(
            id: crecheId,
            name: '',
            address: '',
            createdAt: DateTime.now(),
          ));
  yield* ref
      .watch(firestoreServiceProvider)
      .watchTeachers()
      .map((teachers) =>
          teachers.where((t) => creche.teacherIds.contains(t.uid)).toList());
});

// ─── Creche Form Notifier ────────────────────────────────────────────────────
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
        await _service.updateCreche(existingId, creche.toFirestore());
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
      // Also update teacher's crecheIds
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

// ─── Watch a single child by ID ───────────────────────────────────────────────
final childByIdProvider =
    StreamProvider.family<ChildModel?, String>((ref, childId) {
  return ref.watch(firestoreServiceProvider).watchChildById(childId);
});

// ─── Admin User Creation ──────────────────────────────────────────────────────
class AdminUserFormState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const AdminUserFormState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  AdminUserFormState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) =>
      AdminUserFormState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        isSuccess: isSuccess ?? this.isSuccess,
      );
}

class AdminUserFormNotifier extends Notifier<AdminUserFormState> {
  @override
  AdminUserFormState build() => const AdminUserFormState();

  AdminUserService get _service => ref.read(adminUserServiceProvider);

  Future<void> createUser({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
    String? phoneNumber,
    List<String> crecheIds = const [],
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.createUser(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
        phoneNumber: phoneNumber,
        crecheIds: crecheIds,
      );
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create account: ${e.toString()}',
      );
    }
  }

  void reset() => state = const AdminUserFormState();
}

final adminUserFormProvider =
    NotifierProvider<AdminUserFormNotifier, AdminUserFormState>(
  AdminUserFormNotifier.new,
);

// ─── Link Parent to Child ─────────────────────────────────────────────────────
class LinkParentState {
  final String? error;
  const LinkParentState({this.error});
}

class LinkParentNotifier extends Notifier<LinkParentState> {
  @override
  LinkParentState build() => const LinkParentState();

  FirestoreService get _db => ref.read(firestoreServiceProvider);

  Future<void> link({
    required String childId,
    required String parentUid,
    required String crecheId,
  }) async {
    try {
      await _db.linkParentToChild(
          childId: childId, parentUid: parentUid, crecheId: crecheId);
    } catch (_) {
      state = const LinkParentState(error: 'Failed to link parent.');
    }
  }

  Future<void> unlink({
    required String childId,
    required String parentUid,
  }) async {
    try {
      await _db.unlinkParentFromChild(childId: childId, parentUid: parentUid);
    } catch (_) {
      state = const LinkParentState(error: 'Failed to unlink parent.');
    }
  }
}

final linkParentProvider =
    NotifierProvider<LinkParentNotifier, LinkParentState>(
  LinkParentNotifier.new,
);
