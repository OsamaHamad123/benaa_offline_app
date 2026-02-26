import 'dart:async';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as drift;
import 'package:logger/logger.dart';

import 'package:benaa_offline_app/core/config/api_config.dart';
import 'package:benaa_offline_app/core/sync/domain/entities/sync_result.dart';
import 'package:benaa_offline_app/core/sync/domain/repositories/i_sync_repository.dart';
import '../../data/db/drift_database.dart';
import '../mappers/beneficiary_sync_mapper.dart' as mapper;
import '../mappers/visit_sync_mapper.dart' as visit_mapper;
import '../storage/secure_storage.dart';
import '../../features/sync/services/file_id_service.dart';
import '../../features/sync/domain/entities/sync_flow_contract.dart';
import '../../features/sync/domain/usecases/sync_down_flow_usecase.dart';
import '../../features/sync/domain/usecases/sync_associations_module_usecase.dart';
import '../../features/sync/domain/usecases/sync_sponsorships_module_usecase.dart';
import '../../features/sync/domain/usecases/sync_related_entities_up_usecase.dart';
import '../../features/sync/domain/usecases/sync_up_flow_usecase.dart';
import '../../features/sync/domain/usecases/tombstone_delete_sync_usecase.dart';
import '../../features/sync/data/parsers/mobile_sync_response_parser.dart';
import '../../features/sync/data/repositories/mobile_sync_beneficiary_repository.dart';
import '../../features/sync/data/repositories/mobile_sync_related_entities_repository.dart';
import '../../features/sync/domain/utils/api_endpoint_normalizer.dart' as sync_endpoint;
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
  final ISyncRepository? _syncRepository;
  late final TombstoneDeleteSyncUseCase _tombstoneDeleteSyncUseCase;
  late final SyncDownFlowUseCase _syncDownFlowUseCase;
  late final SyncUpFlowUseCase _syncUpFlowUseCase;
  late final SyncRelatedEntitiesUpUseCase _syncRelatedEntitiesUpUseCase;
  final SyncAssociationsModuleUseCase? _syncAssociationsModuleUseCase;
  final SyncSponsorshipsModuleUseCase? _syncSponsorshipsModuleUseCase;
  final MobileSyncResponseParser _responseParser;
  late final MobileSyncBeneficiaryRepository _beneficiaryRepository;
  late final MobileSyncRelatedEntitiesRepository _relatedEntitiesRepository;
  final Logger _logger = Logger();

  // Sync state
  final _statusController = StreamController<MobileSyncStatus>.broadcast();
  final _operationEventsController = StreamController<SyncOperationEvent>.broadcast();
  MobileSyncStatus _currentStatus = MobileSyncStatus();
  static const int _uiYieldInterval = 20;

  MobileSyncService(
    this._db,
    this._storage, {
    Dio? dio,
    FileIdService? fileIdService,
    TaxonomyRepository? taxonomyRepository,
    ISyncRepository? syncRepository,
    TombstoneDeleteSyncUseCase? tombstoneDeleteSyncUseCase,
    SyncDownFlowUseCase? syncDownFlowUseCase,
    SyncUpFlowUseCase? syncUpFlowUseCase,
    SyncRelatedEntitiesUpUseCase? syncRelatedEntitiesUpUseCase,
    SyncAssociationsModuleUseCase? syncAssociationsModuleUseCase,
    SyncSponsorshipsModuleUseCase? syncSponsorshipsModuleUseCase,
    MobileSyncResponseParser? responseParser,
    MobileSyncBeneficiaryRepository? beneficiaryRepository,
    MobileSyncRelatedEntitiesRepository? relatedEntitiesRepository,
  })  : _fileIdService = fileIdService,
        _taxonomyRepository = taxonomyRepository,
        _syncRepository = syncRepository,
        _syncAssociationsModuleUseCase = syncAssociationsModuleUseCase,
        _syncSponsorshipsModuleUseCase = syncSponsorshipsModuleUseCase,
        _responseParser = responseParser ?? MobileSyncResponseParser(),
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
            ) {
    _tombstoneDeleteSyncUseCase = tombstoneDeleteSyncUseCase ??
        TombstoneDeleteSyncUseCase(
          syncDao: _db.syncDao,
          dio: _dio,
          normalizeApiEndpoint: _normalizeApiEndpoint,
        );

    _syncDownFlowUseCase = syncDownFlowUseCase ??
        SyncDownFlowUseCase(
          emit: _operationEventsController.add,
        );

    _syncUpFlowUseCase = syncUpFlowUseCase ??
        SyncUpFlowUseCase(
          emit: _operationEventsController.add,
        );

    _syncRelatedEntitiesUpUseCase = syncRelatedEntitiesUpUseCase ??
        SyncRelatedEntitiesUpUseCase(
          database: _db,
          dio: _dio,
          normalizeApiEndpoint: _normalizeApiEndpoint,
          logger: _logger,
        );

    _relatedEntitiesRepository =
        relatedEntitiesRepository ?? MobileSyncRelatedEntitiesRepository(database: _db, logger: _logger);

    _beneficiaryRepository = beneficiaryRepository ?? MobileSyncBeneficiaryRepository(database: _db, logger: _logger);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await _storage.getAuthToken();
            if (token != null && token.trim().isNotEmpty) {
              options.headers['Authorization'] = 'Bearer ${token.trim()}';
            }
          } catch (_) {}

          options.headers.putIfAbsent('Accept', () => 'application/json');
          handler.next(options);
        },
      ),
    );
  }

  Stream<MobileSyncStatus> get statusStream => _statusController.stream;
  Stream<SyncOperationEvent> get operationEventsStream => _operationEventsController.stream;
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

  Future<MobileSyncResult> syncRecordByFileId(String fileIdNumber) async {
    _updateStatus(
      _currentStatus.copyWith(
        isSyncing: true,
        currentOperation: 'جاري تنزيل سجل الملف $fileIdNumber ...',
        progress: 0.0,
      ),
    );

    final writeCounter = _EntityWriteCounter();

    try {
      final response = await _dio.get(
        _normalizeApiEndpoint('/api/mobile/database/data/$fileIdNumber'),
      );

      final root = _toStringDynamicMap(response.data) ?? const <String, dynamic>{};
      final dataNode = _toStringDynamicMap(root['data']) ?? const <String, dynamic>{};
      final record = _toStringDynamicMap(dataNode['record']);

      if (record == null || record.isEmpty) {
        _updateStatus(
          _currentStatus.copyWith(
            isSyncing: false,
            currentOperation: 'لم يتم العثور على بيانات للملف $fileIdNumber',
            progress: 1.0,
          ),
        );
        return MobileSyncResult(success: false, recordsSynced: 0, error: 'record_not_found');
      }

      final upsertResult = await _upsertBeneficiaryRecord(record);
      writeCounter.record('beneficiaries', upsertResult.outcome);

      await _syncRelatedEntitiesForBeneficiary(
        record,
        upsertResult.localBeneficiaryId,
        writeCounter,
      );

      _updateStatus(
        _currentStatus.copyWith(
          isSyncing: false,
          currentOperation: 'تم تنزيل سجل الملف $fileIdNumber بنجاح',
          progress: 1.0,
          lastSyncAt: DateTime.now(),
        ),
      );

      return MobileSyncResult(
        success: true,
        recordsSynced: 1,
        writeCounters: writeCounter.toFlatMap(),
      );
    } catch (e, stack) {
      _logger.e('Sync single record failed', error: e, stackTrace: stack);
      _updateStatus(
        _currentStatus.copyWith(
          isSyncing: false,
          lastError: e.toString(),
        ),
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

  /// مزامنة كاملة - تنزيل كل البيانات من السيرفر
  Future<MobileSyncResult> syncDown() async {
    final flowResult = await _syncDownFlowUseCase.execute(
      syncTaxonomies: _syncTaxonomiesNonCritical,
      ensureFileReservation: _ensureFileReservationNonCritical,
      syncBeneficiariesDown: () async {
        final result = await _syncBeneficiariesDown();
        _logger.i('Synced ${result.recordsSynced} beneficiaries');
        return _toFlowResult(result);
      },
      onProgress: ({
        required String operation,
        required double progress,
        bool isSyncing = true,
        DateTime? lastSyncAt,
        String? lastError,
      }) {
        _updateStatus(
          _currentStatus.copyWith(
            isSyncing: isSyncing,
            currentOperation: operation,
            progress: progress,
            lastSyncAt: lastSyncAt,
            lastError: lastError,
          ),
        );
      },
      classifyError: _classifyError,
      extractErrorContext: _extractErrorContext,
    );
    final baseResult = _fromFlowResult(flowResult);

    if (!baseResult.success) {
      return baseResult;
    }

    var result = baseResult;

    if (_syncAssociationsModuleUseCase != null) {
      try {
        _updateStatus(
          _currentStatus.copyWith(
            isSyncing: true,
            currentOperation: 'جاري مزامنة الجمعيات والموظفين... ',
            progress: 0.95,
          ),
        );

        final counters = await _syncAssociationsModuleUseCase.syncDown();

        final mergedPayload = Map<String, int>.from(result.payloadCounters)
          ..update(
            'sponsors',
            (value) => value + counters.uploaded,
            ifAbsent: () => counters.uploaded,
          );

        result = MobileSyncResult(
          success: result.success && counters.failed == 0,
          recordsSynced: result.recordsSynced + counters.uploaded,
          recordsFailed: result.recordsFailed + counters.failed,
          payloadCounters: mergedPayload,
          writeCounters: result.writeCounters,
          error: counters.failed > 0 ? 'associations_sync_partial_failure' : result.error,
          errorCategory: counters.failed > 0 ? 'partial_failure' : result.errorCategory,
          errorContext: result.errorContext,
        );
      } catch (e) {
        _logger.w('Associations module sync-down step failed: $e');
        result = MobileSyncResult(
          success: false,
          recordsSynced: result.recordsSynced,
          recordsFailed: result.recordsFailed + 1,
          payloadCounters: result.payloadCounters,
          writeCounters: result.writeCounters,
          error: 'associations_sync_down_failed: $e',
          errorCategory: _classifyError(e),
          errorContext: _extractErrorContext(e),
        );
      }
    }

    if (_syncSponsorshipsModuleUseCase != null) {
      try {
        _updateStatus(
          _currentStatus.copyWith(
            isSyncing: true,
            currentOperation: 'جاري مزامنة الكفالات... ',
            progress: 0.98,
          ),
        );

        final counters = await _syncSponsorshipsModuleUseCase.syncDown();

        final mergedPayload = Map<String, int>.from(result.payloadCounters)
          ..update(
            'sponsorships',
            (value) => value + counters.uploaded,
            ifAbsent: () => counters.uploaded,
          );

        result = MobileSyncResult(
          success: result.success && counters.failed == 0,
          recordsSynced: result.recordsSynced + counters.uploaded,
          recordsFailed: result.recordsFailed + counters.failed,
          payloadCounters: mergedPayload,
          writeCounters: result.writeCounters,
          error: counters.failed > 0 ? 'sponsorships_sync_partial_failure' : result.error,
          errorCategory: counters.failed > 0 ? 'partial_failure' : result.errorCategory,
          errorContext: result.errorContext,
        );
      } catch (e) {
        _logger.w('Sponsorships module sync-down step failed: $e');
        result = MobileSyncResult(
          success: false,
          recordsSynced: result.recordsSynced,
          recordsFailed: result.recordsFailed + 1,
          payloadCounters: result.payloadCounters,
          writeCounters: result.writeCounters,
          error: 'sponsorships_sync_down_failed: $e',
          errorCategory: _classifyError(e),
          errorContext: _extractErrorContext(e),
        );
      }
    }

    _updateStatus(
      _currentStatus.copyWith(
        isSyncing: false,
        currentOperation: result.success ? 'اكتملت المزامنة النهائية' : 'اكتملت المزامنة مع مشاكل',
        progress: 1.0,
        lastSyncAt: DateTime.now(),
        lastError: result.success ? null : result.error,
      ),
    );

    return result;
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
              if (_isServerDeletedRow(record)) {
                final deleted = await _deleteBeneficiaryFromServerRow(record);
                writeCounter.record('beneficiaries', deleted ? _WriteOutcome.updated : _WriteOutcome.skipped);
                await _yieldToUiIfNeeded(index + 1);
                continue;
              }

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
        if (_isServerDeletedRow(row)) {
          final deleted = await _deleteAttachmentFromServerRow(row);
          return deleted ? _WriteOutcome.updated : _WriteOutcome.skipped;
        }

        final localBeneficiaryId = await _resolveLocalBeneficiaryIdFromPayload(row, index: identityIndex);
        if (localBeneficiaryId == null) return _WriteOutcome.skipped;
        final outcome = await _relatedEntitiesRepository.upsertAttachment(
          row,
          localBeneficiaryId: localBeneficiaryId,
          sequence: index,
        );
        return _mapRelatedWriteOutcome(outcome);
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
        if (_isServerDeletedRow(row)) {
          final deleted = await _deleteFamilyMemberFromServerRow(row);
          return deleted ? _WriteOutcome.updated : _WriteOutcome.skipped;
        }

        final localBeneficiaryId = await _resolveLocalBeneficiaryIdFromPayload(row, index: identityIndex);
        if (localBeneficiaryId == null) return _WriteOutcome.skipped;
        final outcome = await _relatedEntitiesRepository.upsertFamilyMember(
          row,
          localBeneficiaryId: localBeneficiaryId,
        );
        return _mapRelatedWriteOutcome(outcome);
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
      listKeys: const ['dead_people', 'family_deceased', 'deceased', 'deceased_parents', 'records', 'items', 'data'],
      pageSize: pageSize,
      onRow: (row, _) async {
        if (_isServerDeletedRow(row)) {
          final deleted = await _deleteFamilyDeceasedFromServerRow(row);
          return deleted ? _WriteOutcome.updated : _WriteOutcome.skipped;
        }

        final localBeneficiaryId = await _resolveLocalBeneficiaryIdFromPayload(row, index: identityIndex);
        if (localBeneficiaryId == null) return _WriteOutcome.skipped;
        final outcome = await _relatedEntitiesRepository.upsertFamilyDeceased(
          row,
          localBeneficiaryId: localBeneficiaryId,
        );
        return _mapRelatedWriteOutcome(outcome);
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
    return _responseParser.parseRelatedRowsResponse(
      raw: raw,
      page: page,
      pageSize: pageSize,
      listKeys: listKeys,
    );
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
    return _responseParser.parseBeneficiariesResponse(raw, page, pageSize);
  }

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  Map<String, dynamic>? _toStringDynamicMap(dynamic value) {
    return _responseParser.toMap(value);
  }

  Future<void> _syncRelatedEntitiesForBeneficiary(
    Map<String, dynamic> beneficiary,
    int localBeneficiaryId,
    _EntityWriteCounter writeCounter,
  ) async {
    final nestedAttachments = _extractListOfMaps(
      beneficiary,
      const ['attachments', 'documents', 'files'],
    );
    for (var i = 0; i < nestedAttachments.length; i++) {
      if (_isServerDeletedRow(nestedAttachments[i])) {
        final deleted = await _deleteAttachmentFromServerRow(nestedAttachments[i]);
        writeCounter.record('attachments', deleted ? _WriteOutcome.updated : _WriteOutcome.skipped);
        continue;
      }

      final relatedOutcome = await _relatedEntitiesRepository.upsertAttachment(
        nestedAttachments[i],
        localBeneficiaryId: localBeneficiaryId,
        sequence: i,
      );
      final outcome = _mapRelatedWriteOutcome(relatedOutcome);
      writeCounter.record('attachments', outcome);
    }

    final nestedMembers = _extractListOfMaps(
      beneficiary,
      const ['family_members', 'members', 'orphans'],
    );
    for (var index = 0; index < nestedMembers.length; index++) {
      final member = nestedMembers[index];
      if (_isServerDeletedRow(member)) {
        final deleted = await _deleteFamilyMemberFromServerRow(member);
        writeCounter.record('family_members', deleted ? _WriteOutcome.updated : _WriteOutcome.skipped);
        await _yieldToUiIfNeeded(index + 1);
        continue;
      }

      final relatedOutcome = await _relatedEntitiesRepository.upsertFamilyMember(
        member,
        localBeneficiaryId: localBeneficiaryId,
      );
      final outcome = _mapRelatedWriteOutcome(relatedOutcome);
      writeCounter.record('family_members', outcome);

      await _yieldToUiIfNeeded(index + 1);
    }

    final nestedDeceased = _extractListOfMaps(
      beneficiary,
      const ['dead_people', 'family_deceased', 'deceased', 'deceased_parents'],
    );
    for (var index = 0; index < nestedDeceased.length; index++) {
      final deceased = nestedDeceased[index];
      if (_isServerDeletedRow(deceased)) {
        final deleted = await _deleteFamilyDeceasedFromServerRow(deceased);
        writeCounter.record('dead_people', deleted ? _WriteOutcome.updated : _WriteOutcome.skipped);
        await _yieldToUiIfNeeded(index + 1);
        continue;
      }

      final relatedOutcome = await _relatedEntitiesRepository.upsertFamilyDeceased(
        deceased,
        localBeneficiaryId: localBeneficiaryId,
      );
      final outcome = _mapRelatedWriteOutcome(relatedOutcome);
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
      if (_isServerDeletedRow(attachment)) {
        final deleted = await _deleteAttachmentFromServerRow(attachment);
        writeCounter.record('attachments', deleted ? _WriteOutcome.updated : _WriteOutcome.skipped);
        await _yieldToUiIfNeeded(i + 1);
        continue;
      }

      final localBeneficiaryId = await _resolveLocalBeneficiaryIdFromPayload(attachment, index: identityIndex);
      if (localBeneficiaryId != null) {
        final relatedOutcome = await _relatedEntitiesRepository.upsertAttachment(
          attachment,
          localBeneficiaryId: localBeneficiaryId,
          sequence: i,
        );
        final outcome = _mapRelatedWriteOutcome(relatedOutcome);
        writeCounter.record('attachments', outcome);
      } else {
        writeCounter.record('attachments', _WriteOutcome.skipped);
      }

      await _yieldToUiIfNeeded(i + 1);
    }

    for (var i = 0; i < pageResult.familyMembers.length; i++) {
      final member = pageResult.familyMembers[i];
      if (_isServerDeletedRow(member)) {
        final deleted = await _deleteFamilyMemberFromServerRow(member);
        writeCounter.record('family_members', deleted ? _WriteOutcome.updated : _WriteOutcome.skipped);
        await _yieldToUiIfNeeded(i + 1);
        continue;
      }

      final localBeneficiaryId = await _resolveLocalBeneficiaryIdFromPayload(member, index: identityIndex);
      if (localBeneficiaryId != null) {
        final relatedOutcome = await _relatedEntitiesRepository.upsertFamilyMember(
          member,
          localBeneficiaryId: localBeneficiaryId,
        );
        final outcome = _mapRelatedWriteOutcome(relatedOutcome);
        writeCounter.record('family_members', outcome);
      } else {
        writeCounter.record('family_members', _WriteOutcome.skipped);
      }

      await _yieldToUiIfNeeded(i + 1);
    }

    for (var i = 0; i < pageResult.familyDeceased.length; i++) {
      final deceased = pageResult.familyDeceased[i];
      if (_isServerDeletedRow(deceased)) {
        final deleted = await _deleteFamilyDeceasedFromServerRow(deceased);
        writeCounter.record('dead_people', deleted ? _WriteOutcome.updated : _WriteOutcome.skipped);
        await _yieldToUiIfNeeded(i + 1);
        continue;
      }

      final localBeneficiaryId = await _resolveLocalBeneficiaryIdFromPayload(deceased, index: identityIndex);
      if (localBeneficiaryId != null) {
        final relatedOutcome = await _relatedEntitiesRepository.upsertFamilyDeceased(
          deceased,
          localBeneficiaryId: localBeneficiaryId,
        );
        final outcome = _mapRelatedWriteOutcome(relatedOutcome);
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
    final upsert = await _beneficiaryRepository.upsertFromServerRecord(record);
    final outcome =
        upsert.outcome == SyncBeneficiaryWriteOutcome.updated ? _WriteOutcome.updated : _WriteOutcome.inserted;

    return (
      localBeneficiaryId: upsert.localBeneficiaryId,
      serverBeneficiaryId: upsert.serverBeneficiaryId,
      outcome: outcome,
    );
  }

  List<Map<String, dynamic>> _extractListOfMaps(
    Map<String, dynamic> source,
    List<String> keys,
  ) {
    return _responseParser.extractRelatedList(
      source,
      keys,
      normalizeDeceased: keys.contains('deceased_parents') ||
          keys.contains('dead_people') ||
          keys.contains('family_deceased') ||
          keys.contains('deceased'),
    );
  }

  int? _resolveServerBeneficiaryId(Map<String, dynamic> row) {
    return _beneficiaryRepository.resolveServerBeneficiaryId(row);
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

    final fileIdCandidate = _beneficiaryRepository.extractFileIdCandidate(row);
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

    final nationalId = _beneficiaryRepository.extractNationalIdCandidate(row);
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

    final fileId = _beneficiaryRepository.extractFileIdCandidate(row);
    if (fileId != null && fileId.isNotEmpty) {
      final byFile = index.byFileId(fileId);
      if (byFile != null) return byFile;
    }

    final nationalId = _beneficiaryRepository.extractNationalIdCandidate(row);
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

    final fileCandidate = _beneficiaryRepository.extractFileIdCandidate(beneficiaryRow);
    if (fileCandidate != null && fileCandidate.isNotEmpty) {
      index.registerFileId(fileCandidate, localBeneficiaryId);
    }

    final nationalCandidate = _beneficiaryRepository.extractNationalIdCandidate(beneficiaryRow);
    if (nationalCandidate != null && nationalCandidate.isNotEmpty) {
      index.registerNationalId(nationalCandidate, localBeneficiaryId);
    }
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

  bool _isServerDeletedRow(Map<String, dynamic> row) {
    final directDeleted = row['deleted_at'] ?? row['deletedAt'];
    if (_hasMeaningfulValue(directDeleted)) {
      return true;
    }

    final boolFlags = [
      row['is_deleted'],
      row['isDeleted'],
      row['sync_deleted'],
      row['syncDeleted'],
      row['deleted'],
    ];

    for (final flag in boolFlags) {
      if (flag is bool && flag) return true;
      final raw = flag?.toString().toLowerCase().trim();
      if (raw == '1' || raw == 'true' || raw == 'yes') return true;
    }

    final meta = _toStringDynamicMap(row['meta']);
    if (meta != null && _isServerDeletedRow(meta)) {
      return true;
    }

    return false;
  }

  Future<bool> _deleteBeneficiaryFromServerRow(Map<String, dynamic> row) async {
    return _beneficiaryRepository.deleteFromServerRow(row);
  }

  Future<bool> _deleteFamilyMemberFromServerRow(Map<String, dynamic> row) async {
    return _relatedEntitiesRepository.deleteFamilyMemberFromServerRow(row);
  }

  Future<bool> _deleteFamilyDeceasedFromServerRow(Map<String, dynamic> row) async {
    return _relatedEntitiesRepository.deleteFamilyDeceasedFromServerRow(row);
  }

  Future<bool> _deleteAttachmentFromServerRow(Map<String, dynamic> row) async {
    return _relatedEntitiesRepository.deleteAttachmentFromServerRow(row);
  }

  _WriteOutcome _mapRelatedWriteOutcome(SyncRelatedWriteOutcome outcome) {
    switch (outcome) {
      case SyncRelatedWriteOutcome.inserted:
        return _WriteOutcome.inserted;
      case SyncRelatedWriteOutcome.updated:
        return _WriteOutcome.updated;
      case SyncRelatedWriteOutcome.skipped:
        return _WriteOutcome.skipped;
    }
  }

  bool _hasMeaningfulValue(dynamic value) {
    if (value == null) return false;
    final raw = value.toString().trim().toLowerCase();
    if (raw.isEmpty) return false;
    if (raw == 'null' || raw == '0' || raw == 'false') return false;
    return true;
  }

  // ========================================================================
  // 🔼 BATCH SYNC UP - رفع التغييرات المحلية مجمعة
  // ========================================================================

  /// رفع المستفيدين المحليين للسيرفر باستخدام الـ Batch API
  Future<MobileSyncResult> syncUp() async {
    final flowResult = await _syncUpFlowUseCase.execute(
      runUnifiedBridge: () async {
        final result = await _runUnifiedSyncBridge();
        return SyncUnifiedBridgeOutcome(
          uploaded: result.uploaded,
          failed: result.failed,
          handledBeneficiaries: result.handledBeneficiaries,
          handledVisits: result.handledVisits,
        );
      },
      getDeviceId: _storage.getDeviceId,
      syncLegacyBeneficiaries: () async {
        final deviceId = await _storage.getDeviceId();
        return _syncLegacyBeneficiariesBatch(deviceId);
      },
      syncDeleteTombstones: () async {
        final deleteResult = await _tombstoneDeleteSyncUseCase.execute();
        return SyncStageCounters(
          uploaded: deleteResult.deletedCount,
          failed: deleteResult.failedCount,
        );
      },
      syncVisits: () async {
        final deviceId = await _storage.getDeviceId();
        final result = await _syncVisitsUp(deviceId);
        return SyncStageCounters(
          uploaded: result.recordsSynced,
          failed: result.recordsFailed,
        );
      },
      syncFamilyMembers: () async {
        final deviceId = await _storage.getDeviceId();
        final result = await _syncFamilyMembersUp(deviceId);
        return SyncStageCounters(
          uploaded: result.recordsSynced,
          failed: result.recordsFailed,
        );
      },
      syncDeadPeople: () async {
        final deviceId = await _storage.getDeviceId();
        final result = await _syncDeadPeopleUp(deviceId);
        return SyncStageCounters(
          uploaded: result.recordsSynced,
          failed: result.recordsFailed,
        );
      },
      syncAttachments: () async {
        final deviceId = await _storage.getDeviceId();
        final result = await _syncAttachmentsUp(deviceId);
        return SyncStageCounters(
          uploaded: result.recordsSynced,
          failed: result.recordsFailed,
        );
      },
      syncUsedFileIds: () async {
        if (_fileIdService == null) return;
        await _fileIdService.syncUsage();
      },
      onProgress: ({
        required String operation,
        required double progress,
        bool isSyncing = true,
        DateTime? lastSyncAt,
        String? lastError,
      }) {
        _updateStatus(
          _currentStatus.copyWith(
            isSyncing: isSyncing,
            currentOperation: operation,
            progress: progress,
            lastSyncAt: lastSyncAt,
            lastError: lastError,
          ),
        );
      },
      classifyError: _classifyError,
      extractErrorContext: _extractErrorContext,
    );
    final baseResult = _fromFlowResult(flowResult);

    if (_syncAssociationsModuleUseCase == null && _syncSponsorshipsModuleUseCase == null) {
      return baseResult;
    }

    var result = baseResult;

    if (_syncAssociationsModuleUseCase != null) {
      try {
        _updateStatus(
          _currentStatus.copyWith(
            isSyncing: true,
            currentOperation: 'جاري رفع مزامنة الجمعيات والموظفين... ',
            progress: 0.92,
          ),
        );

        final counters = await _syncAssociationsModuleUseCase.syncUp();

        final mergedPayload = Map<String, int>.from(result.payloadCounters)
          ..update(
            'associations_up',
            (value) => value + counters.uploaded,
            ifAbsent: () => counters.uploaded,
          );

        result = MobileSyncResult(
          success: result.success && counters.failed == 0,
          recordsSynced: result.recordsSynced + counters.uploaded,
          recordsFailed: result.recordsFailed + counters.failed,
          payloadCounters: mergedPayload,
          writeCounters: result.writeCounters,
          error: counters.failed > 0 ? 'associations_sync_up_partial_failure' : result.error,
          errorCategory: counters.failed > 0 ? 'partial_failure' : result.errorCategory,
          errorContext: result.errorContext,
        );
      } catch (e) {
        _logger.w('Associations module sync-up step failed: $e');
        result = MobileSyncResult(
          success: false,
          recordsSynced: result.recordsSynced,
          recordsFailed: result.recordsFailed + 1,
          payloadCounters: result.payloadCounters,
          writeCounters: result.writeCounters,
          error: 'associations_sync_up_failed: $e',
          errorCategory: _classifyError(e),
          errorContext: _extractErrorContext(e),
        );
      }
    }

    if (_syncSponsorshipsModuleUseCase != null) {
      try {
        _updateStatus(
          _currentStatus.copyWith(
            isSyncing: true,
            currentOperation: 'جاري رفع مزامنة الكفالات... ',
            progress: 0.96,
          ),
        );

        final counters = await _syncSponsorshipsModuleUseCase.syncUp();

        final mergedPayload = Map<String, int>.from(result.payloadCounters)
          ..update(
            'sponsorships_up',
            (value) => value + counters.uploaded,
            ifAbsent: () => counters.uploaded,
          );

        result = MobileSyncResult(
          success: result.success && counters.failed == 0,
          recordsSynced: result.recordsSynced + counters.uploaded,
          recordsFailed: result.recordsFailed + counters.failed,
          payloadCounters: mergedPayload,
          writeCounters: result.writeCounters,
          error: counters.failed > 0 ? 'sponsorships_sync_up_partial_failure' : result.error,
          errorCategory: counters.failed > 0 ? 'partial_failure' : result.errorCategory,
          errorContext: result.errorContext,
        );
      } catch (e) {
        _logger.w('Sponsorships module sync-up step failed: $e');
        result = MobileSyncResult(
          success: false,
          recordsSynced: result.recordsSynced,
          recordsFailed: result.recordsFailed + 1,
          payloadCounters: result.payloadCounters,
          writeCounters: result.writeCounters,
          error: 'sponsorships_sync_up_failed: $e',
          errorCategory: _classifyError(e),
          errorContext: _extractErrorContext(e),
        );
      }
    }

    _updateStatus(
      _currentStatus.copyWith(
        isSyncing: false,
        currentOperation: result.success ? 'اكتمل رفع المزامنة النهائية' : 'اكتمل رفع المزامنة مع مشاكل',
        progress: 1.0,
        lastSyncAt: DateTime.now(),
        lastError: result.success ? null : result.error,
      ),
    );

    return result;
  }

  Future<void> _syncTaxonomiesNonCritical() async {
    if (_taxonomyRepository == null) return;
    _logger.i('Syncing taxonomies...');
    try {
      await _taxonomyRepository.syncFromServer();
    } catch (e) {
      _logger.w('Taxonomy sync failed (non-critical): $e');
    }
  }

  Future<void> _ensureFileReservationNonCritical() async {
    if (_fileIdService == null) return;
    _logger.i('Checking file ID reservation...');
    try {
      await _fileIdService.ensureReservation();
    } catch (e) {
      _logger.w('File ID reservation failed (non-critical): $e');
    }
  }

  Future<SyncStageCounters> _syncLegacyBeneficiariesBatch(String deviceId) async {
    final localBeneficiaries = await (_db.select(_db.beneficiaries)
          ..where(
            (b) => b.syncState.equals('pending') | b.syncState.equals('modified'),
          ))
        .get();

    _logger.i('Found ${localBeneficiaries.length} beneficiaries to upload');
    if (localBeneficiaries.isEmpty) {
      return const SyncStageCounters();
    }

    int uploaded = 0;
    int failed = 0;
    const batchSize = ApiConfig.batchSize;

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
        final dataList = batch.map((b) => mapper.BeneficiaryMapper.toBackend(b)).toList();

        final response = await _dio.post(
          _normalizeApiEndpoint(ApiConfig.batchDataSyncEndpoint),
          data: {
            'records': dataList,
            'device_id': deviceId,
          },
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseMap = _toStringDynamicMap(response.data) ?? const <String, dynamic>{};
          final responseDataNode = _toStringDynamicMap(responseMap['data']) ?? const <String, dynamic>{};

          final created = _extractIntList(
            responseDataNode['created'] ?? responseMap['created'],
          );
          final updated = _extractIntList(
            responseDataNode['updated'] ?? responseMap['updated'],
          );
          final successfulFileIds = <int>{...created, ...updated};

          final failedExplicit = _asInt(
            responseDataNode['failed_count'] ?? responseMap['failed_count'],
          );

          final localIdByFileId = <int, int>{};
          for (final row in batch) {
            final fileId = int.tryParse((row.fileIdNumber ?? '').trim());
            if (fileId != null) {
              localIdByFileId[fileId] = row.id;
            }
          }

          if (successfulFileIds.isNotEmpty) {
            final successLocalIds =
                successfulFileIds.map((fileId) => localIdByFileId[fileId]).whereType<int>().toList(growable: false);

            if (successLocalIds.isNotEmpty) {
              await (_db.update(_db.beneficiaries)..where((b) => b.id.isIn(successLocalIds))).write(
                BeneficiariesCompanion(
                  syncState: const drift.Value('synced'),
                  lastSyncedAt: drift.Value(DateTime.now()),
                ),
              );
            }

            uploaded += successLocalIds.length;
            failed += failedExplicit ?? (batch.length - successLocalIds.length).clamp(0, batch.length);
            _logger.i(
                '✅ Synced beneficiaries batch: success=${successLocalIds.length}, failed=${failedExplicit ?? (batch.length - successLocalIds.length)}');
          } else if ((failedExplicit ?? 0) == 0) {
            final ids = batch.map((b) => b.id).toList(growable: false);
            await (_db.update(_db.beneficiaries)..where((b) => b.id.isIn(ids))).write(
              BeneficiariesCompanion(
                syncState: const drift.Value('synced'),
                lastSyncedAt: drift.Value(DateTime.now()),
              ),
            );

            uploaded += batch.length;
            _logger.i('✅ Synced batch of ${batch.length} records');
          } else {
            failed += failedExplicit!;
            _logger.w('❌ Sync batch partially failed: failed_count=$failedExplicit');
          }
        } else {
          failed += batch.length;
          _logger.w('❌ Sync batch failed: ${response.data}');
        }
      } catch (e) {
        failed += batch.length;
        _logger.e('Error syncing batch', error: e);
      }
    }

    return SyncStageCounters(uploaded: uploaded, failed: failed);
  }

  SyncFlowResult _toFlowResult(MobileSyncResult result) {
    return SyncFlowResult(
      success: result.success,
      recordsSynced: result.recordsSynced,
      recordsFailed: result.recordsFailed,
      payloadCounters: result.payloadCounters,
      writeCounters: result.writeCounters,
      error: result.error,
      errorCategory: result.errorCategory,
      errorContext: result.errorContext,
    );
  }

  MobileSyncResult _fromFlowResult(SyncFlowResult result) {
    return MobileSyncResult(
      success: result.success,
      recordsSynced: result.recordsSynced,
      recordsFailed: result.recordsFailed,
      payloadCounters: result.payloadCounters,
      writeCounters: result.writeCounters,
      error: result.error,
      errorCategory: result.errorCategory,
      errorContext: result.errorContext,
    );
  }

  Future<_UnifiedSyncBridgeResult> _runUnifiedSyncBridge() async {
    final repository = _syncRepository;
    if (repository == null) {
      return const _UnifiedSyncBridgeResult();
    }

    int uploaded = 0;
    int failed = 0;
    bool handledBeneficiaries = false;
    bool handledVisits = false;

    final pendingBeneficiaryRows = await (_db.select(_db.beneficiaries)
          ..where(
            (b) => b.syncState.equals('pending') | b.syncState.equals('modified'),
          )
          ..limit(1))
        .get();

    final pendingVisitRows = await _db.visitsDao.getPendingVisits();

    final queueBeneficiaries = await repository.getPendingChangesCount('beneficiaries');
    final queueVisits = await repository.getPendingChangesCount('visits');

    if (pendingBeneficiaryRows.isEmpty && queueBeneficiaries > 0) {
      handledBeneficiaries = true;
      final result = await repository.pushChanges('beneficiaries');
      final counters = _toCounters(result, fallbackFailureCount: queueBeneficiaries);
      uploaded += counters.$1;
      failed += counters.$2;
    }

    if (pendingVisitRows.isEmpty && queueVisits > 0) {
      handledVisits = true;
      final result = await repository.pushChanges('visits');
      final counters = _toCounters(result, fallbackFailureCount: queueVisits);
      uploaded += counters.$1;
      failed += counters.$2;
    }

    return _UnifiedSyncBridgeResult(
      uploaded: uploaded,
      failed: failed,
      handledBeneficiaries: handledBeneficiaries,
      handledVisits: handledVisits,
    );
  }

  (int, int) _toCounters(SyncResult result, {required int fallbackFailureCount}) {
    if (result is SyncSuccess) {
      return (result.itemsSynced, 0);
    }
    if (result is SyncPartial) {
      return (result.successCount, result.failureCount);
    }
    return (0, fallbackFailureCount);
  }

  /// مزامنة المرفقات محلية الرفع للسيرفر
  Future<MobileSyncResult> _syncAttachmentsUp(String deviceId) async {
    final counters = await _syncRelatedEntitiesUpUseCase.syncAttachments(deviceId);
    return MobileSyncResult(
      success: counters.failed == 0,
      recordsSynced: counters.uploaded,
      recordsFailed: counters.failed,
    );
  }

  Future<MobileSyncResult> _syncFamilyMembersUp(String deviceId) async {
    final counters = await _syncRelatedEntitiesUpUseCase.syncFamilyMembers(deviceId);
    return MobileSyncResult(
      success: counters.failed == 0,
      recordsSynced: counters.uploaded,
      recordsFailed: counters.failed,
    );
  }

  Future<MobileSyncResult> _syncDeadPeopleUp(String deviceId) async {
    final counters = await _syncRelatedEntitiesUpUseCase.syncDeadPeople(deviceId);
    return MobileSyncResult(
      success: counters.failed == 0,
      recordsSynced: counters.uploaded,
      recordsFailed: counters.failed,
    );
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
    _operationEventsController.close();
  }

  String _normalizeApiEndpoint(String endpoint) {
    return sync_endpoint.normalizeApiEndpoint(
      endpoint: endpoint,
      baseUrl: _dio.options.baseUrl,
    );
  }

  List<int> _extractIntList(dynamic value) {
    if (value is! List) return const <int>[];
    return value.map((e) => _asInt(e)).whereType<int>().toList(growable: false);
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

class _UnifiedSyncBridgeResult {
  final int uploaded;
  final int failed;
  final bool handledBeneficiaries;
  final bool handledVisits;

  const _UnifiedSyncBridgeResult({
    this.uploaded = 0,
    this.failed = 0,
    this.handledBeneficiaries = false,
    this.handledVisits = false,
  });
}

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
