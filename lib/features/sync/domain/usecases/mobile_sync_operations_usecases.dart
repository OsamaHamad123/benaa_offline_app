import '../../../../core/sync/mobile_sync_service.dart';
import '../../../../core/sync/sync_history_store.dart';
import '../../../../core/sync/sync_result_snapshot_store.dart';

class MobileSyncDownUseCase {
  final MobileSyncService _service;

  const MobileSyncDownUseCase(this._service);

  Future<MobileSyncResult> call() => _service.syncDown();
}

class MobileSyncUpUseCase {
  final MobileSyncService _service;

  const MobileSyncUpUseCase(this._service);

  Future<MobileSyncResult> call() => _service.syncUp();
}

class MobileSyncRecordByFileIdUseCase {
  final MobileSyncService _service;

  const MobileSyncRecordByFileIdUseCase(this._service);

  Future<MobileSyncResult> call(String fileIdNumber) => _service.syncRecordByFileId(fileIdNumber);
}

class MobileOfficialSyncUseCase {
  final MobileSyncDownUseCase _syncDown;
  final MobileSyncUpUseCase _syncUp;

  const MobileOfficialSyncUseCase({
    required MobileSyncDownUseCase syncDown,
    required MobileSyncUpUseCase syncUp,
  })  : _syncDown = syncDown,
        _syncUp = syncUp;

  Future<({MobileSyncResult down, MobileSyncResult up})> call() async {
    final downResult = await _syncDown();
    await SyncResultSnapshotStore.save(
      SyncResultSnapshot.fromMobileResult(
        operation: 'sync_down',
        source: 'foreground',
        result: downResult,
      ),
    );
    await SyncHistoryStore.addEntry(
      SyncHistoryEntrySnapshot(
        timestamp: DateTime.now(),
        success: downResult.success,
        operation: 'sync_down',
        source: 'foreground',
        message: downResult.error,
        downloadedCount: downResult.recordsSynced,
        errorCategory: downResult.errorCategory,
      ),
    );

    final upResult = await _syncUp();
    await SyncResultSnapshotStore.save(
      SyncResultSnapshot.fromMobileResult(
        operation: 'sync_up',
        source: 'foreground',
        result: upResult,
      ),
    );
    await SyncHistoryStore.addEntry(
      SyncHistoryEntrySnapshot(
        timestamp: DateTime.now(),
        success: upResult.success,
        operation: 'sync_up',
        source: 'foreground',
        message: upResult.error,
        uploadedCount: upResult.recordsSynced,
        errorCategory: upResult.errorCategory,
      ),
    );

    return (down: downResult, up: upResult);
  }
}
