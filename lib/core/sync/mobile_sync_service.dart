import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as drift;
import 'package:logger/logger.dart';

import 'package:benaa_offline_app/core/config/api_config.dart';
import '../../data/db/drift_database.dart';
import '../mappers/beneficiary_sync_mapper.dart' as mapper;
import '../mappers/visit_sync_mapper.dart' as visit_mapper;
import '../storage/secure_storage.dart';
import '../../features/sync/services/file_id_service.dart';
import '../../features/taxonomies/domain/repositories/taxonomy_repository.dart';

/// ========================================================================
/// 📱 Mobile Sync Service - للمزامنة مع Mobile Sync API
/// ========================================================================
/// هذا Service للمزامنة المؤقتة مع API الموبايل الموجود
/// الـ API بدون authentication ولا file upload لكن يسمح بمزامنة البيانات النصية
///
/// Base URL: https://palestine.benaadev.org
/// Database: u983550065_sy_test
///
/// ⚠️ LIMITATIONS:
/// - لا يوجد authentication (مؤقت)
/// - لا يوجد file upload (المرفقات ما بتنزامن)
/// - لا يوجد conflict resolution (server-wins)
/// - لا يوجد soft delete tracking
/// ========================================================================

class MobileSyncService {
  final AppDatabase _db;
  final Dio _dio;
  final SecureStorage _storage;
  final FileIdService? _fileIdService;
  final TaxonomyRepository? _taxonomyRepository;
  final Logger _logger = Logger();

  // Sync state
  final _statusController = StreamController<MobileSyncStatus>.broadcast();
  MobileSyncStatus _currentStatus = MobileSyncStatus();
  static const int _uiYieldInterval = 20;

  MobileSyncService(
    this._db,
    this._storage, {
    Dio? dio,
    FileIdService? fileIdService,
    TaxonomyRepository? taxonomyRepository,
  })  : _fileIdService = fileIdService,
        _taxonomyRepository = taxonomyRepository,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.defaultBaseUrl,
                connectTimeout: ApiConfig.connectTimeout,
                receiveTimeout: ApiConfig.receiveTimeout,
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            );

  Stream<MobileSyncStatus> get statusStream => _statusController.stream;
  MobileSyncStatus get currentStatus => _currentStatus;

  void _updateStatus(MobileSyncStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  Future<void> _yieldToUiIfNeeded(int processedCount) async {
    if (processedCount % _uiYieldInterval == 0) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  // ========================================================================
  // 🔽 SYNC DOWN - تنزيل البيانات من السيرفر
  // ========================================================================

  /// مزامنة كاملة - تنزيل كل البيانات من السيرفر
  Future<MobileSyncResult> syncDown() async {
    _updateStatus(
      _currentStatus.copyWith(
        isSyncing: true,
        currentOperation: 'جاري تنزيل البيانات من السيرفر...',
        progress: 0.0,
      ),
    );

    try {
      // 1. Sync Taxonomies (Lookups)
      if (_taxonomyRepository != null) {
        _logger.i('Syncing taxonomies...');
        _updateStatus(
          _currentStatus.copyWith(
            currentOperation: 'جاري تحديث القوائم والتصنيفات...',
            progress: 0.1,
          ),
        );
        try {
          await _taxonomyRepository.syncFromServer();
        } catch (e) {
          _logger.w('Taxonomy sync failed (non-critical): $e');
        }
      }

      // 2. Check File IDs
      if (_fileIdService != null) {
        _logger.i('Checking file ID reservation...');
        _updateStatus(
          _currentStatus.copyWith(
            currentOperation: 'جاري التحقق من مخزون الأرقام...',
            progress: 0.2,
          ),
        );
        try {
          await _fileIdService.ensureReservation();
        } catch (e) {
          _logger.w('File ID reservation failed (non-critical): $e');
        }
      }

      // Sync beneficiaries directly
      _updateStatus(
        _currentStatus.copyWith(
          currentOperation: 'جاري تنزيل بيانات المستفيدين...',
          progress: 0.3,
        ),
      );

      final result = await _syncBeneficiariesDown();
      _logger.i('Synced ${result.recordsSynced} beneficiaries');

      _updateStatus(
        _currentStatus.copyWith(
          currentOperation: 'تم تنزيل ${result.recordsSynced} مستفيد',
          progress: 1.0,
          isSyncing: false,
          lastSyncAt: DateTime.now(),
        ),
      );

      return result;
    } catch (e, stack) {
      _logger.e('Sync down failed', error: e, stackTrace: stack);

      _updateStatus(
        _currentStatus.copyWith(isSyncing: false, lastError: e.toString()),
      );

      return MobileSyncResult(
        success: false,
        recordsSynced: 0,
        error: e.toString(),
        errorCategory: _classifyError(e),
        errorContext: _extractErrorContext(e),
      );
    }
  }

  /// مزامنة المستفيدين - تنزيل
  Future<MobileSyncResult> _syncBeneficiariesDown() async {
    int totalSynced = 0;
    int page = 1;
    const pageSize = 100; // Use pagination
    int payloadBeneficiaries = 0;
    int payloadAttachments = 0;
    int payloadFamilyMembers = 0;
    int payloadDeadPeople = 0;
    final writeCounter = _EntityWriteCounter();
    final identityIndex = _BeneficiaryIdentityIndex();

    try {
      while (true) {
        final pageResult = await _fetchBeneficiariesPage(page, pageSize);
        final records = pageResult.records;
        final hasMore = pageResult.hasMore;

        payloadBeneficiaries += records.length;
        payloadAttachments += pageResult.attachments.length;
        payloadFamilyMembers += pageResult.familyMembers.length;
        payloadDeadPeople += pageResult.familyDeceased.length;

        _logger.i('Received ${records.length} records on page $page');
        _logger.i(
          'Page $page payload counters => beneficiaries: ${records.length}, attachments: ${pageResult.attachments.length}, family_members: ${pageResult.familyMembers.length}, dead_people: ${pageResult.familyDeceased.length}',
        );

        if (records.isEmpty) break;

        await _db.transaction(() async {
          for (var index = 0; index < records.length; index++) {
            final record = records[index];
            try {
              final upsertResult = await _upsertBeneficiaryRecord(record as Map<String, dynamic>);
              writeCounter.record('beneficiaries', upsertResult.outcome);

              _registerBeneficiaryIdentity(
                record,
                localBeneficiaryId: upsertResult.localBeneficiaryId,
                serverBeneficiaryId: upsertResult.serverBeneficiaryId,
                index: identityIndex,
              );

              await _syncRelatedEntitiesForBeneficiary(
                record,
                upsertResult.localBeneficiaryId,
                upsertResult.serverBeneficiaryId,
                writeCounter,
              );

              totalSynced++;
            } catch (e) {
              writeCounter.record('beneficiaries', _WriteOutcome.skipped);
              _logger.w('Failed to sync record ${record['id']}: $e');
            }

            await _yieldToUiIfNeeded(index + 1);
          }

          await _syncRelatedEntitiesFromPage(pageResult, writeCounter, identityIndex: identityIndex);
        });

        _logger.i('Page $page: ${records.length} records');

        if (!hasMore) {
          break;
        }

        page++;
      }

      final dedicatedRelated = await _syncRelatedEntitiesFromDedicatedEndpoints(
        pageSize: pageSize,
        writeCounter: writeCounter,
        identityIndex: identityIndex,
      );
      payloadAttachments += dedicatedRelated.attachments;
      payloadFamilyMembers += dedicatedRelated.familyMembers;
      payloadDeadPeople += dedicatedRelated.familyDeceased;

      return MobileSyncResult(
        success: true,
        recordsSynced: totalSynced,
        payloadCounters: {
          'beneficiaries': payloadBeneficiaries,
          'attachments': payloadAttachments,
          'family_members': payloadFamilyMembers,
          'dead_people': payloadDeadPeople,
        },
        writeCounters: writeCounter.toFlatMap(),
      );
    } catch (e, stack) {
      _logger.e('Beneficiaries sync down failed', error: e, stackTrace: stack);
      return MobileSyncResult(
        success: false,
        recordsSynced: totalSynced,
        error: e.toString(),
        payloadCounters: {
          'beneficiaries': payloadBeneficiaries,
          'attachments': payloadAttachments,
          'family_members': payloadFamilyMembers,
          'dead_people': payloadDeadPeople,
        },
        writeCounters: writeCounter.toFlatMap(),
        errorCategory: _classifyError(e),
        errorContext: _extractErrorContext(e),
      );
    }
  }

  Future<({int attachments, int familyMembers, int familyDeceased})> _syncRelatedEntitiesFromDedicatedEndpoints({
    required int pageSize,
    required _EntityWriteCounter writeCounter,
    required _BeneficiaryIdentityIndex identityIndex,
  }) async {
    int attachmentsSynced = 0;
    int familyMembersSynced = 0;
    int familyDeceasedSynced = 0;

    _updateStatus(
      _currentStatus.copyWith(
        currentOperation: 'جاري تنزيل المرفقات من المسار الرسمي... ',
        progress: 0.75,
      ),
    );

    await _syncEndpointRows(
      entityKey: 'attachments',
      endpoint: _normalizeApiEndpoint('/api/mobile/database/attachments'),
      listKeys: const ['attachments', 'records', 'items', 'data'],
      pageSize: pageSize,
      onRow: (row, index) async {
        final localBeneficiaryId = await _resolveLocalBeneficiaryIdFromPayload(row, index: identityIndex);
        if (localBeneficiaryId == null) return _WriteOutcome.skipped;
        return _upsertAttachment(
          row,
          localBeneficiaryId: localBeneficiaryId,
          serverBeneficiaryId: _resolveServerBeneficiaryId(row),
          sequence: index,
        );
      },
      onCounted: (count) => attachmentsSynced += count,
      writeCounter: writeCounter,
    );

    _updateStatus(
      _currentStatus.copyWith(
        currentOperation: 'جاري تنزيل أفراد العائلة من المسار الرسمي... ',
        progress: 0.82,
      ),
    );

    await _syncEndpointRows(
      entityKey: 'family_members',
      endpoint: _normalizeApiEndpoint('/api/mobile/database/re-people'),
      listKeys: const ['re_people', 'family_members', 'members', 'orphans', 'records', 'items', 'data'],
      pageSize: pageSize,
      onRow: (row, _) async {
        final localBeneficiaryId = await _resolveLocalBeneficiaryIdFromPayload(row, index: identityIndex);
        if (localBeneficiaryId == null) return _WriteOutcome.skipped;
        return _upsertFamilyMember(
          row,
          localBeneficiaryId: localBeneficiaryId,
        );
      },
      onCounted: (count) => familyMembersSynced += count,
      writeCounter: writeCounter,
    );

    _updateStatus(
      _currentStatus.copyWith(
        currentOperation: 'جاري تنزيل بيانات المتوفين من المسار الرسمي... ',
        progress: 0.9,
      ),
    );

    await _syncEndpointRows(
      entityKey: 'dead_people',
      endpoint: _normalizeApiEndpoint('/api/mobile/database/dead-people'),
      listKeys: const ['dead_people', 'family_deceased', 'deceased', 'records', 'items', 'data'],
      pageSize: pageSize,
      onRow: (row, _) async {
        final localBeneficiaryId = await _resolveLocalBeneficiaryIdFromPayload(row, index: identityIndex);
        if (localBeneficiaryId == null) return _WriteOutcome.skipped;
        return _upsertFamilyDeceased(
          row,
          localBeneficiaryId: localBeneficiaryId,
        );
      },
      onCounted: (count) => familyDeceasedSynced += count,
      writeCounter: writeCounter,
    );

    _logger.i(
      'Dedicated related endpoints synced => attachments: $attachmentsSynced, family_members: $familyMembersSynced, dead_people: $familyDeceasedSynced',
    );

    return (
      attachments: attachmentsSynced,
      familyMembers: familyMembersSynced,
      familyDeceased: familyDeceasedSynced,
    );
  }

  Future<void> _syncEndpointRows({
    required String entityKey,
    required String endpoint,
    required List<String> listKeys,
    required int pageSize,
    required Future<_WriteOutcome> Function(Map<String, dynamic> row, int sequence) onRow,
    required void Function(int counted) onCounted,
    required _EntityWriteCounter writeCounter,
  }) async {
    int page = 1;
    int sequence = 0;

    while (true) {
      final pageResult = await _fetchRelatedPage(
        endpoint: endpoint,
        page: page,
        pageSize: pageSize,
        listKeys: listKeys,
      );

      if (pageResult.rows.isEmpty) break;

      await _db.transaction(() async {
        for (var index = 0; index < pageResult.rows.length; index++) {
          final row = pageResult.rows[index];
          final outcome = await onRow(row, sequence);
          writeCounter.record(entityKey, outcome);
          sequence++;

          await _yieldToUiIfNeeded(index + 1);
        }
      });
      onCounted(pageResult.rows.length);

      if (!pageResult.hasMore) break;
      page++;
    }
  }

  Future<({List<Map<String, dynamic>> rows, bool hasMore})> _fetchRelatedPage({
    required String endpoint,
    required int page,
    required int pageSize,
    required List<String> listKeys,
  }) async {
    try {
      final response = await _getWithRetry(
        endpoint,
        queryParameters: {
          'page': page,
          'per_page': pageSize,
          'limit': pageSize,
          'order_by': 'id',
          'order_direction': 'ASC',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.data}');
      }

      final parsed = _parseRelatedRowsResponse(
        raw: response.data,
        page: page,
        pageSize: pageSize,
        listKeys: listKeys,
      );
      _logger.i('Fetched ${parsed.rows.length} rows from $endpoint page $page');
      return parsed;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 404 || status == 422) {
        _logger.w('Related endpoint $endpoint unavailable with status $status; skipping.');
        return (rows: const <Map<String, dynamic>>[], hasMore: false);
      }
      rethrow;
    }
  }

  ({List<Map<String, dynamic>> rows, bool hasMore}) _parseRelatedRowsResponse({
    required dynamic raw,
    required int page,
    required int pageSize,
    required List<String> listKeys,
  }) {
    final data = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
    final rows = _extractRowsFromPayload(data, preferredKeys: listKeys);
    final pagination = _extractPaginationMap(data);

    bool hasMore;
    if (pagination != null) {
      final currentPage = _asInt(pagination['current_page']) ?? _asInt(pagination['page']) ?? page;
      final lastPage = _asInt(pagination['last_page']) ?? _asInt(pagination['total_pages']);
      final nextPageUrl = pagination['next_page_url']?.toString();
      final hasNextUrl = nextPageUrl != null && nextPageUrl.isNotEmpty;
      hasMore = lastPage != null ? currentPage < lastPage : (hasNextUrl || rows.length >= pageSize);
    } else {
      hasMore = rows.length >= pageSize;
    }

    return (rows: rows, hasMore: hasMore);
  }

  List<Map<String, dynamic>> _extractRowsFromPayload(
    Map<String, dynamic> root, {
    required List<String> preferredKeys,
  }) {
    final directData = _extractRowsFromValue(root['data']);
    if (directData.isNotEmpty) return directData;

    final fromPreferred = _extractRowsFromMapByKeys(root, preferredKeys);
    if (fromPreferred.isNotEmpty) return fromPreferred;

    final dataNode = root['data'];
    if (dataNode is Map<String, dynamic>) {
      final nestedPreferred = _extractRowsFromMapByKeys(dataNode, preferredKeys);
      if (nestedPreferred.isNotEmpty) return nestedPreferred;
    }

    final commonKeys = <String>['rows', 'records', 'items', 'results', 'entities'];
    final fromCommon = _extractRowsFromMapByKeys(root, commonKeys);
    if (fromCommon.isNotEmpty) return fromCommon;

    if (dataNode is Map<String, dynamic>) {
      final nestedCommon = _extractRowsFromMapByKeys(dataNode, commonKeys);
      if (nestedCommon.isNotEmpty) return nestedCommon;
    }

    return const <Map<String, dynamic>>[];
  }

  List<Map<String, dynamic>> _extractRowsFromMapByKeys(
    Map<String, dynamic> root,
    List<String> keys,
  ) {
    for (final key in keys) {
      final directRows = _extractRowsFromValue(root[key]);
      if (directRows.isNotEmpty) return directRows;

      for (final value in _findValuesByKeyRecursive(root, key)) {
        final nestedRows = _extractRowsFromValue(value);
        if (nestedRows.isNotEmpty) return nestedRows;
      }
    }
    return const <Map<String, dynamic>>[];
  }

  Iterable<dynamic> _findValuesByKeyRecursive(dynamic node, String targetKey) sync* {
    if (node is Map<String, dynamic>) {
      for (final entry in node.entries) {
        if (entry.key == targetKey) {
          yield entry.value;
        }
        yield* _findValuesByKeyRecursive(entry.value, targetKey);
      }
    } else if (node is List) {
      for (final item in node) {
        yield* _findValuesByKeyRecursive(item, targetKey);
      }
    }
  }

  List<Map<String, dynamic>> _extractRowsFromValue(dynamic value) {
    if (value is List) {
      return value.whereType<Map<String, dynamic>>().toList();
    }

    if (value is Map<String, dynamic>) {
      for (final key in const ['data', 'items', 'records', 'rows', 'results', 'entities']) {
        final nested = value[key];
        if (nested is List) {
          final rows = nested.whereType<Map<String, dynamic>>().toList();
          if (rows.isNotEmpty) return rows;
        }
      }
    }

    return const <Map<String, dynamic>>[];
  }

  Map<String, dynamic>? _extractPaginationMap(Map<String, dynamic> root) {
    final candidates = <dynamic>[
      root['pagination'],
      root['meta'],
      root['data'] is Map<String, dynamic> ? (root['data'] as Map<String, dynamic>)['pagination'] : null,
      root['data'] is Map<String, dynamic> ? (root['data'] as Map<String, dynamic>)['meta'] : null,
    ];

    for (final candidate in candidates) {
      if (candidate is Map<String, dynamic>) {
        return candidate;
      }
    }

    for (final key in const ['pagination', 'meta']) {
      for (final candidate in _findValuesByKeyRecursive(root, key)) {
        if (candidate is Map<String, dynamic>) {
          return candidate;
        }
      }
    }

    return null;
  }

  Future<
      ({
        List<dynamic> records,
        bool hasMore,
        List<Map<String, dynamic>> attachments,
        List<Map<String, dynamic>> familyMembers,
        List<Map<String, dynamic>> familyDeceased,
      })> _fetchBeneficiariesPage(
    int page,
    int pageSize,
  ) async {
    final endpoint = _normalizeApiEndpoint('/api/mobile/database/data');
    final params = _buildBeneficiariesQueryParams(page, pageSize);

    final fullUrl = '${_dio.options.baseUrl}$endpoint';
    _logger.i('Fetching page $page from: $fullUrl');

    final response = await _getWithRetry(
      endpoint,
      queryParameters: params,
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.data}');
    }

    return _parseBeneficiariesResponse(response.data, page, pageSize);
  }

  Future<Response<dynamic>> _getWithRetry(
    String path, {
    Map<String, dynamic>? queryParameters,
    int maxAttempts = 3,
  }) async {
    DioException? lastError;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await _dio.get(
          path,
          queryParameters: queryParameters,
        );
      } on DioException catch (e) {
        lastError = e;
        final retryable = _isRetryableDioError(e);
        if (!retryable || attempt >= maxAttempts) {
          rethrow;
        }

        final delay = Duration(milliseconds: 350 * (1 << (attempt - 1)) + (attempt * 90));
        _logger.w('Retrying $path (attempt ${attempt + 1}/$maxAttempts) after ${delay.inMilliseconds}ms: ${e.message}');
        await Future.delayed(delay);
      }
    }

    throw lastError ?? Exception('Request failed without DioException for $path');
  }

  bool _isRetryableDioError(DioException e) {
    final status = e.response?.statusCode;
    if (status != null && (status == 429 || status >= 500)) {
      return true;
    }

    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError;
  }

  Map<String, dynamic> _buildBeneficiariesQueryParams(int page, int pageSize) {
    return {
      'page': page,
      'per_page': pageSize,
      'order_by': 'id',
      'order_direction': 'ASC',
    };
  }

  ({
    List<dynamic> records,
    bool hasMore,
    List<Map<String, dynamic>> attachments,
    List<Map<String, dynamic>> familyMembers,
    List<Map<String, dynamic>> familyDeceased,
  }) _parseBeneficiariesResponse(
    dynamic raw,
    int page,
    int pageSize,
  ) {
    final data = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
    final entities = data['entities'];
    final rawData = data['data'];

    List<dynamic> records = const [];
    final attachments = <Map<String, dynamic>>[];
    final familyMembers = <Map<String, dynamic>>[];
    final familyDeceased = <Map<String, dynamic>>[];

    if (entities is List) {
      final normalized = <dynamic>[];
      for (final item in entities) {
        if (item is Map<String, dynamic>) {
          final entityType = (item['entity_type'] ?? item['entityType'])?.toString().toLowerCase().trim();
          final payload = item['data'];
          final row = payload is Map<String, dynamic> ? payload : item;

          if (entityType == null || entityType == 'beneficiary' || entityType == 'beneficiaries') {
            normalized.add(row);
          } else if (entityType.contains('attach')) {
            attachments.add(row);
          } else if (entityType.contains('dead') || entityType.contains('deceased')) {
            familyDeceased.add(row);
          } else if (entityType.contains('family_member') ||
              entityType.contains('member') ||
              entityType.contains('orphan') ||
              entityType.contains('re_people')) {
            familyMembers.add(row);
          }
        }
      }
      records = normalized;
    } else if (rawData is List) {
      records = rawData;
    } else if (rawData is Map<String, dynamic>) {
      final fromKey = rawData['beneficiaries'] ??
          rawData['re_people'] ??
          rawData['people'] ??
          rawData['records'] ??
          rawData['items'] ??
          rawData['data'];
      if (fromKey is List) {
        records = fromKey;
      }

      final rawAttachments = rawData['attachments'];
      if (rawAttachments is List) {
        attachments.addAll(rawAttachments.whereType<Map<String, dynamic>>());
      }

      final rawFamilyMembers = rawData['family_members'] ?? rawData['members'] ?? rawData['orphans'];
      if (rawFamilyMembers is List) {
        familyMembers.addAll(rawFamilyMembers.whereType<Map<String, dynamic>>());
      }

      final rawFamilyDeceased = rawData['dead_people'] ?? rawData['family_deceased'] ?? rawData['deceased'];
      if (rawFamilyDeceased is List) {
        familyDeceased.addAll(rawFamilyDeceased.whereType<Map<String, dynamic>>());
      }
    } else if (data['re_people'] is List) {
      records = data['re_people'] as List<dynamic>;
    } else if (data['beneficiaries'] is List) {
      records = data['beneficiaries'] as List<dynamic>;
    }

    if (data['attachments'] is List) {
      attachments.addAll((data['attachments'] as List).whereType<Map<String, dynamic>>());
    }
    if (data['family_members'] is List) {
      familyMembers.addAll((data['family_members'] as List).whereType<Map<String, dynamic>>());
    }
    if (data['dead_people'] is List) {
      familyDeceased.addAll((data['dead_people'] as List).whereType<Map<String, dynamic>>());
    }

    final pagination = data['pagination'];
    bool hasMore = false;
    if (pagination is Map<String, dynamic>) {
      final currentPage = _asInt(pagination['current_page']) ?? _asInt(pagination['page']) ?? page;
      final lastPage = _asInt(pagination['last_page']) ?? _asInt(pagination['total_pages']);
      if (lastPage != null) {
        hasMore = currentPage < lastPage;
      }
    } else {
      hasMore = records.length >= pageSize;
    }

    return (
      records: records,
      hasMore: hasMore,
      attachments: attachments,
      familyMembers: familyMembers,
      familyDeceased: familyDeceased,
    );
  }

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  Future<void> _syncRelatedEntitiesForBeneficiary(
    Map<String, dynamic> beneficiary,
    int localBeneficiaryId,
    int? serverBeneficiaryId,
    _EntityWriteCounter writeCounter,
  ) async {
    final nestedAttachments = _extractListOfMaps(
      beneficiary,
      const ['attachments', 'documents', 'files'],
    );
    for (var i = 0; i < nestedAttachments.length; i++) {
      final outcome = await _upsertAttachment(
        nestedAttachments[i],
        localBeneficiaryId: localBeneficiaryId,
        serverBeneficiaryId: serverBeneficiaryId,
        sequence: i,
      );
      writeCounter.record('attachments', outcome);
    }

    final nestedMembers = _extractListOfMaps(
      beneficiary,
      const ['family_members', 'members', 'orphans'],
    );
    for (var index = 0; index < nestedMembers.length; index++) {
      final member = nestedMembers[index];
      final outcome = await _upsertFamilyMember(
        member,
        localBeneficiaryId: localBeneficiaryId,
      );
      writeCounter.record('family_members', outcome);

      await _yieldToUiIfNeeded(index + 1);
    }

    final nestedDeceased = _extractListOfMaps(
      beneficiary,
      const ['dead_people', 'family_deceased', 'deceased'],
    );
    for (var index = 0; index < nestedDeceased.length; index++) {
      final deceased = nestedDeceased[index];
      final outcome = await _upsertFamilyDeceased(
        deceased,
        localBeneficiaryId: localBeneficiaryId,
      );
      writeCounter.record('dead_people', outcome);

      await _yieldToUiIfNeeded(index + 1);
    }
  }

  Future<void> _syncRelatedEntitiesFromPage(
      ({
        List<dynamic> records,
        bool hasMore,
        List<Map<String, dynamic>> attachments,
        List<Map<String, dynamic>> familyMembers,
        List<Map<String, dynamic>> familyDeceased,
      }) pageResult,
      _EntityWriteCounter writeCounter,
      {required _BeneficiaryIdentityIndex identityIndex}) async {
    for (var i = 0; i < pageResult.attachments.length; i++) {
      final attachment = pageResult.attachments[i];
      final localBeneficiaryId = await _resolveLocalBeneficiaryIdFromPayload(attachment, index: identityIndex);
      if (localBeneficiaryId != null) {
        final outcome = await _upsertAttachment(
          attachment,
          localBeneficiaryId: localBeneficiaryId,
          serverBeneficiaryId: _resolveServerBeneficiaryId(attachment),
          sequence: i,
        );
        writeCounter.record('attachments', outcome);
      } else {
        writeCounter.record('attachments', _WriteOutcome.skipped);
      }

      await _yieldToUiIfNeeded(i + 1);
    }

    for (var i = 0; i < pageResult.familyMembers.length; i++) {
      final member = pageResult.familyMembers[i];
      final localBeneficiaryId = await _resolveLocalBeneficiaryIdFromPayload(member, index: identityIndex);
      if (localBeneficiaryId != null) {
        final outcome = await _upsertFamilyMember(
          member,
          localBeneficiaryId: localBeneficiaryId,
        );
        writeCounter.record('family_members', outcome);
      } else {
        writeCounter.record('family_members', _WriteOutcome.skipped);
      }

      await _yieldToUiIfNeeded(i + 1);
    }

    for (var i = 0; i < pageResult.familyDeceased.length; i++) {
      final deceased = pageResult.familyDeceased[i];
      final localBeneficiaryId = await _resolveLocalBeneficiaryIdFromPayload(deceased, index: identityIndex);
      if (localBeneficiaryId != null) {
        final outcome = await _upsertFamilyDeceased(
          deceased,
          localBeneficiaryId: localBeneficiaryId,
        );
        writeCounter.record('dead_people', outcome);
      } else {
        writeCounter.record('dead_people', _WriteOutcome.skipped);
      }

      await _yieldToUiIfNeeded(i + 1);
    }
  }

  Future<({int localBeneficiaryId, int? serverBeneficiaryId, _WriteOutcome outcome})> _upsertBeneficiaryRecord(
    Map<String, dynamic> record,
  ) async {
    final companion = mapper.BeneficiaryMapper.fromBackend(record);

    final serverIdRaw = record['id'];
    final serverId =
        serverIdRaw is int ? serverIdRaw : (serverIdRaw != null ? int.tryParse(serverIdRaw.toString()) : null);
    late final int localBeneficiaryId;
    _WriteOutcome outcome;

    if (serverId != null) {
      final existing =
          await (_db.select(_db.beneficiaries)..where((b) => b.serverId.equals(serverId))).getSingleOrNull();
      if (existing != null) {
        await (_db.update(_db.beneficiaries)..where((b) => b.id.equals(existing.id))).write(companion);
        localBeneficiaryId = existing.id;
        outcome = _WriteOutcome.updated;
      } else {
        localBeneficiaryId = await _db.into(_db.beneficiaries).insert(companion);
        outcome = _WriteOutcome.inserted;
      }
    } else {
      localBeneficiaryId = await _db.into(_db.beneficiaries).insert(companion);
      outcome = _WriteOutcome.inserted;
    }

    return (
      localBeneficiaryId: localBeneficiaryId,
      serverBeneficiaryId: serverId,
      outcome: outcome,
    );
  }

  List<Map<String, dynamic>> _extractListOfMaps(
    Map<String, dynamic> source,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = source[key];
      if (value is List) {
        return value.whereType<Map<String, dynamic>>().toList();
      }
    }
    return const [];
  }

  int? _resolveServerBeneficiaryId(Map<String, dynamic> row) {
    const directKeys = <String>[
      'beneficiary_id',
      'beneficiaryId',
      'data_id',
      'dataId',
      'data_record_id',
      'beneficiary_data_id',
      'main_beneficiary_id',
      'main_person_id',
      'primary_person_id',
      'beneficiary_server_id',
      'beneficiaryServerId',
      'beneficiary_server',
      're_people_id',
      'rePeopleId',
      're_person_id',
      'person_id',
      'owner_id',
      'related_beneficiary_id',
      'parent_beneficiary_id',
      'orphan_parent_id',
    ];

    for (final key in directKeys) {
      final parsed = _asIntLoose(row[key]);
      if (parsed != null) return parsed;
    }

    const nestedKeys = <String>[
      'beneficiary',
      'data',
      'beneficiary_data',
      're_people',
      'person',
      'owner',
      'main_person',
      'primary_person',
      'related_beneficiary',
    ];
    for (final nestedKey in nestedKeys) {
      final nested = row[nestedKey];
      if (nested is Map<String, dynamic>) {
        final parsed = _asIntLoose(
          nested['id'] ??
              nested['data_id'] ??
              nested['beneficiary_data_id'] ??
              nested['server_id'] ??
              nested['beneficiary_id'] ??
              nested['beneficiary_server_id'] ??
              nested['re_people_id'],
        );
        if (parsed != null) return parsed;
      }
    }

    return null;
  }

  Future<int?> _resolveLocalBeneficiaryIdFromPayload(
    Map<String, dynamic> row, {
    _BeneficiaryIdentityIndex? index,
  }) async {
    if (index != null) {
      final byIndex = _resolveLocalBeneficiaryIdFromIndex(row, index);
      if (byIndex != null) return byIndex;
    }

    final localId = _asInt(
      row['beneficiary_local_id'] ??
          row['beneficiaryLocalId'] ??
          row['beneficiary_local'] ??
          row['local_beneficiary_id'] ??
          row['data_local_id'] ??
          row['dataLocalId'] ??
          row['person_local_id'] ??
          row['personLocalId'] ??
          row['local_id'],
    );
    if (localId != null) {
      return localId;
    }

    for (final nestedKey in const [
      'beneficiary',
      'data',
      'beneficiary_data',
      're_people',
      'person',
      'owner',
      'main_person',
      'primary_person',
    ]) {
      final nested = row[nestedKey];
      if (nested is Map<String, dynamic>) {
        final nestedLocalId = _asInt(
          nested['local_id'] ??
              nested['beneficiary_local_id'] ??
              nested['beneficiaryLocalId'] ??
              nested['data_local_id'] ??
              nested['dataLocalId'] ??
              nested['person_local_id'],
        );
        if (nestedLocalId != null) return nestedLocalId;
      }
    }

    final serverId = _resolveServerBeneficiaryId(row);
    if (serverId != null) {
      final byServer =
          await (_db.select(_db.beneficiaries)..where((b) => b.serverId.equals(serverId))).getSingleOrNull();
      if (byServer != null) return byServer.id;
    }

    final fileIdCandidate = _extractFileIdCandidate(row);
    if (fileIdCandidate != null && fileIdCandidate.isNotEmpty) {
      final normalized = _normalizeIdentityToken(fileIdCandidate);
      final fileCandidates = <String>{fileIdCandidate};
      if (normalized != null) {
        fileCandidates.add(normalized);
      }

      final byFileId = await (_db.select(_db.beneficiaries)
            ..where((b) =>
                b.fileIdNumber.isIn(fileCandidates.toList()) | b.originalFileIdFromExcel.isIn(fileCandidates.toList())))
          .getSingleOrNull();
      if (byFileId != null) return byFileId.id;
    }

    final nationalId = _extractNationalIdCandidate(row);
    if (nationalId != null && nationalId.isNotEmpty) {
      final normalized = _normalizeIdentityToken(nationalId);
      final nationalCandidates = <String>{nationalId};
      if (normalized != null) {
        nationalCandidates.add(normalized);
      }

      final nationalIdInts = nationalCandidates.map(int.tryParse).whereType<int>().toList();
      if (nationalIdInts.isEmpty) {
        return null;
      }

      final byNationalId =
          await (_db.select(_db.beneficiaries)..where((b) => b.idNumber.isIn(nationalIdInts))).getSingleOrNull();
      if (byNationalId != null) return byNationalId.id;
    }

    return null;
  }

  int? _resolveLocalBeneficiaryIdFromIndex(
    Map<String, dynamic> row,
    _BeneficiaryIdentityIndex index,
  ) {
    final serverId = _resolveServerBeneficiaryId(row);
    if (serverId != null) {
      final byServer = index.byServerId(serverId);
      if (byServer != null) return byServer;
    }

    final fileId = _extractFileIdCandidate(row);
    if (fileId != null && fileId.isNotEmpty) {
      final byFile = index.byFileId(fileId);
      if (byFile != null) return byFile;
    }

    final nationalId = _extractNationalIdCandidate(row);
    if (nationalId != null && nationalId.isNotEmpty) {
      final byNational = index.byNationalId(nationalId);
      if (byNational != null) return byNational;
    }

    return null;
  }

  void _registerBeneficiaryIdentity(
    Map<String, dynamic> beneficiaryRow, {
    required int localBeneficiaryId,
    required int? serverBeneficiaryId,
    required _BeneficiaryIdentityIndex index,
  }) {
    index.registerLocal(localBeneficiaryId);

    final serverCandidates = <int>{
      if (serverBeneficiaryId != null) serverBeneficiaryId,
    };

    for (final key in const [
      'id',
      'server_id',
      'data_id',
      'beneficiary_id',
      'beneficiary_server_id',
    ]) {
      final parsed = _asIntLoose(beneficiaryRow[key]);
      if (parsed != null) {
        serverCandidates.add(parsed);
      }
    }

    for (final serverId in serverCandidates) {
      index.registerServerId(serverId, localBeneficiaryId);
    }

    final fileCandidate = _extractFileIdCandidate(beneficiaryRow);
    if (fileCandidate != null && fileCandidate.isNotEmpty) {
      index.registerFileId(fileCandidate, localBeneficiaryId);
    }

    final nationalCandidate = _extractNationalIdCandidate(beneficiaryRow);
    if (nationalCandidate != null && nationalCandidate.isNotEmpty) {
      index.registerNationalId(nationalCandidate, localBeneficiaryId);
    }
  }

  String? _extractFileIdCandidate(Map<String, dynamic> row) {
    final value = row['file_id_number'] ??
        row['fileIdNumber'] ??
        row['data_file_id'] ??
        row['dataFileId'] ??
        row['data_file_number'] ??
        row['dataFileNumber'] ??
        row['beneficiary_file_id'] ??
        row['beneficiary_file_no'] ??
        row['data_file_id_number'] ??
        row['data_file_no'] ??
        row['file_no'] ??
        row['registration_id'] ??
        row['registrationId'] ??
        row['re_file_id'] ??
        row['file_id'] ??
        row['owner_file_id'] ??
        row['beneficiary_code'];

    if (value == null) {
      for (final nestedKey in const [
        'beneficiary',
        'data',
        'beneficiary_data',
        're_people',
        'person',
        'owner',
        'main_person',
        'primary_person',
      ]) {
        final nested = row[nestedKey];
        if (nested is Map<String, dynamic>) {
          final nestedValue = nested['file_id_number'] ??
              nested['fileIdNumber'] ??
              nested['data_file_id'] ??
              nested['dataFileId'] ??
              nested['file_no'] ??
              nested['file_id'] ??
              nested['data_file_id_number'] ??
              nested['data_file_no'];
          if (nestedValue != null) {
            final parsedNested = _asIntLoose(nestedValue);
            if (parsedNested != null) return parsedNested.toString();
            final rawNested = nestedValue.toString().trim();
            if (rawNested.isNotEmpty) return rawNested;
          }
        }
      }
    }

    final parsed = _asIntLoose(value);
    if (parsed != null) return parsed.toString();

    final raw = value?.toString().trim();
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

  String? _extractNationalIdCandidate(Map<String, dynamic> row) {
    final value = row['beneficiary_national_id'] ??
        row['beneficiaryNationalId'] ??
        row['person_identity_number'] ??
        row['data_national_id'] ??
        row['dataNationalId'] ??
        row['national_id'] ??
        row['nationalId'] ??
        row['data_id_number'] ??
        row['data_national_id'] ??
        row['id_number'] ??
        row['person_national_id'] ??
        row['identity_number'];

    if (value != null) {
      final raw = value.toString().trim();
      if (raw.isNotEmpty) return raw;
    }

    for (final nestedKey in const [
      'beneficiary',
      'data',
      'beneficiary_data',
      're_people',
      'person',
      'owner',
      'main_person',
      'primary_person',
    ]) {
      final nested = row[nestedKey];
      if (nested is Map<String, dynamic>) {
        final nestedValue = nested['national_id'] ??
            nested['nationalId'] ??
            nested['person_identity_number'] ??
            nested['data_national_id'] ??
            nested['dataNationalId'] ??
            nested['id_number'] ??
            nested['data_id_number'] ??
            nested['data_national_id'] ??
            nested['identity_number'];
        if (nestedValue != null) {
          final raw = nestedValue.toString().trim();
          if (raw.isNotEmpty) return raw;
        }
      }
    }

    return null;
  }

  String? _normalizeIdentityToken(String? value) {
    if (value == null) return null;
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    return digits;
  }

  int? _asIntLoose(dynamic value) {
    final direct = _asInt(value);
    if (direct != null) return direct;
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) return null;
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

  Future<_WriteOutcome> _upsertAttachment(
    Map<String, dynamic> row, {
    required int localBeneficiaryId,
    required int? serverBeneficiaryId,
    required int sequence,
  }) async {
    final serverAttachmentId = (row['id'] ?? row['server_id'] ?? row['attachment_id'])?.toString();
    final fileName =
        (row['file_name'] ?? row['filename'] ?? row['name'] ?? row['document_name'] ?? 'attachment_${sequence + 1}')
            .toString();
    final serverUrl = (row['server_url'] ?? row['url'] ?? row['file_url'] ?? row['path'])?.toString();
    final attachmentId = (serverAttachmentId != null && serverAttachmentId.isNotEmpty)
        ? 'srv_att_$serverAttachmentId'
        : 'srv_att_${serverBeneficiaryId ?? localBeneficiaryId}_$sequence';

    final now = DateTime.now();
    final createdAt = _parseDateTimeLoose(row['created_at']) ?? now;
    final updatedAt = _parseDateTimeLoose(row['updated_at']) ?? now;

    final companion = AttachmentsCompanion.insert(
      id: attachmentId,
      beneficiaryId: localBeneficiaryId.toString(),
      fileName: fileName,
      filePath: serverUrl ?? fileName,
      type: _resolveAttachmentType(fileName, row['type']?.toString()),
      fileSize: _asInt(row['file_size'] ?? row['size']) ?? 0,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncState: const drift.Value('synced'),
      serverUrl: drift.Value(serverUrl),
      lastSyncedAt: drift.Value(now),
      visitId: drift.Value((row['visit_id'] ?? row['visitId'])?.toString()),
      thumbnailPath: drift.Value((row['thumbnail_path'] ?? row['thumbnail'])?.toString()),
      documentType: drift.Value((row['document_type'] ?? row['documentType'])?.toString()),
      personType: drift.Value((row['person_type'] ?? row['personType'])?.toString()),
      personId: drift.Value((row['person_id'] ?? row['personId'])?.toString()),
      notes: drift.Value(row['notes']?.toString()),
    );

    final existing = await (_db.select(_db.attachments)..where((a) => a.id.equals(attachmentId))).getSingleOrNull();
    if (existing != null) {
      await (_db.update(_db.attachments)..where((a) => a.id.equals(attachmentId))).write(companion);
      return _WriteOutcome.updated;
    }

    await _db.into(_db.attachments).insert(companion);
    return _WriteOutcome.inserted;
  }

  Future<_WriteOutcome> _upsertFamilyMember(
    Map<String, dynamic> row, {
    required int localBeneficiaryId,
  }) async {
    final now = DateTime.now();
    final serverId = _asInt(row['id'] ?? row['server_id'] ?? row['member_id']);

    final companion = FamilyMembersTableCompanion(
      beneficiaryId: drift.Value(localBeneficiaryId),
      orphanNationalId: drift.Value(_asInt(row['orphan_national_id'] ?? row['national_id'] ?? row['id_number']) ?? 0),
      firstName: drift.Value((row['first_name'] ?? row['name'] ?? '').toString().isEmpty
          ? 'غير محدد'
          : (row['first_name'] ?? row['name']).toString()),
      secondName: drift.Value(row['second_name']?.toString()),
      thirdName: drift.Value(row['third_name']?.toString()),
      familyName: drift.Value((row['family_name'] ?? row['last_name'] ?? 'غير محدد').toString()),
      birthDate: drift.Value(_parseDateTimeLoose(row['birth_date']) ?? now),
      age: drift.Value(_asInt(row['age'])),
      gender: drift.Value(_parseGender(row['gender'])),
      healthStatus: drift.Value(_parseHealthStatus(row['health_status'])),
      sponsorshipStatus: drift.Value(_asInt(row['sponsorship_status'])),
      sponsorshipType: drift.Value(_asInt(row['sponsorship_type'])),
      sponsorName: drift.Value(row['sponsor_name']?.toString()),
      sponsorshipStartDate: drift.Value(_parseDateTimeLoose(row['sponsorship_start_date'])),
      notes: drift.Value(row['notes']?.toString()),
      attachments: drift.Value(row['attachments']?.toString()),
      createdAt: drift.Value(_parseDateTimeLoose(row['created_at'])),
      updatedAt: drift.Value(_parseDateTimeLoose(row['updated_at']) ?? now),
      syncState: const drift.Value('synced'),
      serverId: drift.Value(serverId),
      lastSyncedAt: drift.Value(now),
    );

    if (serverId != null) {
      final existing = await (_db.select(_db.familyMembersTable)
            ..where((t) => t.serverId.equals(serverId) & t.beneficiaryId.equals(localBeneficiaryId)))
          .getSingleOrNull();
      if (existing != null) {
        await (_db.update(_db.familyMembersTable)..where((t) => t.id.equals(existing.id))).write(companion);
        return _WriteOutcome.updated;
      }
    }

    await _db.into(_db.familyMembersTable).insert(companion);
    return _WriteOutcome.inserted;
  }

  Future<_WriteOutcome> _upsertFamilyDeceased(
    Map<String, dynamic> row, {
    required int localBeneficiaryId,
  }) async {
    final now = DateTime.now();
    final serverId = _asInt(row['id'] ?? row['server_id'] ?? row['deceased_id']);

    final companion = FamilyDeceasedTableCompanion(
      beneficiaryId: drift.Value(localBeneficiaryId),
      deceasedType: drift.Value(_parseDeceasedType(row['deceased_type'])),
      firstName: drift.Value((row['first_name'] ?? row['name'] ?? '').toString().isEmpty
          ? 'غير محدد'
          : (row['first_name'] ?? row['name']).toString()),
      secondName: drift.Value(row['second_name']?.toString()),
      thirdName: drift.Value(row['third_name']?.toString()),
      familyName: drift.Value((row['family_name'] ?? row['last_name'] ?? 'غير محدد').toString()),
      nationalId: drift.Value(_asInt(row['national_id'] ?? row['id_number']) ?? 0),
      deathDate: drift.Value(_parseDateTimeLoose(row['death_date']) ?? now),
      deathCause: drift.Value(_parseDeathCause(row['death_cause'])),
      documentType: drift.Value(_asInt(row['document_type'])),
      documentPath: drift.Value(row['document_path']?.toString()),
      notes: drift.Value(row['notes']?.toString()),
      createdAt: drift.Value(_parseDateTimeLoose(row['created_at'])),
      updatedAt: drift.Value(_parseDateTimeLoose(row['updated_at']) ?? now),
      syncState: const drift.Value('synced'),
      serverId: drift.Value(serverId),
      lastSyncedAt: drift.Value(now),
    );

    if (serverId != null) {
      final existing = await (_db.select(_db.familyDeceasedTable)
            ..where((t) => t.serverId.equals(serverId) & t.beneficiaryId.equals(localBeneficiaryId)))
          .getSingleOrNull();
      if (existing != null) {
        await (_db.update(_db.familyDeceasedTable)..where((t) => t.id.equals(existing.id))).write(companion);
        return _WriteOutcome.updated;
      }
    }

    await _db.into(_db.familyDeceasedTable).insert(companion);
    return _WriteOutcome.inserted;
  }

  DateTime? _parseDateTimeLoose(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  String _resolveAttachmentType(String fileName, String? hintedType) {
    if (hintedType != null && hintedType.isNotEmpty) return hintedType;
    final name = fileName.toLowerCase();
    if (name.endsWith('.jpg') || name.endsWith('.jpeg') || name.endsWith('.png') || name.endsWith('.webp')) {
      return 'image';
    }
    if (name.endsWith('.pdf')) return 'pdf';
    return 'other';
  }

  int _parseGender(dynamic value) {
    final raw = value?.toString().toLowerCase().trim();
    if (raw == '1' || raw == 'male' || raw == 'ذكر') return 1;
    if (raw == '2' || raw == 'female' || raw == 'أنثى') return 2;
    return 1;
  }

  int _parseHealthStatus(dynamic value) {
    final raw = value?.toString().toLowerCase().trim();
    if (raw == '1' || raw == 'healthy' || raw == 'سليم') return 1;
    if (raw == '2' || raw == 'sick' || raw == 'مريض') return 2;
    if (raw == '3' || raw == 'chronic' || raw == 'مريض مزمن') return 3;
    if (raw == '4' || raw == 'disabled' || raw == 'معاق') return 4;
    return 5;
  }

  int _parseDeceasedType(dynamic value) {
    final raw = value?.toString().toLowerCase().trim();
    if (raw == '1' || raw == 'father' || raw == 'أب') return 1;
    if (raw == '2' || raw == 'mother' || raw == 'أم') return 2;
    return 1;
  }

  int _parseDeathCause(dynamic value) {
    final raw = value?.toString().toLowerCase().trim();
    if (raw == '1' || raw == 'طبيعية' || raw == 'natural') return 1;
    if (raw == '2' || raw == 'مرض' || raw == 'disease') return 2;
    if (raw == '3' || raw == 'فجأة' || raw == 'sudden') return 3;
    if (raw == '4' || raw == 'حادث' || raw == 'accident') return 4;
    if (raw == '5' || raw == 'أخرى' || raw == 'other') return 5;
    if (raw == '6' || raw == 'انتحار' || raw == 'suicide') return 6;
    if (raw == '7' || raw == 'مغدور' || raw == 'murdered') return 7;
    return 8;
  }

  // ========================================================================
  // 🔼 BATCH SYNC UP - رفع التغييرات المحلية مجمعة
  // ========================================================================

  /// رفع المستفيدين المحليين للسيرفر باستخدام الـ Batch API
  Future<MobileSyncResult> syncUp() async {
    _updateStatus(
      _currentStatus.copyWith(
        isSyncing: true,
        currentOperation: 'جاري رفع التغييرات (Batch Sync)...',
        progress: 0.0,
      ),
    );

    try {
      // Get local beneficiaries that need sync (pending or modified)
      final localBeneficiaries = await (_db.select(_db.beneficiaries)
            ..where(
              (b) => b.syncState.equals('pending') | b.syncState.equals('modified'),
            ))
          .get();

      final deviceId = await _storage.getDeviceId(); // 🆔 Get real device ID

      _logger.i('Found ${localBeneficiaries.length} beneficiaries to upload');

      if (localBeneficiaries.isEmpty) {
        _updateStatus(
          _currentStatus.copyWith(
            isSyncing: false,
            currentOperation: 'لا توجد تغييرات للرفع - جميع البيانات متزامنة ✓',
          ),
        );

        return MobileSyncResult(success: true, recordsSynced: 0);
      }

      // Process in batches
      const batchSize = ApiConfig.batchSize;
      int uploaded = 0;
      int failed = 0;

      for (int i = 0; i < localBeneficiaries.length; i += batchSize) {
        final end = (i + batchSize < localBeneficiaries.length) ? i + batchSize : localBeneficiaries.length;
        final batch = localBeneficiaries.sublist(i, end);

        _updateStatus(
          _currentStatus.copyWith(
            currentOperation: 'جاري رفع الدفعة ${(i ~/ batchSize) + 1}...',
            progress: (i + batch.length) / localBeneficiaries.length,
          ),
        );

        try {
          // Convert batch to backend format
          final dataList = batch.map((b) => mapper.BeneficiaryMapper.toBackend(b)).toList();

          final response = await _dio.post(
            _normalizeApiEndpoint(ApiConfig.batchDataSyncEndpoint),
            data: {
              'records': dataList,
              'device_id': deviceId, // ✅ Using real device ID
            },
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            // Mark these records as synced in DB
            final ids = batch.map((b) => b.id).toList();
            await (_db.update(_db.beneficiaries)..where((b) => b.id.isIn(ids))).write(
              BeneficiariesCompanion(
                syncState: const drift.Value('synced'),
                lastSyncedAt: drift.Value(DateTime.now()),
              ),
            );

            uploaded += batch.length;
            _logger.i('✅ Synced batch of ${batch.length} records');
          } else {
            failed += batch.length;
            _logger.w('❌ Sync batch failed: ${response.data}');
          }
        } catch (e) {
          failed += batch.length;
          _logger.e('Error syncing batch', error: e);
        }
      }

      // 1.5️⃣ Upload Visits
      _updateStatus(
        _currentStatus.copyWith(
          currentOperation: 'جاري رفع الزيارات...',
          progress: 0.6,
        ),
      );

      final visitsResult = await _syncVisitsUp(deviceId);
      uploaded += visitsResult.recordsSynced;
      failed += visitsResult.recordsFailed;

      // 2️⃣ Upload Attachments
      _updateStatus(
        _currentStatus.copyWith(
          currentOperation: 'جاري رفع المرفقات...',
          progress: 0.8,
        ),
      );

      final attachmentResult = await _syncAttachmentsUp(deviceId);
      uploaded += attachmentResult.recordsSynced;
      failed += attachmentResult.recordsFailed;

      _updateStatus(
        _currentStatus.copyWith(
          isSyncing: false,
          currentOperation: failed > 0 ? 'تم رفع $uploaded سجل (فشل $failed)' : 'تم رفع $uploaded سجل بنجاح ✓',
          progress: 1.0,
          lastSyncAt: DateTime.now(),
        ),
      );

      return MobileSyncResult(
        success: failed == 0,
        recordsSynced: uploaded,
        recordsFailed: failed,
      );
    } catch (e, stack) {
      _logger.e('Sync up failed', error: e, stackTrace: stack);
      _updateStatus(_currentStatus.copyWith(isSyncing: false, lastError: e.toString()));
      return MobileSyncResult(success: false, recordsSynced: 0, error: e.toString());
    }
  }

  /// مزامنة المرفقات محلية الرفع للسيرفر
  Future<MobileSyncResult> _syncAttachmentsUp(String deviceId) async {
    int uploaded = 0;
    int failedCount = 0;

    try {
      final pendingAttachments = await _db.attachmentsDao.getPendingAttachments();
      _logger.i('Found ${pendingAttachments.length} attachments to upload');

      for (final attachment in pendingAttachments) {
        try {
          final file = File(attachment.filePath);
          if (!file.existsSync()) {
            _logger.w('File not found: ${attachment.filePath}');
            failedCount++;
            continue;
          }

          final personIdentityNumber = await _resolvePersonIdentityNumberForAttachment(attachment);
          if (personIdentityNumber == null || personIdentityNumber.isEmpty) {
            _logger.w('Missing person_identity_number for attachment ${attachment.id}');
            failedCount++;
            continue;
          }

          final resolvedFileType = _resolveAttachmentFileTypeForUpload(attachment, file);

          final formData = FormData.fromMap({
            'file': await MultipartFile.fromFile(file.path, filename: attachment.fileName),
            'person_identity_number': personIdentityNumber,
            if (resolvedFileType != null) 'file_type': resolvedFileType,
            'entity_type': 'beneficiary',
            'entity_id': attachment.beneficiaryId,
            'device_id': deviceId,
            if (attachment.documentType != null && attachment.documentType!.trim().isNotEmpty)
              'document_type': attachment.documentType,
            if (attachment.notes != null && attachment.notes!.trim().isNotEmpty) 'notes': attachment.notes,
          });

          final response = await _dio.post(
            _normalizeApiEndpoint(ApiConfig.attachmentUploadEndpoint),
            data: formData,
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            final serverUrl = response.data['url'] as String?;
            await _db.attachmentsDao.updateAttachmentSyncState(
              attachment.id,
              'synced',
              serverUrl: serverUrl,
            );
            uploaded++;
          } else {
            failedCount++;
            _logger.w('Failed to upload attachment ${attachment.id}: ${response.statusCode}');
          }
        } catch (e) {
          _logger.w('Error uploading attachment ${attachment.id}: $e');
          failedCount++;
        }
      }

      return MobileSyncResult(
        success: failedCount == 0,
        recordsSynced: uploaded,
        recordsFailed: failedCount,
      );
    } catch (e) {
      _logger.e('Attachments sync up failed', error: e);
      return MobileSyncResult(success: false, recordsSynced: 0, error: e.toString());
    }
  }

  Future<String?> _resolvePersonIdentityNumberForAttachment(Attachment attachment) async {
    final directPersonId = attachment.personId?.trim();
    if (directPersonId != null && directPersonId.isNotEmpty) {
      return directPersonId;
    }

    final localBeneficiaryId = int.tryParse(attachment.beneficiaryId);
    if (localBeneficiaryId == null) {
      return null;
    }

    final beneficiary =
        await (_db.select(_db.beneficiaries)..where((b) => b.id.equals(localBeneficiaryId))).getSingleOrNull();

    final idNumber = beneficiary?.idNumber;
    if (idNumber == null) {
      return null;
    }

    return idNumber.toString();
  }

  String? _resolveAttachmentFileTypeForUpload(Attachment attachment, File file) {
    final explicitType = attachment.documentType?.trim();
    if (explicitType != null && explicitType.isNotEmpty) {
      return explicitType;
    }

    final fileName = file.path.split(Platform.pathSeparator).last;
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex <= 0 || dotIndex >= fileName.length - 1) {
      return null;
    }

    return fileName.substring(dotIndex + 1).toLowerCase();
  }

  /// مزامنة الزيارات محلية الرفع للسيرفر
  Future<MobileSyncResult> _syncVisitsUp(String deviceId) async {
    int uploaded = 0;
    int failedCount = 0;

    try {
      final pendingVisits = await _db.visitsDao.getPendingVisits();
      _logger.i('Found ${pendingVisits.length} visits to upload');

      if (pendingVisits.isEmpty) {
        return MobileSyncResult(success: true, recordsSynced: 0);
      }

      // Process in batches
      const batchSize = ApiConfig.batchSize;
      for (int i = 0; i < pendingVisits.length; i += batchSize) {
        final end = (i + batchSize < pendingVisits.length) ? i + batchSize : pendingVisits.length;
        final batch = pendingVisits.sublist(i, end);
        final dataList = batch.map(visit_mapper.VisitSyncMapper.toBackend).toList();

        try {
          final response = await _dio.post(
            _normalizeApiEndpoint(ApiConfig.visitsBatchSyncEndpoint),
            data: {
              'records': dataList,
              'device_id': deviceId,
            },
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            final results = response.data['results'] as List?;
            if (results != null) {
              for (var res in results) {
                final localId = res['local_id']?.toString();
                final serverId = res['id']?.toString();
                if (localId != null && serverId != null) {
                  await _db.visitsDao.updateVisitSyncStatus(localId, serverId);
                  uploaded++;
                }
              }
            }
          } else {
            failedCount += batch.length;
            _logger.w('❌ Visits sync batch failed: ${response.statusCode}');
          }
        } catch (e) {
          failedCount += batch.length;
          _logger.e('Error syncing visits batch', error: e);
        }
      }

      return MobileSyncResult(
        success: failedCount == 0,
        recordsSynced: uploaded,
        recordsFailed: failedCount,
      );
    } catch (e) {
      _logger.e('Visits sync up failed', error: e);
      return MobileSyncResult(success: false, recordsSynced: 0, error: e.toString());
    }
  }

  String _classifyError(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      if (status == 401 || status == 403) return 'auth';
      if (status == 404) return 'route';
      if (status == 422) return 'validation';
      if (status != null && status >= 500) return 'server';
      return 'network';
    }

    final message = error.toString().toLowerCase();
    if (message.contains('parse') || message.contains('format')) return 'parser';
    if (message.contains('database') || message.contains('sql') || message.contains('drift')) return 'db';
    if (message.contains('socket') || message.contains('timeout') || message.contains('network')) return 'network';
    return 'unknown';
  }

  String? _extractErrorContext(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode?.toString() ?? 'n/a';
      final path = error.requestOptions.path;
      final body = error.response?.data?.toString();
      if (body == null || body.isEmpty) {
        return 'path=$path status=$status';
      }
      final trimmed = body.length > 300 ? body.substring(0, 300) : body;
      return 'path=$path status=$status body=$trimmed';
    }
    return null;
  }

  // ========================================================================
  // 📊 CLEANUP
  // ========================================================================

  /// Dispose
  void dispose() {
    _statusController.close();
  }

  String _normalizeApiEndpoint(String endpoint) {
    final normalized = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final basePath = Uri.tryParse(_dio.options.baseUrl)?.path ?? '';

    if (basePath.endsWith('/api') && normalized.startsWith('/api/')) {
      return normalized.substring(4);
    }

    return normalized;
  }
}

// ========================================================================
// 📦 DATA MODELS
// ========================================================================

/// Mobile Sync Status
class MobileSyncStatus {
  final bool isSyncing;
  final String currentOperation;
  final double progress;
  final DateTime? lastSyncAt;
  final String? lastError;

  MobileSyncStatus({
    this.isSyncing = false,
    this.currentOperation = 'جاهز',
    this.progress = 0.0,
    this.lastSyncAt,
    this.lastError,
  });

  MobileSyncStatus copyWith({
    bool? isSyncing,
    String? currentOperation,
    double? progress,
    DateTime? lastSyncAt,
    String? lastError,
  }) {
    return MobileSyncStatus(
      isSyncing: isSyncing ?? this.isSyncing,
      currentOperation: currentOperation ?? this.currentOperation,
      progress: progress ?? this.progress,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      lastError: lastError,
    );
  }
}

/// Mobile Sync Result
class MobileSyncResult {
  final bool success;
  final int recordsSynced;
  final int recordsFailed;
  final String? error;
  final Map<String, int> payloadCounters;
  final Map<String, int> writeCounters;
  final String? errorCategory;
  final String? errorContext;

  MobileSyncResult({
    required this.success,
    required this.recordsSynced,
    this.recordsFailed = 0,
    this.error,
    this.payloadCounters = const {},
    this.writeCounters = const {},
    this.errorCategory,
    this.errorContext,
  });
}

enum _WriteOutcome { inserted, updated, skipped }

class _EntityWriteCounter {
  final Map<String, Map<String, int>> _data = <String, Map<String, int>>{};

  void record(String entity, _WriteOutcome outcome) {
    final current = _data.putIfAbsent(
        entity,
        () => {
              'inserted': 0,
              'updated': 0,
              'skipped': 0,
            });

    switch (outcome) {
      case _WriteOutcome.inserted:
        current['inserted'] = (current['inserted'] ?? 0) + 1;
        break;
      case _WriteOutcome.updated:
        current['updated'] = (current['updated'] ?? 0) + 1;
        break;
      case _WriteOutcome.skipped:
        current['skipped'] = (current['skipped'] ?? 0) + 1;
        break;
    }
  }

  Map<String, int> toFlatMap() {
    final flat = <String, int>{};
    for (final entry in _data.entries) {
      flat['${entry.key}_inserted'] = entry.value['inserted'] ?? 0;
      flat['${entry.key}_updated'] = entry.value['updated'] ?? 0;
      flat['${entry.key}_skipped'] = entry.value['skipped'] ?? 0;
    }
    return flat;
  }
}

class _BeneficiaryIdentityIndex {
  final Map<int, int> _serverToLocal = <int, int>{};
  final Map<String, int> _fileToLocal = <String, int>{};
  final Map<String, int> _nationalToLocal = <String, int>{};
  final Set<int> _locals = <int>{};

  void registerLocal(int localId) => _locals.add(localId);

  void registerServerId(int serverId, int localId) {
    _locals.add(localId);
    _serverToLocal[serverId] = localId;
  }

  void registerFileId(String fileId, int localId) {
    _locals.add(localId);
    final raw = fileId.trim();
    if (raw.isEmpty) return;
    _fileToLocal[raw] = localId;

    final normalized = _normalizeDigits(raw);
    if (normalized != null) {
      _fileToLocal[normalized] = localId;
    }
  }

  void registerNationalId(String nationalId, int localId) {
    _locals.add(localId);
    final raw = nationalId.trim();
    if (raw.isEmpty) return;
    _nationalToLocal[raw] = localId;

    final normalized = _normalizeDigits(raw);
    if (normalized != null) {
      _nationalToLocal[normalized] = localId;
    }
  }

  int? byServerId(int serverId) => _serverToLocal[serverId];

  int? byFileId(String fileId) {
    final raw = fileId.trim();
    if (raw.isEmpty) return null;
    final direct = _fileToLocal[raw];
    if (direct != null) return direct;

    final normalized = _normalizeDigits(raw);
    if (normalized == null) return null;
    return _fileToLocal[normalized];
  }

  int? byNationalId(String nationalId) {
    final raw = nationalId.trim();
    if (raw.isEmpty) return null;
    final direct = _nationalToLocal[raw];
    if (direct != null) return direct;

    final normalized = _normalizeDigits(raw);
    if (normalized == null) return null;
    return _nationalToLocal[normalized];
  }

  String? _normalizeDigits(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    return digits;
  }
}
