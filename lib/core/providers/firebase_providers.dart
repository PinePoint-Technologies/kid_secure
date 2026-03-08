import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/services/firestore_service.dart';
import '../../shared/services/admin_user_service.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (_) => FirebaseAuth.instance,
);

final firestoreProvider = Provider<FirebaseFirestore>(
  (_) => FirebaseFirestore.instance,
);

final storageProvider = Provider<FirebaseStorage>(
  (_) => FirebaseStorage.instanceFor(bucket: 'gs://heavy-6c072'),
);

final firestoreServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(ref.watch(firestoreProvider)),
);

final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(firebaseAuthProvider).authStateChanges(),
);

final bootstrappedProvider = StreamProvider<bool>(
  (ref) => ref.watch(firestoreServiceProvider).watchBootstrapped(),
);

final adminUserServiceProvider = Provider<AdminUserService>(
  (ref) => AdminUserService(ref.watch(firestoreServiceProvider)),
);
