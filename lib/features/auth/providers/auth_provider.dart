import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/services/firestore_service.dart';

// ─── Current user profile ────────────────────────────────────────────────────
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  final service = ref.watch(firestoreServiceProvider);
  return authState.when(
    data: (user) => user != null ? service.watchUser(user.uid) : Stream.value(null),
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// ─── Auth State Notifier ─────────────────────────────────────────────────────
sealed class AuthStatus {
  const AuthStatus();
}

class AuthIdle extends AuthStatus {
  const AuthIdle();
}

class AuthLoading extends AuthStatus {
  const AuthLoading();
}

class AuthSuccess extends AuthStatus {
  final UserModel user;
  const AuthSuccess(this.user);
}

class AuthError extends AuthStatus {
  final String message;
  const AuthError(this.message);
}

class AuthNotifier extends Notifier<AuthStatus> {
  @override
  AuthStatus build() => const AuthIdle();

  FirebaseAuth get _auth => ref.read(firebaseAuthProvider);
  FirestoreService get _service => ref.read(firestoreServiceProvider);

  Future<void> signIn({required String email, required String password}) async {
    state = const AuthLoading();
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = await _service.getUser(credential.user!.uid);
      if (user == null) {
        await _auth.signOut();
        state = const AuthError('Account not found. Contact your administrator.');
        return;
      }
      if (!user.isActive) {
        await _auth.signOut();
        state = const AuthError('Your account has been deactivated.');
        return;
      }
      // update lastSignIn
      await _service.updateUser(user.uid, {'lastSignIn': DateTime.now()});
      state = AuthSuccess(user);
    } on FirebaseAuthException catch (e) {
      state = AuthError(_mapFirebaseError(e));
    } catch (e) {
      state = AuthError('Something went wrong. Please try again.');
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
    String? phoneNumber,
  }) async {
    state = const AuthLoading();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user!.updateDisplayName(displayName);
      final user = UserModel(
        uid: credential.user!.uid,
        email: email.trim(),
        displayName: displayName,
        phoneNumber: phoneNumber,
        role: role,
        createdAt: DateTime.now(),
      );
      await _service.createUser(user);
      state = AuthSuccess(user);
    } on FirebaseAuthException catch (e) {
      state = AuthError(_mapFirebaseError(e));
    } catch (e) {
      state = AuthError('Registration failed. Please try again.');
    }
  }

  Future<void> setupSuperAdmin({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
  }) async {
    state = const AuthLoading();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user!.updateDisplayName(displayName);
      final user = UserModel(
        uid: credential.user!.uid,
        email: email.trim(),
        displayName: displayName,
        phoneNumber: phoneNumber,
        role: UserRole.superAdmin,
        createdAt: DateTime.now(),
      );
      await _service.createUser(user);
      await _service.markBootstrapped();
      state = AuthSuccess(user);
    } on FirebaseAuthException catch (e) {
      state = AuthError(_mapFirebaseError(e));
    } catch (e) {
      state = AuthError('Setup failed. Please try again.');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    state = const AuthIdle();
  }

  Future<void> resetPassword(String email) async {
    state = const AuthLoading();
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      state = const AuthIdle();
    } on FirebaseAuthException catch (e) {
      state = AuthError(_mapFirebaseError(e));
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) => switch (e.code) {
        'user-not-found' => 'No account found with this email.',
        'wrong-password' => 'Incorrect password.',
        'invalid-credential' => 'Invalid email or password.',
        'email-already-in-use' => 'An account already exists with this email.',
        'weak-password' =>
          'Password is too weak. Use at least 8 characters.',
        'invalid-email' => 'Please enter a valid email address.',
        'too-many-requests' =>
          'Too many attempts. Please try again later.',
        'network-request-failed' =>
          'Network error. Check your connection.',
        _ => e.message ?? 'Authentication failed.',
      };
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthStatus>(
  AuthNotifier.new,
);
