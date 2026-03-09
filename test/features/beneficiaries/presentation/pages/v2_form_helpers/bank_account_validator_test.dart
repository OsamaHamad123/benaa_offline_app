import 'package:flutter_test/flutter_test.dart';

import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/bank_account_validator.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_controllers.dart';

void main() {
  group('BankAccountValidator', () {
    late BeneficiaryFormControllers controllers;

    setUp(() {
      controllers = BeneficiaryFormControllers();
    });

    tearDown(() {
      controllers.dispose();
    });

    test('hasAnyBankData returns false when all fields empty', () {
      expect(BankAccountValidator.hasAnyBankData(controllers), isFalse);
    });

    test('hasAnyBankData returns true when one field is filled', () {
      controllers.bankNameLabelController.text = 'Bank X';
      expect(BankAccountValidator.hasAnyBankData(controllers), isTrue);
    });

    test('validateBankNameId rejects non-positive/non-numeric input', () {
      expect(BankAccountValidator.validateBankNameId('abc'), isNotNull);
      expect(BankAccountValidator.validateBankNameId('0'), isNotNull);
      expect(BankAccountValidator.validateBankNameId('5'), isNull);
    });

    test('validateAtLeastOneBankName enforces id or label when bank section has data', () {
      final error = BankAccountValidator.validateAtLeastOneBankName(
        bankNameId: '',
        bankNameLabel: '',
        hasAnyBankData: true,
      );
      expect(error, isNotNull);

      final ok = BankAccountValidator.validateAtLeastOneBankName(
        bankNameId: '3',
        bankNameLabel: '',
        hasAnyBankData: true,
      );
      expect(ok, isNull);
    });

    test('validateIbanPair requires at least one iban when section has data', () {
      final error = BankAccountValidator.validateIbanPair(
        currentValue: '',
        otherIbanValue: '',
        hasAnyBankData: true,
      );
      expect(error, isNotNull);
    });

    test('validateIbanPair accepts valid IBAN and rejects invalid format', () {
      final invalid = BankAccountValidator.validateIbanPair(
        currentValue: '123',
        otherIbanValue: '',
        hasAnyBankData: true,
      );
      expect(invalid, isNotNull);

      final valid = BankAccountValidator.validateIbanPair(
        currentValue: 'PS92PIBC000000000012345678901',
        otherIbanValue: '',
        hasAnyBankData: true,
      );
      expect(valid, isNull);
    });
  });
}
