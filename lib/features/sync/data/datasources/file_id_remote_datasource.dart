import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';

/// 🌐 File ID Remote Data Source
///
/// Handles API requests for File ID reservation and usage sync.
abstract class FileIdRemoteDataSource {
  /// 📥 Reserve IDs from server
  Future<List<int>> reserveIds(int count);

  /// 🔄 Sync used IDs to server
  Future<void> syncUsedIds(List<int> usedIds);
}

class FileIdRemoteDataSourceImpl implements FileIdRemoteDataSource {
  final Dio _dio;

  FileIdRemoteDataSourceImpl(this._dio);

  @override
  Future<List<int>> reserveIds(int count) async {
    try {
      final response = await _dio.post(
        ApiConfig.reserveFileIdsEndpoint,
        data: {'count': count},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final ids = List<int>.from(data['ids'] ?? []);
        return ids;
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    } on DioException catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> syncUsedIds(List<int> usedIds) async {
    try {
      await _dio.post(
        ApiConfig.syncUsedFileIdsEndpoint,
        data: {'ids': usedIds},
      );
    } on DioException catch (e) {
      rethrow;
    }
  }
}
