import 'form_constants.dart';
import 'form_controllers.dart';

class FormValidationErrorResult {
  final int firstErrorTab;
  final List<String> errorFields;

  const FormValidationErrorResult({
    required this.firstErrorTab,
    required this.errorFields,
  });
}

class FormValidationErrorHelper {
  static FormValidationErrorResult? evaluateRequiredFieldErrors(BeneficiaryFormControllers controllers) {
    final errorsByTab = <int, List<String>>{};

    final basicErrors = <String>[];
    if (controllers.firstNameController.text.trim().isEmpty) {
      basicErrors.add('الاسم الأول');
    }
    if (controllers.fatherNameController.text.trim().isEmpty) {
      basicErrors.add('اسم الأب');
    }
    if (controllers.lastNameController.text.trim().isEmpty) {
      basicErrors.add('اسم العائلة');
    }

    final nationalId = controllers.nationalIdController.text.trim();
    if (nationalId.isEmpty) {
      basicErrors.add('الرقم الوطني');
    } else if (nationalId.length != FormConstants.nationalIdLength) {
      basicErrors.add('الرقم الوطني (غير صحيح)');
    }

    if (controllers.selectedGender == null) {
      basicErrors.add('الجنس');
    }

    if (basicErrors.isNotEmpty) {
      errorsByTab[0] = basicErrors;
    }

    final contactErrors = <String>[];
    if (controllers.phoneController.text.trim().isEmpty) {
      contactErrors.add('رقم الهاتف');
    }
    if (contactErrors.isNotEmpty) {
      errorsByTab[1] = contactErrors;
    }

    if (errorsByTab.isEmpty) {
      return null;
    }

    final firstErrorTab = errorsByTab.keys.first;
    final errorFields = errorsByTab[firstErrorTab] ?? const <String>[];
    return FormValidationErrorResult(
      firstErrorTab: firstErrorTab,
      errorFields: errorFields,
    );
  }

  static String resolveTabName(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return 'المعلومات الأساسية';
      case 1:
        return 'معلومات الاتصال';
      case 2:
        return 'العائلة';
      default:
        return 'المرفقات';
    }
  }

  static String buildSnackbarMessage(FormValidationErrorResult result) {
    final tabName = resolveTabName(result.firstErrorTab);
    return '⚠️ يرجى تعبئة الحقول التالية في "$tabName":\n• ${result.errorFields.join('\n• ')}';
  }
}
