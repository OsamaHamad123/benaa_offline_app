import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/beneficiary_followup_entities.dart';

DateTime? _date(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

class BeneficiaryVisitFirestoreModel extends BeneficiaryVisitFirestoreEntity {
  const BeneficiaryVisitFirestoreModel({
    required super.id,
    required super.beneficiaryId,
    required super.beneficiaryFileNumber,
    required super.visitType,
    required super.status,
    super.sponsorshipId,
    super.associationId,
    super.scheduledAt,
    super.completedAt,
    super.visitedBy,
    super.visitedByName,
    super.locationGovernorate,
    super.locationCity,
    super.locationAddress,
    super.summary,
    super.needs,
    super.recommendations,
    super.nextVisitAt,
    super.attachments,
    super.createdBy,
    super.createdAt,
    super.updatedAt,
  });

  factory BeneficiaryVisitFirestoreModel.fromJson(Map<String, dynamic> json) {
    return BeneficiaryVisitFirestoreModel(
      id: (json['id'] ?? '').toString(),
      beneficiaryId: (json['beneficiaryId'] ?? '').toString(),
      beneficiaryFileNumber: (json['beneficiaryFileNumber'] ?? '').toString(),
      sponsorshipId: json['sponsorshipId']?.toString(),
      associationId: json['associationId']?.toString(),
      visitType: (json['visitType'] ?? 'other').toString(),
      status: (json['status'] ?? 'scheduled').toString(),
      scheduledAt: json['scheduledAt']?.toString(),
      completedAt: json['completedAt']?.toString(),
      visitedBy: json['visitedBy']?.toString(),
      visitedByName: json['visitedByName']?.toString(),
      locationGovernorate: json['locationGovernorate']?.toString(),
      locationCity: json['locationCity']?.toString(),
      locationAddress: json['locationAddress']?.toString(),
      summary: json['summary']?.toString(),
      needs: (json['needs'] as List?)?.map((e) => e.toString()).toList(growable: false) ?? const <String>[],
      recommendations: json['recommendations']?.toString(),
      nextVisitAt: json['nextVisitAt']?.toString(),
      attachments: (json['attachments'] as List?)?.map((e) => e.toString()).toList(growable: false) ?? const <String>[],
      createdBy: json['createdBy']?.toString(),
      createdAt: _date(json['createdAt']),
      updatedAt: _date(json['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestoreCreateJson({required String uid}) => <String, dynamic>{
        'id': id,
        'beneficiaryId': beneficiaryId,
        'beneficiaryFileNumber': beneficiaryFileNumber,
        'sponsorshipId': sponsorshipId,
        'associationId': associationId,
        'visitType': visitType,
        'status': status,
        'scheduledAt': scheduledAt,
        'completedAt': completedAt,
        'visitedBy': visitedBy,
        'visitedByName': visitedByName,
        'locationGovernorate': locationGovernorate,
        'locationCity': locationCity,
        'locationAddress': locationAddress,
        'summary': summary,
        'needs': needs,
        'recommendations': recommendations,
        'nextVisitAt': nextVisitAt,
        'attachments': attachments,
        'createdBy': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  Map<String, dynamic> toFirestoreUpdateJson() => <String, dynamic>{
        'id': id,
        'beneficiaryId': beneficiaryId,
        'beneficiaryFileNumber': beneficiaryFileNumber,
        'sponsorshipId': sponsorshipId,
        'associationId': associationId,
        'visitType': visitType,
        'status': status,
        'scheduledAt': scheduledAt,
        'completedAt': completedAt,
        'visitedBy': visitedBy,
        'visitedByName': visitedByName,
        'locationGovernorate': locationGovernorate,
        'locationCity': locationCity,
        'locationAddress': locationAddress,
        'summary': summary,
        'needs': needs,
        'recommendations': recommendations,
        'nextVisitAt': nextVisitAt,
        'attachments': attachments,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

class BeneficiaryFollowupModel extends BeneficiaryFollowupEntity {
  const BeneficiaryFollowupModel({
    required super.id,
    required super.beneficiaryId,
    required super.type,
    required super.status,
    required super.title,
    super.relatedVisitId,
    super.relatedSponsorshipId,
    super.description,
    super.assignedTo,
    super.dueDate,
    super.completedAt,
    super.createdBy,
    super.createdAt,
    super.updatedAt,
  });

  factory BeneficiaryFollowupModel.fromJson(Map<String, dynamic> json) {
    return BeneficiaryFollowupModel(
      id: (json['id'] ?? '').toString(),
      beneficiaryId: (json['beneficiaryId'] ?? '').toString(),
      relatedVisitId: json['relatedVisitId']?.toString(),
      relatedSponsorshipId: json['relatedSponsorshipId']?.toString(),
      type: (json['type'] ?? 'other').toString(),
      status: (json['status'] ?? 'open').toString(),
      title: (json['title'] ?? '').toString(),
      description: json['description']?.toString(),
      assignedTo: json['assignedTo']?.toString(),
      dueDate: json['dueDate']?.toString(),
      completedAt: json['completedAt']?.toString(),
      createdBy: json['createdBy']?.toString(),
      createdAt: _date(json['createdAt']),
      updatedAt: _date(json['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestoreCreateJson({required String uid}) => <String, dynamic>{
        'id': id,
        'beneficiaryId': beneficiaryId,
        'relatedVisitId': relatedVisitId,
        'relatedSponsorshipId': relatedSponsorshipId,
        'type': type,
        'status': status,
        'title': title,
        'description': description,
        'assignedTo': assignedTo,
        'dueDate': dueDate,
        'completedAt': completedAt,
        'createdBy': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  Map<String, dynamic> toFirestoreUpdateJson() => <String, dynamic>{
        'id': id,
        'beneficiaryId': beneficiaryId,
        'relatedVisitId': relatedVisitId,
        'relatedSponsorshipId': relatedSponsorshipId,
        'type': type,
        'status': status,
        'title': title,
        'description': description,
        'assignedTo': assignedTo,
        'dueDate': dueDate,
        'completedAt': completedAt,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
