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
    super.birthDate,
    super.motherName,
    super.fatherName,
    super.grandFatherName,
    super.familyName,
    super.phoneNumber,
    super.altPhoneNumber,
    super.governorate,
    super.district,
    super.address,
    super.currentAddress,
    super.addressBeforeDisplacement,
    super.fileNo,
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
    super.notes,
    required super.createdAt,
    required super.updatedAt,
    super.needsSync = false,
  });

  /// Create from Drift database row
  factory BeneficiaryModel.fromDrift(Beneficiary data) {
    return BeneficiaryModel(
      id: data.id,
      fullName: data.fullName,
      nationalId: data.nationalId,
      gender: domain.Gender.fromString(data.gender),
      category: domain.BeneficiaryCategory.fromString(data.category),
      birthDate: data.birthDate,
      motherName: data.motherName,
      fatherName: data.fatherName,
      grandFatherName: data.grandFatherName,
      familyName: data.familyName,
      phoneNumber: data.phoneNumber,
      altPhoneNumber: data.altPhoneNumber,
      governorate: data.governorate,
      district: data.district,
      address: data.address,
      currentAddress: data.currentAddress,
      addressBeforeDisplacement: data.addressBeforeDisplacement,
      fileNo: data.fileNo,
      associationName: data.associationName,
      maritalStatus: data.maritalStatus != null
          ? _parseMaritalStatus(data.maritalStatus!)
          : null,
      educationLevel: data.educationLevel != null
          ? _parseEducationLevel(data.educationLevel!)
          : null,
      healthStatus: data.healthStatus != null
          ? domain.HealthStatus.fromString(data.healthStatus!)
          : domain.HealthStatus.good,
      hasDisability: data.hasDisability,
      familySize: data.familySize,
      numberOfMales: data.numberOfMales,
      numberOfFemales: data.numberOfFemales,
      chronicDiseasesCount: data.chronicDiseasesCount,
      specialNeedsCount: data.specialNeedsCount,
      displacementStatus: domain.DisplacementStatus.fromCode(
        data.displacementStatus,
      ),
      employmentStatus: domain.EmploymentStatus.fromCode(data.employmentStatus),
      housingStatus: domain.HousingStatus.fromCode(data.housingStatus),
      housingType: domain.HousingType.fromCode(data.housingType),
      requestStatus: domain.RequestStatus.fromCode(data.requestStatus),
      notes: data.notes.isEmpty ? null : data.notes,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      needsSync: data.syncState == 'pending',
    );
  }

  /// Convert to Drift companion for insert/update
  BeneficiariesCompanion toDrift() {
    return BeneficiariesCompanion(
      id: drift.Value(id),
      fullName: drift.Value(fullName),
      fullNameNorm: drift.Value(_normalizeArabic(fullName)),
      nationalId: drift.Value(nationalId),
      fileNo: drift.Value(fileNo ?? ''),
      governorate: drift.Value(governorate ?? ''),
      district: drift.Value(district),
      address: drift.Value(address),
      phoneNumber: drift.Value(phoneNumber),
      motherName: drift.Value(motherName),
      fatherName: drift.Value(fatherName),
      grandFatherName: drift.Value(grandFatherName),
      familyName: drift.Value(familyName),
      altPhoneNumber: drift.Value(altPhoneNumber),
      familySize: drift.Value(familySize),
      gender: drift.Value(gender.englishValue),
      category: drift.Value(category.englishValue),
      birthDate: drift.Value(birthDate),
      maritalStatus: drift.Value(maritalStatus?.arabicLabel),
      educationLevel: drift.Value(educationLevel?.arabicLabel),
      healthStatus: drift.Value(healthStatus.arabicLabel),
      hasDisability: drift.Value(hasDisability),
      displacementStatus: drift.Value(displacementStatus?.code),
      addressBeforeDisplacement: drift.Value(addressBeforeDisplacement),
      currentAddress: drift.Value(currentAddress),
      numberOfMales: drift.Value(numberOfMales),
      numberOfFemales: drift.Value(numberOfFemales),
      chronicDiseasesCount: drift.Value(chronicDiseasesCount),
      specialNeedsCount: drift.Value(specialNeedsCount),
      employmentStatus: drift.Value(employmentStatus?.code),
      housingStatus: drift.Value(housingStatus?.code),
      housingType: drift.Value(housingType?.code),
      requestStatus: drift.Value(requestStatus?.code),
      associationName: drift.Value(associationName),
      notes: drift.Value(notes ?? ''),
      createdAt: drift.Value(createdAt),
      updatedAt: drift.Value(updatedAt),
      syncState: drift.Value(needsSync ? 'pending' : 'synced'),
    );
  }

  /// Normalize Arabic text for search
  static String _normalizeArabic(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .toLowerCase();
  }

  /// Parse marital status from string
  static domain.MaritalStatus? _parseMaritalStatus(String value) {
    return domain.MaritalStatus.values
        .where((s) => s.arabicLabel == value)
        .firstOrNull;
  }

  /// Parse education level from string
  static domain.EducationLevel? _parseEducationLevel(String value) {
    return domain.EducationLevel.values
        .where((e) => e.arabicLabel == value)
        .firstOrNull;
  }
}
