import 'package:benaa_offline_app/features/beneficiaries/domain/entities/beneficiary.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_controllers.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_save_coordinator.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_save_flow_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormSaveFlowHelper', () {
    test('prepareBeneficiaryForSave keeps server-owned file id', () {
      final controllers = BeneficiaryFormControllers();
      addTearDown(controllers.dispose);

      controllers.firstNameController.text = 'خالد';
      controllers.fatherNameController.text = 'عمر';
      controllers.lastNameController.text = 'حسن';
      controllers.nationalIdController.text = '123456789';
      controllers.selectedGender = 'male';
      controllers.selectedCategory = '1';

      final existing = Beneficiary(
        id: '10',
        fullName: 'خالد عمر حسن',
        nationalId: '123456789',
        gender: Gender.male,
        category: BeneficiaryCategory.orphan,
        fileNo: 'legacy-x',
        fileIdNumber: '8001',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final entity = FormSaveFlowHelper.prepareBeneficiaryForSave(
        controllers: controllers,
        beneficiaryId: '10',
        currentBeneficiary: existing,
        now: DateTime(2026, 2, 26),
      );

      expect(entity.fileNo, '8001');
      expect(entity.fileIdNumber, '8001');
    });

    test('executeSaveFlow delegates to coordinator', () async {
      const coordinator = FormSaveCoordinator();

      final result = await FormSaveFlowHelper.executeSaveFlow(
        coordinator: coordinator,
        checkDuplicate: () async => false,
        saveBeneficiary: () async => true,
        getSavedBeneficiaryId: () async => '42',
        saveAttachments: (_) async => 0,
        saveFamilyMembers: (_) async {},
        clearPendingAttachments: () {},
      );

      expect(result.status, FormSaveStatus.saved);
      expect(result.failedAttachmentsCount, 0);
    });
  });
}
