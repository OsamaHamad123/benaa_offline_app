import '../../../domain/entities/beneficiary.dart';
import 'form_controllers.dart';
import 'form_data_handler.dart';
import 'form_save_coordinator.dart';

class FormSaveFlowHelper {
  static Beneficiary prepareBeneficiaryForSave({
    required BeneficiaryFormControllers controllers,
    required String? beneficiaryId,
    required Beneficiary? currentBeneficiary,
    required DateTime now,
  }) {
    return BeneficiaryFormDataHandler.buildBeneficiary(
      controllers: controllers,
      beneficiaryId: beneficiaryId,
      fileNo: (currentBeneficiary?.fileIdNumber ?? currentBeneficiary?.fileNo) ?? '',
      createdAt: currentBeneficiary?.createdAt ?? now,
    );
  }

  static Future<FormSaveResult> executeSaveFlow({
    required FormSaveCoordinator coordinator,
    required Future<bool> Function() checkDuplicate,
    required Future<bool> Function() saveBeneficiary,
    required Future<String?> Function() getSavedBeneficiaryId,
    required Future<int> Function(String beneficiaryId) saveAttachments,
    required Future<void> Function(String beneficiaryId) saveFamilyMembers,
    Future<void> Function(String beneficiaryId)? saveGuardianBankAccount,
    required void Function() clearPendingAttachments,
  }) {
    return coordinator.execute(
      checkDuplicate: checkDuplicate,
      saveBeneficiary: saveBeneficiary,
      getSavedBeneficiaryId: getSavedBeneficiaryId,
      saveAttachments: saveAttachments,
      saveFamilyMembers: saveFamilyMembers,
      saveGuardianBankAccount: saveGuardianBankAccount,
      clearPendingAttachments: clearPendingAttachments,
    );
  }
}
