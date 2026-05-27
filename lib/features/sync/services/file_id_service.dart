import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/notifications/notifications_service.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/utils/unified_logger.dart';
import '../data/repositories/local_file_number_pool_repository.dart';
import '../data/services/firestore_file_number_service.dart';
import '../domain/repositories/file_id_reservation_repository.dart';
import 'file_number_formatter.dart';

class CedarFileNumbersProgress {
  final String phase;
  final int total;
  final int processed;
  final int available;
  final String? rangeStart;
  final String? rangeEnd;

  const CedarFileNumbersProgress({
    required this.phase,
    required this.total,
    required this.processed,
    required this.available,
    this.rangeStart,
    this.rangeEnd,
  });
}

class CedarFileNumbersResult {
  final int reservedCount;
  final int availableCount;
  final String rangeStart;
  final String rangeEnd;

  const CedarFileNumbersResult({
    required this.reservedCount,
    required this.availableCount,
    required this.rangeStart,
    required this.rangeEnd,
  });
}

class FileNumberPoolSnapshot {
  final int available;
  final int assignedLocal;
  final int synced;
  final int conflicts;
  final String? rangeStart;
  final String? rangeEnd;

  const FileNumberPoolSnapshot({
    required this.available,
    required this.assignedLocal,
    required this.synced,
    required this.conflicts,
    required this.rangeStart,
    required this.rangeEnd,
  });
}

/// 🆔 File ID Service
///
/// Orchestrates File ID management:
/// - Provides next available ID
/// - Triggers background reservation if running low
/// - Manages usage sync
class FileIdService {
  final FileIdReservationRepository _repository;
  final LocalFileNumberPoolRepository? _localPoolRepository;
  final FirestoreFileNumberService? _firestoreFileNumberService;
  final SecureStorage? _secureStorage;
  final int _lowThreshold;
  final int _reserveBatchSize;
  final int _minimumLocalThreshold;
  final String _filePrefix;

  bool _isReserving = false;
  bool _noCodesAdminAlertSent = false;

  FileIdService(
    this._repository, {
    LocalFileNumberPoolRepository? localPoolRepository,
    FirestoreFileNumberService? firestoreFileNumberService,
    SecureStorage? secureStorage,
    int lowThreshold = ApiConfig.fileIdRenewThreshold,
    int reserveBatchSize = ApiConfig.fileIdReserveBatchSize,
    int minimumLocalThreshold = 100,
    String filePrefix = 'GZ',
  })  : _lowThreshold = lowThreshold < 1 ? ApiConfig.fileIdRenewThreshold : lowThreshold,
        _reserveBatchSize = reserveBatchSize.clamp(100, 10000),
        _minimumLocalThreshold = minimumLocalThreshold < 1 ? 100 : minimumLocalThreshold,
        _filePrefix = filePrefix.trim().isEmpty ? 'GZ' : filePrefix.trim().toUpperCase(),
        _localPoolRepository = localPoolRepository,
        _firestoreFileNumberService = firestoreFileNumberService,
        _secureStorage = secureStorage;

  Future<String?> getNextFileNumber() async {
    final localPool = _localPoolRepository;
    if (localPool == null) {
      final legacy = await getNextId();
      if (legacy == null || legacy <= 0) return null;
      return legacy.toString();
    }

    try {
      await localPool.cleanupExpiredTentatives();
      await _ensurePoolHealthy();

      var next = await localPool.getNextAvailableNumber();
      if (next == null) {
        await reserveRemoteBlock();
        next = await localPool.getNextAvailableNumber();
      }

      return next?.fileNumber;
    } catch (e) {
      UnifiedLogger.error('❌ Failed to fetch next file number from local pool', error: e);
      return null;
    }
  }

  Future<void> markTentative({
    required String fileNumber,
    required String formSessionId,
  }) async {
    final localPool = _localPoolRepository;
    if (localPool == null) return;
    await localPool.markTentative(fileNumber, formSessionId);
  }

  Future<void> releaseTentative(String formSessionId) async {
    final localPool = _localPoolRepository;
    if (localPool == null) return;
    await localPool.releaseTentative(formSessionId);
  }

  Future<void> assignFileNumberToBeneficiary({
    required String fileNumber,
    required int beneficiaryLocalId,
  }) async {
    final localPool = _localPoolRepository;
    if (localPool != null) {
      await localPool.assignToBeneficiary(fileNumber, beneficiaryLocalId.toString());
      return;
    }

    final numeric = FileNumberFormatter.extractSequence(fileNumber);
    if (numeric != null) {
      await markAsUsed(numeric, beneficiaryLocalId);
    }
  }

  Future<void> markFileNumberSynced(String fileNumber) async {
    final localPool = _localPoolRepository;
    if (localPool == null) return;
    await localPool.markSynced(fileNumber);
  }

  Future<void> markFileNumberConflict(String fileNumber) async {
    final localPool = _localPoolRepository;
    if (localPool == null) return;
    await localPool.markConflict(fileNumber);
  }

  Future<void> releaseAssignedFileNumber(String fileNumber) async {
    final localPool = _localPoolRepository;
    if (localPool == null) return;
    await localPool.releaseAssigned(fileNumber);
  }

  Future<int> getAvailableFileNumbersCount() async {
    final localPool = _localPoolRepository;
    if (localPool == null) {
      final legacy = await _repository.getAvailableCount();
      return legacy.getOrNull() ?? 0;
    }
    return localPool.getAvailableCount();
  }

  /// 🆔 Get Next Available ID
  ///
  /// returns the next ID and triggers background reservation if low.
  Future<int?> getNextId() async {
    final modern = await getNextFileNumber();
    if (modern != null) {
      return FileNumberFormatter.extractSequence(modern);
    }

    try {
      final result = await _repository.getNextAvailableId();

      if (result.isFailure) {
        UnifiedLogger.error('❌ Failed to get next File ID', error: result.getOrThrow());
        return null;
      }

      final id = result.getOrNull();

      // Check if we are running low and need to reserve more
      _checkAndReserveIfNeeded();

      return id;
    } catch (e) {
      UnifiedLogger.error('❌ Error in FileIdService.getNextId', error: e);
      return null;
    }
  }

  /// ✅ Mark ID as used
  Future<void> markAsUsed(
    int fileId,
    int beneficiaryId, {
    String recordType = 'data',
    int? recordId,
  }) async {
    await _repository.markAsUsed(
      fileId,
      beneficiaryId,
      recordType: recordType,
      recordId: recordId,
    );
    UnifiedLogger.info('🆔 File ID $fileId marked as used for beneficiary $beneficiaryId');
  }

  /// 📥 Force reserve now
  Future<void> forceReserve() async {
    if (_isReserving) return;
    if (_localPoolRepository != null && _firestoreFileNumberService != null) {
      await reserveRemoteBlock();
      return;
    }
    await _refillByCodesContract();
  }

  /// 🔄 Sync usage to server
  Future<void> syncUsage() async {
    if (_localPoolRepository != null && _firestoreFileNumberService != null) {
      await confirmAssignedNumbers();
      return;
    }
    await _repository.syncUsedIds();
  }

  /// ⭐ Run login sync against /codes/login-sync
  Future<void> loginSync() async {
    await _repository.loginSyncCodes();
  }

  Future<String> buildNoFileIdSaveMessage() async {
    if (_localPoolRepository != null && _firestoreFileNumberService != null) {
      return 'لا توجد أرقام ملفات متاحة محلياً. يرجى الاتصال بالإنترنت ومزامنة أرقام الملفات.';
    }

    final diagnostics = await getDiagnostics();
    final code = diagnostics?.lastRefillErrorCode?.trim();

    if (code == 'no_codes_available') {
      return 'لا توجد أكواد متاحة على السيرفر حالياً. يرجى إبلاغ الإدارة لإنشاء دفعة أكواد جديدة ثم إعادة المحاولة.';
    }

    if (code == 'limit_reached') {
      return 'وصل الجهاز للحد الأعلى من الأكواد غير المستخدمة (5000). استخدم الأكواد الحالية أو نفّذ مزامنة ثم أعد المحاولة.';
    }

    return 'تعذر حجز رقم الملف من السيرفر. يرجى تنفيذ المزامنة ثم إعادة المحاولة.';
  }

  /// 🔄 Public method to trigger reservation check
  Future<void> ensureReservation() async {
    if (_localPoolRepository != null && _firestoreFileNumberService != null) {
      await syncDownFileNumberState();
      await _ensurePoolHealthy();
      return;
    }
    await _checkAndReserveIfNeeded();
  }

  Future<void> syncDownFileNumberState() async {
    final localPool = _localPoolRepository;
    final remote = _firestoreFileNumberService;
    if (localPool == null || remote == null) return;

    try {
      final deviceId = await _resolveDeviceId();
      final userId = _resolveUserId();

      final remoteBlocks = await remote.fetchDeviceBlocks(deviceId: deviceId, userId: userId);
      for (final block in remoteBlocks) {
        await localPool.importReservedBlock(block);
      }

      final allocations = await remote.fetchDeviceAllocations(deviceId: deviceId, userId: userId);
      await localPool.mergeRemoteAllocationStatuses(allocations);
    } catch (e) {
      UnifiedLogger.warning('⚠️ File-number sync-down merge failed: $e');
    }
  }

  Future<int> reserveRemoteBlock({int? blockSize}) async {
    if (_isReserving) return 0;

    final localPool = _localPoolRepository;
    final remote = _firestoreFileNumberService;
    if (localPool == null || remote == null) return 0;

    _isReserving = true;
    try {
      final deviceId = await _resolveDeviceId();
      final userId = _resolveUserId();
      final year = DateTime.now().year;
      final requestedSize = (blockSize ?? _reserveBatchSize).clamp(100, 5000);

      final block = await remote.reserveBlock(
        deviceId: deviceId,
        userId: userId,
        prefix: _filePrefix,
        year: year,
        blockSize: requestedSize,
      );

      await localPool.importReservedBlock(block);
      UnifiedLogger.success('✅ Reserved block ${block.blockId} (${block.size} numbers)');
      return block.size;
    } catch (e) {
      UnifiedLogger.warning('⚠️ Failed to reserve Firestore block: $e');
      return 0;
    } finally {
      _isReserving = false;
    }
  }

  Future<void> debugFileNumberFirestoreAccess({int? year}) async {
    final remote = _firestoreFileNumberService;
    if (remote == null) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      UnifiedLogger.warning('[CedarFileNumbers] debug aborted: FirebaseAuth.currentUser is null');
      throw StateError('FirebaseAuth.currentUser is null');
    }

    final effectiveYear = year ?? DateTime.now().year;
    UnifiedLogger.info('[CedarFileNumbers] debug project=${remote.projectId} year=$effectiveYear');
    UnifiedLogger.info(
      '[CedarFileNumbers] debug user uid=${currentUser.uid} email=${currentUser.email ?? 'unknown'}',
    );

    try {
      await remote.debugFileNumberFirestoreAccess(
        year: effectiveYear,
        uid: currentUser.uid,
        email: currentUser.email ?? 'unknown',
      );
      UnifiedLogger.info('[CedarFileNumbers] debug firestore access passed all steps');
    } catch (e) {
      UnifiedLogger.error('[CedarFileNumbers] debug firestore access failed', error: e);
      rethrow;
    }
  }

  Future<CedarFileNumbersResult> uploadCedarFileNumbers({
    int blockSize = 500,
    int? year,
    FutureOr<void> Function(CedarFileNumbersProgress progress)? onProgress,
  }) async {
    final localPool = _localPoolRepository;
    final remote = _firestoreFileNumberService;
    if (localPool == null || remote == null) {
      throw StateError('Cedar file-number upload is not configured.');
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw StateError('FirebaseAuth.currentUser is required to upload Cedar file numbers.');
    }

    final effectiveYear = year ?? DateTime.now().year;
    final safeBlockSize = blockSize <= 0 ? 500 : blockSize;
    UnifiedLogger.info('[CedarFileNumbers] started blockSize=$safeBlockSize');

    await onProgress?.call(
      CedarFileNumbersProgress(
        phase: 'reserving_block',
        total: safeBlockSize,
        processed: 0,
        available: await localPool.getAvailableCount(),
      ),
    );

    await remote.ensureCounterDocument(
      year: effectiveYear,
      prefix: _filePrefix,
      blockSizeDefault: safeBlockSize,
    );
    UnifiedLogger.info('[CedarFileNumbers] counter created/read: global_$effectiveYear');

    final deviceId = await _resolveDeviceId();
    final block = await remote.reserveBlock(
      deviceId: deviceId,
      userId: currentUser.uid,
      prefix: _filePrefix,
      year: effectiveYear,
      blockSize: safeBlockSize,
    );
    UnifiedLogger.info('[CedarFileNumbers] block reserved start=${block.start} end=${block.end}');

    await onProgress?.call(
      CedarFileNumbersProgress(
        phase: 'importing_local_pool',
        total: safeBlockSize,
        processed: 0,
        available: await localPool.getAvailableCount(),
        rangeStart: FileNumberFormatter.format(prefix: block.prefix, year: block.year, number: block.start),
        rangeEnd: FileNumberFormatter.format(prefix: block.prefix, year: block.year, number: block.end),
      ),
    );

    await localPool.importReservedBlock(block);
    UnifiedLogger.info('[CedarFileNumbers] imported local pool count=${block.size}');

    final available = await localPool.getAvailableCount();
    final rangeStart = FileNumberFormatter.format(prefix: block.prefix, year: block.year, number: block.start);
    final rangeEnd = FileNumberFormatter.format(prefix: block.prefix, year: block.year, number: block.end);

    await onProgress?.call(
      CedarFileNumbersProgress(
        phase: 'completed',
        total: safeBlockSize,
        processed: safeBlockSize,
        available: available,
        rangeStart: rangeStart,
        rangeEnd: rangeEnd,
      ),
    );

    UnifiedLogger.info('[CedarFileNumbers] completed available=$available');

    return CedarFileNumbersResult(
      reservedCount: block.size,
      availableCount: available,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
    );
  }

  Future<FileNumberPoolSnapshot?> getLocalPoolSnapshot() async {
    final localPool = _localPoolRepository;
    if (localPool == null) return null;

    final available = await localPool.getAvailableCount();
    final assignedLocal = await localPool.getAssignedLocalCount();
    final synced = await localPool.getSyncedCount();
    final conflicts = await localPool.getConflictCount();
    final range = await localPool.getCurrentReservedRange();

    return FileNumberPoolSnapshot(
      available: available,
      assignedLocal: assignedLocal,
      synced: synced,
      conflicts: conflicts,
      rangeStart: range?.start,
      rangeEnd: range?.end,
    );
  }

  Future<void> confirmAssignedNumbers() async {
    final localPool = _localPoolRepository;
    final remote = _firestoreFileNumberService;
    if (localPool == null || remote == null) return;

    final deviceId = await _resolveDeviceId();
    final userId = _resolveUserId();
    final pending = await localPool.getPendingAssignedNumbers(deviceId: deviceId, userId: userId);
    if (pending.isEmpty) return;

    try {
      await remote.confirmAssignedNumbers(pending);
      for (final item in pending) {
        await localPool.markSynced(item.fileNumber);
      }
      UnifiedLogger.info('✅ Confirmed ${pending.length} file-number allocations on Firestore');
    } catch (e) {
      UnifiedLogger.warning('⚠️ Failed to confirm assigned file numbers: $e');
    }
  }

  Future<void> _ensurePoolHealthy() async {
    final localPool = _localPoolRepository;
    if (localPool == null) return;

    final available = await localPool.getAvailableCount();
    if (available >= _minimumLocalThreshold) return;
    await reserveRemoteBlock();
  }

  Future<String> _resolveDeviceId() async {
    try {
      final secureStorage = _secureStorage ?? SecureStorage();
      final deviceId = (await secureStorage.getDeviceId()).trim();
      if (deviceId.isNotEmpty) return deviceId;
    } catch (_) {}

    return 'unknown-device';
  }

  String _resolveUserId() {
    final userId = FirebaseAuth.instance.currentUser?.uid.trim();
    if (userId != null && userId.isNotEmpty) return userId;
    return 'anonymous';
  }

  /// 📊 Get diagnostics for local/remote File ID state
  Future<FileIdDiagnostics?> getDiagnostics() async {
    if (_localPoolRepository != null) {
      final available = await _localPoolRepository.getAvailableCount();
      final pending = await _localPoolRepository.getPendingAssignedNumbers(
        deviceId: await _resolveDeviceId(),
        userId: _resolveUserId(),
      );

      return FileIdDiagnostics(
        availableCount: available,
        usedUnsyncedCount: pending.length,
      );
    }

    final result = await _repository.getDiagnostics();
    if (result.isFailure) {
      return null;
    }
    return result.getOrNull();
  }

  /// 📊 Check availability and reserve in background if needed
  Future<void> _checkAndReserveIfNeeded() async {
    if (_isReserving) return;

    _isReserving = true;
    try {
      final refillResult = await _repository.refillIfNeeded(
        lowThreshold: _lowThreshold,
        requestCount: _reserveBatchSize,
      );

      if (refillResult.isSuccess) {
        final added = refillResult.getOrThrow();
        if (added > 0) {
          UnifiedLogger.success('✅ Refilled $added codes via /codes/request-codes');
        }
        await _handleRefillDiagnostics();
        return;
      }

      UnifiedLogger.warning('⚠️ Codes refill failed via /codes/request-codes');
      await _handleRefillDiagnostics();
    } finally {
      _isReserving = false;
    }
  }

  Future<void> _refillByCodesContract() async {
    _isReserving = true;
    try {
      final result = await _repository.refillIfNeeded(
        lowThreshold: _lowThreshold,
        requestCount: _reserveBatchSize,
      );

      if (result.isSuccess) {
        final added = result.getOrThrow();
        if (added > 0) {
          UnifiedLogger.success('✅ Requested and saved $added codes');
        }
        await _handleRefillDiagnostics();
        return;
      }
      UnifiedLogger.warning('⚠️ Force refill finished without new codes');
      await _handleRefillDiagnostics();
    } catch (e) {
      UnifiedLogger.warning('⚠️ Force refill failed: $e');
    } finally {
      _isReserving = false;
    }
  }

  Future<void> _handleRefillDiagnostics() async {
    final diagnostics = await getDiagnostics();
    final code = diagnostics?.lastRefillErrorCode?.trim();
    final message = diagnostics?.lastRefillErrorMessage?.trim();

    if (code == 'no_codes_available') {
      UnifiedLogger.warning('🚨 No codes available on server. Admin needs to create a new batch.');
      if (!_noCodesAdminAlertSent) {
        _noCodesAdminAlertSent = true;
        await NotificationsService.showCodesInventoryAlert(
          title: 'تنبيه إداري: نفاد أكواد السيرفر',
          body: 'لا توجد أكواد متاحة حالياً. يلزم إنشاء دفعة جديدة من السيرفر فوراً.',
        );
      }
      return;
    }

    _noCodesAdminAlertSent = false;

    if (code == 'limit_reached') {
      UnifiedLogger.info('ℹ️ Device reached max unused codes limit (5000).');
      return;
    }

    if (message != null && message.isNotEmpty) {
      UnifiedLogger.warning('⚠️ Codes refill issue: $message');
    }
  }
}
