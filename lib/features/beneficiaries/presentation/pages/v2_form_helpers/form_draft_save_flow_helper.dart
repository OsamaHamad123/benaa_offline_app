import '../../../../../core/errors/user_friendly_error.dart';
import 'draft_manager.dart';
import 'draft_save_coordinator.dart';
import 'form_controllers.dart';

class FormDraftSaveFlowHelper {
  static Future<void> execute({
    required Future<Map<String, String>?> Function() showDraftDialog,
    required void Function(bool isSaving) setSaving,
    required BeneficiaryFormControllers controllers,
    required DraftSaveCoordinator draftSaveCoordinator,
    required int currentTabIndex,
    required String? beneficiaryId,
    required bool Function() isMounted,
    required void Function(DateTime value) setLastSaved,
    required void Function(bool hasUnsavedChanges) setHasUnsavedChanges,
    required void Function(String draftName) onSuccess,
    required void Function(String message) onError,
    required void Function(String message) logError,
    DateTime Function() nowProvider = DateTime.now,
    SaveDraftAction saveDraft = DraftManager.saveDraft,
  }) async {
    final result = await showDraftDialog();
    if (result == null) {
      return;
    }

    final draftName = result['name'];
    final draftNotes = result['notes'];
    if (draftName == null || draftNotes == null) {
      return;
    }

    setSaving(true);

    try {
      final formData = draftSaveCoordinator.buildManualSaveFormData(controllers);

      final draftId = 'draft_${nowProvider().millisecondsSinceEpoch}';
      await saveDraft(
        draftId: draftId,
        formData: draftSaveCoordinator.buildDraftEnvelope(
          name: draftName,
          notes: draftNotes,
          formData: formData,
          currentTab: currentTabIndex,
          beneficiaryId: beneficiaryId,
        ),
      );

      if (!isMounted()) return;
      setLastSaved(nowProvider());
      setHasUnsavedChanges(false);
      setSaving(false);
      onSuccess(draftName);
    } catch (e, stackTrace) {
      if (!isMounted()) return;
      setSaving(false);
      final errorMsg = UserFriendlyError.getMessage(e, stackTrace);
      onError(errorMsg);
      logError('❌ Save draft error: $e');
    }
  }
}

typedef SaveDraftAction = Future<void> Function({
  required String draftId,
  required Map<String, dynamic> formData,
});
