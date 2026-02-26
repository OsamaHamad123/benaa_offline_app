import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_controller_reset_helper.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_controllers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormControllerResetHelper', () {
    test('clears text fields and resets taxonomy selections', () {
      final controllers = BeneficiaryFormControllers();
      addTearDown(controllers.dispose);

      controllers.firstNameController.text = 'محمد';
      controllers.fileNumberController.text = '9999';
      controllers.selectedCategory = '2';
      controllers.selectedRelationship = '11';

      FormControllerResetHelper.reset(controllers);

      expect(controllers.firstNameController.text, isEmpty);
      expect(controllers.fileNumberController.text, isEmpty);
      expect(controllers.selectedCategory, isNull);
      expect(controllers.selectedRelationship, isNull);
    });
  });
}
