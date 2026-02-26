import '../../../domain/entities/beneficiary.dart';

class FormInitializationResult {
  final String? resolvedBeneficiaryId;

  const FormInitializationResult({
    required this.resolvedBeneficiaryId,
  });
}

class FormInitializationHelper {
  static Future<FormInitializationResult> initialize({
    required String? routeBeneficiaryId,
    required Map<String, dynamic>? civilRegistryData,
    required Future<String?> Function(String beneficiaryId) resolveLocalBeneficiaryId,
    required Future<void> Function(String beneficiaryId) loadBeneficiary,
    required Beneficiary? Function() readLoadedBeneficiary,
    required Future<void> Function(Beneficiary beneficiary) onLoadedBeneficiary,
    required void Function() onCreateNew,
    required void Function() onClearControllers,
    required void Function(Map<String, dynamic> data) onScheduleCivilRegistryFill,
    required void Function() onScheduleFirstFieldFocus,
    required Future<void> Function() onRefreshTaxonomyCoverage,
    required void Function(String description) onSaveToHistory,
  }) async {
    String? resolvedBeneficiaryId;

    if (routeBeneficiaryId != null) {
      resolvedBeneficiaryId = await resolveLocalBeneficiaryId(routeBeneficiaryId);
      final beneficiaryIdForLoad = resolvedBeneficiaryId ?? routeBeneficiaryId;
      await loadBeneficiary(beneficiaryIdForLoad);

      final beneficiary = readLoadedBeneficiary();
      if (beneficiary != null) {
        await onLoadedBeneficiary(beneficiary);
        onSaveToHistory('Initial load');
      }
    } else {
      onClearControllers();
      onCreateNew();

      if (civilRegistryData != null) {
        onScheduleCivilRegistryFill(civilRegistryData);
      } else {
        onScheduleFirstFieldFocus();
      }
    }

    await onRefreshTaxonomyCoverage();

    return FormInitializationResult(
      resolvedBeneficiaryId: resolvedBeneficiaryId,
    );
  }
}
