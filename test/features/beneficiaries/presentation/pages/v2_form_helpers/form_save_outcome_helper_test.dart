import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_save_coordinator.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_save_outcome_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormSaveOutcomeHelper', () {
    test('manual successful save includes success UI actions', () {
      const result = FormSaveResult(
        status: FormSaveStatus.saved,
        failedAttachmentsCount: 2,
      );

      final outcome = FormSaveOutcomeHelper.resolve(
        result: result,
        isAutoSave: false,
      );

      expect(outcome.traceResult, 'saved');
      expect(outcome.markSavedState, true);
      expect(outcome.showAttachmentWarning, true);
      expect(outcome.showSaveSuccessOverlay, true);
      expect(outcome.delayThenPop, true);
      expect(outcome.failureMessage, isNull);
    });

    test('auto-save success skips manual-only UI actions', () {
      const result = FormSaveResult(status: FormSaveStatus.saved);

      final outcome = FormSaveOutcomeHelper.resolve(
        result: result,
        isAutoSave: true,
      );

      expect(outcome.traceResult, 'autosaved');
      expect(outcome.markSavedState, true);
      expect(outcome.showAttachmentWarning, false);
      expect(outcome.showSaveSuccessOverlay, false);
      expect(outcome.delayThenPop, false);
      expect(outcome.failureMessage, isNull);
    });

    test('duplicate/missing resolve failure messaging correctly', () {
      const duplicate = FormSaveResult(status: FormSaveStatus.duplicateNationalId);
      const missing = FormSaveResult(status: FormSaveStatus.missingSavedBeneficiary);

      final duplicateOutcome = FormSaveOutcomeHelper.resolve(result: duplicate, isAutoSave: false);
      final missingOutcome = FormSaveOutcomeHelper.resolve(result: missing, isAutoSave: false);

      expect(duplicateOutcome.traceResult, 'duplicate');
      expect(duplicateOutcome.failureMessage, isNull);
      expect(missingOutcome.traceResult, 'missing_saved_beneficiary');
      expect(missingOutcome.failureMessage, isNotNull);
    });

    test('save failure exposes error message only for manual save', () {
      const failed = FormSaveResult(status: FormSaveStatus.saveFailed);

      final manualOutcome = FormSaveOutcomeHelper.resolve(result: failed, isAutoSave: false);
      final autoOutcome = FormSaveOutcomeHelper.resolve(result: failed, isAutoSave: true);

      expect(manualOutcome.traceResult, 'save_failed');
      expect(manualOutcome.failureMessage, isNotNull);
      expect(autoOutcome.failureMessage, isNull);
    });
  });
}
