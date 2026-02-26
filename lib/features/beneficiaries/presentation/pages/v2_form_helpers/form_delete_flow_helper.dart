import 'beneficiary_delete_coordinator.dart';

class FormDeleteFlowHelper {
  static Future<BeneficiaryDeleteResult> execute({
    required BeneficiaryDeleteCoordinator coordinator,
    required String beneficiaryId,
    required Future<void> Function(String beneficiaryId) deleteAction,
  }) {
    return coordinator.execute(
      beneficiaryId: beneficiaryId,
      deleteAction: deleteAction,
    );
  }
}
