import 'package:flutter/material.dart';
import '../../../domain/entities/beneficiary.dart';
import 'form_controllers.dart';

/// 🔄 Form Data Handler
///
/// Handles data loading and entity building
class BeneficiaryFormDataHandler {
  static Gender _parseGender(String? value) {
    if (value == null || value.trim().isEmpty) return Gender.unknown;
    final normalized = value.trim();

    if (normalized == '1' || normalized == 'male' || normalized == 'ذكر') {
      return Gender.male;
    }
    if (normalized == '2' || normalized == 'female' || normalized == 'أنثى') {
      return Gender.female;
    }

    return Gender.fromString(normalized);
  }

  static BeneficiaryCategory _parseCategory(String? value) {
    if (value == null || value.trim().isEmpty) return BeneficiaryCategory.poor;
    final normalized = value.trim();

    final code = int.tryParse(normalized);
    if (code != null) {
      return BeneficiaryCategory.fromCode(code);
    }

    return BeneficiaryCategory.values.firstWhere(
      (category) =>
          category.name == normalized || category.englishValue == normalized || category.arabicLabel == normalized,
      orElse: () => BeneficiaryCategory.poor,
    );
  }

  static MaritalStatus? _parseMaritalStatus(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final normalized = value.trim();

    final code = int.tryParse(normalized);
    if (code != null) {
      switch (code) {
        case 1:
          return MaritalStatus.single;
        case 2:
          return MaritalStatus.married;
        case 3:
          return MaritalStatus.divorced;
        case 4:
          return MaritalStatus.widowed;
      }
    }

    return MaritalStatus.values.firstWhere(
      (status) =>
          status.name.toLowerCase() == normalized.toLowerCase() ||
          status.arabicLabel == normalized ||
          (status == MaritalStatus.single && (normalized == 'أعزب/عزباء' || normalized == 'اعزب/عزباء')) ||
          (status == MaritalStatus.married && (normalized == 'متزوج' || normalized == 'متزوجة')) ||
          (status == MaritalStatus.divorced && (normalized == 'مطلق' || normalized == 'مطلقة')) ||
          (status == MaritalStatus.widowed &&
              (normalized == 'أرمل' || normalized == 'أرملة' || normalized == 'ارمل' || normalized == 'ارملة')),
      orElse: () => MaritalStatus.single,
    );
  }

  static EducationLevel? _parseEducationLevel(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final normalized = value.trim();

    final code = int.tryParse(normalized);
    if (code != null) {
      switch (code) {
        case 1:
          return EducationLevel.none;
        case 2:
          return EducationLevel.primary;
        case 3:
          return EducationLevel.intermediate;
        case 4:
          return EducationLevel.secondary;
        case 5:
          return EducationLevel.diploma;
        case 6:
          return EducationLevel.bachelor;
        case 7:
          return EducationLevel.master;
        case 8:
          return EducationLevel.phd;
      }
    }

    return EducationLevel.values.firstWhere(
      (level) => level.name.toLowerCase() == normalized.toLowerCase() || level.arabicLabel == normalized,
      orElse: () => EducationLevel.none,
    );
  }

  static EmploymentStatus? _parseEmploymentStatus(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final normalized = value.trim();

    final code = int.tryParse(normalized);
    if (code != null) {
      return EmploymentStatus.fromCode(code);
    }

    return EmploymentStatus.values.firstWhere(
      (status) => status.name == normalized || status.arabicLabel == normalized,
      orElse: () => EmploymentStatus.unemployed,
    );
  }

  static DisplacementStatus? _parseDisplacementStatus(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final normalized = value.trim();

    final code = int.tryParse(normalized);
    if (code != null) {
      return DisplacementStatus.fromCode(code);
    }

    return DisplacementStatus.values.firstWhere(
      (status) => status.name == normalized || status.arabicLabel == normalized,
      orElse: () => DisplacementStatus.notDisplaced,
    );
  }

  static HousingStatus? _parseHousingStatus(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final normalized = value.trim();

    final code = int.tryParse(normalized);
    if (code != null) {
      return HousingStatus.fromCode(code);
    }

    return HousingStatus.values.firstWhere(
      (status) => status.name == normalized || status.arabicLabel == normalized,
      orElse: () => HousingStatus.rented,
    );
  }

  static HousingType? _parseHousingType(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final normalized = value.trim();

    final code = int.tryParse(normalized);
    if (code != null) {
      return HousingType.fromCode(code);
    }

    return HousingType.values.firstWhere(
      (type) => type.name == normalized || type.arabicLabel == normalized,
      orElse: () => HousingType.other,
    );
  }

  static HealthStatus _parseHealthStatus(String? value) {
    if (value == null || value.trim().isEmpty) return HealthStatus.good;
    final normalized = value.trim();
    final code = int.tryParse(normalized);
    if (code != null) {
      switch (code) {
        case 1:
          return HealthStatus.good;
        case 2:
          return HealthStatus.fair;
        case 3:
          return HealthStatus.chronicDisease;
        case 4:
          return HealthStatus.disability;
        case 5:
          return HealthStatus.poor;
      }
    }
    return HealthStatus.fromString(normalized);
  }

  static RequestStatus? _parseRequestStatus(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final normalized = value.trim();

    final code = int.tryParse(normalized);
    if (code != null) {
      return RequestStatus.fromCode(code);
    }

    return RequestStatus.values.firstWhere(
      (status) => status.name.toLowerCase() == normalized.toLowerCase() || status.arabicLabel == normalized,
      orElse: () => RequestStatus.pending,
    );
  }

  /// Populate controllers from existing beneficiary
  static void populateControllers(
    BeneficiaryFormControllers controllers,
    Beneficiary beneficiary,
    Function(VoidCallback) setState,
  ) {
    final nameParts = beneficiary.fullName.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();

    // Basic Info
    controllers.firstNameController.text = nameParts.isNotEmpty ? nameParts.first : '';
    controllers.fatherNameController.text = beneficiary.fatherName ?? '';
    controllers.grandfatherNameController.text = beneficiary.grandFatherName ?? '';
    controllers.lastNameController.text = beneficiary.familyName ?? '';
    controllers.motherNameController.text = beneficiary.motherName ?? '';
    controllers.nationalIdController.text = beneficiary.nationalId;
    controllers.birthDateController.text = beneficiary.birthDate?.toString().split(' ')[0] ?? '';

    // Contact
    controllers.phoneController.text = beneficiary.phoneNumber ?? '';
    controllers.altPhoneController.text = beneficiary.altPhoneNumber ?? '';
    controllers.addressController.text = beneficiary.address ?? '';
    controllers.neighborhoodController.text = beneficiary.district ?? '';
    controllers.chronicDiseasesController.text = beneficiary.chronicDiseasesCount?.toString() ?? '';
    controllers.addressBeforeDisplacementController.text = beneficiary.addressBeforeDisplacement ?? '';

    // Family
    controllers.numberOfDependentsController.text = beneficiary.familySize?.toString() ?? '';
    controllers.numberOfMalesController.text = beneficiary.numberOfMales?.toString() ?? '';
    controllers.numberOfFemalesController.text = beneficiary.numberOfFemales?.toString() ?? '';

    // Notes
    controllers.notesController.text = beneficiary.notes ?? '';

    setState(() {
      controllers.selectedGender = beneficiary.gender == Gender.unknown ? null : beneficiary.gender.englishValue;
      controllers.selectedMaritalStatus = beneficiary.maritalStatus?.name;
      controllers.selectedEducationLevel = beneficiary.educationLevel?.name;
      controllers.selectedEmploymentStatus = beneficiary.employmentStatus?.name;
      controllers.selectedHealthStatus = beneficiary.healthStatus.name;
      controllers.selectedCategory = beneficiary.category.code.toString();
      controllers.selectedDisplacementStatus = beneficiary.displacementStatus?.name;
      controllers.selectedHousingStatus = beneficiary.housingStatus?.name;
      controllers.selectedHousingType = beneficiary.housingType?.name;
      controllers.selectedRequestStatus = beneficiary.requestStatus?.name;
      controllers.selectedRelationship = beneficiary.relationship?.toString();
      controllers.selectedSection = beneficiary.sectionId?.toString();
      controllers.hasDisability = beneficiary.hasDisability;
      // Note: city, province, relationship need enum conversion from IDs
    });
  }

  /// Build beneficiary entity from form data
  static Beneficiary buildBeneficiary({
    required BeneficiaryFormControllers controllers,
    required String? beneficiaryId,
    required String fileNo,
    required DateTime createdAt,
  }) {
    final now = DateTime.now();

    // Build full name
    final fullName = [
      controllers.firstNameController.text.trim(),
      controllers.fatherNameController.text.trim(),
      controllers.grandfatherNameController.text.trim(),
      controllers.lastNameController.text.trim(),
    ].where((s) => s.isNotEmpty).join(' ');

    // Parse taxonomy-backed values safely (code/name/label)
    final gender = _parseGender(controllers.selectedGender);
    final category = _parseCategory(controllers.selectedCategory);
    final maritalStatus = _parseMaritalStatus(controllers.selectedMaritalStatus);
    final educationLevel = _parseEducationLevel(controllers.selectedEducationLevel);
    final employmentStatus = _parseEmploymentStatus(controllers.selectedEmploymentStatus);
    final displacementStatus = _parseDisplacementStatus(controllers.selectedDisplacementStatus);
    final housingStatus = _parseHousingStatus(controllers.selectedHousingStatus);
    final housingType = _parseHousingType(controllers.selectedHousingType);
    final healthStatus = _parseHealthStatus(controllers.selectedHealthStatus);
    final requestStatus = _parseRequestStatus(controllers.selectedRequestStatus);
    final relationshipCode = int.tryParse(controllers.selectedRelationship ?? '');
    final sectionCode = int.tryParse(controllers.selectedSection ?? '');

    return Beneficiary(
      id: beneficiaryId ?? '',
      fullName: fullName,
      nationalId: controllers.nationalIdController.text.trim(),
      fileNo: fileNo,
      gender: gender,
      category: category,
      birthDate: controllers.birthDateController.text.isNotEmpty
          ? DateTime.tryParse(controllers.birthDateController.text)
          : null,
      motherName:
          controllers.motherNameController.text.trim().isEmpty ? null : controllers.motherNameController.text.trim(),
      fatherName:
          controllers.fatherNameController.text.trim().isEmpty ? null : controllers.fatherNameController.text.trim(),
      grandFatherName: controllers.grandfatherNameController.text.trim().isEmpty
          ? null
          : controllers.grandfatherNameController.text.trim(),
      familyName:
          controllers.lastNameController.text.trim().isEmpty ? null : controllers.lastNameController.text.trim(),
      phoneNumber: controllers.phoneController.text.trim().isEmpty ? null : controllers.phoneController.text.trim(),
      altPhoneNumber:
          controllers.altPhoneController.text.trim().isEmpty ? null : controllers.altPhoneController.text.trim(),
      address: controllers.addressController.text.trim().isEmpty ? null : controllers.addressController.text.trim(),
      district: controllers.neighborhoodController.text.trim().isEmpty
          ? null
          : controllers.neighborhoodController.text.trim(),
      governorate: controllers.selectedProvince,
      relationship: relationshipCode,
      sectionId: sectionCode,
      currentAddress:
          controllers.addressController.text.trim().isEmpty ? null : controllers.addressController.text.trim(),
      addressBeforeDisplacement: controllers.addressBeforeDisplacementController.text.trim().isEmpty
          ? null
          : controllers.addressBeforeDisplacementController.text.trim(),
      maritalStatus: maritalStatus,
      educationLevel: educationLevel,
      employmentStatus: employmentStatus,
      displacementStatus: displacementStatus,
      healthStatus: healthStatus,
      requestStatus: requestStatus,
      housingStatus: housingStatus,
      housingType: housingType,
      hasDisability: controllers.hasDisability,
      chronicDiseasesCount: controllers.chronicDiseasesController.text.trim().isEmpty
          ? null
          : int.tryParse(controllers.chronicDiseasesController.text.trim()),
      familySize: controllers.numberOfDependentsController.text.trim().isEmpty
          ? null
          : int.tryParse(controllers.numberOfDependentsController.text.trim()),
      numberOfMales: controllers.numberOfMalesController.text.trim().isEmpty
          ? null
          : int.tryParse(controllers.numberOfMalesController.text.trim()),
      numberOfFemales: controllers.numberOfFemalesController.text.trim().isEmpty
          ? null
          : int.tryParse(controllers.numberOfFemalesController.text.trim()),
      notes: controllers.notesController.text.trim().isEmpty ? null : controllers.notesController.text.trim(),
      createdAt: createdAt,
      updatedAt: now,
    );
  }
}
