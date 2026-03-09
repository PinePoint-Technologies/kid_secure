import 'package:cloud_firestore/cloud_firestore.dart';

enum ChildStatus { active, inactive, graduated }

class ChildModel {
  final String id;
  final String crecheId;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String? photoUrl;
  final String? allergies;
  final String? medicalNotes;
  final String? dietaryRequirements;
  final List<String> parentIds; // uid references
  final List<String> guardianIds; // guardian doc ids
  final String? classGroup; // e.g. "Toddlers", "Pre-K"
  final ChildStatus status;
  final DateTime enrollmentDate;
  final DateTime? graduationDate;
  final Map<String, dynamic>? emergencyContact;
  final String? qrCode; // unique QR for sign-in/out
  final String? trackerId; // GPS tracker device ID

  const ChildModel({
    required this.id,
    required this.crecheId,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    this.photoUrl,
    this.allergies,
    this.medicalNotes,
    this.dietaryRequirements,
    this.parentIds = const [],
    this.guardianIds = const [],
    this.classGroup,
    this.status = ChildStatus.active,
    required this.enrollmentDate,
    this.graduationDate,
    this.emergencyContact,
    this.qrCode,
    this.trackerId,
  });

  String get fullName => '$firstName $lastName';
  String get initials =>
      '${firstName[0]}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase();

  factory ChildModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChildModel(
      id: doc.id,
      crecheId: data['crecheId'] as String? ?? '',
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate() ??
          DateTime(2020, 1, 1),
      photoUrl: data['photoUrl'] as String?,
      allergies: data['allergies'] as String?,
      medicalNotes: data['medicalNotes'] as String?,
      dietaryRequirements: data['dietaryRequirements'] as String?,
      parentIds: List<String>.from(data['parentIds'] as List? ?? []),
      guardianIds: List<String>.from(data['guardianIds'] as List? ?? []),
      classGroup: data['classGroup'] as String?,
      status: ChildStatus.values.firstWhere(
        (s) => s.name == (data['status'] as String? ?? 'active'),
        orElse: () => ChildStatus.active,
      ),
      enrollmentDate:
          (data['enrollmentDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      graduationDate: (data['graduationDate'] as Timestamp?)?.toDate(),
      emergencyContact: data['emergencyContact'] as Map<String, dynamic>?,
      qrCode: data['qrCode'] as String?,
      trackerId: data['trackerId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'crecheId': crecheId,
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': Timestamp.fromDate(dateOfBirth),
        'photoUrl': photoUrl,
        'allergies': allergies,
        'medicalNotes': medicalNotes,
        'dietaryRequirements': dietaryRequirements,
        'parentIds': parentIds,
        'guardianIds': guardianIds,
        'classGroup': classGroup,
        'status': status.name,
        'enrollmentDate': Timestamp.fromDate(enrollmentDate),
        'graduationDate':
            graduationDate != null ? Timestamp.fromDate(graduationDate!) : null,
        'emergencyContact': emergencyContact,
        'qrCode': qrCode,
        'trackerId': trackerId,
      };

  ChildModel copyWith({
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? photoUrl,
    String? allergies,
    String? medicalNotes,
    String? dietaryRequirements,
    List<String>? parentIds,
    List<String>? guardianIds,
    String? classGroup,
    ChildStatus? status,
    DateTime? graduationDate,
    Map<String, dynamic>? emergencyContact,
    String? qrCode,
    String? trackerId,
  }) =>
      ChildModel(
        id: id,
        crecheId: crecheId,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        photoUrl: photoUrl ?? this.photoUrl,
        allergies: allergies ?? this.allergies,
        medicalNotes: medicalNotes ?? this.medicalNotes,
        dietaryRequirements: dietaryRequirements ?? this.dietaryRequirements,
        parentIds: parentIds ?? this.parentIds,
        guardianIds: guardianIds ?? this.guardianIds,
        classGroup: classGroup ?? this.classGroup,
        status: status ?? this.status,
        enrollmentDate: enrollmentDate,
        graduationDate: graduationDate ?? this.graduationDate,
        emergencyContact: emergencyContact ?? this.emergencyContact,
        qrCode: qrCode ?? this.qrCode,
        trackerId: trackerId ?? this.trackerId,
      );
}
