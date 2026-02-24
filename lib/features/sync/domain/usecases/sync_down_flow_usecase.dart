import '../entities/sync_flow_contract.dart';

typedef SyncDownProgressCallback = void Function({
  required String operation,
  required double progress,
  bool isSyncing,
  DateTime? lastSyncAt,
  String? lastError,
});

class SyncDownFlowUseCase {
  final void Function(SyncOperationEvent event)? _emit;

  const SyncDownFlowUseCase({
    void Function(SyncOperationEvent event)? emit,
  }) : _emit = emit;

  Future<SyncFlowResult> execute({
    required Future<void> Function() syncTaxonomies,
    required Future<void> Function() ensureFileReservation,
    required Future<SyncFlowResult> Function() syncBeneficiariesDown,
    required SyncDownProgressCallback onProgress,
    required String Function(Object error) classifyError,
    required String? Function(Object error) extractErrorContext,
  }) async {
    _emit?.call(
      SyncOperationEvent(
        phase: SyncOperationPhase.syncDown,
        status: SyncOperationStatus.started,
        stage: 'start',
        message: 'Starting sync down flow',
        progress: 0.0,
        timestamp: DateTime.now(),
      ),
    );

    onProgress(
      operation: 'جاري تنزيل البيانات من السيرفر...',
      progress: 0.0,
      isSyncing: true,
    );

    try {
      onProgress(
        operation: 'جاري تحديث القوائم والتصنيفات...',
        progress: 0.1,
      );
      _emit?.call(
        SyncOperationEvent(
          phase: SyncOperationPhase.syncDown,
          status: SyncOperationStatus.inProgress,
          stage: 'taxonomies',
          message: 'Syncing taxonomies',
          progress: 0.1,
          timestamp: DateTime.now(),
        ),
      );
      await syncTaxonomies();

      onProgress(
        operation: 'جاري التحقق من مخزون الأرقام...',
        progress: 0.2,
      );
      _emit?.call(
        SyncOperationEvent(
          phase: SyncOperationPhase.syncDown,
          status: SyncOperationStatus.inProgress,
          stage: 'file_ids',
          message: 'Ensuring file id reservation',
          progress: 0.2,
          timestamp: DateTime.now(),
        ),
      );
      await ensureFileReservation();

      onProgress(
        operation: 'جاري تنزيل بيانات المستفيدين...',
        progress: 0.3,
      );
      _emit?.call(
        SyncOperationEvent(
          phase: SyncOperationPhase.syncDown,
          status: SyncOperationStatus.inProgress,
          stage: 'beneficiaries',
          message: 'Syncing beneficiaries down',
          progress: 0.3,
          timestamp: DateTime.now(),
        ),
      );

      final result = await syncBeneficiariesDown();

      onProgress(
        operation: 'تم تنزيل ${result.recordsSynced} مستفيد',
        progress: 1.0,
        isSyncing: false,
        lastSyncAt: DateTime.now(),
      );

      _emit?.call(
        SyncOperationEvent(
          phase: SyncOperationPhase.syncDown,
          status: SyncOperationStatus.completed,
          stage: 'completed',
          message: 'Sync down completed',
          progress: 1.0,
          timestamp: DateTime.now(),
        ),
      );

      return result;
    } catch (error) {
      final message = error.toString();
      final category = classifyError(error);
      final context = extractErrorContext(error);

      onProgress(
        operation: 'فشل تنزيل البيانات',
        progress: 1.0,
        isSyncing: false,
        lastError: message,
      );

      _emit?.call(
        SyncOperationEvent(
          phase: SyncOperationPhase.syncDown,
          status: SyncOperationStatus.failed,
          stage: 'failed',
          message: message,
          progress: 1.0,
          timestamp: DateTime.now(),
        ),
      );

      return SyncFlowResult.failure(
        error: message,
        errorCategory: category,
        errorContext: context,
      );
    }
  }
}
