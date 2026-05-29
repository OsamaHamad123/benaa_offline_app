class SponsorshipFileEntity {
  final String id;
  final String associationId;
  final String title;
  final String sourceType;
  final String? fileUrl;
  final String status;
  final int totalRows;
  final int matchedBeneficiaries;
  final int createdBeneficiaries;
  final int unmatchedRows;
  final String? notes;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SponsorshipFileEntity({
    required this.id,
    required this.associationId,
    required this.title,
    required this.sourceType,
    required this.status,
    this.fileUrl,
    this.totalRows = 0,
    this.matchedBeneficiaries = 0,
    this.createdBeneficiaries = 0,
    this.unmatchedRows = 0,
    this.notes,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });
}

class SponsorshipCandidateEntity {
  final String id;
  final String sponsorshipFileId;
  final String associationId;
  final String rawName;
  final String? nationalId;
  final String? phone;
  final String? governorate;
  final String? city;
  final String? address;
  final int familyMembersCount;
  final String? caseDescription;
  final String matchStatus;
  final String? matchedBeneficiaryId;
  final String? createdBeneficiaryId;
  final String sponsorshipType;
  final num requestedAmount;
  final String currency;
  final String priority;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SponsorshipCandidateEntity({
    required this.id,
    required this.sponsorshipFileId,
    required this.associationId,
    required this.rawName,
    required this.matchStatus,
    required this.sponsorshipType,
    required this.currency,
    required this.priority,
    this.nationalId,
    this.phone,
    this.governorate,
    this.city,
    this.address,
    this.familyMembersCount = 0,
    this.caseDescription,
    this.matchedBeneficiaryId,
    this.createdBeneficiaryId,
    this.requestedAmount = 0,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });
}

class SponsorshipEntity {
  final String id;
  final String beneficiaryId;
  final String beneficiaryFileNumber;
  final String associationId;
  final String? sponsorshipFileId;
  final String? candidateId;
  final String type;
  final String status;
  final num amount;
  final String currency;
  final String frequency;
  final String? startDate;
  final String? endDate;
  final String? sponsorName;
  final String? sponsorPhone;
  final String? sponsorCountry;
  final String? notes;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SponsorshipEntity({
    required this.id,
    required this.beneficiaryId,
    required this.beneficiaryFileNumber,
    required this.associationId,
    required this.type,
    required this.status,
    required this.amount,
    required this.currency,
    required this.frequency,
    this.sponsorshipFileId,
    this.candidateId,
    this.startDate,
    this.endDate,
    this.sponsorName,
    this.sponsorPhone,
    this.sponsorCountry,
    this.notes,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });
}

class SponsorshipPaymentEntity {
  final String id;
  final String sponsorshipId;
  final String beneficiaryId;
  final String associationId;
  final num amount;
  final String currency;
  final String paymentDate;
  final String period;
  final String status;
  final String? receiptUrl;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SponsorshipPaymentEntity({
    required this.id,
    required this.sponsorshipId,
    required this.beneficiaryId,
    required this.associationId,
    required this.amount,
    required this.currency,
    required this.paymentDate,
    required this.period,
    required this.status,
    this.receiptUrl,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });
}
