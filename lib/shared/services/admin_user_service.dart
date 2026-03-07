import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

/// Creates Firebase Auth users + Firestore user docs without signing out the
/// currently logged-in super-admin.  A temporary secondary [FirebaseApp] is
/// initialised for each call, the account is created there, then the app is
/// deleted — leaving the primary auth session completely untouched.
class AdminUserService {
  final FirestoreService _db;
  AdminUserService(this._db);

  Future<UserModel> createUser({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
    String? phoneNumber,
    List<String> crecheIds = const [],
  }) async {
    // Unique name prevents collisions if called rapidly.
    final appName = 'admin_tmp_${DateTime.now().millisecondsSinceEpoch}';
    final secondaryApp = await Firebase.initializeApp(
      name: appName,
      options: Firebase.app().options,
    );
    try {
      final auth = FirebaseAuth.instanceFor(app: secondaryApp);
      final cred = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user!.updateDisplayName(displayName.trim());

      final user = UserModel(
        uid: cred.user!.uid,
        email: email.trim(),
        displayName: displayName.trim(),
        phoneNumber: (phoneNumber != null && phoneNumber.trim().isNotEmpty)
            ? phoneNumber.trim()
            : null,
        role: role,
        crecheIds: crecheIds,
        createdAt: DateTime.now(),
      );
      await _db.createUser(user);

      // Sign out of the secondary app before deleting it.
      await auth.signOut();
      return user;
    } finally {
      await secondaryApp.delete();
    }
  }
}
