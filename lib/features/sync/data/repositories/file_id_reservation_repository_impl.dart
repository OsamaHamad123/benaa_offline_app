import '../../../../core/error_handling/result.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../data/db/daos/file_id_reservation_dao.dart';
import '../../domain/repositories/file_id_reservation_repository.dart';
import '../datasources/file_id_remote_datasource.dart';

/// 🆔 File ID Reservation Repository Implementation
class FileIdReservationRepositoryImpl implements FileIdReservationRepository {
  final FileIdRemoteDataSource remoteDataSource;
  final FileIdReservationDao localDao;
  FileIdReservationSnapshot? _lastReservedSnapshot;
  static const int _maxRequestCodesCount = 5000;
  DateTime? _lastLoginSyncAt;
  DeviceCodeStats? _lastDeviceCodeStats;
  String? _lastRefillErrorCode;
  String? _lastRefillErrorMessage;

  FileIdReservationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDao,
  });

  @override
  Future<Result<void>> loginSyncCodes() async {
    try {
      var deviceId = '';

      try {
        deviceId = (await SecureStorage().getDeviceId()).trim();
      } catch (_) {
        final activeBatch = await localDao.getActiveReservationBatch();
        deviceId = (activeBatch?['device_id']?.toString() ?? '').trim();
      }

      if (deviceId.isEmpty) {
        return const Success(null);
      }

      final localCodes = await localDao.getAllCodesForLoginSyncPayload();
      final payload = localCodes
          .map(
            (row) => DeviceCodeStatusPayload(
              code: row['code'].toString(),
              used: row['used'] == true,
              usedAt: row['used_at']?.toString(),
              recordId: row['record_id']?.toString(),
            ),
          )
          .toList(growable: false);

      final result = await remoteDataSource.loginSync(
        deviceId: deviceId,
        deviceCodes: payload,
      );

      final confirmed = <int>{...result.confirmedUsed, ...result.alreadyConfirmed}.toList(growable: false);
      if (confirmed.isNotEmpty) {
        await localDao.markAsSynced(confirmed);
      }

      if (result.invalidCodes.isNotEmpty) {
        await localDao.deleteCodes(result.invalidCodes);
      }

      if (result.conflictCodes.isNotEmpty) {
        await localDao.markAsConflict(result.conflictCodes);
      }

      if (result.newCodes.isNotEmpty) {
        await localDao.insertReservedIds(result.newCodes);
      }

      _lastLoginSyncAt = DateTime.now();

      return const Success(null);
    } catch (e) {
      return Failure(NetworkFailure('Failed to run login-sync: $e'));
    }
  }

  @override
  Future<Result<List<int>>> reserveFromRemote(int count) async {
    try {
      final snapshot = await remoteDataSource.reserveBatchSnapshot(count);
      if (snapshot != null) {
        _lastReservedSnapshot = snapshot;
        final ids = List<int>.generate(snapshot.endId - snapshot.startId + 1, (index) => snapshot.startId + index);
        return Success(ids);
      }

      final ids = await remoteDataSource.reserveIds(count);
      return Success(ids);
    } catch (e) {
      return Failure(NetworkFailure('Failed to reserve IDs: $e'));
    }
  }

  @override
  Future<Result<void>> saveLocal(List<int> ids) async {
    try {
      final snapshot = _lastReservedSnapshot;
      if (snapshot != null) {
        await localDao.upsertActiveReservationBatch(
          reservationId: snapshot.reservationId,
          deviceId: snapshot.deviceId,
          startId: snapshot.startId,
          endId: snapshot.endId,
          batchSize: snapshot.batchSize,
          usedCount: snapshot.usedCount,
          remainingCount: snapshot.remainingCount,
          nextAvailableId: snapshot.nextAvailableId,
          status: snapshot.status,
          expiresAt: snapshot.expiresAt,
          createdAt: snapshot.createdAt,
        );
      }

      await localDao.insertReservedIds(ids);
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseFailure('Failed to save IDs locally: $e'));
    }
  }

  @override
  Future<Result<int?>> getNextAvailableId() async {
    try {
      final idFromBatch = await localDao.allocateNextAvailableFromBatch();
      if (idFromBatch != null) {
        return Success(idFromBatch);
      }

      final id = await localDao.getNextAvailableId();
      return Success(id);
    } catch (e) {
      return Failure(DatabaseFailure('Failed to get next ID: $e'));
    }
  }

  @override
  Future<Result<void>> markAsUsed(
    int fileId,
    int beneficiaryId, {
    String recordType = 'data',
    int? recordId,
  }) async {
    try {
      await localDao.markAsUsed(
        fileId,
        beneficiaryId,
        recordType: recordType,
        recordId: recordId,
      );
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseFailure('Failed to mark ID as used: $e'));
    }
  }

  @override
  Future<Result<void>> syncUsedIds() async {
    try {
      final usedRecords = await localDao.getUsedUnsyncedIds();
      if (usedRecords.isNotEmpty) {
        final payloadRows = await localDao.getUnsyncedUsedCodesPayload();
        final payload = payloadRows
            .map(
              (row) => ConfirmUsageCodePayload(
                code: row['code'].toString(),
                usedAt: row['used_at']?.toString(),
                recordType: row['record_type']?.toString(),
                recordId: row['record_id'] is int ? row['record_id'] as int : int.tryParse('${row['record_id']}'),
              ),
            )
            .toList(growable: false);

        final syncedCodes = <int>{};
        final conflictCodes = <int>{};
        final notFoundCodes = <int>{};

        const chunkSize = 500;
        for (var start = 0; start < payload.length; start += chunkSize) {
          final end = (start + chunkSize) > payload.length ? payload.length : (start + chunkSize);
          final chunk = payload.sublist(start, end);

          final details = await remoteDataSource.confirmUsageCodes(chunk);
          syncedCodes.addAll(details.confirmed);
          syncedCodes.addAll(details.alreadyUsed);
          conflictCodes.addAll(details.conflicts);
          notFoundCodes.addAll(details.notFound);
        }

        if (syncedCodes.isNotEmpty) {
          await localDao.markAsSynced(syncedCodes.toList(growable: false));
        }

        if (conflictCodes.isNotEmpty) {
          await localDao.markAsConflict(conflictCodes.toList(growable: false));
        }

        if (notFoundCodes.isNotEmpty) {
          await localDao.deleteCodes(notFoundCodes.toList(growable: false));
        }

        final reservationId = await localDao.getActiveReservationBatchId();
        if (reservationId != null) {
          await localDao.markBatchUsedCountSynced(reservationId);
        }
        return const Success(null);
      }

      return const Success(null);
    } catch (e) {
      return Failure(NetworkFailure('Failed to sync used IDs: $e'));
    }
  }

  @override
  Future<Result<int>> getAvailableCount() async {
    try {
      final count = await localDao.countAvailable();
      return Success(count);
    } catch (e) {
      return Failure(DatabaseFailure('Failed to count available IDs: $e'));
    }
  }

  @override
  Future<Result<int>> refillIfNeeded({
    required int lowThreshold,
    required int requestCount,
  }) async {
    try {
      _clearRefillIssue();
      final localAvailableBefore = await localDao.countAvailable();
      if (localAvailableBefore >= lowThreshold) {
        return const Success(0);
      }

      final stats = await remoteDataSource.getDeviceCodeStats();
      if (stats != null) {
        _lastDeviceCodeStats = stats;
      }

      if (stats == null) {
        final fallbackRequestCount = _resolveRequestCount(
          requestCount: requestCount,
          availableSlots: null,
        );
        if (fallbackRequestCount <= 0) {
          return const Success(0);
        }

        final requestedCodes = await remoteDataSource.requestCodes(fallbackRequestCount);
        if (requestedCodes.isEmpty) {
          return const Success(0);
        }

        await localDao.insertReservedIds(requestedCodes);
        _clearRefillIssue();
        final localAvailableAfterFallback = await localDao.countAvailable();
        return Success(localAvailableAfterFallback - localAvailableBefore);
      }

      if (stats.unusedCount >= lowThreshold) {
        final loginSyncResult = await loginSyncCodes();
        if (loginSyncResult.isFailure) {
          return Failure(NetworkFailure('Failed to recover assigned codes via login-sync'));
        }

        final localAvailableAfterSync = await localDao.countAvailable();
        if (localAvailableAfterSync >= lowThreshold || !stats.canRequestMore) {
          return Success(localAvailableAfterSync - localAvailableBefore);
        }
      }

      final shouldRequest = stats.unusedCount < lowThreshold && stats.canRequestMore;
      if (!shouldRequest) {
        if (!stats.canRequestMore) {
          _setRefillIssue(
            code: 'limit_reached',
            message: 'Maximum unused codes limit reached (5000)',
          );
        }
        return const Success(0);
      }

      final effectiveRequestCount = _resolveRequestCount(
        requestCount: requestCount,
        availableSlots: stats.availableSlots,
      );
      if (effectiveRequestCount <= 0) {
        _setRefillIssue(
          code: 'limit_reached',
          message: 'No available slots for requesting additional codes',
        );
        return const Success(0);
      }

      final codes = await remoteDataSource.requestCodes(effectiveRequestCount);
      if (codes.isEmpty) {
        return const Success(0);
      }

      await localDao.insertReservedIds(codes);
      _clearRefillIssue();

      final localAvailableAfter = await localDao.countAvailable();
      return Success(localAvailableAfter - localAvailableBefore);
    } on CodesApiException catch (e) {
      _setRefillIssue(
        code: e.errorCode,
        message: e.message,
      );
      if (e.errorCode == 'limit_reached' || e.errorCode == 'no_codes_available') {
        return const Success(0);
      }
      return Failure(NetworkFailure('Failed to refill codes: $e'));
    } catch (e) {
      return Failure(NetworkFailure('Failed to refill codes: $e'));
    }
  }

  int _resolveRequestCount({
    required int requestCount,
    required int? availableSlots,
  }) {
    if (requestCount <= 0) {
      return 0;
    }

    var effectiveRequestCount = requestCount > _maxRequestCodesCount ? _maxRequestCodesCount : requestCount;
    if (availableSlots != null && availableSlots < effectiveRequestCount) {
      effectiveRequestCount = availableSlots;
    }

    return effectiveRequestCount;
  }

  @override
  Future<Result<FileIdDiagnostics>> getDiagnostics() async {
    try {
      final availableCount = await localDao.countAvailable();
      final activeBatch = await localDao.getActiveReservationBatch();
      final batchRemaining = (activeBatch?['remaining_count'] as int?) ?? 0;
      final usedUnsyncedCount = await localDao.countUsedUnsynced();
      final lastReservedAt = await localDao.getLastReservedAt();
      final lastSyncedAt = await localDao.getLastSyncedAt();
      var latestStats = _lastDeviceCodeStats;
      try {
        final remoteStats = await remoteDataSource.getDeviceCodeStats();
        if (remoteStats != null) {
          latestStats = remoteStats;
          _lastDeviceCodeStats = remoteStats;
        }
      } catch (_) {}

      int? reservationId;
      int? remainingCount;
      try {
        final remoteStatus = await remoteDataSource.getActiveReservationStatus();
        reservationId = remoteStatus.reservationId;
        remainingCount = remoteStatus.remainingCount;
      } catch (_) {
        reservationId = null;
        remainingCount = null;
      }

      return Success(
        FileIdDiagnostics(
          availableCount: batchRemaining > availableCount ? batchRemaining : availableCount,
          usedUnsyncedCount: usedUnsyncedCount,
          lastReservedAt: lastReservedAt,
          lastSyncedAt: lastSyncedAt,
          activeReservationId: reservationId,
          activeReservationRemaining: remainingCount,
          remoteUnusedCount: latestStats?.unusedCount,
          remoteCanRequestMore: latestStats?.canRequestMore,
          remoteAvailableSlots: latestStats?.availableSlots,
          lastLoginSyncAt: _lastLoginSyncAt,
          lastRefillErrorCode: _lastRefillErrorCode,
          lastRefillErrorMessage: _lastRefillErrorMessage,
        ),
      );
    } catch (e) {
      return Failure(DatabaseFailure('Failed to load file-id diagnostics: $e'));
    }
  }

  void _setRefillIssue({
    required String code,
    required String message,
  }) {
    _lastRefillErrorCode = code.trim().isEmpty ? null : code.trim();
    _lastRefillErrorMessage = message.trim().isEmpty ? null : message.trim();
  }

  void _clearRefillIssue() {
    _lastRefillErrorCode = null;
    _lastRefillErrorMessage = null;
  }
}
