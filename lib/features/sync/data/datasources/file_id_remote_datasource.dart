import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/utils/api_endpoint_normalizer.dart' as sync_endpoint;

/// 🌐 File ID Remote Data Source
///
/// Handles API requests for File ID reservation and usage sync.
abstract class FileIdRemoteDataSource {
  /// ⭐ Login sync: reconcile device codes and fetch new ones
  Future<CodesLoginSyncResult> loginSync({
    required String deviceId,
    required List<DeviceCodeStatusPayload> deviceCodes,
  });

  /// 📥 Reserve IDs from server
  Future<List<int>> reserveIds(int count);

  /// 📥 Reserve batch snapshot from server
  Future<FileIdReservationSnapshot?> reserveBatchSnapshot(int count);

  /// 🔄 Sync used IDs to server
  Future<void> syncUsedIds(List<int> usedIds);

  /// 🔄 Confirm usage via codes contract with detailed result buckets
  Future<CodesConfirmUsageResult> confirmUsageCodes(List<ConfirmUsageCodePayload> codes);

  /// 🔄 Sync used count to server (contract-aligned)
  Future<void> syncUsedCount({
    required int reservationId,
    required int usedCount,
  });

  /// 📊 Get active reservation status from server
  Future<({int? reservationId, int? remainingCount})> getActiveReservationStatus();

  /// 📊 Get device code stats from /codes/device-stats
  Future<DeviceCodeStats?> getDeviceCodeStats();

  /// 📥 Request new codes from /codes/request-codes
  Future<List<int>> requestCodes(int count);
}

class FileIdRemoteDataSourceImpl implements FileIdRemoteDataSource {
  final Dio _dio;
  final SecureStorage _secureStorage;
  final Logger _logger = Logger();
  static const int _minRequestCodesCount = 1;
  static const int _maxRequestCodesCount = 5000;

  FileIdRemoteDataSourceImpl(this._dio, {SecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? SecureStorage();

  @override
  Future<CodesLoginSyncResult> loginSync({
    required String deviceId,
    required List<DeviceCodeStatusPayload> deviceCodes,
  }) async {
    final response = await _dio.post(
      _normalizeApiEndpoint(ApiConfig.codesLoginSyncEndpoint),
      data: {
        'device_id': deviceId,
        'device_codes': deviceCodes
            .map(
              (entry) => {
                'code': entry.code,
                'used': entry.used,
                if (entry.usedAt != null) 'used_at': entry.usedAt,
                if (entry.recordId != null && entry.recordId!.isNotEmpty) 'record_id': entry.recordId,
              },
            )
            .toList(growable: false),
      },
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    final body = response.data;
    if (response.statusCode != 200 || body is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }

    final dataNode = body['data'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final syncResult = dataNode['sync_result'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final newCodesRaw = dataNode['new_codes'];

    return CodesLoginSyncResult(
      confirmedUsed: _parseCodesAsInts(syncResult['confirmed_used']),
      alreadyConfirmed: _parseCodesAsInts(syncResult['already_confirmed']),
      invalidCodes: _parseCodesAsInts(syncResult['invalid_codes']),
      conflictCodes: _parseCodesAsInts(syncResult['conflict_codes']),
      newCodes: _parseCodesAsInts(newCodesRaw),
    );
  }

  @override
  Future<List<int>> reserveIds(int count) async {
    final fromCodes = await _tryReserveViaCodes(count);
    if (fromCodes != null && fromCodes.isNotEmpty) {
      return fromCodes;
    }

    try {
      final deviceId = await _secureStorage.getDeviceId();

      final response = await _dio.post(
        _normalizeApiEndpoint(ApiConfig.reserveFileIdsEndpoint),
        data: {
          'batch_size': count,
          'device_id': deviceId,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }

      final data = response.data as Map<String, dynamic>;
      final explicitIds = _extractExplicitIds(data);
      if (explicitIds.isNotEmpty) {
        return explicitIds;
      }

      final reservation = _extractReservationMap(data);
      if (reservation == null) return const <int>[];

      final startId = int.tryParse(reservation['start_id']?.toString() ?? '');
      final endId = int.tryParse(reservation['end_id']?.toString() ?? '');
      if (startId == null || endId == null || endId < startId) {
        return const <int>[];
      }

      return List<int>.generate(endId - startId + 1, (index) => startId + index);
    } on DioException catch (e) {
      _logger.e(
        'File ID reserve failed: status=${e.response?.statusCode}, response=${e.response?.data}',
      );
      rethrow;
    }
  }

  @override
  Future<FileIdReservationSnapshot?> reserveBatchSnapshot(int count) async {
    final codesSnapshot = await _tryReserveSnapshotViaCodes(count);
    if (codesSnapshot != null) {
      return codesSnapshot;
    }

    try {
      final deviceId = await _secureStorage.getDeviceId();

      final response = await _dio.post(
        _normalizeApiEndpoint(ApiConfig.reserveFileIdsEndpoint),
        data: {
          'batch_size': count,
          'device_id': deviceId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final reservation = _extractReservationMap(data);
        if (reservation != null) {
          final id = int.tryParse(reservation['id']?.toString() ?? '');
          final startId = int.tryParse(reservation['start_id']?.toString() ?? '');
          final endId = int.tryParse(reservation['end_id']?.toString() ?? '');
          final batchSize = int.tryParse(reservation['batch_size']?.toString() ?? '') ?? count;
          final usedCount = int.tryParse(reservation['used_count']?.toString() ?? '') ?? 0;
          final remainingCount = int.tryParse(reservation['remaining_count']?.toString() ?? '') ?? batchSize;
          final parsedNextAvailableId = int.tryParse(reservation['next_available_id']?.toString() ?? '');
          final status = (reservation['status']?.toString() ?? 'active').trim();
          final expiresAt = DateTime.tryParse(reservation['expires_at']?.toString() ?? '');
          final createdAt = DateTime.tryParse(reservation['created_at']?.toString() ?? '');

          if (id != null && startId != null && endId != null && endId >= startId) {
            return FileIdReservationSnapshot(
              reservationId: id,
              deviceId: deviceId,
              startId: startId,
              endId: endId,
              batchSize: batchSize,
              usedCount: usedCount,
              remainingCount: remainingCount,
              nextAvailableId: parsedNextAvailableId ?? startId,
              status: status.isEmpty ? 'active' : status,
              expiresAt: expiresAt,
              createdAt: createdAt,
            );
          }
        }

        return null;
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    } on DioException catch (e) {
      _logger.e(
        'File ID reserve failed: status=${e.response?.statusCode}, response=${e.response?.data}',
      );
      rethrow;
    }
  }

  @override
  Future<void> syncUsedIds(List<int> usedIds) async {
    try {
      if (usedIds.isEmpty) return;

      final syncedWithCodes = await _trySyncUsedViaCodes(usedIds);
      if (syncedWithCodes) return;

      final deviceId = await _secureStorage.getDeviceId();
      final reservationId = await _tryGetActiveReservationId(deviceId);
      if (reservationId == null) return;

      await syncUsedCount(
        reservationId: reservationId,
        usedCount: usedIds.length,
      );
    } on DioException catch (e) {
      _logger.e(
        'File ID sync-used failed: status=${e.response?.statusCode}, response=${e.response?.data}',
      );
      rethrow;
    }
  }

  @override
  Future<void> syncUsedCount({
    required int reservationId,
    required int usedCount,
  }) async {
    final deviceId = await _secureStorage.getDeviceId();
    await _dio.post(
      _normalizeApiEndpoint(ApiConfig.syncUsedFileIdsEndpoint),
      data: {
        'device_id': deviceId,
        'reservation_id': reservationId,
        'used_count': usedCount,
      },
    );
  }

  String _normalizeApiEndpoint(String endpoint) {
    return sync_endpoint.normalizeApiEndpoint(
      endpoint: endpoint,
      baseUrl: _dio.options.baseUrl,
    );
  }

  Future<int?> _tryGetActiveReservationId(String deviceId) async {
    try {
      final response = await _dio.get(
        _normalizeApiEndpoint(ApiConfig.fileIdReservationsEndpoint),
        queryParameters: {'device_id': deviceId},
      );

      if (response.statusCode != 200) return null;
      final data = response.data as Map<String, dynamic>?;
      if (data == null) return null;

      final activeReservation = _extractReservationMap(data);
      if (activeReservation is Map<String, dynamic>) {
        return int.tryParse(activeReservation['id']?.toString() ?? '');
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<({int? reservationId, int? remainingCount})> getActiveReservationStatus() async {
    final codesStats = await _tryGetStatusViaCodes();
    if (codesStats != null) {
      return codesStats;
    }

    final deviceId = await _secureStorage.getDeviceId();
    final response = await _dio.get(
      _normalizeApiEndpoint(ApiConfig.fileIdReservationsEndpoint),
      queryParameters: {'device_id': deviceId},
    );

    if (response.statusCode != 200) {
      return (reservationId: null, remainingCount: null);
    }

    final data = response.data as Map<String, dynamic>?;
    final activeReservation = data == null ? null : _extractReservationMap(data);
    if (activeReservation is! Map<String, dynamic>) {
      return (reservationId: null, remainingCount: null);
    }

    return (
      reservationId: int.tryParse(activeReservation['id']?.toString() ?? ''),
      remainingCount: int.tryParse(activeReservation['remaining_count']?.toString() ?? ''),
    );
  }

  @override
  Future<DeviceCodeStats?> getDeviceCodeStats() async {
    try {
      final deviceId = await _secureStorage.getDeviceId();
      final response = await _dio.get(
        _normalizeApiEndpoint(ApiConfig.codesDeviceStatsEndpoint),
        queryParameters: {'device_id': deviceId},
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode != 200 || response.data is! Map<String, dynamic>) {
        return null;
      }

      final body = response.data as Map<String, dynamic>;
      final data = body['data'];
      if (data is! Map<String, dynamic>) {
        return null;
      }

      return DeviceCodeStats(
        unusedCount: int.tryParse(data['unused_count']?.toString() ?? '') ?? 0,
        canRequestMore: data['can_request_more'] == true,
        availableSlots: int.tryParse(data['available_slots']?.toString() ?? ''),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<int>> requestCodes(int count) async {
    if (count < _minRequestCodesCount || count > _maxRequestCodesCount) {
      throw CodesApiException(
        errorCode: 'invalid_request_count',
        message: 'Count must be between $_minRequestCodesCount and $_maxRequestCodesCount',
      );
    }

    final deviceId = await _secureStorage.getDeviceId();
    final response = await _dio.post(
      _normalizeApiEndpoint(ApiConfig.codesRequestCodesEndpoint),
      data: {
        'device_id': deviceId,
        'count': count,
      },
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = response.data;
      if (body is! Map<String, dynamic>) {
        throw const CodesApiException(
          errorCode: 'invalid_response',
          message: 'Invalid request-codes response body',
        );
      }

      final data = body['data'];
      if (data is! Map<String, dynamic>) {
        throw const CodesApiException(
          errorCode: 'invalid_response',
          message: 'Missing request-codes data payload',
        );
      }

      final rawCodes = data['codes'];
      if (rawCodes is! List) {
        return const <int>[];
      }

      return rawCodes.map((e) => int.tryParse(e?.toString() ?? '')).whereType<int>().toList(growable: false);
    }

    final errorBody =
        response.data is Map<String, dynamic> ? response.data as Map<String, dynamic> : const <String, dynamic>{};
    final errorCode = (errorBody['error']?.toString() ?? 'request_codes_failed').trim();
    final message = (errorBody['message']?.toString() ?? 'Request codes failed').trim();

    throw CodesApiException(
      errorCode: errorCode.isEmpty ? 'request_codes_failed' : errorCode,
      message: message.isEmpty ? 'Request codes failed' : message,
      statusCode: response.statusCode,
    );
  }

  Future<List<int>?> _tryReserveViaCodes(int count) async {
    try {
      final deviceId = await _secureStorage.getDeviceId();
      final response = await _dio.post(
        _normalizeApiEndpoint(ApiConfig.codesRequestCodesEndpoint),
        data: {
          'device_id': deviceId,
          'count': count,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) return null;
      final body = response.data;
      if (body is! Map<String, dynamic>) return null;
      final data = body['data'];
      if (data is! Map<String, dynamic>) return null;
      final rawCodes = data['codes'];
      if (rawCodes is! List) return null;

      final parsed = rawCodes.map((e) => int.tryParse(e?.toString() ?? '')).whereType<int>().toList(growable: false);
      return parsed;
    } catch (_) {
      return null;
    }
  }

  Future<FileIdReservationSnapshot?> _tryReserveSnapshotViaCodes(int count) async {
    try {
      final ids = await _tryReserveViaCodes(count);
      if (ids == null || ids.isEmpty) return null;

      final sorted = [...ids]..sort();
      final start = sorted.first;
      final end = sorted.last;
      final now = DateTime.now();

      return FileIdReservationSnapshot(
        reservationId: now.microsecondsSinceEpoch,
        deviceId: await _secureStorage.getDeviceId(),
        startId: start,
        endId: end,
        batchSize: sorted.length,
        usedCount: 0,
        remainingCount: sorted.length,
        nextAvailableId: start,
        status: 'active',
        createdAt: now,
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> _trySyncUsedViaCodes(List<int> usedIds) async {
    try {
      final deviceId = await _secureStorage.getDeviceId();
      final payloadCodes = usedIds
          .map(
            (id) => {
              'code': _formatCode(id),
              'used_at': DateTime.now().toUtc().toIso8601String(),
            },
          )
          .toList(growable: false);

      final response = await _dio.post(
        _normalizeApiEndpoint(ApiConfig.codesConfirmUsageEndpoint),
        data: {
          'device_id': deviceId,
          'codes': payloadCodes,
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<CodesConfirmUsageResult> confirmUsageCodes(List<ConfirmUsageCodePayload> codes) async {
    final deviceId = await _secureStorage.getDeviceId();

    final response = await _dio.post(
      _normalizeApiEndpoint(ApiConfig.codesConfirmUsageEndpoint),
      data: {
        'device_id': deviceId,
        'codes': codes
            .map(
              (entry) => {
                'code': entry.code,
                if (entry.usedAt != null && entry.usedAt!.trim().isNotEmpty) 'used_at': entry.usedAt,
                if (entry.recordType != null && entry.recordType!.trim().isNotEmpty) 'record_type': entry.recordType,
                if (entry.recordId != null) 'record_id': entry.recordId,
              },
            )
            .toList(growable: false),
      },
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode != 200 || response.data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }

    final body = response.data as Map<String, dynamic>;
    final dataNode = body['data'] as Map<String, dynamic>? ?? const <String, dynamic>{};

    return CodesConfirmUsageResult(
      confirmed: _parseCodesAsInts(dataNode['confirmed']),
      alreadyUsed: _parseCodesAsInts(dataNode['already_used']),
      notFound: _parseCodesAsInts(dataNode['not_found']),
      conflicts: _parseCodesAsInts(dataNode['conflicts']),
    );
  }

  Future<({int? reservationId, int? remainingCount})?> _tryGetStatusViaCodes() async {
    try {
      final deviceId = await _secureStorage.getDeviceId();
      final response = await _dio.get(
        _normalizeApiEndpoint(ApiConfig.codesDeviceStatsEndpoint),
        queryParameters: {'device_id': deviceId},
      );

      if (response.statusCode != 200) return null;
      final body = response.data;
      if (body is! Map<String, dynamic>) return null;
      final data = body['data'];
      if (data is! Map<String, dynamic>) return null;

      final remaining = int.tryParse(data['unused_count']?.toString() ?? '');
      return (reservationId: null, remainingCount: remaining);
    } catch (_) {
      return null;
    }
  }

  String _formatCode(int id) {
    final normalized = id < 0 ? 0 : id;
    return normalized.toString().padLeft(6, '0');
  }

  Map<String, dynamic>? _extractReservationMap(Map<String, dynamic> root) {
    final dataNode = root['data'];
    if (dataNode is Map<String, dynamic>) {
      final reservation = dataNode['reservation'];
      if (reservation is Map<String, dynamic>) {
        return reservation;
      }

      final activeReservation = dataNode['active_reservation'];
      if (activeReservation is Map<String, dynamic>) {
        return activeReservation;
      }
    }

    final topReservation = root['reservation'];
    if (topReservation is Map<String, dynamic>) {
      return topReservation;
    }

    final topActive = root['active_reservation'];
    if (topActive is Map<String, dynamic>) {
      return topActive;
    }

    final topReservationData = root['reservation_data'];
    if (topReservationData is Map<String, dynamic>) {
      return topReservationData;
    }

    return null;
  }

  List<int> _extractExplicitIds(Map<String, dynamic> root) {
    final topIds = _parseIntList(root['ids']);
    if (topIds.isNotEmpty) return topIds;

    final dataNode = root['data'];
    if (dataNode is Map<String, dynamic>) {
      final dataIds = _parseIntList(dataNode['ids']);
      if (dataIds.isNotEmpty) return dataIds;

      final records = _parseIntList(dataNode['records']);
      if (records.isNotEmpty) return records;
    }

    return const <int>[];
  }

  List<int> _parseIntList(dynamic value) {
    if (value is! List) return const <int>[];
    return value.map((e) => int.tryParse(e?.toString() ?? '')).whereType<int>().toList(growable: false);
  }

  List<int> _parseCodesAsInts(dynamic value) {
    if (value is! List) return const <int>[];

    return value
        .map((entry) {
          if (entry is Map<String, dynamic>) {
            return int.tryParse(entry['code']?.toString() ?? '');
          }
          return int.tryParse(entry?.toString() ?? '');
        })
        .whereType<int>()
        .toList(growable: false);
  }
}

class DeviceCodeStatusPayload {
  final String code;
  final bool used;
  final String? usedAt;
  final String? recordId;

  const DeviceCodeStatusPayload({
    required this.code,
    required this.used,
    this.usedAt,
    this.recordId,
  });
}

class CodesLoginSyncResult {
  final List<int> confirmedUsed;
  final List<int> alreadyConfirmed;
  final List<int> invalidCodes;
  final List<int> conflictCodes;
  final List<int> newCodes;

  const CodesLoginSyncResult({
    this.confirmedUsed = const <int>[],
    this.alreadyConfirmed = const <int>[],
    this.invalidCodes = const <int>[],
    this.conflictCodes = const <int>[],
    this.newCodes = const <int>[],
  });
}

class ConfirmUsageCodePayload {
  final String code;
  final String? usedAt;
  final String? recordType;
  final int? recordId;

  const ConfirmUsageCodePayload({
    required this.code,
    this.usedAt,
    this.recordType,
    this.recordId,
  });
}

class CodesConfirmUsageResult {
  final List<int> confirmed;
  final List<int> alreadyUsed;
  final List<int> notFound;
  final List<int> conflicts;

  const CodesConfirmUsageResult({
    this.confirmed = const <int>[],
    this.alreadyUsed = const <int>[],
    this.notFound = const <int>[],
    this.conflicts = const <int>[],
  });
}

class FileIdReservationSnapshot {
  final int reservationId;
  final String deviceId;
  final int startId;
  final int endId;
  final int batchSize;
  final int usedCount;
  final int remainingCount;
  final int nextAvailableId;
  final String status;
  final DateTime? expiresAt;
  final DateTime? createdAt;

  const FileIdReservationSnapshot({
    required this.reservationId,
    required this.deviceId,
    required this.startId,
    required this.endId,
    required this.batchSize,
    required this.usedCount,
    required this.remainingCount,
    required this.nextAvailableId,
    required this.status,
    this.expiresAt,
    this.createdAt,
  });
}

class DeviceCodeStats {
  final int unusedCount;
  final bool canRequestMore;
  final int? availableSlots;

  const DeviceCodeStats({
    required this.unusedCount,
    required this.canRequestMore,
    this.availableSlots,
  });
}

class CodesApiException implements Exception {
  final String errorCode;
  final String message;
  final int? statusCode;

  const CodesApiException({
    required this.errorCode,
    required this.message,
    this.statusCode,
  });

  @override
  String toString() {
    final statusPart = statusCode == null ? '' : ' (status: $statusCode)';
    return 'CodesApiException[$errorCode]$statusPart: $message';
  }
}
