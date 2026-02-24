import 'form_controllers.dart';
import 'form_constants.dart';

class DraftLoadResult {
  final int currentTab;

  const DraftLoadResult({required this.currentTab});
}

/// 📥 Draft Load Coordinator
///
/// Applies draft payload into form controllers.
class DraftLoadCoordinator {
  const DraftLoadCoordinator();

  String? _safeTaxonomyValue(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    if (value is num || value is bool) {
      return value.toString();
    }

    return null;
  }

  DraftLoadResult applyDraft({
    required BeneficiaryFormControllers controllers,
    required Map<String, dynamic> draft,
  }) {
    final formDataRaw = draft['formData'];
    if (formDataRaw is! Map<String, dynamic>) {
      throw const FormatException('Invalid draft formData');
    }

    controllers.firstNameController.text = (formDataRaw['firstName'] ?? '').toString();
    controllers.fatherNameController.text = (formDataRaw['fatherName'] ?? '').toString();
    controllers.grandfatherNameController.text = (formDataRaw['grandfatherName'] ?? '').toString();
    controllers.lastNameController.text = (formDataRaw['lastName'] ?? '').toString();
    controllers.motherNameController.text = (formDataRaw['motherName'] ?? '').toString();
    controllers.nationalIdController.text = (formDataRaw['nationalId'] ?? '').toString();
    controllers.phoneController.text = (formDataRaw['phone'] ?? '').toString();
    controllers.altPhoneController.text = (formDataRaw['altPhone'] ?? '').toString();
    controllers.addressController.text = (formDataRaw['address'] ?? '').toString();
    controllers.neighborhoodController.text = (formDataRaw['neighborhood'] ?? '').toString();
    controllers.notesController.text = (formDataRaw['notes'] ?? '').toString();

    final birthDate = formDataRaw['birthDate'];
    controllers.birthDateController.text = birthDate == null ? '' : birthDate.toString();

    controllers.selectedGender = _safeTaxonomyValue(formDataRaw['selectedGender'] ?? formDataRaw['gender']);
    controllers.selectedMaritalStatus =
        _safeTaxonomyValue(formDataRaw['selectedMaritalStatus'] ?? formDataRaw['maritalStatus']);
    controllers.selectedEducationLevel =
        _safeTaxonomyValue(formDataRaw['selectedEducationLevel'] ?? formDataRaw['educationLevel']);
    controllers.selectedEmploymentStatus =
        _safeTaxonomyValue(formDataRaw['selectedEmploymentStatus'] ?? formDataRaw['employmentStatus']);
    controllers.selectedCategory = _safeTaxonomyValue(formDataRaw['selectedCategory'] ?? formDataRaw['category']);
    controllers.selectedRelationship =
        _safeTaxonomyValue(formDataRaw['selectedRelationship'] ?? formDataRaw['relationship']);
    controllers.selectedSection = _safeTaxonomyValue(formDataRaw['selectedSection'] ?? formDataRaw['section']);
    controllers.selectedCity = _safeTaxonomyValue(formDataRaw['selectedCity'] ?? formDataRaw['city']);
    controllers.selectedProvince = _safeTaxonomyValue(formDataRaw['selectedProvince'] ?? formDataRaw['province']);
    controllers.selectedDisplacementStatus =
        _safeTaxonomyValue(formDataRaw['selectedDisplacementStatus'] ?? formDataRaw['displacementStatus']);
    controllers.selectedHealthStatus =
        _safeTaxonomyValue(formDataRaw['selectedHealthStatus'] ?? formDataRaw['healthStatus']);
    controllers.selectedHousingStatus =
        _safeTaxonomyValue(formDataRaw['selectedHousingStatus'] ?? formDataRaw['housingStatus']);
    controllers.selectedHousingType =
        _safeTaxonomyValue(formDataRaw['selectedHousingType'] ?? formDataRaw['housingType']);
    controllers.selectedDisabilityType =
        _safeTaxonomyValue(formDataRaw['selectedDisabilityType'] ?? formDataRaw['disabilityType']);
    controllers.selectedIncomeSource =
        _safeTaxonomyValue(formDataRaw['selectedIncomeSource'] ?? formDataRaw['incomeSource']);
    controllers.selectedRequestStatus =
        _safeTaxonomyValue(formDataRaw['selectedRequestStatus'] ?? formDataRaw['requestStatus']);
    controllers.selectedAssistanceType =
        _safeTaxonomyValue(formDataRaw['selectedAssistanceType'] ?? formDataRaw['assistanceType']);
    controllers.specialNeedsCountController.text = (formDataRaw['specialNeedsCount'] ?? '').toString();

    final rawTab = draft['currentTab'];
    final parsedTab = rawTab is int ? rawTab : int.tryParse(rawTab?.toString() ?? '') ?? 0;
    final currentTab = parsedTab.clamp(0, FormConstants.totalTabs - 1);

    return DraftLoadResult(currentTab: currentTab);
  }
}
