import 'package:flutter/material.dart';
import '../../../domain/entities/beneficiary.dart';
import 'form_controllers.dart';

/// 🔄 Form Data Handler
///
/// Handles data loading and entity building
class BeneficiaryFormDataHandler {
  /// Populate controllers from existing beneficiary
  static void populateControllers(
    BeneficiaryFormControllers controllers,
    Beneficiary beneficiary,
    Function(VoidCallback) setState,
  ) {
    // Basic Info
    controllers.firstNameController.text = beneficiary.fatherName ?? '';
    controllers.fatherNameController.text = beneficiary.fatherName ?? '';
    controllers.grandfatherNameController.text =
        beneficiary.grandFatherName ?? '';
    controllers.lastNameController.text = beneficiary.familyName ?? '';
    controllers.motherNameController.text = beneficiary.motherName ?? '';
    controllers.nationalIdController.text = beneficiary.nationalId;
    controllers.birthDateController.text =
        beneficiary.birthDate?.toString().split(' ')[0] ?? '';

    // Contact
    controllers.phoneController.text = beneficiary.phoneNumber ?? '';
    controllers.altPhoneController.text = beneficiary.altPhoneNumber ?? '';
    controllers.addressController.text = beneficiary.address ?? '';
    controllers.neighborhoodController.text = beneficiary.district ?? '';
    controllers.chronicDiseasesController.text =
        beneficiary.chronicDiseasesCount?.toString() ?? '';
    controllers.addressBeforeDisplacementController.text =
        beneficiary.addressBeforeDisplacement ?? '';

    // Family
    controllers.numberOfDependentsController.text =
        beneficiary.familySize?.toString() ?? '';
    controllers.numberOfMalesController.text =
        beneficiary.numberOfMales?.toString() ?? '';
    controllers.numberOfFemalesController.text =
        beneficiary.numberOfFemales?.toString() ?? '';

    // Notes
    controllers.notesController.text = beneficiary.notes ?? '';

    setState(() {
      // Map gender to Arabic display values
      controllers.selectedGender =
          beneficiary.gender == Gender.male ? 'ذكر' : 'أنثى';
      controllers.selectedMaritalStatus = beneficiary.maritalStatus?.name;
      controllers.selectedEducationLevel = beneficiary.educationLevel?.name;
      controllers.selectedEmploymentStatus = beneficiary.employmentStatus?.name;
      controllers.selectedHealthStatus = beneficiary.healthStatus.name;
      controllers.selectedCategory = beneficiary.category.name;
      controllers.selectedDisplacementStatus =
          beneficiary.displacementStatus?.name;
      controllers.selectedHousingStatus = beneficiary.housingStatus?.name;
      controllers.selectedHousingType = beneficiary.housingType?.name;
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

    // Parse gender
    final gender =
        controllers.selectedGender == 'ذكر' ? Gender.male : Gender.female;

    return Beneficiary(
      id: beneficiaryId ?? '',
      fullName: fullName,
      nationalId: controllers.nationalIdController.text.trim(),
      fileNo: fileNo,
      gender: gender,
      category: controllers.selectedCategory != null
          ? BeneficiaryCategory.values.firstWhere(
              (e) => e.name == controllers.selectedCategory,
              orElse: () => BeneficiaryCategory.poor,
            )
          : BeneficiaryCategory.poor,
      birthDate: controllers.birthDateController.text.isNotEmpty
          ? DateTime.tryParse(controllers.birthDateController.text)
          : null,
      motherName: controllers.motherNameController.text.trim().isEmpty
          ? null
          : controllers.motherNameController.text.trim(),
      fatherName: controllers.fatherNameController.text.trim().isEmpty
          ? null
          : controllers.fatherNameController.text.trim(),
      grandFatherName: controllers.grandfatherNameController.text.trim().isEmpty
          ? null
          : controllers.grandfatherNameController.text.trim(),
      familyName: controllers.lastNameController.text.trim().isEmpty
          ? null
          : controllers.lastNameController.text.trim(),
      phoneNumber: controllers.phoneController.text.trim().isEmpty
          ? null
          : controllers.phoneController.text.trim(),
      altPhoneNumber: controllers.altPhoneController.text.trim().isEmpty
          ? null
          : controllers.altPhoneController.text.trim(),
      address: controllers.addressController.text.trim().isEmpty
          ? null
          : controllers.addressController.text.trim(),
      district: controllers.neighborhoodController.text.trim().isEmpty
          ? null
          : controllers.neighborhoodController.text.trim(),
      governorate: controllers.selectedProvince,
      currentAddress: controllers.addressController.text.trim().isEmpty
          ? null
          : controllers.addressController.text.trim(),
      addressBeforeDisplacement:
          controllers.addressBeforeDisplacementController.text.trim().isEmpty
              ? null
              : controllers.addressBeforeDisplacementController.text.trim(),
      maritalStatus: controllers.selectedMaritalStatus != null
          ? MaritalStatus.values.firstWhere(
              (e) => e.name == controllers.selectedMaritalStatus,
              orElse: () => MaritalStatus.single,
            )
          : null,
      educationLevel: controllers.selectedEducationLevel != null
          ? EducationLevel.values.firstWhere(
              (e) => e.name == controllers.selectedEducationLevel,
              orElse: () => EducationLevel.none,
            )
          : null,
      employmentStatus: controllers.selectedEmploymentStatus != null
          ? EmploymentStatus.values.firstWhere(
              (e) => e.name == controllers.selectedEmploymentStatus,
              orElse: () => EmploymentStatus.unemployed,
            )
          : null,
      displacementStatus: controllers.selectedDisplacementStatus != null
          ? DisplacementStatus.values.firstWhere(
              (e) => e.name == controllers.selectedDisplacementStatus,
              orElse: () => DisplacementStatus.notDisplaced,
            )
          : null,
      healthStatus: controllers.selectedHealthStatus != null
          ? HealthStatus.values.firstWhere(
              (e) => e.name == controllers.selectedHealthStatus,
              orElse: () => HealthStatus.good,
            )
          : HealthStatus.good,
      housingStatus: controllers.selectedHousingStatus != null
          ? HousingStatus.values.firstWhere(
              (e) => e.name == controllers.selectedHousingStatus,
              orElse: () => HousingStatus.rented,
            )
          : null,
      housingType: controllers.selectedHousingType != null
          ? HousingType.values.firstWhere(
              (e) => e.name == controllers.selectedHousingType,
              orElse: () => HousingType.other,
            )
          : null,
      hasDisability: controllers.hasDisability,
      chronicDiseasesCount:
          controllers.chronicDiseasesController.text.trim().isEmpty
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
      notes: controllers.notesController.text.trim().isEmpty
          ? null
          : controllers.notesController.text.trim(),
      createdAt: createdAt,
      updatedAt: now,
    );
  }
}
