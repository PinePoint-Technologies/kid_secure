import 'package:cloud_firestore/cloud_firestore.dart';

enum GuardianRelationship {
  mother,
  father,
  grandmother,
  grandfather,
  aunt,
  uncle,
  sibling,
  nanny,
  other;

  String get displayName => switch (this) {
        GuardianRelationship.mother => 'Mother',
        GuardianRelationship.father => 'Father',
        GuardianRelationship.grandmother => 'Grandmother',
        GuardianRelationship.grandfather => 'Grandfather',
        GuardianRelationship.aunt => 'Aunt',
        GuardianRelationship.uncle => 'Uncle',
        GuardianRelationship.sibling => 'Sibling',
        GuardianRelationship.nanny => 'Nanny',
        GuardianRelationship.other => 'Other',
      };
}

enum VerificationMethod { qrCode, pin, biometric }

class GuardianModel {
  final String id;
  final String parentUid; // uid of the parent who added this guardian
  final String childId;
  final String crecheId;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? email;
  final String? photoUrl;
  final String? idNumber;
  final GuardianRelationship relationship;
  final String? pin; // 4-6 digit PIN (stored hashed)
  final String? qrCode; // unique QR token
  final bool canSignIn;
  final bool canSignOut;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastUsed;

  const GuardianModel({
    required this.id,
    required this.parentUid,
    required this.childId,
    required this.crecheId,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.email,
    this.photoUrl,
    this.idNumber,
    required this.relationship,
    this.pin,
    this.qrCode,
    this.canSignIn = true,
    this.canSignOut = true,
    this.isVerified = false,
    this.isActive = true,
    required this.createdAt,
    this.lastUsed,
  });

  String get fullName => '$firstName $lastName';

  factory GuardianModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GuardianModel(
      id: doc.id,
      parentUid: data['parentUid'] as String? ?? '',
      childId: data['childId'] as String? ?? '',
      crecheId: data['crecheId'] as String? ?? '',
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      email: data['email'] as String?,
      photoUrl: data['photoUrl'] as String?,
      idNumber: data['idNumber'] as String?,
      relationship: GuardianRelationship.values.firstWhere(
        (r) =>
            r.name == (data['relationship'] as String? ?? 'other'),
        orElse: () => GuardianRelationship.other,
      ),
      pin: data['pin'] as String?,
      qrCode: data['qrCode'] as String?,
      canSignIn: data['canSignIn'] as bool? ?? true,
      canSignOut: data['canSignOut'] as bool? ?? true,
      isVerified: data['isVerified'] as bool? ?? false,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUsed: (data['lastUsed'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'parentUid': parentUid,
        'childId': childId,
        'crecheId': crecheId,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'email': email,
        'photoUrl': photoUrl,
        'idNumber': idNumber,
        'relationship': relationship.name,
        'pin': pin,
        'qrCode': qrCode,
        'canSignIn': canSignIn,
        'canSignOut': canSignOut,
        'isVerified': isVerified,
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
        'lastUsed': lastUsed != null ? Timestamp.fromDate(lastUsed!) : null,
      };

  GuardianModel copyWith({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? email,
    String? photoUrl,
    String? idNumber,
    GuardianRelationship? relationship,
    String? pin,
    String? qrCode,
    bool? canSignIn,
    bool? canSignOut,
    bool? isVerified,
    bool? isActive,
    DateTime? lastUsed,
  }) =>
      GuardianModel(
        id: id,
        parentUid: parentUid,
        childId: childId,
        crecheId: crecheId,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        email: email ?? this.email,
        photoUrl: photoUrl ?? this.photoUrl,
        idNumber: idNumber ?? this.idNumber,
        relationship: relationship ?? this.relationship,
        pin: pin ?? this.pin,
        qrCode: qrCode ?? this.qrCode,
        canSignIn: canSignIn ?? this.canSignIn,
        canSignOut: canSignOut ?? this.canSignOut,
        isVerified: isVerified ?? this.isVerified,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt,
        lastUsed: lastUsed ?? this.lastUsed,
      );
}
