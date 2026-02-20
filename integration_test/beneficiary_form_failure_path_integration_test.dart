import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_save_coordinator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Beneficiary Form Failure Paths Integration', () {
    testWidgets('returns duplicate status when duplicate national id is detected', (tester) async {
      const coordinator = FormSaveCoordinator();

      final result = await coordinator.execute(
        checkDuplicate: () async => true,
        saveBeneficiary: () async => true,
        getSavedBeneficiaryId: () async => 'benef_1',
        saveAttachments: (_) async => 0,
        saveFamilyMembers: (_) async {},
        clearPendingAttachments: () {},
      );

      expect(result.status, FormSaveStatus.duplicateNationalId);
      expect(result.isSuccess, isFalse);
    });

    testWidgets('preserves attachment failures count after successful save', (tester) async {
      const coordinator = FormSaveCoordinator();

      final result = await coordinator.execute(
        checkDuplicate: () async => false,
        saveBeneficiary: () async => true,
        getSavedBeneficiaryId: () async => 'benef_1',
        saveAttachments: (_) async => 3,
        saveFamilyMembers: (_) async {},
        clearPendingAttachments: () {},
      );

      expect(result.status, FormSaveStatus.saved);
      expect(result.failedAttachmentsCount, 3);
    });
  });
}
