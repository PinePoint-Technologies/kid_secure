import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/providers/invite_provider.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/services/invite_service.dart';

// ── State ────────────────────────────────────────────────────────────────────

sealed class InviteRegisterStatus {
  const InviteRegisterStatus();
}

class InviteIdle extends InviteRegisterStatus {
  const InviteIdle();
}

class InviteValidating extends InviteRegisterStatus {
  const InviteValidating();
}

class InviteValid extends InviteRegisterStatus {
  final String role;
  final String crecheId;
  final String tokenId;
  const InviteValid({
    required this.role,
    required this.crecheId,
    required this.tokenId,
  });
}

class InviteInvalid extends InviteRegisterStatus {
  final String message;
  const InviteInvalid(this.message);
}

class InviteRegistering extends InviteRegisterStatus {
  const InviteRegistering();
}

class InviteSuccess extends InviteRegisterStatus {
  final UserModel user;
  const InviteSuccess(this.user);
}

class InviteError extends InviteRegisterStatus {
  final String message;
  const InviteError(this.message);
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class InviteRegisterNotifier extends Notifier<InviteRegisterStatus> {
  @override
  InviteRegisterStatus build() => const InviteIdle();

  FirebaseAuth get _auth => ref.read(firebaseAuthProvider);
  FirestoreService get _db => ref.read(firestoreServiceProvider);
  InviteService get _inviteService => ref.read(inviteServiceProvider);

  Future<void> validateToken(String rawToken) async {
    if (rawToken.isEmpty) {
      state = const InviteInvalid('No invite token provided.');
      return;
    }
    state = const InviteValidating();
    try {
      final result = await _inviteService.validateInvite(rawToken);
      if (result.valid) {
        state = InviteValid(
          role: result.role!,
          crecheId: result.crecheId!,
          tokenId: result.tokenId!,
        );
      } else {
        state = InviteInvalid(result.error ?? 'Invalid invite link.');
      }
    } catch (_) {
      state = const InviteInvalid('Could not verify invite. Check your connection and try again.');
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
    required String role,
    required String crecheId,
    required String tokenId,
  }) async {
    state = const InviteRegistering();
    try {
      // 1. Create Firebase Auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user!.updateDisplayName(displayName.trim());

      // 2. Build and persist Firestore user doc
      final userRole = UserRole.fromString(role);
      final user = UserModel(
        uid: credential.user!.uid,
        email: email.trim(),
        displayName: displayName.trim(),
        phoneNumber: phoneNumber?.trim().isEmpty == true ? null : phoneNumber?.trim(),
        role: userRole,
        crecheIds: [crecheId],
        createdAt: DateTime.now(),
      );
      await _db.createUser(user);

      // 3. If teacher, also add to creche's teacherIds array
      if (userRole == UserRole.teacher) {
        await _db.addTeacherToCreche(crecheId, credential.user!.uid);
      }

      // 4. Consume the invite token (best-effort — don't fail registration if this errors)
      try {
        await _inviteService.consumeInvite(tokenId);
      } catch (_) {
        // Non-fatal: audit log may be missing but user account is created
      }

      state = InviteSuccess(user);
    } on FirebaseAuthException catch (e) {
      state = InviteError(_mapError(e));
    } catch (_) {
      state = const InviteError('Registration failed. Please try again.');
    }
  }

  void reset() => state = const InviteIdle();

  String _mapError(FirebaseAuthException e) => switch (e.code) {
        'email-already-in-use' => 'An account already exists with this email.',
        'weak-password' => 'Password is too weak. Use at least 8 characters.',
        'invalid-email' => 'Please enter a valid email address.',
        'too-many-requests' => 'Too many attempts. Please try again later.',
        'network-request-failed' => 'Network error. Check your connection.',
        _ => e.message ?? 'Authentication failed.',
      };
}

final inviteRegisterProvider =
    NotifierProvider<InviteRegisterNotifier, InviteRegisterStatus>(
  InviteRegisterNotifier.new,
);
