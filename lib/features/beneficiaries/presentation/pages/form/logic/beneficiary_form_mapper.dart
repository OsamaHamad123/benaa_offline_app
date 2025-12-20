import '../../../../domain/entities/beneficiary.dart';
import '../../v2_form_helpers/form_controllers.dart';

/// 🎯 Form Data Mapper - Maps between UI controllers and domain entities
class BeneficiaryFormMapper {
  /// Map controllers to Beneficiary entity for saving
  static Beneficiary mapControllersToBeneficiary({
    required BeneficiaryFormControllers controllers,
    String? beneficiaryId,
  }) {
    return Beneficiary(
      id: beneficiaryId,
      firstName: controllers.firstNameController.text.trim(),
      fatherName: controllers.fatherNameController.text.trim(),
      grandfatherName: controllers.grandfatherNameController.text.trim(),
      lastName: controllers.lastNameController.text.trim(),
      motherName:
          controllers.motherNameController.text.trim().isNotEmpty ? controllers.motherNameController.text.trim() : null,
      nationalId: controllers.nationalIdController.text.trim(),
      birthDate: controllers.birthDateController.text.trim(),
      gender: controllers.selectedGender,
      maritalStatus: controllers.selectedMaritalStatus,
      phone: controllers.phoneController.text.trim(),
      altPhone:
          controllers.altPhoneController.text.trim().isNotEmpty ? controllers.altPhoneController.text.trim() : null,
      address: controllers.addressController.text.trim(),
      neighborhood: controllers.neighborhoodController.text.trim().isNotEmpty
          ? controllers.neighborhoodController.text.trim()
          : null,
      educationLevel: controllers.selectedEducationLevel,
      employmentStatus: controllers.selectedEmploymentStatus,
      category: controllers.selectedCategory,
      displacementStatus: controllers.selectedDisplacementStatus,
      healthStatus: controllers.selectedHealthStatus,
      housingStatus: controllers.selectedHousingStatus,
      housingType: controllers.selectedHousingType,
      hasDisability: controllers.hasDisability,
      notes: controllers.notesController.text.trim().isNotEmpty ? controllers.notesController.text.trim() : null,
      createdAt: beneficiaryId == null ? DateTime.now() : null,
      updatedAt: DateTime.now(),
      livingMembers: controllers.livingMembers,
      deceasedMembers: controllers.deceasedMembers,
    );
  }

  /// Map Beneficiary entity to controllers for editing
  static void mapBeneficiaryToControllers({
    required Beneficiary beneficiary,
    required BeneficiaryFormControllers controllers,
  }) {
    // Basic Info
    controllers.firstNameController.text = beneficiary.firstName;
    controllers.fatherNameController.text = beneficiary.fatherName;
    controllers.grandfatherNameController.text = beneficiary.grandfatherName;
    controllers.lastNameController.text = beneficiary.lastName;
    controllers.motherNameController.text = beneficiary.motherName ?? '';
    controllers.nationalIdController.text = beneficiary.nationalId;
    controllers.birthDateController.text = beneficiary.birthDate;

    // Contact Info
    controllers.phoneController.text = beneficiary.phone;
    controllers.altPhoneController.text = beneficiary.altPhone ?? '';
    controllers.addressController.text = beneficiary.address;
    controllers.neighborhoodController.text = beneficiary.neighborhood ?? '';

    // Dropdowns
    controllers.selectedGender = beneficiary.gender;
    controllers.selectedMaritalStatus = beneficiary.maritalStatus;
    controllers.selectedEducationLevel = beneficiary.educationLevel;
    controllers.selectedEmploymentStatus = beneficiary.employmentStatus;
    controllers.selectedCategory = beneficiary.category;
    controllers.selectedDisplacementStatus = beneficiary.displacementStatus;
    controllers.selectedHealthStatus = beneficiary.healthStatus;
    controllers.selectedHousingStatus = beneficiary.housingStatus;
    controllers.selectedHousingType = beneficiary.housingType;
    controllers.hasDisability = beneficiary.hasDisability;

    // Notes
    controllers.notesController.text = beneficiary.notes ?? '';

    // Family Members
    controllers.livingMembers = beneficiary.livingMembers;
    controllers.deceasedMembers = beneficiary.deceasedMembers;
  }

  /// Map controllers to draft data (for auto-save)
  static Map<String, dynamic> mapControllersToDraftData({
    required BeneficiaryFormControllers controllers,
    required int currentTabIndex,
    String? beneficiaryId,
  }) {
    return {
      'firstName': controllers.firstNameController.text,
      'fatherName': controllers.fatherNameController.text,
      'grandfatherName': controllers.grandfatherNameController.text,
      'lastName': controllers.lastNameController.text,
      'motherName': controllers.motherNameController.text,
      'nationalId': controllers.nationalIdController.text,
      'birthDate': controllers.birthDateController.text,
      'phone': controllers.phoneController.text,
      'altPhone': controllers.altPhoneController.text,
      'address': controllers.addressController.text,
      'neighborhood': controllers.neighborhoodController.text,
      'notes': controllers.notesController.text,
      'gender': controllers.selectedGender,
      'maritalStatus': controllers.selectedMaritalStatus,
      'educationLevel': controllers.selectedEducationLevel,
      'employmentStatus': controllers.selectedEmploymentStatus,
      'category': controllers.selectedCategory,
      'displacementStatus': controllers.selectedDisplacementStatus,
      'healthStatus': controllers.selectedHealthStatus,
      'housingStatus': controllers.selectedHousingStatus,
      'housingType': controllers.selectedHousingType,
      'hasDisability': controllers.hasDisability,
      'currentTab': currentTabIndex,
      'beneficiaryId': beneficiaryId,
    };
  }

  /// Map draft data to controllers (for restoring)
  static void mapDraftDataToControllers({
    required Map<String, dynamic> draftData,
    required BeneficiaryFormControllers controllers,
  }) {
    final formData = draftData['formData'] as Map<String, dynamic>;

    // Basic Info
    controllers.firstNameController.text = formData['firstName'] ?? '';
    controllers.fatherNameController.text = formData['fatherName'] ?? '';
    controllers.grandfatherNameController.text = formData['grandfatherName'] ?? '';
    controllers.lastNameController.text = formData['lastName'] ?? '';
    controllers.motherNameController.text = formData['motherName'] ?? '';
    controllers.nationalIdController.text = formData['nationalId'] ?? '';
    controllers.birthDateController.text = formData['birthDate'] ?? '';

    // Contact Info
    controllers.phoneController.text = formData['phone'] ?? '';
    controllers.altPhoneController.text = formData['altPhone'] ?? '';
    controllers.addressController.text = formData['address'] ?? '';
    controllers.neighborhoodController.text = formData['neighborhood'] ?? '';

    // Dropdowns
    controllers.selectedGender = formData['gender'];
    controllers.selectedMaritalStatus = formData['maritalStatus'];
    controllers.selectedEducationLevel = formData['educationLevel'];
    controllers.selectedEmploymentStatus = formData['employmentStatus'];
    controllers.selectedCategory = formData['category'];
    controllers.selectedDisplacementStatus = formData['displacementStatus'];
    controllers.selectedHealthStatus = formData['healthStatus'];
    controllers.selectedHousingStatus = formData['housingStatus'];
    controllers.selectedHousingType = formData['housingType'];
    controllers.hasDisability = formData['hasDisability'] ?? false;

    // Notes
    controllers.notesController.text = formData['notes'] ?? '';
  }

  /// Calculate filled fields count
  static int calculateFilledFieldsCount(BeneficiaryFormControllers controllers) {
    int filled = 0;

    // Required text fields
    if (controllers.firstNameController.text.isNotEmpty) filled++;
    if (controllers.fatherNameController.text.isNotEmpty) filled++;
    if (controllers.grandfatherNameController.text.isNotEmpty) filled++;
    if (controllers.lastNameController.text.isNotEmpty) filled++;
    if (controllers.nationalIdController.text.isNotEmpty) filled++;
    if (controllers.birthDateController.text.isNotEmpty) filled++;
    if (controllers.phoneController.text.isNotEmpty) filled++;
    if (controllers.addressController.text.isNotEmpty) filled++;

    // Dropdowns
    if (controllers.selectedGender != null) filled++;
    if (controllers.selectedMaritalStatus != null) filled++;
    if (controllers.selectedEducationLevel != null) filled++;

    // Optional field: family members
    if (controllers.livingMembers.isNotEmpty || controllers.deceasedMembers.isNotEmpty) filled++;

    return filled;
  }
}
