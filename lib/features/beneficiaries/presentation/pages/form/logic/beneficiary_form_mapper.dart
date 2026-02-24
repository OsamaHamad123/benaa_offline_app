import '../../../../domain/entities/beneficiary.dart';
import '../../v2_form_helpers/form_controllers.dart';
import '../../v2_form_helpers/form_data_handler.dart';

/// 🎯 Form Data Mapper - Maps between UI controllers and domain entities
/// Updated to match actual Beneficiary entity structure
class BeneficiaryFormMapper {
  /// Map controllers to Beneficiary entity for saving
  static Beneficiary mapControllersToBeneficiary({
    required BeneficiaryFormControllers controllers,
    String? beneficiaryId,
    String? createdByUser,
  }) {
    final creator = createdByUser?.trim();
    if ((controllers.createdByUserController.text.trim().isEmpty) && (creator?.isNotEmpty == true)) {
      controllers.createdByUserController.text = creator!;
    }

    final fileNo = controllers.fileNumberController.text.trim().isNotEmpty
        ? controllers.fileNumberController.text.trim()
        : 'F-${DateTime.now().millisecondsSinceEpoch}';

    return BeneficiaryFormDataHandler.buildBeneficiary(
      controllers: controllers,
      beneficiaryId: beneficiaryId,
      fileNo: fileNo,
      createdAt: DateTime.now(),
    );
  }

  /// Map Beneficiary entity to controllers for editing
  static void mapBeneficiaryToControllers({
    required Beneficiary beneficiary,
    required BeneficiaryFormControllers controllers,
  }) {
    // Split fullName إلى أجزاء
    final nameParts = beneficiary.fullName.split(' ');

    controllers.firstNameController.text = nameParts.isNotEmpty ? nameParts[0] : '';
    controllers.fatherNameController.text = nameParts.length > 1 ? nameParts[1] : '';
    controllers.grandfatherNameController.text = nameParts.length > 2 ? nameParts[2] : '';
    controllers.lastNameController.text = nameParts.length > 3 ? nameParts[3] : '';
    controllers.motherNameController.text = beneficiary.motherName ?? '';

    controllers.nationalIdController.text = beneficiary.nationalId;

    // Format DateTime to string for birthDate
    if (beneficiary.birthDate != null) {
      controllers.birthDateController.text = _formatDate(beneficiary.birthDate!);
    }

    // Contact Info
    controllers.phoneController.text = beneficiary.phoneNumber ?? '';
    controllers.altPhoneController.text = beneficiary.altPhoneNumber ?? '';
    controllers.addressController.text = beneficiary.address ?? '';
    controllers.neighborhoodController.text = ''; // غير موجود في Entity
    controllers.addressBeforeDisplacementController.text = beneficiary.addressBeforeDisplacement ?? '';

    // Dropdowns - Convert enums back to strings
    controllers.selectedGender = beneficiary.gender.arabicLabel;
    controllers.selectedMaritalStatus = beneficiary.maritalStatus?.arabicLabel;
    controllers.selectedEducationLevel = beneficiary.educationLevel?.arabicLabel;
    controllers.selectedEmploymentStatus = beneficiary.employmentStatus?.arabicLabel.toString();
    controllers.selectedCategory = beneficiary.category.code.toString();
    controllers.selectedDisplacementStatus = beneficiary.displacementStatus?.arabicLabel;
    controllers.selectedHealthStatus = beneficiary.healthStatus.arabicLabel;
    controllers.selectedHousingStatus = beneficiary.housingStatus?.arabicLabel;
    controllers.selectedHousingType = beneficiary.housingType?.arabicLabel;
    controllers.selectedRequestStatus = beneficiary.requestStatus?.arabicLabel; // 🆕 NEW
    controllers.specialNeedsCountController.text = beneficiary.specialNeedsCount?.toString() ?? ''; // 🆕 NEW

    // Convert relationship int to string representation
    controllers.selectedRelationship = beneficiary.relationship?.toString();
    controllers.selectedSection = beneficiary.sectionId?.toString();
    controllers.createdByUserController.text = beneficiary.createdByUser ?? ''; // 🆕 Created by user
    controllers.fileNumberController.text = beneficiary.fileNo ?? ''; // 🆕 NEW

    // Convert location codes to strings
    controllers.selectedProvince = beneficiary.governorate;
    controllers.selectedCity = _normalizeCityText(beneficiary.district);

    // Family counts
    if (beneficiary.numberOfMales != null) {
      controllers.numberOfMalesController.text = beneficiary.numberOfMales.toString();
    }
    if (beneficiary.numberOfFemales != null) {
      controllers.numberOfFemalesController.text = beneficiary.numberOfFemales.toString();
    }
    if (beneficiary.chronicDiseasesCount != null) {
      controllers.chronicDiseasesController.text = beneficiary.chronicDiseasesCount.toString();
    }

    // Notes
    controllers.notesController.text = beneficiary.notes ?? '';
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
      'specialNeedsCount': controllers.specialNeedsCountController.text,
      'relationship': controllers.selectedRelationship,
      'section': controllers.selectedSection,
      'createdByUser': controllers.createdByUserController.text, // 🆕 Created by user
      'province': controllers.selectedProvince,
      'city': _normalizeCityText(controllers.selectedCity),
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
    final specialNeedsCountRaw = formData['specialNeedsCount']?.toString();
    if (specialNeedsCountRaw != null && specialNeedsCountRaw.trim().isNotEmpty) {
      controllers.specialNeedsCountController.text = specialNeedsCountRaw;
    } else {
      final legacyHasDisability = formData['hasDisability'] == true;
      controllers.specialNeedsCountController.text = legacyHasDisability ? '1' : '';
    }
    controllers.selectedRelationship = formData['relationship'];
    controllers.selectedSection = formData['section'];
    controllers.createdByUserController.text = formData['createdByUser'] ?? ''; // 🆕 Created by user
    controllers.selectedProvince = formData['province'];
    controllers.selectedCity = _normalizeCityText(formData['city']?.toString());

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

    return filled;
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String? _normalizeCityText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed.replaceAll(RegExp(r'\s+'), ' ');
  }
}
