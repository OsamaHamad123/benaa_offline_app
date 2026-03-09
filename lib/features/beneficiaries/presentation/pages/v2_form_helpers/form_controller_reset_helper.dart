import 'form_controllers.dart';

class FormControllerResetHelper {
  static void reset(BeneficiaryFormControllers controllers) {
    controllers.firstNameController.clear();
    controllers.fatherNameController.clear();
    controllers.grandfatherNameController.clear();
    controllers.lastNameController.clear();
    controllers.motherNameController.clear();
    controllers.nationalIdController.clear();
    controllers.birthDateController.clear();
    controllers.fileNumberController.clear();
    controllers.phoneController.clear();
    controllers.altPhoneController.clear();
    controllers.addressController.clear();
    controllers.neighborhoodController.clear();
    controllers.notesController.clear();
    controllers.numberOfDependentsController.clear();
    controllers.numberOfMalesController.clear();
    controllers.numberOfFemalesController.clear();
    controllers.chronicDiseasesController.clear();
    controllers.specialNeedsCountController.clear();
    controllers.createdByUserController.clear();
    controllers.addressBeforeDisplacementController.clear();

    controllers.selectedGender = null;
    controllers.selectedCategory = null;
    controllers.selectedMaritalStatus = null;
    controllers.selectedEducationLevel = null;
    controllers.selectedEmploymentStatus = null;
    controllers.selectedRelationship = null;
    controllers.selectedCity = null;
    controllers.selectedProvince = null;
    controllers.selectedDisplacementStatus = null;
    controllers.selectedHealthStatus = null;
    controllers.selectedHousingStatus = null;
    controllers.selectedHousingType = null;
    controllers.selectedAssistanceType = null;
    controllers.selectedDisabilityType = null;
    controllers.selectedIncomeSource = null;
    controllers.selectedGuaranteeType = null;
    controllers.selectedRequestStatus = null;
    controllers.selectedSection = null;
    controllers.hasDisability = false;
    controllers.clearPendingAttachments();
    controllers.updatePendingFiles([]);
  }
}
