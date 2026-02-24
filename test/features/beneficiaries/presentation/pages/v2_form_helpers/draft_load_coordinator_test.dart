import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/draft_load_coordinator.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_controllers.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_constants.dart';

void main() {
  group('DraftLoadCoordinator', () {
    const coordinator = DraftLoadCoordinator();
    late BeneficiaryFormControllers controllers;

    setUp(() {
      controllers = BeneficiaryFormControllers();
    });

    tearDown(() {
      controllers.dispose();
    });

    test('applies draft fields and returns current tab', () {
      final result = coordinator.applyDraft(
        controllers: controllers,
        draft: {
          'formData': {
            'firstName': 'محمد',
            'fatherName': 'أحمد',
            'lastName': 'العلي',
            'nationalId': '12345678901',
            'phone': '0999',
            'birthDate': '2000-01-01',
            'gender': 'male',
            'maritalStatus': 'single',
            'educationLevel': 'none',
          },
          'currentTab': 2,
        },
      );

      expect(controllers.firstNameController.text, 'محمد');
      expect(controllers.fatherNameController.text, 'أحمد');
      expect(controllers.lastNameController.text, 'العلي');
      expect(controllers.nationalIdController.text, '12345678901');
      expect(controllers.birthDateController.text, '2000-01-01');
      expect(controllers.selectedGender, 'male');
      expect(result.currentTab, 2);
    });

    test('throws format exception when formData is invalid', () {
      expect(
        () => coordinator.applyDraft(
          controllers: controllers,
          draft: {'formData': 'invalid'},
        ),
        throwsFormatException,
      );
    });

    test('clamps current tab when draft tab index exceeds available tabs', () {
      final result = coordinator.applyDraft(
        controllers: controllers,
        draft: {
          'formData': {
            'firstName': 'محمد',
            'nationalId': '12345678901',
          },
          'currentTab': 999,
        },
      );

      expect(result.currentTab, FormConstants.totalTabs - 1);
    });

    test('falls back to tab zero when currentTab is invalid text', () {
      final result = coordinator.applyDraft(
        controllers: controllers,
        draft: {
          'formData': {
            'firstName': 'محمد',
            'nationalId': '12345678901',
          },
          'currentTab': 'abc',
        },
      );

      expect(result.currentTab, 0);
    });
  });
}
