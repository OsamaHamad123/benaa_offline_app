import '../entities/guardian_bank_account.dart';
import '../repositories/guardian_bank_account_repository.dart';

class LoadGuardianBankAccountUseCase {
  final GuardianBankAccountRepository repository;
  const LoadGuardianBankAccountUseCase(this.repository);

  Future<GuardianBankAccount?> execute(String beneficiaryId) {
    return repository.loadByBeneficiaryLocalId(beneficiaryId);
  }
}

class SaveGuardianBankAccountUseCase {
  final GuardianBankAccountRepository repository;
  const SaveGuardianBankAccountUseCase(this.repository);

  Future<void> execute({
    required String beneficiaryId,
    required GuardianBankAccount draft,
  }) {
    return repository.saveByBeneficiaryLocalId(
      beneficiaryId: beneficiaryId,
      draft: draft,
    );
  }
}
