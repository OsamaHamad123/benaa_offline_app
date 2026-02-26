import 'package:drift/drift.dart' as drift;
import '../../domain/entities/beneficiary.dart' as domain;
import '../../../../data/db/drift_database.dart';

/// 📦 Beneficiary Model - Data Layer
///
/// Maps between Drift database and domain entity.
class BeneficiaryModel extends domain.Beneficiary {
  const BeneficiaryModel({
    required super.id,
    required super.fullName,
    required super.nationalId,
    required super.gender,
    required super.category,
    required super.createdAt,
    required super.updatedAt,
    super.birthDate,
    super.motherName,
    super.fatherName,
    super.grandFatherName,
    super.familyName,
    super.relationship,
    super.sectionId,
    super.phoneNumber,
    super.altPhoneNumber,
    super.governorate,
    super.district,
    super.address,
    super.currentAddress,
    super.addressBeforeDisplacement,
    super.fileNo,
    super.fileIdNumber,
    super.associationName,
    super.maritalStatus,
    super.educationLevel,
    super.healthStatus = domain.HealthStatus.good,
    super.hasDisability = false,
    super.familySize,
    super.numberOfMales,
    super.numberOfFemales,
    super.chronicDiseasesCount,
    super.specialNeedsCount,
    super.displacementStatus,
    super.employmentStatus,
    super.housingStatus,
    super.housingType,
    super.requestStatus,
    super.assistanceTypeCode,
    super.disabilityTypeCode,
    super.incomeSourceCode,
    super.guaranteeTypeCode,
    super.notes,
    super.createdByUser,
    super.needsSync = false,
  });

  /// Create from Drift database row (NEW SCHEMA)
  factory BeneficiaryModel.fromDrift(Beneficiary data) {
    // Build full name from parts
    final fullName = _buildFullName(
      data.firstName,
      data.fatherName,
      data.grandFatherName,
      data.familyName,
    );

    return BeneficiaryModel(
      id: data.id.toString(),
      fullName: fullName,
      nationalId: data.idNumber.toString(),
      gender: data.gender == 1 ? domain.Gender.male : domain.Gender.female,
      category: domain.BeneficiaryCategory.fromCode(data.sectionId),
      sectionId: data.sectionId,
      birthDate: data.birthDate,
      fatherName: data.fatherName,
      grandFatherName: data.grandFatherName,
      familyName: data.familyName,
      relationship: data.relationship,
      phoneNumber: data.phoneNumber.toString(),
      altPhoneNumber: data.altPhoneNumber != 0 ? data.altPhoneNumber.toString() : null,
      governorate: data.province?.toString(),
      district: data.city?.toString(),
      currentAddress: data.currentAddress,
      addressBeforeDisplacement: data.addressBeforeDisplacement,
      fileNo: data.fileIdNumber,
      fileIdNumber: data.fileIdNumber,
      maritalStatus: _codeToMaritalStatus(data.maritalStatus),
      educationLevel: _codeToEducationLevel(data.academicQualification),
      healthStatus: _codeToHealthStatus(data.healthStatus),
      hasDisability: (data.numberOfPeopleWithSpecialNeeds ?? 0) > 0,
      familySize: data.numberOfIndividuals,
      numberOfMales: data.numberOfMales,
      numberOfFemales: data.numberOfFemales,
      chronicDiseasesCount: data.numberOfIndividualsWithChronicDiseases,
      specialNeedsCount: data.numberOfPeopleWithSpecialNeeds,
      displacementStatus: domain.DisplacementStatus.fromCode(
        data.displacementStatus,
      ),
      employmentStatus: domain.EmploymentStatus.fromCode(
        data.employmentStatusBreadwinner,
      ),
      housingStatus: domain.HousingStatus.fromCode(data.housingStatus),
      housingType: domain.HousingType.fromCode(data.currentHousingType),
      requestStatus: domain.RequestStatus.fromCode(data.requestStatus),
      assistanceTypeCode: data.assistanceTypeCode,
      disabilityTypeCode: data.disabilityTypeCode,
      incomeSourceCode: data.incomeSourceCode,
      guaranteeTypeCode: data.guaranteeTypeCode,
      notes: data.descriptionNeeds,
      createdByUser: data.userInsertData,
      createdAt: data.createdAt ?? DateTime.now(),
      updatedAt: data.updatedAt ?? DateTime.now(),
      needsSync: data.syncState == 'pending',
    );
  }

  /// Build full name from parts
  static String _buildFullName(
    String? firstName,
    String? fatherName,
    String? grandFatherName,
    String? familyName,
  ) {
    return [
      firstName,
      fatherName,
      grandFatherName,
      familyName,
    ].where((part) => part != null && part.isNotEmpty).join(' ').trim();
  }

  /// Convert to Drift companion for insert/update (NEW SCHEMA)
  BeneficiariesCompanion toDrift() {
    // Split full name into parts (simple approach)
    final nameParts = fullName.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts[0] : null;
    final fatherName = nameParts.length > 1 ? nameParts[1] : this.fatherName;
    final grandFatherName = nameParts.length > 2 ? nameParts[2] : this.grandFatherName;
    final familyName = nameParts.length > 3 ? nameParts.sublist(3).join(' ') : this.familyName;

    return BeneficiariesCompanion.insert(
      idNumber: int.tryParse(nationalId) ?? 0,
      phoneNumber: int.tryParse(phoneNumber?.replaceAll(RegExp(r'\D'), '') ?? '0') ?? 0,
      altPhoneNumber: int.tryParse(altPhoneNumber?.replaceAll(RegExp(r'\D'), '') ?? '0') ?? 0,
      fileIdNumber: drift.Value(fileIdNumber),
      sectionId: drift.Value(sectionId ?? category.code),
      requestStatus: drift.Value(requestStatus?.code ?? 1),
      firstName: drift.Value(firstName),
      fatherName: drift.Value(fatherName),
      grandFatherName: drift.Value(grandFatherName),
      familyName: drift.Value(familyName),
      relationship: drift.Value(relationship),
      birthDate: drift.Value(birthDate),
      gender: drift.Value(gender == domain.Gender.male ? 1 : 2),
      numberOfIndividuals: drift.Value(familySize),
      maritalStatus: drift.Value(_maritalStatusToCode(maritalStatus)),
      numberOfMales: drift.Value(numberOfMales),
      numberOfFemales: drift.Value(numberOfFemales),
      academicQualification: drift.Value(_educationLevelToCode(educationLevel)),
      employmentStatusBreadwinner: drift.Value(employmentStatus?.code),
      displacementStatus: drift.Value(displacementStatus?.code),
      addressBeforeDisplacement: drift.Value(addressBeforeDisplacement),
      currentAddress: drift.Value(currentAddress),
      city: drift.Value(int.tryParse(district ?? '0')),
      province: drift.Value(int.tryParse(governorate ?? '0')),
      healthStatus: drift.Value(_healthStatusToCode(healthStatus)),
      numberOfIndividualsWithChronicDiseases: drift.Value(chronicDiseasesCount),
      numberOfPeopleWithSpecialNeeds: drift.Value(specialNeedsCount),
      housingStatus: drift.Value(housingStatus?.code),
      currentHousingType: drift.Value(housingType?.code),
      assistanceTypeCode: drift.Value(assistanceTypeCode),
      disabilityTypeCode: drift.Value(disabilityTypeCode),
      incomeSourceCode: drift.Value(incomeSourceCode),
      guaranteeTypeCode: drift.Value(guaranteeTypeCode),
      descriptionNeeds: drift.Value(notes),
      userInsertData: drift.Value(createdByUser),
      createdAt: drift.Value(createdAt),
      updatedAt: drift.Value(updatedAt),
      syncState: drift.Value(needsSync ? 'pending' : 'synced'),
    );
  }

  // ========================================================================
  // Helper Methods for Code Conversion
  // ========================================================================

  /// Convert MaritalStatus enum to integer code
  static int? _maritalStatusToCode(domain.MaritalStatus? status) {
    if (status == null) return null;
    switch (status) {
      case domain.MaritalStatus.single:
        return 1;
      case domain.MaritalStatus.married:
        return 2;
      case domain.MaritalStatus.divorced:
        return 3;
      case domain.MaritalStatus.widowed:
        return 4;
    }
  }

  /// Convert integer code to MaritalStatus enum
  static domain.MaritalStatus? _codeToMaritalStatus(int? code) {
    if (code == null) return null;
    switch (code) {
      case 1:
        return domain.MaritalStatus.single;
      case 2:
        return domain.MaritalStatus.married;
      case 3:
        return domain.MaritalStatus.divorced;
      case 4:
        return domain.MaritalStatus.widowed;
      default:
        return null;
    }
  }

  /// Convert EducationLevel enum to integer code
  static int? _educationLevelToCode(domain.EducationLevel? level) {
    if (level == null) return null;
    switch (level) {
      case domain.EducationLevel.none:
      case domain.EducationLevel.illiterate:
        return 1;
      case domain.EducationLevel.primary:
        return 2;
      case domain.EducationLevel.intermediate:
        return 3;
      case domain.EducationLevel.secondary:
        return 4;
      case domain.EducationLevel.diploma:
      case domain.EducationLevel.bachelor:
        return 5;
      case domain.EducationLevel.master:
      case domain.EducationLevel.phd:
        return 6;
    }
  }

  /// Convert integer code to EducationLevel enum
  static domain.EducationLevel? _codeToEducationLevel(int? code) {
    if (code == null) return null;
    switch (code) {
      case 1:
        return domain.EducationLevel.none;
      case 2:
        return domain.EducationLevel.primary;
      case 3:
        return domain.EducationLevel.intermediate;
      case 4:
        return domain.EducationLevel.secondary;
      case 5:
        return domain.EducationLevel.bachelor;
      case 6:
        return domain.EducationLevel.master;
      default:
        return null;
    }
  }

  /// Convert HealthStatus enum to integer code
  static int? _healthStatusToCode(domain.HealthStatus? status) {
    if (status == null) return 1; // Default: good
    switch (status) {
      case domain.HealthStatus.good:
        return 1;
      case domain.HealthStatus.fair:
        return 2;
      case domain.HealthStatus.chronicDisease:
        return 3;
      case domain.HealthStatus.disability:
        return 4;
      case domain.HealthStatus.poor:
        return 5;
    }
  }

  /// Convert integer code to HealthStatus enum
  static domain.HealthStatus _codeToHealthStatus(int? code) {
    switch (code) {
      case 2:
        return domain.HealthStatus.fair;
      case 3:
        return domain.HealthStatus.chronicDisease;
      case 4:
        return domain.HealthStatus.disability;
      case 5:
        return domain.HealthStatus.poor;
      default:
        return domain.HealthStatus.good;
    }
  }
}
