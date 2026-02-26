import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_constants.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/widgets/inline_validation_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ValidationMessages', () {
    test('nationalIdLength message matches FormConstants.nationalIdLength', () {
      final widget = ValidationMessages.nationalIdLength();
      expect(widget.message, contains(FormConstants.nationalIdLength.toString()));
    });

    test('phoneInvalid message matches phone validation rule format', () {
      final widget = ValidationMessages.phoneInvalid();
      expect(widget.message, contains('10'));
      expect(widget.message, contains('059'));
      expect(widget.message, contains('056'));
    });
  });
}
