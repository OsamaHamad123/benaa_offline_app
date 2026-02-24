import '../entities/sync_flow_contract.dart';

typedef SyncUpProgressCallback = void Function({
  required String operation,
  required double progress,
  bool isSyncing,
  DateTime? lastSyncAt,
  String? lastError,
});

class SyncUpFlowUseCase {
  final void Function(SyncOperationEvent event)? _emit;

  const SyncUpFlowUseCase({
    void Function(SyncOperationEvent event)? emit,
  }) : _emit = emit;

  Future<SyncFlowResult> execute({
    required Future<SyncUnifiedBridgeOutcome> Function() runUnifiedBridge,
    required Future<String> Function() getDeviceId,
    required Future<SyncStageCounters> Function() syncLegacyBeneficiaries,
    required Future<SyncStageCounters> Function() syncDeleteTombstones,
    required Future<SyncStageCounters> Function() syncVisits,
    required Future<SyncStageCounters> Function() syncFamilyMembers,
    required Future<SyncStageCounters> Function() syncDeadPeople,
    required Future<SyncStageCounters> Function() syncAttachments,
    required SyncUpProgressCallback onProgress,
    required String Function(Object error) classifyError,
    required String? Function(Object error) extractErrorContext,
  }) async {
    _emit?.call(
      SyncOperationEvent(
        phase: SyncOperationPhase.syncUp,
        status: SyncOperationStatus.started,
        stage: 'start',
        message: 'Starting sync up flow',
        progress: 0.0,
        timestamp: DateTime.now(),
      ),
    );

    onProgress(
      operation: 'جاري رفع التغييرات (Batch Sync)...',
      progress: 0.0,
      isSyncing: true,
    );

    try {
      final deviceId = await getDeviceId();
      int uploaded = 0;
      int failed = 0;

      final bridge = await runUnifiedBridge();
      uploaded += bridge.uploaded;
      failed += bridge.failed;

      onProgress(
        operation: 'جاري مزامنة عمليات الحذف... ',
        progress: 0.5,
      );
      _emit?.call(
        SyncOperationEvent(
          phase: SyncOperationPhase.syncUp,
          status: SyncOperationStatus.inProgress,
          stage: 'delete_tombstones',
          message: 'Syncing tombstone deletes',
          progress: 0.5,
          timestamp: DateTime.now(),
        ),
      );

      final deleteCounters = await syncDeleteTombstones();
      uploaded += deleteCounters.uploaded;
      failed += deleteCounters.failed;

      if (!bridge.handledBeneficiaries) {
        final legacy = await syncLegacyBeneficiaries();
        uploaded += legacy.uploaded;
        failed += legacy.failed;
      }

      if (!bridge.handledVisits) {
        onProgress(
          operation: 'جاري رفع الزيارات...',
          progress: 0.6,
        );
        final visits = await syncVisits();
        uploaded += visits.uploaded;
        failed += visits.failed;
      }

      onProgress(
        operation: 'جاري رفع أفراد العائلة... ',
        progress: 0.72,
      );
      final family = await syncFamilyMembers();
      uploaded += family.uploaded;
      failed += family.failed;

      onProgress(
        operation: 'جاري رفع بيانات المتوفين... ',
        progress: 0.78,
      );
      final deadPeople = await syncDeadPeople();
      uploaded += deadPeople.uploaded;
      failed += deadPeople.failed;

      onProgress(
        operation: 'جاري رفع المرفقات...',
        progress: 0.8,
      );
      final attachments = await syncAttachments();
      uploaded += attachments.uploaded;
      failed += attachments.failed;

      onProgress(
        operation: failed > 0 ? 'تم رفع $uploaded سجل (فشل $failed)' : 'تم رفع $uploaded سجل بنجاح ✓',
        progress: 1.0,
        isSyncing: false,
        lastSyncAt: DateTime.now(),
      );

      _emit?.call(
        SyncOperationEvent(
          phase: SyncOperationPhase.syncUp,
          status: SyncOperationStatus.completed,
          stage: 'completed',
          message: 'Sync up completed for device $deviceId',
          progress: 1.0,
          timestamp: DateTime.now(),
        ),
      );

      return SyncFlowResult(
        success: failed == 0,
        recordsSynced: uploaded,
        recordsFailed: failed,
      );
    } catch (error) {
      final message = error.toString();
      final category = classifyError(error);
      final context = extractErrorContext(error);

      onProgress(
        operation: 'فشل رفع التغييرات',
        progress: 1.0,
        isSyncing: false,
        lastError: message,
      );

      _emit?.call(
        SyncOperationEvent(
          phase: SyncOperationPhase.syncUp,
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
