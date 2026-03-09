import 'app_analytics.dart';

/// UX Flow Analytics helpers for operational product metrics.
class UxFlowAnalytics {
  static void trackDashboardOpened({required String viewMode}) {
    AppAnalytics.logEvent(
      'dashboard_opened',
      parameters: {
        'view_mode': viewMode,
      },
    );
  }

  static void trackDashboardFirstAction({
    required String action,
    required int elapsedMs,
    required String viewMode,
  }) {
    AppAnalytics.logEvent(
      'dashboard_time_to_first_action',
      parameters: {
        'action': action,
        'elapsed_ms': elapsedMs,
        'view_mode': viewMode,
      },
    );
  }

  static void trackDashboardAction(
    String action, {
    Map<String, dynamic>? parameters,
  }) {
    AppAnalytics.logEvent(
      'dashboard_action',
      parameters: {
        'action': action,
        ...?parameters,
      },
    );
  }

  static void trackDashboardModeChanged({
    required String mode,
  }) {
    AppAnalytics.logEvent(
      'dashboard_mode_changed',
      parameters: {
        'mode': mode,
      },
    );
  }

  static void trackSyncHubOpened({required String viewMode}) {
    AppAnalytics.logEvent(
      'sync_hub_opened',
      parameters: {
        'view_mode': viewMode,
      },
    );
  }

  static void trackSyncFunnelTriggered({
    required String trigger,
    int? elapsedFromOpenMs,
  }) {
    AppAnalytics.logEvent(
      'sync_funnel_triggered',
      parameters: {
        'trigger': trigger,
        if (elapsedFromOpenMs != null) 'elapsed_from_open_ms': elapsedFromOpenMs,
      },
    );
  }

  static void trackSyncFunnelCompleted({
    required String trigger,
    required bool success,
    int? elapsedFromTriggerMs,
    int? elapsedFromOpenMs,
    String? errorCategory,
  }) {
    AppAnalytics.logEvent(
      'sync_funnel_completed',
      parameters: {
        'trigger': trigger,
        'result': success ? 'success' : 'failure',
        if (elapsedFromTriggerMs != null) 'elapsed_from_trigger_ms': elapsedFromTriggerMs,
        if (elapsedFromOpenMs != null) 'elapsed_from_open_ms': elapsedFromOpenMs,
        if (errorCategory != null && errorCategory.isNotEmpty) 'error_category': errorCategory,
      },
    );
  }

  static void trackSyncManualRetryLoop({
    required String trigger,
    required int loopCount,
    required int elapsedSinceFirstTriggerMs,
  }) {
    AppAnalytics.logEvent(
      'sync_manual_retry_loop',
      parameters: {
        'trigger': trigger,
        'loop_count': loopCount,
        'elapsed_since_first_trigger_ms': elapsedSinceFirstTriggerMs,
      },
    );
  }

  static void trackSyncModeChanged({
    required String mode,
  }) {
    AppAnalytics.logEvent(
      'sync_mode_changed',
      parameters: {
        'mode': mode,
      },
    );
  }

  static void trackDiagnosticsExport({
    required bool success,
    required String source,
    required String viewMode,
  }) {
    AppAnalytics.logEvent(
      'sync_diagnostics_export',
      parameters: {
        'result': success ? 'success' : 'failure',
        'source': source,
        'view_mode': viewMode,
      },
    );
  }

  static void trackSettingsOpened() {
    AppAnalytics.logEvent('settings_opened');
  }

  static void trackSettingsSectionInteraction({
    required String section,
    required String action,
    Map<String, dynamic>? extra,
  }) {
    AppAnalytics.logEvent(
      'settings_section_interaction',
      parameters: {
        'section': section,
        'action': action,
        ...?extra,
      },
    );
  }

  static void trackSettingsSessionEnd({
    required int durationMs,
    required int interactedSectionsCount,
    required List<String> interactedSections,
  }) {
    AppAnalytics.logEvent(
      'settings_session_end',
      parameters: {
        'duration_ms': durationMs,
        'interacted_sections_count': interactedSectionsCount,
        'interacted_sections': interactedSections,
      },
    );
  }

  static void trackBeneficiaryPersonalAutoAdvance({
    required String field,
    required int inputLength,
  }) {
    AppAnalytics.logEvent(
      'beneficiary_personal_auto_advance',
      parameters: {
        'field': field,
        'input_length': inputLength,
      },
    );
  }

  static void trackBeneficiaryPersonalQuickNext({
    required String source,
  }) {
    AppAnalytics.logEvent(
      'beneficiary_personal_quick_next',
      parameters: {
        'source': source,
      },
    );
  }
}
