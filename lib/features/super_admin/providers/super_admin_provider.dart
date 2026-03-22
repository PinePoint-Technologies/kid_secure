import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../shared/models/child_model.dart';
import '../../../shared/models/creche_model.dart';
import '../../../shared/models/guardian_model.dart';
import '../../../shared/models/user_model.dart';

// ─── Entity streams ───────────────────────────────────────────────────────────

final allCrechesProvider = StreamProvider<List<CrecheModel>>(
  (ref) => ref.watch(firestoreServiceProvider).watchAllCreches(),
);

final allTeachersProvider = StreamProvider<List<UserModel>>(
  (ref) => ref.watch(firestoreServiceProvider).watchTeachers(),
);

final allChildrenProvider = StreamProvider<List<ChildModel>>(
  (ref) => ref.watch(firestoreServiceProvider).watchAllChildren(),
);

final allParentsProvider = StreamProvider<List<UserModel>>(
  (ref) => ref.watch(firestoreServiceProvider).watchAllParents(),
);

final allGuardiansProvider = StreamProvider<List<GuardianModel>>(
  (ref) => ref.watch(firestoreServiceProvider).watchAllGuardians(),
);

// ─── Aggregated dashboard stats ───────────────────────────────────────────────

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

  final err = creches.error ??
      teachers.error ??
      children.error ??
      parents.error ??
      guardians.error;
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
