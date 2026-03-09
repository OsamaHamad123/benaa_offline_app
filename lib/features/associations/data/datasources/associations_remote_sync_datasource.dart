import 'package:dio/dio.dart';

import '../../../../core/config/api_config.dart';
import '../models/associations_sync_dto.dart';

class AssociationsRemoteSyncDataSource {
  static const int _maxRateLimitRetries = 3;
  static const int _baseBackoffSeconds = 2;

  final Dio _dio;

  const AssociationsRemoteSyncDataSource(this._dio);

  Future<SponsorsListResponseDto> fetchSponsors({
    DateTime? updatedAfter,
    List<int>? ids,
    int page = 1,
    int perPage = 100,
  }) async {
    final response = await _getWithRateLimitRetry(
      ApiConfig.associationsSponsorsEndpoint,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (updatedAfter != null) 'updated_after': updatedAfter.toIso8601String(),
        if (ids != null && ids.isNotEmpty) 'ids': ids.join(','),
      },
    );

    final body = _asMap(response.data);
    if (body == null) {
      throw Exception('Invalid sponsors response payload');
    }

    return SponsorsListResponseDto.fromJson(body, page: page, perPage: perPage);
  }

  Future<EmployeesListResponseDto> fetchEmployees({
    int? sponsorId,
    List<int>? ids,
    DateTime? updatedAfter,
    int page = 1,
    int perPage = 100,
  }) async {
    final response = await _getWithRateLimitRetry(
      ApiConfig.associationsEmployeesEndpoint,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (sponsorId != null) 'sponsor_id': sponsorId,
        if (ids != null && ids.isNotEmpty) 'ids': ids.join(','),
        if (updatedAfter != null) 'updated_after': updatedAfter.toIso8601String(),
      },
    );

    final body = _asMap(response.data);
    if (body == null) {
      throw Exception('Invalid employees response payload');
    }

    return EmployeesListResponseDto.fromJson(body, page: page, perPage: perPage);
  }

  Future<void> createSponsor(SponsorDto sponsor) async {
    await _dio.post(
      ApiConfig.associationsSponsorsEndpoint,
      data: sponsor.toCreatePayload(),
    );
  }

  Future<void> updateSponsor({
    required int sponsorId,
    required SponsorDto sponsor,
  }) async {
    await _dio.put(
      '${ApiConfig.associationsSponsorsEndpoint}/$sponsorId',
      data: sponsor.toUpdatePayload(),
    );
  }

  Future<void> deleteSponsor(int sponsorId) async {
    await _dio.delete('${ApiConfig.associationsSponsorsEndpoint}/$sponsorId');
  }

  Future<void> createEmployee(AssociationEmployeeDto employee) async {
    await _dio.post(
      ApiConfig.associationsEmployeesEndpoint,
      data: employee.toCreatePayload(),
    );
  }

  Future<void> updateEmployee({
    required int employeeId,
    required AssociationEmployeeDto employee,
  }) async {
    await _dio.put(
      '${ApiConfig.associationsEmployeesEndpoint}/$employeeId',
      data: employee.toUpdatePayload(),
    );
  }

  Future<void> deleteEmployee(int employeeId) async {
    await _dio.delete('${ApiConfig.associationsEmployeesEndpoint}/$employeeId');
  }

  Future<void> batchUpsertEmployees(List<AssociationEmployeeDto> employees) async {
    await _dio.post(
      ApiConfig.associationsEmployeesBatchEndpoint,
      data: {
        'records': employees.map((e) => e.toBatchPayload()).toList(growable: false),
      },
    );
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }

  Future<Response<dynamic>> _getWithRateLimitRetry(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    int retries = 0;
    while (true) {
      try {
        return await _dio.get(path, queryParameters: queryParameters);
      } on DioException catch (e) {
        final statusCode = e.response?.statusCode;
        final isRateLimited = statusCode == 429;
        if (!isRateLimited || retries >= _maxRateLimitRetries) {
          rethrow;
        }

        retries++;
        final retryAfterHeader = e.response?.headers.value('retry-after');
        final retryAfterSeconds = int.tryParse((retryAfterHeader ?? '').trim());
        final backoffSeconds =
            retryAfterSeconds != null && retryAfterSeconds > 0 ? retryAfterSeconds : (_baseBackoffSeconds * retries);

        await Future.delayed(Duration(seconds: backoffSeconds));
      }
    }
  }
}
