class BeneficiaryVisitFirestoreEntity {
  final String id;
  final String beneficiaryId;
  final String beneficiaryFileNumber;
  final String? sponsorshipId;
  final String? associationId;
  final String visitType;
  final String status;
  final String? scheduledAt;
  final String? completedAt;
  final String? visitedBy;
  final String? visitedByName;
  final String? locationGovernorate;
  final String? locationCity;
  final String? locationAddress;
  final String? summary;
  final List<String> needs;
  final String? recommendations;
  final String? nextVisitAt;
  final List<String> attachments;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BeneficiaryVisitFirestoreEntity({
    required this.id,
    required this.beneficiaryId,
    required this.beneficiaryFileNumber,
    required this.visitType,
    required this.status,
    this.sponsorshipId,
    this.associationId,
    this.scheduledAt,
    this.completedAt,
    this.visitedBy,
    this.visitedByName,
    this.locationGovernorate,
    this.locationCity,
    this.locationAddress,
    this.summary,
    this.needs = const <String>[],
    this.recommendations,
    this.nextVisitAt,
    this.attachments = const <String>[],
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });
}

class BeneficiaryFollowupEntity {
  final String id;
  final String beneficiaryId;
  final String? relatedVisitId;
  final String? relatedSponsorshipId;
  final String type;
  final String status;
  final String title;
  final String? description;
  final String? assignedTo;
  final String? dueDate;
  final String? completedAt;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BeneficiaryFollowupEntity({
    required this.id,
    required this.beneficiaryId,
    required this.type,
    required this.status,
    required this.title,
    this.relatedVisitId,
    this.relatedSponsorshipId,
    this.description,
    this.assignedTo,
    this.dueDate,
    this.completedAt,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });
}
