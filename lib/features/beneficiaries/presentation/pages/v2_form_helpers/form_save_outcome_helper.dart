import 'form_save_coordinator.dart';

class FormSaveOutcome {
  final String traceResult;
  final bool markSavedState;
  final bool showAttachmentWarning;
  final bool showSaveSuccessOverlay;
  final bool delayThenPop;
  final String? failureMessage;

  const FormSaveOutcome({
    required this.traceResult,
    required this.markSavedState,
    required this.showAttachmentWarning,
    required this.showSaveSuccessOverlay,
    required this.delayThenPop,
    required this.failureMessage,
  });
}

class FormSaveOutcomeHelper {
  static FormSaveOutcome resolve({
    required FormSaveResult result,
    required bool isAutoSave,
  }) {
    switch (result.status) {
      case FormSaveStatus.saved:
        final isManualSave = !isAutoSave;
        return FormSaveOutcome(
          traceResult: isManualSave ? 'saved' : 'autosaved',
          markSavedState: true,
          showAttachmentWarning: isManualSave && result.failedAttachmentsCount > 0,
          showSaveSuccessOverlay: isManualSave,
          delayThenPop: isManualSave,
          failureMessage: null,
        );
      case FormSaveStatus.duplicateNationalId:
        return const FormSaveOutcome(
          traceResult: 'duplicate',
          markSavedState: false,
          showAttachmentWarning: false,
          showSaveSuccessOverlay: false,
          delayThenPop: false,
          failureMessage: null,
        );
      case FormSaveStatus.missingSavedBeneficiary:
        return const FormSaveOutcome(
          traceResult: 'missing_saved_beneficiary',
          markSavedState: false,
          showAttachmentWarning: false,
          showSaveSuccessOverlay: false,
          delayThenPop: false,
          failureMessage: 'تعذر إكمال الحفظ: لم يتم توليد معرف صالح للمستفيد',
        );
      case FormSaveStatus.saveFailed:
        return FormSaveOutcome(
          traceResult: 'save_failed',
          markSavedState: false,
          showAttachmentWarning: false,
          showSaveSuccessOverlay: false,
          delayThenPop: false,
          failureMessage: isAutoSave ? null : 'فشل حفظ البيانات الأساسية، يرجى المحاولة مرة أخرى',
        );
    }
  }
}
