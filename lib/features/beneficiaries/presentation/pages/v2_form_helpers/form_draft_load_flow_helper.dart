import '../../../../../core/errors/user_friendly_error.dart';
import 'draft_load_coordinator.dart';
import 'form_controllers.dart';
import 'form_flow_metrics_collector.dart';
import 'form_flow_tracer.dart';

class FormDraftLoadFlowHelper {
  static Future<void> execute({
    required Map<String, dynamic> draft,
    required BeneficiaryFormControllers controllers,
    required DraftLoadCoordinator draftLoadCoordinator,
    required Future<void> Function() normalizeAllTaxonomySelections,
    required void Function(bool isLoading) setLoading,
    required void Function(int tabIndex) goToTab,
    required bool Function() isMounted,
    required void Function(bool hasUnsavedChanges) setHasUnsavedChanges,
    required void Function(String message) showSuccess,
    required void Function(String message) showError,
    required void Function(String message) logError,
    required FormFlowMetricsCollector flowMetricsCollector,
  }) async {
    final trace = FormFlowTracer.start('loadDraft');

    try {
      setLoading(true);
      trace.startStep('applyDraft');

      final result = draftLoadCoordinator.applyDraft(
        controllers: controllers,
        draft: draft,
      );

      await normalizeAllTaxonomySelections();
      trace.endStep('applyDraft');

      goToTab(result.currentTab);

      if (!isMounted()) return;
      setLoading(false);
      setHasUnsavedChanges(true);
      showSuccess('تم تحميل المسودة "${draft['name']}" بنجاح');

      final elapsed = trace.end(result: 'success');
      flowMetricsCollector.record(operation: 'loadDraft', durationMs: elapsed);
    } catch (e, stackTrace) {
      if (!isMounted()) return;
      setLoading(false);
      final errorMsg = UserFriendlyError.getMessage(e, stackTrace);
      showError(errorMsg);
      logError('❌ Load draft error: $e');

      final elapsed = trace.end(result: 'error');
      flowMetricsCollector.record(operation: 'loadDraft', durationMs: elapsed);
    }
  }
}
