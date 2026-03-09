import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../../data/db/drift_database.dart';
import '../storage/secure_storage.dart';
import '../notifications/notifications_service.dart';
import 'mobile_sync_service.dart';
import 'sync_result_snapshot_store.dart';
import '../../features/civil_db_download/data/datasources/database_download_service.dart';
import '../../features/civil_db_download/domain/entities/download_progress.dart';
import '../../features/civil_db_download/presentation/pages/config/download_config.dart';
import '../../features/sync/services/file_id_service.dart';
import '../../features/sync/data/datasources/file_id_remote_datasource.dart';
import '../../features/sync/data/repositories/file_id_reservation_repository_impl.dart';
import '../../features/taxonomies/data/datasources/taxonomy_remote_datasource.dart';
import '../../features/taxonomies/data/datasources/taxonomy_local_drift_datasource.dart';
import '../../features/taxonomies/data/repositories/taxonomy_repository_impl.dart';
import '../../features/sync/domain/usecases/sync_associations_module_usecase.dart';
import '../../features/associations/data/datasources/associations_remote_sync_datasource.dart';
import '../../features/sync/domain/usecases/sync_sponsorships_module_usecase.dart';
import '../../features/kafalat/data/datasources/sponsorships_remote_sync_datasource.dart';
import '../utils/debug_logger.dart';
import 'sync_history_store.dart';

/// 🔄 Background Sync Worker - Smart Background Synchronization
///
/// Features:
/// - Runs every 15 minutes (configurable)
/// - WiFi-only constraint (configurable)
/// - Battery-aware (>15%)
/// - Exponential backoff on failures
/// - Priority-based queue processing
class BackgroundSyncWorker {
  static const String syncCodeVersion = 'sync-fix-2026-02-27-v3';

  @Deprecated('Use periodicSyncTaskName instead')
  static const String syncTaskName = 'benaa_sync_task';
  @Deprecated('Legacy tag kept for compatibility')
  static const String syncTaskTag = 'sync';
  @Deprecated('Legacy config kept for compatibility')
  static const int batteryThreshold = 15;

  static const String periodicSyncTaskName = 'benaa_periodic_sync_task';
  static const String periodicSyncUniqueName = 'benaa_periodic_sync_unique';
  static const String oneOffSyncDownTaskName = 'benaa_sync_down_task';
  static const String oneOffSyncUpTaskName = 'benaa_sync_up_task';
  static const String oneOffFullSyncTaskName = 'benaa_sync_full_task';
  static const String oneOffDbDownloadTaskName = 'benaa_civil_db_download_task';
  static const String oneOffSyncDownUniqueName = 'benaa_sync_down_unique';
  static const String oneOffSyncUpUniqueName = 'benaa_sync_up_unique';
  static const String oneOffFullSyncUniqueName = 'benaa_sync_full_unique';
  static const String oneOffDbDownloadUniqueName = 'benaa_civil_db_download_unique';
  static const String _downloadUrlInputKey = 'download_url';

  // Configuration
  static const Duration syncInterval = Duration(minutes: 15);
  static const bool requireWifi = false; // Set to true for WiFi-only
  static bool _initialized = false;

  static bool _shouldRetrySyncResult(MobileSyncResult result) {
    if (result.success) return false;

    final category = (result.errorCategory ?? '').toLowerCase();
    if (category == 'validation' ||
        category == 'partial_failure' ||
        category == 'parser' ||
        category == 'db' ||
        category == 'auth' ||
        category == 'route') {
      return false;
    }

    if (category == 'network' || category == 'server') {
      return true;
    }

    if (category == 'local_lock') {
      return false;
    }

    final errorText = (result.error ?? '').toLowerCase();
    if (errorText.contains('timeout') || errorText.contains('connection') || errorText.contains('socket')) {
      return true;
    }

    return false;
  }

  static bool _shouldStopFullSyncAfterDownFailure(MobileSyncResult result) {
    if (result.success) return false;

    final category = (result.errorCategory ?? '').toLowerCase();
    if (category == 'network' || category == 'server' || category == 'partial_failure') {
      return false;
    }

    return true;
  }

  static Future<void> _recordSyncArtifacts({
    required String operation,
    required MobileSyncResult result,
    required String source,
  }) async {
    await SyncResultSnapshotStore.save(
      SyncResultSnapshot.fromMobileResult(operation: operation, source: source, result: result),
    );

    await SyncHistoryStore.addEntry(
      SyncHistoryEntrySnapshot(
        timestamp: DateTime.now(),
        success: result.success,
        operation: operation,
        source: source,
        message: result.error,
        uploadedCount: operation == 'sync_up' ? result.recordsSynced : null,
        downloadedCount: operation == 'sync_down' ? result.recordsSynced : null,
        errorCategory: result.errorCategory,
      ),
    );
  }

  /// Initialize Background Sync
  static Future<void> initialize() async {
    if (_initialized) {
      DebugLogger.info('ℹ️ Background Sync Worker already initialized in this process');
      return;
    }

    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );

    // Register periodic sync task
    await registerPeriodicSync();
    _initialized = true;

    DebugLogger.success('✅ Background Sync Worker initialized');
  }

  /// Register Periodic Sync Task
  static Future<void> registerPeriodicSync() async {
    await Workmanager().registerPeriodicTask(
      periodicSyncUniqueName,
      periodicSyncTaskName,
      frequency: syncInterval,
      constraints: Constraints(
        networkType: requireWifi ? NetworkType.unmetered : NetworkType.connected,
        requiresBatteryNotLow: true,
        requiresCharging: false,
      ),
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 5),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      initialDelay: const Duration(seconds: 30), // First run after 30s
    );

    DebugLogger.info(
      '⏰ Periodic sync registered: every ${syncInterval.inMinutes} minutes',
    );
  }

  /// Cancel Background Sync
  static Future<void> cancel() async {
    await Workmanager().cancelByUniqueName(periodicSyncUniqueName);
    DebugLogger.info('❌ Background sync cancelled');
  }

  /// Trigger Manual Sync (One-time)
  static Future<void> triggerManualSync() async {
    await Workmanager().registerOneOffTask(
      oneOffFullSyncUniqueName,
      oneOffFullSyncTaskName,
      constraints: Constraints(networkType: NetworkType.connected),
      initialDelay: Duration.zero,
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );

    DebugLogger.info('🚀 Manual sync triggered');
  }

  static Future<void> triggerSyncDown() async {
    await Workmanager().registerOneOffTask(
      oneOffSyncDownUniqueName,
      oneOffSyncDownTaskName,
      constraints: Constraints(networkType: NetworkType.connected),
      initialDelay: Duration.zero,
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );
  }

  static Future<void> triggerSyncUp() async {
    await Workmanager().registerOneOffTask(
      oneOffSyncUpUniqueName,
      oneOffSyncUpTaskName,
      constraints: Constraints(networkType: NetworkType.connected),
      initialDelay: Duration.zero,
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );
  }

  static Future<void> triggerCivilDbDownload({String? downloadUrl}) async {
    await Workmanager().registerOneOffTask(
      oneOffDbDownloadUniqueName,
      oneOffDbDownloadTaskName,
      constraints: Constraints(networkType: NetworkType.connected),
      initialDelay: Duration.zero,
      existingWorkPolicy: ExistingWorkPolicy.replace,
      inputData: {
        _downloadUrlInputKey:
            (downloadUrl == null || downloadUrl.trim().isEmpty) ? DownloadConfig.downloadUrl : downloadUrl.trim(),
      },
    );
  }

  /// Check if sync should run
  static Future<bool> shouldRunSync() async {
    final lockActive = await SecureStorage().isSyncLockActive();
    if (lockActive) {
      DebugLogger.info('⏸️ Sync lock is active - skipping background sync run');
      return false;
    }

    // Check connectivity
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      DebugLogger.warning('⚠️ No internet connection - skipping sync');
      return false;
    }

    // Check if WiFi-only and not on WiFi
    if (requireWifi && !connectivity.contains(ConnectivityResult.wifi)) {
      DebugLogger.info('📶 Waiting for WiFi connection');
      return false;
    }

    return true;
  }
}

/// Background Task Dispatcher
/// This function runs in isolate - keep it top-level
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      DebugLogger.info('🔄 Background sync started: $task (code=${BackgroundSyncWorker.syncCodeVersion})');

      if (task == BackgroundSyncWorker.oneOffDbDownloadTaskName) {
        final downloadService = DatabaseDownloadService();
        final url = (inputData?[BackgroundSyncWorker._downloadUrlInputKey] as String?) ?? DownloadConfig.downloadUrl;

        await downloadService.downloadDatabase(
          downloadUrl: url,
          onProgress: (progress) {
            if (progress.status == DownloadStatus.completed) {
              unawaited(NotificationsService.showCivilDbDownloadCompleted());
              return;
            }
            if (progress.status == DownloadStatus.failed) {
              unawaited(
                NotificationsService.showCivilDbDownloadFailed(
                  progress.errorMessage ?? 'حدث خطأ أثناء تنزيل السجل المدني في الخلفية.',
                ),
              );
              return;
            }
            if (progress.status == DownloadStatus.cancelled) {
              unawaited(NotificationsService.showCivilDbDownloadCancelled());
              return;
            }
            unawaited(
              NotificationsService.showCivilDbDownloadProgress(
                percentage: progress.percentage,
                subtitle: progress.status == DownloadStatus.downloading
                    ? '${progress.downloadedSize} / ${progress.totalSize}'
                    : (progress.status == DownloadStatus.extracting
                        ? 'جاري فك ضغط الملف...'
                        : 'جاري التحقق من سلامة قاعدة البيانات...'),
              ),
            );
          },
        );

        return Future.value(true);
      }

      final shouldRun = await BackgroundSyncWorker.shouldRunSync();
      if (!shouldRun) {
        return Future.value(true); // Success but skipped
      }

      final db = AppDatabase(openEncryptedDb());
      final secureStorage = SecureStorage();
      final dio = Dio(
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

      final fileIdRemote = FileIdRemoteDataSourceImpl(dio, secureStorage: secureStorage);
      final fileIdRepository = FileIdReservationRepositoryImpl(
        remoteDataSource: fileIdRemote,
        localDao: db.fileIdReservationDao,
      );
      final fileIdService = FileIdService(fileIdRepository);

      final taxonomyRepository = TaxonomyRepositoryImpl(
        remoteDataSource: TaxonomyRemoteDataSourceImpl(dio),
        localDataSource: TaxonomyLocalDriftDataSource(db.taxonomiesDao, db.syncMetadataDao),
      );

      final syncAssociationsModuleUseCase = SyncAssociationsModuleUseCase(
        database: db,
        remote: AssociationsRemoteSyncDataSource(dio),
      );

      final syncSponsorshipsModuleUseCase = SyncSponsorshipsModuleUseCase(
        database: db,
        remote: SponsorshipsRemoteSyncDataSource(dio),
      );

      final syncService = MobileSyncService(
        db,
        secureStorage,
        dio: dio,
        fileIdService: fileIdService,
        taxonomyRepository: taxonomyRepository,
        syncAssociationsModuleUseCase: syncAssociationsModuleUseCase,
        syncSponsorshipsModuleUseCase: syncSponsorshipsModuleUseCase,
      );

      try {
        if (task == BackgroundSyncWorker.oneOffSyncDownTaskName) {
          final result = await syncService.syncDown();
          await BackgroundSyncWorker._recordSyncArtifacts(
            operation: 'sync_down',
            result: result,
            source: 'background',
          );
          final shouldRetry = BackgroundSyncWorker._shouldRetrySyncResult(result);
          DebugLogger.info(
            'Background syncDown decision: shouldRetry=$shouldRetry '
            'success=${result.success} category=${result.errorCategory} error=${result.error}',
          );
          return Future.value(!shouldRetry);
        }
        if (task == BackgroundSyncWorker.oneOffSyncUpTaskName) {
          final result = await syncService.syncUp();
          await BackgroundSyncWorker._recordSyncArtifacts(
            operation: 'sync_up',
            result: result,
            source: 'background',
          );
          final shouldRetry = BackgroundSyncWorker._shouldRetrySyncResult(result);
          DebugLogger.info(
            'Background syncUp decision: shouldRetry=$shouldRetry '
            'success=${result.success} category=${result.errorCategory} error=${result.error}',
          );
          return Future.value(!shouldRetry);
        }

        final down = await syncService.syncDown();
        await BackgroundSyncWorker._recordSyncArtifacts(
          operation: 'sync_down',
          result: down,
          source: 'background',
        );

        if (BackgroundSyncWorker._shouldStopFullSyncAfterDownFailure(down)) {
          final shouldRetry = BackgroundSyncWorker._shouldRetrySyncResult(down);
          DebugLogger.info(
            'Background full-sync short-circuit after syncDown failure: '
            'shouldRetry=$shouldRetry category=${down.errorCategory} error=${down.error}',
          );
          return Future.value(!shouldRetry);
        }

        final up = await syncService.syncUp();
        await BackgroundSyncWorker._recordSyncArtifacts(
          operation: 'sync_up',
          result: up,
          source: 'background',
        );
        final shouldRetry =
            BackgroundSyncWorker._shouldRetrySyncResult(down) || BackgroundSyncWorker._shouldRetrySyncResult(up);
        return Future.value(!shouldRetry);
      } finally {
        syncService.dispose();
        await db.close();
      }
    } catch (e) {
      DebugLogger.error('❌ Background sync failed', e);
      return Future.value(false); // Will trigger backoff retry
    }
  });
}

/// Sync Status Notifier - For UI updates
class SyncStatusNotifier extends ChangeNotifier {
  bool _isSyncing = false;
  String? _error;
  DateTime? _lastSyncTime;
  int _pendingItems = 0;

  bool get isSyncing => _isSyncing;
  String? get error => _error;
  DateTime? get lastSyncTime => _lastSyncTime;
  int get pendingItems => _pendingItems;

  String get statusText {
    if (_isSyncing) return 'جاري المزامنة...';
    if (_error != null) return 'فشلت المزامنة';
    if (_lastSyncTime == null) return 'لم تتم المزامنة بعد';

    final diff = DateTime.now().difference(_lastSyncTime!);
    if (diff.inMinutes < 1) return 'تمت المزامنة الآن';
    if (diff.inMinutes < 60) return 'تمت المزامنة منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'تمت المزامنة منذ ${diff.inHours} ساعة';
    return 'تمت المزامنة منذ ${diff.inDays} يوم';
  }

  void startSync() {
    _isSyncing = true;
    _error = null;
    notifyListeners();
  }

  void completeSync({int? pendingItems}) {
    _isSyncing = false;
    _lastSyncTime = DateTime.now();
    _pendingItems = pendingItems ?? 0;
    _error = null;
    notifyListeners();
  }

  void failSync(String error) {
    _isSyncing = false;
    _error = error;
    notifyListeners();
  }

  void updatePendingItems(int count) {
    _pendingItems = count;
    notifyListeners();
  }
}
