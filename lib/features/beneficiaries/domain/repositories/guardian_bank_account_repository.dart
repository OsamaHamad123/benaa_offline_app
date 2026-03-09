import '../entities/guardian_bank_account.dart';

abstract class GuardianBankAccountRepository {
  Future<GuardianBankAccount?> loadByBeneficiaryLocalId(String beneficiaryId);

  Future<void> saveByBeneficiaryLocalId({
    required String beneficiaryId,
    required GuardianBankAccount draft,
  });
}
