import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';

/// All named permissions in the app.
///
/// [UserModel.hasPermission] always returns `true` for [UserRole.superAdmin],
/// so any value added here is automatically granted to super_admin without
/// requiring any other code change.
enum Permission {
  // ── Crèches ──────────────────────────────────────────────────────────────
  viewCreches,
  createCreche,
  editCreche,
  deleteCreche,

  // ── Teachers ─────────────────────────────────────────────────────────────
  viewTeachers,
  assignTeachers,
  removeTeachers,
  deactivateTeacher,

  // ── Parents ───────────────────────────────────────────────────────────────
  viewParents,
  editParent,
  deactivateParent,

  // ── Kids ─────────────────────────────────────────────────────────────────
  viewKids,
  createKid,
  editKid,
  deleteKid,

  // ── Guardians ─────────────────────────────────────────────────────────────
  viewGuardians,
  createGuardian,
  editGuardian,
  deleteGuardian,

  // ── Reports ───────────────────────────────────────────────────────────────
  viewOwnReports,
  viewAllReports,

  // ── Stats ─────────────────────────────────────────────────────────────────
  viewStats,
}

enum UserRole {
  superAdmin,
  teacher,
  parent;

  static UserRole fromString(String value) => switch (value) {
        AppConstants.roleSuperAdmin => UserRole.superAdmin,
        AppConstants.roleTeacher => UserRole.teacher,
        _ => UserRole.parent,
      };

  String get value => switch (this) {
        UserRole.superAdmin => AppConstants.roleSuperAdmin,
        UserRole.teacher => AppConstants.roleTeacher,
        UserRole.parent => AppConstants.roleParent,
      };

  String get displayName => switch (this) {
        UserRole.superAdmin => 'Super Admin',
        UserRole.teacher => 'Teacher',
        UserRole.parent => 'Parent',
      };
}

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final UserRole role;
  final List<String> crecheIds; // schools this user belongs to
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastSignIn;
  final Map<String, dynamic>? metadata;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.phoneNumber,
    required this.role,
    this.crecheIds = const [],
    this.isActive = true,
    required this.createdAt,
    this.lastSignIn,
    this.metadata,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      role: UserRole.fromString(data['role'] as String? ?? ''),
      crecheIds: List<String>.from(data['crecheIds'] as List? ?? []),
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastSignIn: (data['lastSignIn'] as Timestamp?)?.toDate(),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'phoneNumber': phoneNumber,
        'role': role.value,
        'crecheIds': crecheIds,
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
        'lastSignIn':
            lastSignIn != null ? Timestamp.fromDate(lastSignIn!) : null,
        'metadata': metadata,
      };

  /// `true` when this user is a super-admin.
  bool get isSuperAdmin => role == UserRole.superAdmin;

  /// Returns `true` for **every** [Permission] when the user is a super-admin.
  /// For all other roles this always returns `false`; extend here when
  /// fine-grained per-role permissions are needed in the future.
  bool hasPermission(Permission permission) => isSuperAdmin;

  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    UserRole? role,
    List<String>? crecheIds,
    bool? isActive,
    DateTime? lastSignIn,
    Map<String, dynamic>? metadata,
  }) =>
      UserModel(
        uid: uid,
        email: email,
        displayName: displayName ?? this.displayName,
        photoUrl: photoUrl ?? this.photoUrl,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        role: role ?? this.role,
        crecheIds: crecheIds ?? this.crecheIds,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt,
        lastSignIn: lastSignIn ?? this.lastSignIn,
        metadata: metadata ?? this.metadata,
      );
}
