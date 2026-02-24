import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../data/db/daos/sync_dao.dart';

class TombstoneDeleteSyncOutcome {
  final int deletedCount;
  final int failedCount;

  const TombstoneDeleteSyncOutcome({
    required this.deletedCount,
    required this.failedCount,
  });
}

class TombstoneDeleteSyncUseCase {
  final SyncDao _syncDao;
  final Dio _dio;
  final String Function(String endpoint) _normalizeApiEndpoint;

  const TombstoneDeleteSyncUseCase({
    required SyncDao syncDao,
    required Dio dio,
    required String Function(String endpoint) normalizeApiEndpoint,
  })  : _syncDao = syncDao,
        _dio = dio,
        _normalizeApiEndpoint = normalizeApiEndpoint;

  Future<TombstoneDeleteSyncOutcome> execute({int limit = 300}) async {
    int deleted = 0;
    int failed = 0;

    final rows = await _syncDao.getPendingTombstones(limit: limit);
    if (rows.isEmpty) {
      return const TombstoneDeleteSyncOutcome(deletedCount: 0, failedCount: 0);
    }

    for (final row in rows) {
      final tombstoneId = _asInt(row['id']);
      final entityType = (row['entity_type']?.toString() ?? '').trim();
      final entityId = (row['entity_id']?.toString() ?? '').trim();
      final payload = _parsePayload(row['payload']);

      if (tombstoneId == null || entityType.isEmpty || entityId.isEmpty) {
        failed++;
        continue;
      }

      try {
        await _dispatchDelete(
          entityType: entityType,
          entityId: entityId,
          payload: payload,
        );
        await _syncDao.markTombstoneSynced(tombstoneId);
        deleted++;
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          await _syncDao.markTombstoneSynced(tombstoneId);
          deleted++;
          continue;
        }

        await _syncDao.markTombstoneFailed(tombstoneId, e.toString());
        failed++;
      } catch (e) {
        await _syncDao.markTombstoneFailed(tombstoneId, e.toString());
        failed++;
      }
    }

    return TombstoneDeleteSyncOutcome(
      deletedCount: deleted,
      failedCount: failed,
    );
  }

  Future<void> _dispatchDelete({
    required String entityType,
    required String entityId,
    required Map<String, dynamic>? payload,
  }) async {
    final normalized = entityType.toLowerCase();

    if (normalized == 'data') {
      final fileId = _resolveDataDeleteId(entityId, payload);
      if (fileId == null || fileId.isEmpty) {
        throw StateError('Missing file_id_number for data tombstone');
      }
      await _dio.delete(_normalizeApiEndpoint('/api/mobile/database/data/$fileId'));
      return;
    }

    if (normalized == 're-people') {
      final memberId = _resolveServerEntityId(entityId, payload);
      if (memberId == null || memberId.isEmpty) {
        throw StateError('Missing server id for re-people tombstone');
      }
      await _dio.delete(_normalizeApiEndpoint('/api/mobile/database/re-people/$memberId'));
      return;
    }

    if (normalized == 'attachments') {
      final attachmentId = _resolveAttachmentDeleteId(entityId, payload);
      if (attachmentId == null || attachmentId.isEmpty) {
        throw StateError('Missing attachment id for tombstone');
      }
      await _dio.delete(_normalizeApiEndpoint('/api/mobile/database/attachments/$attachmentId'));
      return;
    }

    if (normalized == 'dead-people') {
      throw StateError('Delete endpoint not documented for dead-people yet');
    }

    if (normalized == 'associations_sponsors' || normalized == 'sponsors') {
      final sponsorId = _resolveServerEntityId(entityId, payload);
      if (sponsorId == null || sponsorId.isEmpty) {
        throw StateError('Missing sponsor server id for tombstone');
      }
      await _dio.delete(_normalizeApiEndpoint('/api/mobile/associations/sponsors/$sponsorId'));
      return;
    }

    if (normalized == 'associations_employees' || normalized == 'employees') {
      final employeeId = _resolveServerEntityId(entityId, payload);
      if (employeeId == null || employeeId.isEmpty) {
        throw StateError('Missing employee server id for tombstone');
      }
      await _dio.delete(_normalizeApiEndpoint('/api/mobile/associations/employees/$employeeId'));
      return;
    }

    throw StateError('Unsupported tombstone entity type: $entityType');
  }

  String? _resolveDataDeleteId(String entityId, Map<String, dynamic>? payload) {
    final payloadFileId = payload?['file_id_number']?.toString().trim();
    if (payloadFileId != null && payloadFileId.isNotEmpty) return payloadFileId;

    if (int.tryParse(entityId) != null) return entityId;

    final payloadServerId = payload?['server_id']?.toString().trim();
    if (payloadServerId != null && payloadServerId.isNotEmpty) return payloadServerId;

    return null;
  }

  String? _resolveServerEntityId(String entityId, Map<String, dynamic>? payload) {
    final payloadServerId = payload?['server_id']?.toString().trim();
    if (payloadServerId != null && payloadServerId.isNotEmpty) return payloadServerId;
    if (int.tryParse(entityId) != null) return entityId;
    return null;
  }

  String? _resolveAttachmentDeleteId(String entityId, Map<String, dynamic>? payload) {
    final payloadServerId = payload?['server_id']?.toString().trim();
    if (payloadServerId != null && payloadServerId.isNotEmpty) return payloadServerId;

    final payloadAttachmentId = payload?['attachment_id']?.toString().trim();
    if (payloadAttachmentId != null && payloadAttachmentId.isNotEmpty) return payloadAttachmentId;

    final serverUrl = payload?['server_url']?.toString().trim();
    if (serverUrl != null && serverUrl.isNotEmpty) {
      final uri = Uri.tryParse(serverUrl);
      final segments = uri?.pathSegments ?? const <String>[];
      final index = segments.indexOf('attachments');
      if (index >= 0 && index + 1 < segments.length) {
        final candidate = segments[index + 1].trim();
        if (candidate.isNotEmpty) return candidate;
      }
    }

    return entityId.isEmpty ? null : entityId;
  }

  Map<String, dynamic>? _parsePayload(dynamic rawPayload) {
    if (rawPayload == null) return null;
    if (rawPayload is Map<String, dynamic>) return rawPayload;
    final encoded = rawPayload.toString().trim();
    if (encoded.isEmpty) return null;

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}

    return null;
  }

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
