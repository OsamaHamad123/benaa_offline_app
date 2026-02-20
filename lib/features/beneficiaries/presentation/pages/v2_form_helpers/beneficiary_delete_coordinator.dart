class BeneficiaryDeleteResult {
  final bool success;
  final Object? error;
  final StackTrace? stackTrace;

  const BeneficiaryDeleteResult._({
    required this.success,
    this.error,
    this.stackTrace,
  });

  const BeneficiaryDeleteResult.success() : this._(success: true);

  const BeneficiaryDeleteResult.failure({
    required Object error,
    required StackTrace stackTrace,
  }) : this._(success: false, error: error, stackTrace: stackTrace);
}

/// 🗑️ Beneficiary Delete Coordinator
///
/// Encapsulates delete execution and error capture.
class BeneficiaryDeleteCoordinator {
  const BeneficiaryDeleteCoordinator();

  Future<BeneficiaryDeleteResult> execute({
    required String beneficiaryId,
    required Future<void> Function(String beneficiaryId) deleteAction,
  }) async {
    try {
      await deleteAction(beneficiaryId);
      return const BeneficiaryDeleteResult.success();
    } catch (error, stackTrace) {
      return BeneficiaryDeleteResult.failure(error: error, stackTrace: stackTrace);
    }
  }
}
