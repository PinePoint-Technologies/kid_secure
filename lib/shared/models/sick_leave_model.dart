import 'package:cloud_firestore/cloud_firestore.dart';

enum SickLeaveStatus { pending, approved, rejected }

class SickLeaveModel {
  final String id;
  final String childId;
  final String childName;
  final String parentUid;
  final String crecheId;
  final DateTime startDate;
  final DateTime? endDate;
  final String reason;
  final String? symptoms;
  final List<String> attachmentUrls; // doctor's note, etc.
  final SickLeaveStatus status;
  final String? teacherNotes;
  final String? approvedByUid;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SickLeaveModel({
    required this.id,
    required this.childId,
    required this.childName,
    required this.parentUid,
    required this.crecheId,
    required this.startDate,
    this.endDate,
    required this.reason,
    this.symptoms,
    this.attachmentUrls = const [],
    this.status = SickLeaveStatus.pending,
    this.teacherNotes,
    this.approvedByUid,
    required this.createdAt,
    this.updatedAt,
  });

  int get daysCount {
    final end = endDate ?? startDate;
    return end.difference(startDate).inDays + 1;
  }

  factory SickLeaveModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SickLeaveModel(
      id: doc.id,
      childId: data['childId'] as String? ?? '',
      childName: data['childName'] as String? ?? '',
      parentUid: data['parentUid'] as String? ?? '',
      crecheId: data['crecheId'] as String? ?? '',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      reason: data['reason'] as String? ?? '',
      symptoms: data['symptoms'] as String?,
      attachmentUrls:
          List<String>.from(data['attachmentUrls'] as List? ?? []),
      status: SickLeaveStatus.values.firstWhere(
        (s) => s.name == (data['status'] as String? ?? 'pending'),
        orElse: () => SickLeaveStatus.pending,
      ),
      teacherNotes: data['teacherNotes'] as String?,
      approvedByUid: data['approvedByUid'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'childId': childId,
        'childName': childName,
        'parentUid': parentUid,
        'crecheId': crecheId,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
        'reason': reason,
        'symptoms': symptoms,
        'attachmentUrls': attachmentUrls,
        'status': status.name,
        'teacherNotes': teacherNotes,
        'approvedByUid': approvedByUid,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      };

  SickLeaveModel copyWith({
    DateTime? endDate,
    String? reason,
    String? symptoms,
    List<String>? attachmentUrls,
    SickLeaveStatus? status,
    String? teacherNotes,
    String? approvedByUid,
  }) =>
      SickLeaveModel(
        id: id,
        childId: childId,
        childName: childName,
        parentUid: parentUid,
        crecheId: crecheId,
        startDate: startDate,
        endDate: endDate ?? this.endDate,
        reason: reason ?? this.reason,
        symptoms: symptoms ?? this.symptoms,
        attachmentUrls: attachmentUrls ?? this.attachmentUrls,
        status: status ?? this.status,
        teacherNotes: teacherNotes ?? this.teacherNotes,
        approvedByUid: approvedByUid ?? this.approvedByUid,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}
