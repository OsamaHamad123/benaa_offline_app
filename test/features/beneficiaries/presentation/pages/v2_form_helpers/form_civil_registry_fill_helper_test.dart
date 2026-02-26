import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_civil_registry_fill_helper.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_controllers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormCivilRegistryFillHelper', () {
    test('fills key fields from valid civil registry payload', () {
      final controllers = BeneficiaryFormControllers();
      addTearDown(controllers.dispose);

      final result = FormCivilRegistryFillHelper.apply(
        controllers: controllers,
        data: {
          'name': 'محمد أحمد علي الأحمدي',
          'nationalId': '123456789',
          'gender': 'ذكر',
          'motherName': 'فاطمة',
          'birthDate': '2000-01-01',
          'governorate': 'بغداد',
          'city': 'الكرادة',
        },
        enableLogging: false,
      );

      expect(result.filledFieldsCount, 8);
      expect(controllers.firstNameController.text, 'محمد');
      expect(controllers.fatherNameController.text, 'أحمد');
      expect(controllers.grandfatherNameController.text, 'علي');
      expect(controllers.lastNameController.text, 'الأحمدي');
      expect(controllers.nationalIdController.text, '123456789');
      expect(controllers.selectedGender, 'ذكر');
      expect(controllers.motherNameController.text, 'فاطمة');
      expect(controllers.birthDateController.text, '2000-01-01');
      expect(controllers.selectedProvince, 'بغداد');
      expect(controllers.selectedCity, 'الكرادة');
      expect(controllers.addressController.text, 'بغداد - الكرادة');
    });

    test('handles non-string/empty values safely', () {
      final controllers = BeneficiaryFormControllers();
      addTearDown(controllers.dispose);

      final result = FormCivilRegistryFillHelper.apply(
        controllers: controllers,
        data: {
          'name': '  ',
          'nationalId': 987654321,
          'gender': null,
          'motherName': '',
          'birthDate': 20010101,
          'governorate': ' ',
          'city': 'رام الله',
        },
        enableLogging: false,
      );

      expect(result.filledFieldsCount, 2);
      expect(controllers.nationalIdController.text, '987654321');
      expect(controllers.birthDateController.text, '20010101');
      expect(controllers.selectedCity, 'رام الله');
      expect(controllers.selectedProvince, isNull);
      expect(controllers.addressController.text, 'رام الله');
      expect(controllers.firstNameController.text, isEmpty);
    });
  });
}
