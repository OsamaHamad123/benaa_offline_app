import 'package:dio/dio.dart';

import '../../../../core/config/api_config.dart';
import '../models/sponsorships_sync_dto.dart';

class SponsorshipsRemoteSyncDataSource {
  final Dio _dio;

  const SponsorshipsRemoteSyncDataSource(this._dio);

  Future<SponsorshipsListResponseDto> fetchSponsorships({
    DateTime? updatedAfter,
    int page = 1,
    int perPage = 100,
  }) async {
    final response = await _dio.get(
      ApiConfig.sponsorshipsEndpoint,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (updatedAfter != null) 'updated_after': updatedAfter.toIso8601String(),
      },
    );

    final body = _asMap(response.data);
    if (body == null) {
      throw Exception('Invalid sponsorships response payload');
    }

    return SponsorshipsListResponseDto.fromJson(body, page: page, perPage: perPage);
  }

  Future<Map<String, dynamic>?> createSponsorship(
    SponsorshipDto dto, {
    required int sponsorId,
    required String identityNumber,
    required String orphanName,
  }) async {
    final response = await _dio.post(
      ApiConfig.sponsorshipsEndpoint,
      data: dto.toCreatePayload(
        sponsorId: sponsorId,
        identityNumber: identityNumber,
        orphanName: orphanName,
      ),
    );

    return _asMap(response.data);
  }

  Future<Map<String, dynamic>?> getSponsorshipById(int sponsorshipId) async {
    final response = await _dio.get('${ApiConfig.sponsorshipsEndpoint}/$sponsorshipId');
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>?> getSponsorshipsByIdentity(String identityNumber) async {
    final response = await _dio.get('${ApiConfig.sponsorshipsEndpoint}/by-identity/$identityNumber');
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>?> fetchSponsorshipStats() async {
    final response = await _dio.get(ApiConfig.sponsorshipsStatsEndpoint);
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>?> updateSponsorship({
    required int sponsorshipId,
    required SponsorshipDto dto,
    required int sponsorId,
    required String identityNumber,
    required String orphanName,
  }) async {
    final response = await _dio.put(
      '${ApiConfig.sponsorshipsEndpoint}/$sponsorshipId',
      data: dto.toUpdatePayload(
        sponsorId: sponsorId,
        identityNumber: identityNumber,
        orphanName: orphanName,
      ),
    );

    return _asMap(response.data);
  }

  Future<void> deleteSponsorship(int sponsorshipId) async {
    await _dio.delete('${ApiConfig.sponsorshipsEndpoint}/$sponsorshipId');
  }

  Future<Map<String, dynamic>?> batchUpsertSponsorships(List<Map<String, dynamic>> records) async {
    final response = await _dio.post(
      ApiConfig.sponsorshipsBatchEndpoint,
      data: {
        'records': records,
      },
    );
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>?> attachSponsors({
    required int sponsorshipId,
    required List<int> sponsorIds,
  }) async {
    final response = await _dio.post(
      '${ApiConfig.sponsorshipsEndpoint}/$sponsorshipId/sponsors',
      data: {
        'sponsor_ids': sponsorIds,
      },
    );
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>?> detachSponsors({
    required int sponsorshipId,
    required List<int> sponsorIds,
  }) async {
    final response = await _dio.delete(
      '${ApiConfig.sponsorshipsEndpoint}/$sponsorshipId/sponsors',
      data: {
        'sponsor_ids': sponsorIds,
      },
    );
    return _asMap(response.data);
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }
}
