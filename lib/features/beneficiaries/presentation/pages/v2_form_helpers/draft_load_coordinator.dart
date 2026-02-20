import 'form_controllers.dart';

class DraftLoadResult {
  final int currentTab;

  const DraftLoadResult({required this.currentTab});
}

/// 📥 Draft Load Coordinator
///
/// Applies draft payload into form controllers.
class DraftLoadCoordinator {
  const DraftLoadCoordinator();

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

    controllers.selectedGender = formDataRaw['gender']?.toString();
    controllers.selectedMaritalStatus = formDataRaw['maritalStatus']?.toString();
    controllers.selectedEducationLevel = formDataRaw['educationLevel']?.toString();

    final rawTab = draft['currentTab'];
    final currentTab = rawTab is int ? rawTab : int.tryParse(rawTab?.toString() ?? '') ?? 0;

    return DraftLoadResult(currentTab: currentTab);
  }
}
