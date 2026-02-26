import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/draft_load_coordinator.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_controllers.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_draft_load_flow_helper.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_flow_metrics_collector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormDraftLoadFlowHelper', () {
    test('applies draft and updates ui state on success', () async {
      final controllers = BeneficiaryFormControllers();
      addTearDown(controllers.dispose);

      final flowMetricsCollector = FormFlowMetricsCollector();
      final coordinator = const DraftLoadCoordinator();

      var isLoading = false;
      var hasUnsavedChanges = false;
      var selectedTab = -1;
      String? successMessage;
      String? errorMessage;

      await FormDraftLoadFlowHelper.execute(
        draft: {
          'name': 'draft-1',
          'currentTab': 1,
          'formData': {
            'firstName': 'Ahmed',
            'nationalId': '1234',
          },
        },
        controllers: controllers,
        draftLoadCoordinator: coordinator,
        normalizeAllTaxonomySelections: () async {},
        setLoading: (value) => isLoading = value,
        goToTab: (tabIndex) => selectedTab = tabIndex,
        isMounted: () => true,
        setHasUnsavedChanges: (value) => hasUnsavedChanges = value,
        showSuccess: (message) => successMessage = message,
        showError: (message) => errorMessage = message,
        logError: (_) {},
        flowMetricsCollector: flowMetricsCollector,
      );

      expect(isLoading, false);
      expect(hasUnsavedChanges, true);
      expect(selectedTab, 1);
      expect(successMessage, contains('draft-1'));
      expect(errorMessage, isNull);
      expect(controllers.firstNameController.text, 'Ahmed');
      expect(flowMetricsCollector.summarize('loadDraft')?.count, 1);
    });

    test('handles invalid draft and routes to error callback', () async {
      final controllers = BeneficiaryFormControllers();
      addTearDown(controllers.dispose);

      final flowMetricsCollector = FormFlowMetricsCollector();
      final coordinator = const DraftLoadCoordinator();

      String? errorMessage;
      var logs = <String>[];

      await FormDraftLoadFlowHelper.execute(
        draft: {
          'name': 'broken-draft',
          'currentTab': 0,
        },
        controllers: controllers,
        draftLoadCoordinator: coordinator,
        normalizeAllTaxonomySelections: () async {},
        setLoading: (_) {},
        goToTab: (_) {},
        isMounted: () => true,
        setHasUnsavedChanges: (_) {},
        showSuccess: (_) {},
        showError: (message) => errorMessage = message,
        logError: logs.add,
        flowMetricsCollector: flowMetricsCollector,
      );

      expect(errorMessage, isNotNull);
      expect(logs, isNotEmpty);
      expect(flowMetricsCollector.summarize('loadDraft')?.count, 1);
    });
  });
}
