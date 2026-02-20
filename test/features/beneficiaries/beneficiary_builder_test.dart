import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/beneficiary_builder.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_controllers.dart';

void main() {
  group('BeneficiaryEntityBuilder Tests', () {
    late BeneficiaryFormControllers controllers;

    setUp(() {
      controllers = BeneficiaryFormControllers();
    });

    test('build should not crash with empty controllers', () {
      expect(
        () => BeneficiaryEntityBuilder.build(
          controllers: controllers,
          existingId: null,
          existingFileNo: null,
          existingCreatedAt: null,
        ),
        returnsNormally,
      );

      final beneficiary = BeneficiaryEntityBuilder.build(
        controllers: controllers,
        existingId: null,
        existingFileNo: null,
        existingCreatedAt: null,
      );
      expect(beneficiary.fullName, isEmpty);
      expect(beneficiary.nationalId, isEmpty);
    });

    test('build should handle partial data from Civil Registry', () {
      controllers.nationalIdController.text = '1234567890';
      controllers.firstNameController.text = 'Ahmed';
      controllers.lastNameController.text = 'Ali';

      final beneficiary = BeneficiaryEntityBuilder.build(
        controllers: controllers,
        existingId: null,
        existingFileNo: null,
        existingCreatedAt: null,
      );

      expect(beneficiary.nationalId, '1234567890');
      expect(beneficiary.fullName, contains('Ahmed'));
      expect(beneficiary.fullName, contains('Ali'));
      expect(beneficiary.birthDate, isNull);
    });

    test('build should correctly map specialNeedsCount', () {
      controllers.specialNeedsCountController.text = '3';

      final beneficiary = BeneficiaryEntityBuilder.build(
        controllers: controllers,
        existingId: null,
        existingFileNo: null,
        existingCreatedAt: null,
      );

      expect(beneficiary.specialNeedsCount, equals(3));
    });

    test('build should handle invalid integer for specialNeedsCount gracefully', () {
      controllers.specialNeedsCountController.text = 'not_a_number';

      final beneficiary = BeneficiaryEntityBuilder.build(
        controllers: controllers,
        existingId: null,
        existingFileNo: null,
        existingCreatedAt: null,
      );

      expect(beneficiary.specialNeedsCount, isNull);
    });
  });
}
