import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/storage/secure_storage.dart';

/// 🌐 File ID Remote Data Source
///
/// Handles API requests for File ID reservation and usage sync.
abstract class FileIdRemoteDataSource {
  /// 📥 Reserve IDs from server
  Future<List<int>> reserveIds(int count);

  /// 🔄 Sync used IDs to server
  Future<void> syncUsedIds(List<int> usedIds);

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
          'count': count,
          'quantity': count,
          'requested_count': count,
          'device_id': deviceId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final rawIds = data['ids'] ?? data['data']?['ids'] ?? data['reserved_ids'] ?? data['data'];
        final ids = rawIds is List ? rawIds.map((e) => int.tryParse(e.toString())).whereType<int>().toList() : <int>[];

        if (ids.isNotEmpty) {
          return ids;
        }

        final activeReservation = data['data']?['active_reservation'] ?? data['active_reservation'];
        if (activeReservation is Map<String, dynamic>) {
          final startId = int.tryParse(activeReservation['start_id']?.toString() ?? '');
          final endId = int.tryParse(activeReservation['end_id']?.toString() ?? '');
          if (startId != null && endId != null && endId >= startId) {
            return List<int>.generate(endId - startId + 1, (index) => startId + index);
          }
        }

        return ids;
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

      await _dio.post(
        _normalizeApiEndpoint(ApiConfig.syncUsedFileIdsEndpoint),
        data: {
          if (reservationId != null) 'reservation_id': reservationId,
          'used_count': usedIds.length,
          'ids': usedIds,
          'used_ids': usedIds,
          'device_id': deviceId,
        },
      );
    } on DioException catch (e) {
      _logger.e(
        'File ID sync-used failed: status=${e.response?.statusCode}, response=${e.response?.data}',
      );
      rethrow;
    }
  }

  String _normalizeApiEndpoint(String endpoint) {
    final normalized = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final basePath = Uri.tryParse(_dio.options.baseUrl)?.path ?? '';

    if (basePath.endsWith('/api') && normalized.startsWith('/api/')) {
      return normalized.substring(4);
    }

    return normalized;
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

      final activeReservation = data['data']?['active_reservation'] ?? data['active_reservation'];
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
    final activeReservation = data?['data']?['active_reservation'] ?? data?['active_reservation'];
    if (activeReservation is! Map<String, dynamic>) {
      return (reservationId: null, remainingCount: null);
    }

    return (
      reservationId: int.tryParse(activeReservation['id']?.toString() ?? ''),
      remainingCount: int.tryParse(activeReservation['remaining_count']?.toString() ?? ''),
    );
  }
}
