import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_save_coordinator.dart';

void main() {
  group('FormSaveCoordinator', () {
    const coordinator = FormSaveCoordinator();

    test('returns duplicate status when duplicate is found', () async {
      var duplicateCalls = 0;
      final result = await coordinator.execute(
        checkDuplicate: () async {
          duplicateCalls++;
          return true;
        },
        saveBeneficiary: () async => true,
        getSavedBeneficiaryId: () async => 'b1',
        saveAttachments: (_) async => 0,
        saveFamilyMembers: (_) async {},
        clearPendingAttachments: () {},
      );

      expect(duplicateCalls, 1);
      expect(result.status, FormSaveStatus.duplicateNationalId);
    });

    test('returns saveFailed status when save fails', () async {
      final result = await coordinator.execute(
        checkDuplicate: () async => false,
        saveBeneficiary: () async => false,
        getSavedBeneficiaryId: () async => 'b1',
        saveAttachments: (_) async => 0,
        saveFamilyMembers: (_) async {},
        clearPendingAttachments: () {},
      );

      expect(result.status, FormSaveStatus.saveFailed);
    });

    test('returns missingSavedBeneficiary when id is not available', () async {
      final result = await coordinator.execute(
        checkDuplicate: () async => false,
        saveBeneficiary: () async => true,
        getSavedBeneficiaryId: () async => null,
        saveAttachments: (_) async => 0,
        saveFamilyMembers: (_) async {},
        clearPendingAttachments: () {},
      );

      expect(result.status, FormSaveStatus.missingSavedBeneficiary);
    });

    test('returns success and failed attachment count', () async {
      var clearCalled = false;
      String? savedFamilyFor;

      final result = await coordinator.execute(
        checkDuplicate: () async => false,
        saveBeneficiary: () async => true,
        getSavedBeneficiaryId: () async => 'benef_42',
        saveAttachments: (_) async => 2,
        saveFamilyMembers: (id) async => savedFamilyFor = id,
        clearPendingAttachments: () => clearCalled = true,
      );

      expect(result.status, FormSaveStatus.saved);
      expect(result.failedAttachmentsCount, 2);
      expect(clearCalled, isTrue);
      expect(savedFamilyFor, 'benef_42');
    });
  });
}
