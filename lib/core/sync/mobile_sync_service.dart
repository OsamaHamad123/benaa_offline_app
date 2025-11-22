import 'dart:async';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as drift;
import 'package:logger/logger.dart';

import '../../data/db/drift_database.dart';
import '../mappers/beneficiary_sync_mapper.dart' as mapper;

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
  final Logger _logger = Logger();

  // Sync state
  final _statusController = StreamController<MobileSyncStatus>.broadcast();
  MobileSyncStatus _currentStatus = MobileSyncStatus();

  MobileSyncService(this._db, {Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://palestine.benaadev.org',
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
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
      );
    }
  }

  /// مزامنة المستفيدين - تنزيل
  Future<MobileSyncResult> _syncBeneficiariesDown() async {
    int totalSynced = 0;
    int page = 1;
    const pageSize = 100; // Use pagination

    try {
      while (true) {
        // Fetch page using correct endpoint from Postman collection
        final endpoint = '/api/mobile-sync/table/sy_benaa_application';
        final fullUrl = '${_dio.options.baseUrl}$endpoint';

        _logger.i('Fetching page $page from: $fullUrl');

        final response = await _dio.get(
          endpoint,
          queryParameters: {
            'page': page,
            'per_page': pageSize,
            'order_by': 'id',
            'order_direction': 'ASC',
          },
        );

        _logger.i('✅ Response status: ${response.statusCode}');

        if (response.statusCode != 200) {
          throw Exception('HTTP ${response.statusCode}: ${response.data}');
        }

        final data = response.data as Map<String, dynamic>;
        final records = data['data'] as List<dynamic>;

        _logger.i('Received ${records.length} records on page $page');

        if (records.isEmpty) break;

        // Save to local database
        for (final record in records) {
          try {
            final companion = mapper.BeneficiaryMapper.fromBackend(
              record as Map<String, dynamic>,
            );

            // Check if exists by serverId
            final serverIdRaw = record['id'];
            final serverId = serverIdRaw is int
                ? serverIdRaw
                : (serverIdRaw != null
                      ? int.tryParse(serverIdRaw.toString())
                      : null);
            if (serverId != null) {
              final existing = await (_db.select(
                _db.beneficiaries,
              )..where((b) => b.serverId.equals(serverId))).getSingleOrNull();

              if (existing != null) {
                // Update existing
                await (_db.update(
                  _db.beneficiaries,
                )..where((b) => b.id.equals(existing.id))).write(companion);
              } else {
                // Insert new
                await _db.into(_db.beneficiaries).insert(companion);
              }
            } else {
              // No serverId, just insert
              await _db.into(_db.beneficiaries).insert(companion);
            }

            totalSynced++;
          } catch (e) {
            _logger.w('Failed to sync record ${record['id']}: $e');
            // Continue with next record
          }
        }

        _logger.i('Page $page: ${records.length} records');

        // Check if more pages
        final pagination = data['pagination'] as Map<String, dynamic>?;
        if (pagination == null ||
            pagination['current_page'] == pagination['last_page']) {
          break;
        }

        page++;
      }

      return MobileSyncResult(success: true, recordsSynced: totalSynced);
    } catch (e, stack) {
      _logger.e('Beneficiaries sync down failed', error: e, stackTrace: stack);
      return MobileSyncResult(
        success: false,
        recordsSynced: totalSynced,
        error: e.toString(),
      );
    }
  }

  // ========================================================================
  // 🔼 SYNC UP - رفع التغييرات المحلية للسيرفر
  // ========================================================================

  /// رفع المستفيدين المحليين للسيرفر
  Future<MobileSyncResult> syncUp() async {
    _updateStatus(
      _currentStatus.copyWith(
        isSyncing: true,
        currentOperation: 'جاري رفع التغييرات للسيرفر...',
        progress: 0.0,
      ),
    );

    try {
      // Get local beneficiaries that need sync (pending or modified)
      final localBeneficiaries =
          await (_db.select(_db.beneficiaries)..where(
                (b) =>
                    b.syncState.equals('pending') |
                    b.syncState.equals('modified'),
              ))
              .get();

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

      int uploaded = 0;
      int failed = 0;

      for (int i = 0; i < localBeneficiaries.length; i++) {
        final beneficiary = localBeneficiaries[i];

        _updateStatus(
          _currentStatus.copyWith(
            currentOperation: 'رفع ${i + 1}/${localBeneficiaries.length}...',
            progress: (i + 1) / localBeneficiaries.length,
          ),
        );

        try {
          // Convert to backend format
          final backendData = mapper.BeneficiaryMapper.toBackend(beneficiary);

          // Check if needs update or create
          if (beneficiary.serverId != null) {
            // Update existing record using correct endpoint
            final response = await _dio.put(
              '/api/mobile-sync/table/sy_benaa_application/${beneficiary.serverId}',
              data: backendData,
            );

            if (response.statusCode == 200) {
              // Mark as synced
              await (_db.update(
                _db.beneficiaries,
              )..where((b) => b.id.equals(beneficiary.id))).write(
                BeneficiariesCompanion(
                  syncState: const drift.Value('synced'),
                  lastSyncedAt: drift.Value(DateTime.now()),
                ),
              );
              uploaded++;
              _logger.i(
                '✅ Updated beneficiary ${beneficiary.id} (serverId: ${beneficiary.serverId})',
              );
            } else {
              failed++;
              _logger.w('Failed to update ${beneficiary.id}: ${response.data}');
            }
          } else {
            // Create new record using correct endpoint
            final response = await _dio.post(
              '/api/mobile-sync/table/sy_benaa_application',
              data: backendData,
            );

            if (response.statusCode == 201 || response.statusCode == 200) {
              final responseData = response.data as Map<String, dynamic>;

              // API returns {success: true, message: "...", id: X}
              final serverIdRaw = responseData['id'];
              final serverId = serverIdRaw is int
                  ? serverIdRaw
                  : (serverIdRaw != null
                        ? int.tryParse(serverIdRaw.toString())
                        : null);

              // Update with serverId and mark as synced
              await (_db.update(
                _db.beneficiaries,
              )..where((b) => b.id.equals(beneficiary.id))).write(
                BeneficiariesCompanion(
                  serverId: drift.Value(serverId),
                  syncState: const drift.Value('synced'),
                  lastSyncedAt: drift.Value(DateTime.now()),
                ),
              );
              uploaded++;
              _logger.i(
                '✅ Created beneficiary ${beneficiary.id} with serverId $serverId',
              );
            } else {
              failed++;
              _logger.w('Failed to create ${beneficiary.id}: ${response.data}');
            }
          }
        } catch (e) {
          failed++;

          // Check if it's a 404 error (endpoint not available)
          if (e.toString().contains('404')) {
            _logger.w(
              '⚠️ Sync endpoint not available on server (404) - beneficiary ${beneficiary.id} not uploaded',
            );
          } else {
            _logger.w('Error uploading ${beneficiary.id}: $e');
          }
        }
      }

      _updateStatus(
        _currentStatus.copyWith(
          isSyncing: false,
          currentOperation: failed > 0
              ? 'تم رفع $uploaded سجل (فشل $failed - السيرفر لا يدعم الرفع حالياً)'
              : 'تم رفع $uploaded سجل بنجاح ✓',
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

      _updateStatus(
        _currentStatus.copyWith(isSyncing: false, lastError: e.toString()),
      );

      return MobileSyncResult(
        success: false,
        recordsSynced: 0,
        error: e.toString(),
      );
    }
  }

  // ========================================================================
  // 📊 CLEANUP
  // ========================================================================

  /// Dispose
  void dispose() {
    _statusController.close();
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

  MobileSyncResult({
    required this.success,
    required this.recordsSynced,
    this.recordsFailed = 0,
    this.error,
  });
}
