import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_controllers.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_validation_error_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormValidationErrorHelper', () {
    test('returns null when required fields are valid', () {
      final controllers = BeneficiaryFormControllers();
      addTearDown(controllers.dispose);

      controllers.firstNameController.text = 'Ali';
      controllers.fatherNameController.text = 'Hassan';
      controllers.lastNameController.text = 'Saleh';
      controllers.nationalIdController.text = '123456789';
      controllers.selectedGender = 'male';
      controllers.phoneController.text = '07900000000';

      final result = FormValidationErrorHelper.evaluateRequiredFieldErrors(controllers);
      expect(result, isNull);
    });

    test('returns first tab errors when basic info is missing', () {
      final controllers = BeneficiaryFormControllers();
      addTearDown(controllers.dispose);

      controllers.phoneController.text = '07900000000';

      final result = FormValidationErrorHelper.evaluateRequiredFieldErrors(controllers);
      expect(result, isNotNull);
      expect(result!.firstErrorTab, 0);
      expect(result.errorFields, contains('الاسم الأول'));
      expect(result.errorFields, contains('الرقم الوطني'));
      expect(FormValidationErrorHelper.buildSnackbarMessage(result), contains('المعلومات الأساسية'));
    });

    test('returns contact tab error when phone is missing only', () {
      final controllers = BeneficiaryFormControllers();
      addTearDown(controllers.dispose);

      controllers.firstNameController.text = 'Ali';
      controllers.fatherNameController.text = 'Hassan';
      controllers.lastNameController.text = 'Saleh';
      controllers.nationalIdController.text = '123456789';
      controllers.selectedGender = 'male';

      final result = FormValidationErrorHelper.evaluateRequiredFieldErrors(controllers);
      expect(result, isNotNull);
      expect(result!.firstErrorTab, 1);
      expect(result.errorFields, equals(['رقم الهاتف']));
      expect(FormValidationErrorHelper.buildSnackbarMessage(result), contains('معلومات الاتصال'));
    });
  });
}
