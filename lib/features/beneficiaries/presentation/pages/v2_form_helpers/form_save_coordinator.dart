/// 💾 Form Save Coordinator
///
/// Orchestrates beneficiary save flow and returns structured outcomes.
enum FormSaveStatus {
  saved,
  duplicateNationalId,
  saveFailed,
  missingSavedBeneficiary,
}

class FormSaveResult {
  final FormSaveStatus status;
  final int failedAttachmentsCount;

  const FormSaveResult({
    required this.status,
    this.failedAttachmentsCount = 0,
  });

  bool get isSuccess => status == FormSaveStatus.saved;
}

class FormSaveCoordinator {
  const FormSaveCoordinator();

  Future<FormSaveResult> execute({
    required Future<bool> Function() checkDuplicate,
    required Future<bool> Function() saveBeneficiary,
    required Future<String?> Function() getSavedBeneficiaryId,
    required Future<int> Function(String beneficiaryId) saveAttachments,
    required Future<void> Function(String beneficiaryId) saveFamilyMembers,
    Future<void> Function(String beneficiaryId)? saveGuardianBankAccount,
    required void Function() clearPendingAttachments,
  }) async {
    final hasDuplicate = await checkDuplicate();
    if (hasDuplicate) {
      return const FormSaveResult(status: FormSaveStatus.duplicateNationalId);
    }

    final saveSuccess = await saveBeneficiary();
    if (!saveSuccess) {
      return const FormSaveResult(status: FormSaveStatus.saveFailed);
    }

    final beneficiaryId = await getSavedBeneficiaryId();
    if (beneficiaryId == null || beneficiaryId.isEmpty) {
      return const FormSaveResult(status: FormSaveStatus.missingSavedBeneficiary);
    }

    final failedAttachmentsCount = await saveAttachments(beneficiaryId);
    clearPendingAttachments();
    await saveFamilyMembers(beneficiaryId);
    if (saveGuardianBankAccount != null) {
      await saveGuardianBankAccount(beneficiaryId);
    }

    return FormSaveResult(
      status: FormSaveStatus.saved,
      failedAttachmentsCount: failedAttachmentsCount,
    );
  }
}
