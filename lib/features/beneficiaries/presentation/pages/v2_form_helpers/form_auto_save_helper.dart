import 'dart:async';

import '../../../../../core/errors/user_friendly_error.dart';
import 'package:flutter/foundation.dart';
import 'auto_save_throttle_guard.dart';
import 'draft_manager.dart';
import 'draft_save_coordinator.dart';
import 'form_controllers.dart';
import 'form_flow_metrics_collector.dart';
import 'form_flow_tracer.dart';

class FormAutoSaveHelper {
  static Future<void> performAutoSave({
    required bool isSaving,
    required bool isDeleting,
    required bool isLoading,
    required DebouncedAutoSave runDebounced,
    required bool Function() isMounted,
    required bool hasChanges,
    required AutoSaveThrottleGuard throttleGuard,
    required Future<void> Function() autoSaveDraft,
  }) async {
    if (isSaving || isDeleting || isLoading) return;

    runDebounced(() async {
      if (!isMounted()) return;
      if (!hasChanges) return;

      final now = DateTime.now();
      if (!throttleGuard.canAttempt(now)) {
        return;
      }

      await autoSaveDraft();
    });
  }

  static Future<void> autoSaveDraft({
    required BeneficiaryFormControllers controllers,
    required DraftSaveCoordinator draftSaveCoordinator,
    required AutoSaveThrottleGuard throttleGuard,
    required int currentTabIndex,
    required String? beneficiaryId,
    required String? currentAutoSaveDraftId,
    required void Function(String value) setAutoSaveDraftId,
    required void Function(DateTime value) onLastSaved,
    required bool Function() isMounted,
    required FormFlowMetricsCollector flowMetricsCollector,
    SaveDraftAction saveDraft = DraftManager.saveDraft,
  }) async {
    final trace = FormFlowTracer.start('autoSaveDraft');
    final now = DateTime.now();
    throttleGuard.markStarted();
    var success = false;
    var signature = '';

    try {
      final formData = draftSaveCoordinator.buildAutoSaveFormData(controllers);
      signature = AutoSaveThrottleGuard.buildSignature(
        formData: formData,
        currentTab: currentTabIndex,
      );

      if (throttleGuard.shouldSkipUnchanged(signature: signature, now: now)) {
        success = true;
        final elapsed = trace.end(result: 'skipped_unchanged');
        flowMetricsCollector.record(operation: 'autoSaveDraft', durationMs: elapsed);
        return;
      }

      final resolvedDraftId = draftSaveCoordinator.ensureAutoSaveDraftId(
        currentDraftId: currentAutoSaveDraftId,
        beneficiaryId: beneficiaryId,
        nationalId: controllers.nationalIdController.text.trim(),
        now: now,
      );
      setAutoSaveDraftId(resolvedDraftId);

      final draftName = draftSaveCoordinator.buildAutoDraftName(controllers);

      await saveDraft(
        draftId: resolvedDraftId,
        formData: draftSaveCoordinator.buildDraftEnvelope(
          name: draftName,
          notes: 'آخر تحديث: ${now.toString().split('.')[0]}',
          formData: formData,
          currentTab: currentTabIndex,
          beneficiaryId: beneficiaryId,
          isAutoSaved: true,
        ),
      ).timeout(const Duration(seconds: 2), onTimeout: () {
        throw TimeoutException('Auto-save draft timed out');
      });

      if (isMounted()) {
        onLastSaved(DateTime.now());
      }

      debugPrint('✅ Auto-saved draft successfully');
      success = true;
      final elapsed = trace.end(result: 'saved');
      flowMetricsCollector.record(operation: 'autoSaveDraft', durationMs: elapsed);
    } catch (e, stackTrace) {
      final errorMsg = UserFriendlyError.getMessage(e, stackTrace);
      debugPrint('❌ Auto-save failed: $errorMsg (technical: $e)');
      final elapsed = trace.end(result: 'failed');
      flowMetricsCollector.record(operation: 'autoSaveDraft', durationMs: elapsed);
    } finally {
      throttleGuard.markFinished(
        success: success,
        signature: signature,
        now: now,
      );
    }
  }
}

typedef DebouncedAutoSave = void Function(Future<void> Function() action);
typedef SaveDraftAction = Future<void> Function({
  required String draftId,
  required Map<String, dynamic> formData,
});
