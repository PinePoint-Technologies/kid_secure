import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/services/admin_user_service.dart';

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
      final user = await _service.createUser(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
        phoneNumber: phoneNumber,
        crecheIds: crecheIds,
      );
      // For teachers, also update each crèche's teacherIds so the assignment
      // screen shows them as assigned (not just the user doc's crecheIds).
      if (role == UserRole.teacher && crecheIds.isNotEmpty) {
        final db = ref.read(firestoreServiceProvider);
        for (final crecheId in crecheIds) {
          await db.addTeacherToCreche(crecheId, user.uid);
        }
      }
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
