import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/draft_save_coordinator.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_controllers.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_draft_save_flow_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormDraftSaveFlowHelper', () {
    test('does nothing when dialog is cancelled', () async {
      final controllers = BeneficiaryFormControllers();
      addTearDown(controllers.dispose);

      var savingCalls = 0;
      var successCalls = 0;

      await FormDraftSaveFlowHelper.execute(
        showDraftDialog: () async => null,
        setSaving: (_) => savingCalls++,
        controllers: controllers,
        draftSaveCoordinator: const DraftSaveCoordinator(),
        currentTabIndex: 0,
        beneficiaryId: null,
        isMounted: () => true,
        setLastSaved: (_) {},
        setHasUnsavedChanges: (_) {},
        onSuccess: (_) => successCalls++,
        onError: (_) {},
        logError: (_) {},
      );

      expect(savingCalls, 0);
      expect(successCalls, 0);
    });

    test('saves draft and reports success', () async {
      final controllers = BeneficiaryFormControllers();
      addTearDown(controllers.dispose);

      controllers.firstNameController.text = 'Ali';

      var isSaving = false;
      var successName = '';
      DateTime? lastSaved;
      var unsavedChanges = true;
      String? savedDraftId;

      await FormDraftSaveFlowHelper.execute(
        showDraftDialog: () async => {
          'name': 'draft-name',
          'notes': 'draft-notes',
        },
        setSaving: (value) => isSaving = value,
        controllers: controllers,
        draftSaveCoordinator: const DraftSaveCoordinator(),
        currentTabIndex: 1,
        beneficiaryId: 'b-1',
        isMounted: () => true,
        setLastSaved: (value) => lastSaved = value,
        setHasUnsavedChanges: (value) => unsavedChanges = value,
        onSuccess: (name) => successName = name,
        onError: (_) {},
        logError: (_) {},
        nowProvider: () => DateTime(2026, 2, 26, 10),
        saveDraft: ({required draftId, required formData}) async {
          savedDraftId = draftId;
          expect(formData['name'], 'draft-name');
          expect(formData['notes'], 'draft-notes');
          expect(formData['currentTab'], 1);
        },
      );

      expect(isSaving, false);
      expect(successName, 'draft-name');
      expect(lastSaved, isNotNull);
      expect(unsavedChanges, false);
      expect(savedDraftId, isNotNull);
      expect(savedDraftId, startsWith('draft_'));
    });
  });
}
