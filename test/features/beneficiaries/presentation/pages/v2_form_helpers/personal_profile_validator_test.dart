import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_controllers.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/personal_profile_validator.dart';

void main() {
  group('PersonalProfileValidator', () {
    late BeneficiaryFormControllers controllers;

    setUp(() {
      controllers = BeneficiaryFormControllers();
    });

    tearDown(() {
      controllers.dispose();
    });

    test('returns all critical issues when personal profile is empty', () {
      final result = PersonalProfileValidator.evaluate(controllers);

      expect(result.isComplete, isFalse);
      expect(result.missingCriticalFields, 5);
      expect(result.completedCriticalFields, 0);
      expect(result.criticalIssues, contains('أدخل الرقم الوطني'));
      expect(result.criticalIssues, contains('أدخل الاسم الأول'));
      expect(result.criticalIssues, contains('أدخل اسم الأب'));
      expect(result.criticalIssues, contains('أدخل اللقب'));
      expect(result.criticalIssues, contains('حدد الجنس'));
    });

    test('reports invalid national id length with exact message', () {
      controllers.firstNameController.text = 'أحمد';
      controllers.fatherNameController.text = 'محمد';
      controllers.lastNameController.text = 'السيد';
      controllers.selectedGender = 'male';
      controllers.nationalIdController.text = '12345';

      final result = PersonalProfileValidator.evaluate(controllers);

      expect(result.isComplete, isFalse);
      expect(result.missingCriticalFields, 1);
      expect(result.criticalIssues.single, 'الرقم الوطني يجب أن يكون 9 أرقام');
      expect(PersonalProfileValidator.hasValidNationalId(controllers), isFalse);
    });

    test('isComplete is true when all critical personal fields are valid', () {
      controllers.firstNameController.text = 'أحمد';
      controllers.fatherNameController.text = 'محمد';
      controllers.lastNameController.text = 'النجار';
      controllers.selectedGender = 'male';
      controllers.nationalIdController.text = '123456789';

      final result = PersonalProfileValidator.evaluate(controllers);

      expect(result.isComplete, isTrue);
      expect(result.criticalIssues, isEmpty);
      expect(result.missingCriticalFields, 0);
      expect(result.completedCriticalFields, 5);
      expect(PersonalProfileValidator.isComplete(controllers), isTrue);
      expect(PersonalProfileValidator.hasValidNationalId(controllers), isTrue);
    });
  });
}
