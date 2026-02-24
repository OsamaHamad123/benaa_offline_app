import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/utils/api_endpoint_normalizer.dart' as sync_endpoint;

/// 🌐 File ID Remote Data Source
///
/// Handles API requests for File ID reservation and usage sync.
abstract class FileIdRemoteDataSource {
  /// 📥 Reserve IDs from server
  Future<List<int>> reserveIds(int count);

  /// 📥 Reserve batch snapshot from server
  Future<FileIdReservationSnapshot?> reserveBatchSnapshot(int count);

  /// 🔄 Sync used IDs to server
  Future<void> syncUsedIds(List<int> usedIds);

  /// 🔄 Sync used count to server (contract-aligned)
  Future<void> syncUsedCount({
    required int reservationId,
    required int usedCount,
  });

  /// 📊 Get active reservation status from server
  Future<({int? reservationId, int? remainingCount})> getActiveReservationStatus();
}

class FileIdRemoteDataSourceImpl implements FileIdRemoteDataSource {
  final Dio _dio;
  final SecureStorage _secureStorage;
  final Logger _logger = Logger();

  FileIdRemoteDataSourceImpl(this._dio, {SecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? SecureStorage();

  @override
  Future<List<int>> reserveIds(int count) async {
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
