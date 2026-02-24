enum SyncOperationPhase {
  syncDown,
  syncUp,
}

enum SyncOperationStatus {
  started,
  inProgress,
  completed,
  failed,
}

class SyncOperationEvent {
  final SyncOperationPhase phase;
  final SyncOperationStatus status;
  final String stage;
  final String message;
  final double progress;
  final DateTime timestamp;

  const SyncOperationEvent({
    required this.phase,
    required this.status,
    required this.stage,
    required this.message,
    required this.progress,
    required this.timestamp,
  });
}

class SyncStageCounters {
  final int uploaded;
  final int failed;

  const SyncStageCounters({
    this.uploaded = 0,
    this.failed = 0,
  });
}

class SyncUnifiedBridgeOutcome {
  final int uploaded;
  final int failed;
  final bool handledBeneficiaries;
  final bool handledVisits;

  const SyncUnifiedBridgeOutcome({
    this.uploaded = 0,
    this.failed = 0,
    this.handledBeneficiaries = false,
    this.handledVisits = false,
  });
}

class SyncFlowResult {
  final bool success;
  final int recordsSynced;
  final int recordsFailed;
  final Map<String, int> payloadCounters;
  final Map<String, int> writeCounters;
  final String? error;
  final String? errorCategory;
  final String? errorContext;

  const SyncFlowResult({
    required this.success,
    this.recordsSynced = 0,
    this.recordsFailed = 0,
    this.payloadCounters = const <String, int>{},
    this.writeCounters = const <String, int>{},
    this.error,
    this.errorCategory,
    this.errorContext,
  });

  factory SyncFlowResult.failure({
    required String error,
    required String errorCategory,
    String? errorContext,
  }) {
    return SyncFlowResult(
      success: false,
      recordsSynced: 0,
      recordsFailed: 0,
      error: error,
      errorCategory: errorCategory,
      errorContext: errorContext,
    );
  }
}
