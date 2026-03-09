import 'form_controllers.dart';

class BankAccountValidator {
  static final RegExp _ibanPattern = RegExp(r'^[A-Z]{2}[0-9A-Z]{13,32}$');

  static bool hasAnyBankData(BeneficiaryFormControllers controllers) {
    return [
      controllers.bankNameIdController.text,
      controllers.bankNameLabelController.text,
      controllers.ibanUsdController.text,
      controllers.ibanShekelController.text,
      controllers.bankRepresentativeIdController.text,
      controllers.bankGuardianNameController.text,
      controllers.bankRepresentativePhoneController.text,
      controllers.bankOwnerIdentityController.text,
    ].any((value) => value.trim().isNotEmpty);
  }

  static String? validateBankNameId(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    final parsed = int.tryParse(text);
    if (parsed == null || parsed <= 0) {
      return 'رقم البنك يجب أن يكون رقمًا صحيحًا موجبًا';
    }
    return null;
  }

  static String? validateAtLeastOneBankName({
    required String? bankNameId,
    required String? bankNameLabel,
    required bool hasAnyBankData,
  }) {
    if (!hasAnyBankData) return null;

    final hasId = (bankNameId ?? '').trim().isNotEmpty;
    final hasLabel = (bankNameLabel ?? '').trim().isNotEmpty;
    if (hasId || hasLabel) return null;

    return 'أدخل رقم البنك أو اسم البنك';
  }

  static String? validateIbanPair({
    required String? currentValue,
    required String? otherIbanValue,
    required bool hasAnyBankData,
  }) {
    final current = (currentValue ?? '').trim().toUpperCase();
    final other = (otherIbanValue ?? '').trim().toUpperCase();

    if (current.isEmpty && other.isEmpty && hasAnyBankData) {
      return 'أدخل IBAN واحد على الأقل (دولار أو شيكل)';
    }

    if (current.isEmpty) return null;

    if (!_ibanPattern.hasMatch(current)) {
      return 'صيغة IBAN غير صحيحة';
    }

    return null;
  }
}
