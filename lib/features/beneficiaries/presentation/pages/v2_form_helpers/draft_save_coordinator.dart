import 'form_controllers.dart';

/// 💾 Draft Save Coordinator
///
/// Centralizes draft payload and metadata creation logic.
class DraftSaveCoordinator {
  const DraftSaveCoordinator();

  /// Build draft form payload for auto-save with extended fields.
  Map<String, dynamic> buildAutoSaveFormData(BeneficiaryFormControllers controllers) {
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
      'selectedGender': controllers.selectedGender,
      'maritalStatus': controllers.selectedMaritalStatus,
      'selectedMaritalStatus': controllers.selectedMaritalStatus,
      'educationLevel': controllers.selectedEducationLevel,
      'selectedEducationLevel': controllers.selectedEducationLevel,
      'employmentStatus': controllers.selectedEmploymentStatus,
      'selectedEmploymentStatus': controllers.selectedEmploymentStatus,
      'category': controllers.selectedCategory,
      'selectedCategory': controllers.selectedCategory,
      'selectedRelationship': controllers.selectedRelationship,
      'selectedSection': controllers.selectedSection,
      'selectedCity': controllers.selectedCity,
      'selectedProvince': controllers.selectedProvince,
      'displacementStatus': controllers.selectedDisplacementStatus,
      'selectedDisplacementStatus': controllers.selectedDisplacementStatus,
      'healthStatus': controllers.selectedHealthStatus,
      'selectedHealthStatus': controllers.selectedHealthStatus,
      'housingStatus': controllers.selectedHousingStatus,
      'selectedHousingStatus': controllers.selectedHousingStatus,
      'housingType': controllers.selectedHousingType,
      'selectedHousingType': controllers.selectedHousingType,
      'disabilityType': controllers.selectedDisabilityType,
      'selectedDisabilityType': controllers.selectedDisabilityType,
      'incomeSource': controllers.selectedIncomeSource,
      'selectedIncomeSource': controllers.selectedIncomeSource,
      'requestStatus': controllers.selectedRequestStatus,
      'selectedRequestStatus': controllers.selectedRequestStatus,
      'assistanceType': controllers.selectedAssistanceType,
      'selectedAssistanceType': controllers.selectedAssistanceType,
      'hasDisability': controllers.hasDisability,
      'specialNeedsCount': controllers.specialNeedsCountController.text,
    };
  }

  /// Build draft form payload for manual save to preserve existing behavior.
  Map<String, dynamic> buildManualSaveFormData(BeneficiaryFormControllers controllers) {
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
      'selectedGender': controllers.selectedGender,
      'maritalStatus': controllers.selectedMaritalStatus,
      'selectedMaritalStatus': controllers.selectedMaritalStatus,
      'educationLevel': controllers.selectedEducationLevel,
      'selectedEducationLevel': controllers.selectedEducationLevel,
      'category': controllers.selectedCategory,
      'selectedCategory': controllers.selectedCategory,
      'selectedRelationship': controllers.selectedRelationship,
      'selectedSection': controllers.selectedSection,
      'selectedCity': controllers.selectedCity,
      'selectedProvince': controllers.selectedProvince,
      'displacementStatus': controllers.selectedDisplacementStatus,
      'selectedDisplacementStatus': controllers.selectedDisplacementStatus,
      'healthStatus': controllers.selectedHealthStatus,
      'selectedHealthStatus': controllers.selectedHealthStatus,
      'housingStatus': controllers.selectedHousingStatus,
      'selectedHousingStatus': controllers.selectedHousingStatus,
      'housingType': controllers.selectedHousingType,
      'selectedHousingType': controllers.selectedHousingType,
      'disabilityType': controllers.selectedDisabilityType,
      'selectedDisabilityType': controllers.selectedDisabilityType,
      'incomeSource': controllers.selectedIncomeSource,
      'selectedIncomeSource': controllers.selectedIncomeSource,
      'requestStatus': controllers.selectedRequestStatus,
      'selectedRequestStatus': controllers.selectedRequestStatus,
      'assistanceType': controllers.selectedAssistanceType,
      'selectedAssistanceType': controllers.selectedAssistanceType,
      'specialNeedsCount': controllers.specialNeedsCountController.text,
    };
  }

  String ensureAutoSaveDraftId({
    required String? currentDraftId,
    required String? beneficiaryId,
    required String nationalId,
    required DateTime now,
  }) {
    if (currentDraftId != null && currentDraftId.isNotEmpty) {
      return currentDraftId;
    }

    if (beneficiaryId != null && beneficiaryId.isNotEmpty) {
      return beneficiaryId;
    }

    if (nationalId.isNotEmpty) {
      return 'auto_draft_$nationalId';
    }

    return 'auto_draft_temp_${now.millisecondsSinceEpoch}';
  }

  String buildAutoDraftName(BeneficiaryFormControllers controllers) {
    final firstName = controllers.firstNameController.text.trim();
    final lastName = controllers.lastNameController.text.trim();

    if (firstName.isEmpty) {
      return 'مسودة جديدة';
    }

    return 'حفظ تلقائي - $firstName ${lastName.isNotEmpty ? lastName : ''}';
  }

  Map<String, dynamic> buildDraftEnvelope({
    required String name,
    required String notes,
    required Map<String, dynamic> formData,
    required int currentTab,
    required String? beneficiaryId,
    bool isAutoSaved = false,
  }) {
    return {
      'name': name,
      'notes': notes,
      'formData': formData,
      'currentTab': currentTab,
      'beneficiaryId': beneficiaryId,
      if (isAutoSaved) 'isAutoSaved': true,
    };
  }
}
