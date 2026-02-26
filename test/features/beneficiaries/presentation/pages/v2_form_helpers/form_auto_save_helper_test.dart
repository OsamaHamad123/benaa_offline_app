import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/auto_save_throttle_guard.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/draft_save_coordinator.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_auto_save_helper.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_controllers.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_flow_metrics_collector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormAutoSaveHelper.autoSaveDraft', () {
    test('saves draft and updates draft id + lastSaved', () async {
      final controllers = BeneficiaryFormControllers();
      addTearDown(controllers.dispose);

      controllers.firstNameController.text = 'Ali';
      controllers.nationalIdController.text = '1234567890';

      final throttleGuard = AutoSaveThrottleGuard();
      final flowMetricsCollector = FormFlowMetricsCollector();
      final draftSaveCoordinator = const DraftSaveCoordinator();

      String? autoSaveDraftId;
      DateTime? lastSaved;
      String? capturedDraftId;
      Map<String, dynamic>? capturedEnvelope;

      await FormAutoSaveHelper.autoSaveDraft(
        controllers: controllers,
        draftSaveCoordinator: draftSaveCoordinator,
        throttleGuard: throttleGuard,
        currentTabIndex: 2,
        beneficiaryId: null,
        currentAutoSaveDraftId: autoSaveDraftId,
        setAutoSaveDraftId: (value) => autoSaveDraftId = value,
        onLastSaved: (value) => lastSaved = value,
        isMounted: () => true,
        flowMetricsCollector: flowMetricsCollector,
        saveDraft: ({required draftId, required formData}) async {
          capturedDraftId = draftId;
          capturedEnvelope = formData;
        },
      );

      expect(capturedDraftId, isNotNull);
      expect(autoSaveDraftId, capturedDraftId);
      expect(lastSaved, isNotNull);
      expect(capturedEnvelope?['isAutoSaved'], true);
      expect(flowMetricsCollector.summarize('autoSaveDraft')?.count, 1);
    });

    test('skips unchanged auto-save calls within cooldown', () async {
      final controllers = BeneficiaryFormControllers();
      addTearDown(controllers.dispose);

      controllers.firstNameController.text = 'Sara';
      controllers.nationalIdController.text = '55555';

      final throttleGuard = AutoSaveThrottleGuard();
      final flowMetricsCollector = FormFlowMetricsCollector();
      final draftSaveCoordinator = const DraftSaveCoordinator();

      String? autoSaveDraftId;
      var saveCalls = 0;

      Future<void> run() {
        return FormAutoSaveHelper.autoSaveDraft(
          controllers: controllers,
          draftSaveCoordinator: draftSaveCoordinator,
          throttleGuard: throttleGuard,
          currentTabIndex: 0,
          beneficiaryId: null,
          currentAutoSaveDraftId: autoSaveDraftId,
          setAutoSaveDraftId: (value) => autoSaveDraftId = value,
          onLastSaved: (_) {},
          isMounted: () => true,
          flowMetricsCollector: flowMetricsCollector,
          saveDraft: ({required draftId, required formData}) async {
            saveCalls++;
          },
        );
      }

      await run();
      await run();

      expect(saveCalls, 1);
    });
  });

  group('FormAutoSaveHelper.performAutoSave', () {
    test('does not trigger auto-save when no changes', () async {
      var autoSaveCalls = 0;

      await FormAutoSaveHelper.performAutoSave(
        isSaving: false,
        isDeleting: false,
        isLoading: false,
        runDebounced: (action) {
          action();
        },
        isMounted: () => true,
        hasChanges: false,
        throttleGuard: AutoSaveThrottleGuard(),
        autoSaveDraft: () async {
          autoSaveCalls++;
        },
      );

      expect(autoSaveCalls, 0);
    });
  });
}
