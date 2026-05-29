import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/sponsorship_entities.dart';

DateTime? _date(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

class SponsorshipFileModel extends SponsorshipFileEntity {
  const SponsorshipFileModel({
    required super.id,
    required super.associationId,
    required super.title,
    required super.sourceType,
    required super.status,
    super.fileUrl,
    super.totalRows,
    super.matchedBeneficiaries,
    super.createdBeneficiaries,
    super.unmatchedRows,
    super.notes,
    super.createdBy,
    super.createdAt,
    super.updatedAt,
  });

  factory SponsorshipFileModel.fromJson(Map<String, dynamic> json) => SponsorshipFileModel(
        id: (json['id'] ?? '').toString(),
        associationId: (json['associationId'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        sourceType: (json['sourceType'] ?? 'manual').toString(),
        fileUrl: json['fileUrl']?.toString(),
        status: (json['status'] ?? 'draft').toString(),
        totalRows: (json['totalRows'] as num?)?.toInt() ?? 0,
        matchedBeneficiaries: (json['matchedBeneficiaries'] as num?)?.toInt() ?? 0,
        createdBeneficiaries: (json['createdBeneficiaries'] as num?)?.toInt() ?? 0,
        unmatchedRows: (json['unmatchedRows'] as num?)?.toInt() ?? 0,
        notes: json['notes']?.toString(),
        createdBy: json['createdBy']?.toString(),
        createdAt: _date(json['createdAt']),
        updatedAt: _date(json['updatedAt']),
      );

  Map<String, dynamic> toFirestoreCreateJson({required String uid}) => <String, dynamic>{
        'id': id,
        'associationId': associationId,
        'title': title,
        'sourceType': sourceType,
        'fileUrl': fileUrl,
        'status': status,
        'totalRows': totalRows,
        'matchedBeneficiaries': matchedBeneficiaries,
        'createdBeneficiaries': createdBeneficiaries,
        'unmatchedRows': unmatchedRows,
        'notes': notes,
        'createdBy': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  Map<String, dynamic> toFirestoreUpdateJson() => <String, dynamic>{
        'id': id,
        'associationId': associationId,
        'title': title,
        'sourceType': sourceType,
        'fileUrl': fileUrl,
        'status': status,
        'totalRows': totalRows,
        'matchedBeneficiaries': matchedBeneficiaries,
        'createdBeneficiaries': createdBeneficiaries,
        'unmatchedRows': unmatchedRows,
        'notes': notes,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

class SponsorshipCandidateModel extends SponsorshipCandidateEntity {
  const SponsorshipCandidateModel({
    required super.id,
    required super.sponsorshipFileId,
    required super.associationId,
    required super.rawName,
    required super.matchStatus,
    required super.sponsorshipType,
    required super.currency,
    required super.priority,
    super.nationalId,
    super.phone,
    super.governorate,
    super.city,
    super.address,
    super.familyMembersCount,
    super.caseDescription,
    super.matchedBeneficiaryId,
    super.createdBeneficiaryId,
    super.requestedAmount,
    super.notes,
    super.createdAt,
    super.updatedAt,
  });

  factory SponsorshipCandidateModel.fromJson(Map<String, dynamic> json) => SponsorshipCandidateModel(
        id: (json['id'] ?? '').toString(),
        sponsorshipFileId: (json['sponsorshipFileId'] ?? '').toString(),
        associationId: (json['associationId'] ?? '').toString(),
        rawName: (json['rawName'] ?? '').toString(),
        nationalId: json['nationalId']?.toString(),
        phone: json['phone']?.toString(),
        governorate: json['governorate']?.toString(),
        city: json['city']?.toString(),
        address: json['address']?.toString(),
        familyMembersCount: (json['familyMembersCount'] as num?)?.toInt() ?? 0,
        caseDescription: json['caseDescription']?.toString(),
        matchStatus: (json['matchStatus'] ?? 'unmatched').toString(),
        matchedBeneficiaryId: json['matchedBeneficiaryId']?.toString(),
        createdBeneficiaryId: json['createdBeneficiaryId']?.toString(),
        sponsorshipType: (json['sponsorshipType'] ?? 'monthly').toString(),
        requestedAmount: (json['requestedAmount'] as num?) ?? 0,
        currency: (json['currency'] ?? 'ILS').toString(),
        priority: (json['priority'] ?? 'medium').toString(),
        notes: json['notes']?.toString(),
        createdAt: _date(json['createdAt']),
        updatedAt: _date(json['updatedAt']),
      );

  Map<String, dynamic> toFirestoreJson() => <String, dynamic>{
        'id': id,
        'sponsorshipFileId': sponsorshipFileId,
        'associationId': associationId,
        'rawName': rawName,
        'nationalId': nationalId,
        'phone': phone,
        'governorate': governorate,
        'city': city,
        'address': address,
        'familyMembersCount': familyMembersCount,
        'caseDescription': caseDescription,
        'matchStatus': matchStatus,
        'matchedBeneficiaryId': matchedBeneficiaryId,
        'createdBeneficiaryId': createdBeneficiaryId,
        'sponsorshipType': sponsorshipType,
        'requestedAmount': requestedAmount,
        'currency': currency,
        'priority': priority,
        'notes': notes,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

class SponsorshipModel extends SponsorshipEntity {
  const SponsorshipModel({
    required super.id,
    required super.beneficiaryId,
    required super.beneficiaryFileNumber,
    required super.associationId,
    required super.type,
    required super.status,
    required super.amount,
    required super.currency,
    required super.frequency,
    super.sponsorshipFileId,
    super.candidateId,
    super.startDate,
    super.endDate,
    super.sponsorName,
    super.sponsorPhone,
    super.sponsorCountry,
    super.notes,
    super.createdBy,
    super.createdAt,
    super.updatedAt,
  });

  factory SponsorshipModel.fromJson(Map<String, dynamic> json) => SponsorshipModel(
        id: (json['id'] ?? '').toString(),
        beneficiaryId: (json['beneficiaryId'] ?? '').toString(),
        beneficiaryFileNumber: (json['beneficiaryFileNumber'] ?? '').toString(),
        associationId: (json['associationId'] ?? '').toString(),
        sponsorshipFileId: json['sponsorshipFileId']?.toString(),
        candidateId: json['candidateId']?.toString(),
        type: (json['type'] ?? 'other').toString(),
        status: (json['status'] ?? 'pending').toString(),
        amount: (json['amount'] as num?) ?? 0,
        currency: (json['currency'] ?? 'ILS').toString(),
        frequency: (json['frequency'] ?? 'monthly').toString(),
        startDate: json['startDate']?.toString(),
        endDate: json['endDate']?.toString(),
        sponsorName: json['sponsorName']?.toString(),
        sponsorPhone: json['sponsorPhone']?.toString(),
        sponsorCountry: json['sponsorCountry']?.toString(),
        notes: json['notes']?.toString(),
        createdBy: json['createdBy']?.toString(),
        createdAt: _date(json['createdAt']),
        updatedAt: _date(json['updatedAt']),
      );

  Map<String, dynamic> toFirestoreCreateJson({required String uid}) => <String, dynamic>{
        'id': id,
        'beneficiaryId': beneficiaryId,
        'beneficiaryFileNumber': beneficiaryFileNumber,
        'associationId': associationId,
        'sponsorshipFileId': sponsorshipFileId,
        'candidateId': candidateId,
        'type': type,
        'status': status,
        'amount': amount,
        'currency': currency,
        'frequency': frequency,
        'startDate': startDate,
        'endDate': endDate,
        'sponsorName': sponsorName,
        'sponsorPhone': sponsorPhone,
        'sponsorCountry': sponsorCountry,
        'notes': notes,
        'createdBy': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  Map<String, dynamic> toFirestoreUpdateJson() => <String, dynamic>{
        'id': id,
        'beneficiaryId': beneficiaryId,
        'beneficiaryFileNumber': beneficiaryFileNumber,
        'associationId': associationId,
        'sponsorshipFileId': sponsorshipFileId,
        'candidateId': candidateId,
        'type': type,
        'status': status,
        'amount': amount,
        'currency': currency,
        'frequency': frequency,
        'startDate': startDate,
        'endDate': endDate,
        'sponsorName': sponsorName,
        'sponsorPhone': sponsorPhone,
        'sponsorCountry': sponsorCountry,
        'notes': notes,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

class SponsorshipPaymentModel extends SponsorshipPaymentEntity {
  const SponsorshipPaymentModel({
    required super.id,
    required super.sponsorshipId,
    required super.beneficiaryId,
    required super.associationId,
    required super.amount,
    required super.currency,
    required super.paymentDate,
    required super.period,
    required super.status,
    super.receiptUrl,
    super.notes,
    super.createdAt,
    super.updatedAt,
  });

  factory SponsorshipPaymentModel.fromJson(Map<String, dynamic> json) => SponsorshipPaymentModel(
        id: (json['id'] ?? '').toString(),
        sponsorshipId: (json['sponsorshipId'] ?? '').toString(),
        beneficiaryId: (json['beneficiaryId'] ?? '').toString(),
        associationId: (json['associationId'] ?? '').toString(),
        amount: (json['amount'] as num?) ?? 0,
        currency: (json['currency'] ?? 'ILS').toString(),
        paymentDate: (json['paymentDate'] ?? '').toString(),
        period: (json['period'] ?? '').toString(),
        status: (json['status'] ?? 'pending').toString(),
        receiptUrl: json['receiptUrl']?.toString(),
        notes: json['notes']?.toString(),
        createdAt: _date(json['createdAt']),
        updatedAt: _date(json['updatedAt']),
      );

  Map<String, dynamic> toFirestoreJson() => <String, dynamic>{
        'id': id,
        'sponsorshipId': sponsorshipId,
        'beneficiaryId': beneficiaryId,
        'associationId': associationId,
        'amount': amount,
        'currency': currency,
        'paymentDate': paymentDate,
        'period': period,
        'status': status,
        'receiptUrl': receiptUrl,
        'notes': notes,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
