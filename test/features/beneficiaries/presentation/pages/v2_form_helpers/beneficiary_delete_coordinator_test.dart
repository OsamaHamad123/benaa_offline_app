import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/beneficiary_delete_coordinator.dart';

void main() {
  group('BeneficiaryDeleteCoordinator', () {
    const coordinator = BeneficiaryDeleteCoordinator();

    test('returns success when delete action succeeds', () async {
      final result = await coordinator.execute(
        beneficiaryId: 'b1',
        deleteAction: (_) async {},
      );

      expect(result.success, isTrue);
      expect(result.error, isNull);
    });

    test('returns failure with captured error when delete fails', () async {
      final result = await coordinator.execute(
        beneficiaryId: 'b1',
        deleteAction: (_) async => throw StateError('delete failed'),
      );

      expect(result.success, isFalse);
      expect(result.error, isA<StateError>());
      expect(result.stackTrace, isNotNull);
    });
  });
}
