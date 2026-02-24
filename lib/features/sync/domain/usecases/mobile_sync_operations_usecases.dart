import '../../../../core/sync/mobile_sync_service.dart';

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
    final upResult = await _syncUp();
    return (down: downResult, up: upResult);
  }
}
