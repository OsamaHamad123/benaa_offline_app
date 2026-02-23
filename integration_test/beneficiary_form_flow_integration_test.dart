import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_controllers.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/draft_save_coordinator.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/draft_load_coordinator.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_save_coordinator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Beneficiary Form Coordinator Flow Integration', () {
    testWidgets('auto-save payload can be restored then saved', (tester) async {
      final controllers = BeneficiaryFormControllers();
      const draftCoordinator = DraftSaveCoordinator();
      const loadCoordinator = DraftLoadCoordinator();
      const saveCoordinator = FormSaveCoordinator();

      controllers.firstNameController.text = 'سارة';
      controllers.lastNameController.text = 'الحموي';
      controllers.nationalIdController.text = '12345678901';
      controllers.selectedGender = 'female';
      controllers.selectedCategory = '2';
      controllers.selectedSection = '1';
      controllers.selectedAssistanceType = 'cash';
      controllers.selectedRequestStatus = 'pending';
      controllers.selectedDisabilityType = 'motor';
      controllers.selectedIncomeSource = 'salary';
      controllers.specialNeedsCountController.text = '1';

      final autoData = draftCoordinator.buildAutoSaveFormData(controllers);
      final envelope = draftCoordinator.buildDraftEnvelope(
        name: draftCoordinator.buildAutoDraftName(controllers),
        notes: 'test',
        formData: autoData,
        currentTab: 1,
        beneficiaryId: null,
        isAutoSaved: true,
      );

      // Simulate clearing form then restoring from draft
      controllers.firstNameController.clear();
      controllers.lastNameController.clear();
      controllers.nationalIdController.clear();
      controllers.selectedGender = null;
      controllers.selectedCategory = null;
      controllers.selectedSection = null;
      controllers.selectedAssistanceType = null;
      controllers.selectedRequestStatus = null;
      controllers.selectedDisabilityType = null;
      controllers.selectedIncomeSource = null;
      controllers.specialNeedsCountController.clear();

      final loadResult = loadCoordinator.applyDraft(
        controllers: controllers,
        draft: {
          'formData': envelope['formData'],
          'currentTab': envelope['currentTab'],
        },
      );

      expect(controllers.firstNameController.text, 'سارة');
      expect(controllers.lastNameController.text, 'الحموي');
      expect(controllers.nationalIdController.text, '12345678901');
      expect(controllers.selectedCategory, '2');
      expect(controllers.selectedSection, '1');
      expect(controllers.selectedAssistanceType, 'cash');
      expect(controllers.selectedRequestStatus, 'pending');
      expect(controllers.selectedDisabilityType, 'motor');
      expect(controllers.selectedIncomeSource, 'salary');
      expect(controllers.specialNeedsCountController.text, '1');
      expect(loadResult.currentTab, 1);

      final saveResult = await saveCoordinator.execute(
        checkDuplicate: () async => false,
        saveBeneficiary: () async => true,
        getSavedBeneficiaryId: () async => 'benef_1',
        saveAttachments: (_) async => 0,
        saveFamilyMembers: (_) async {},
        clearPendingAttachments: () {},
      );

      expect(saveResult.status, FormSaveStatus.saved);

      controllers.dispose();
    });
  });
}
