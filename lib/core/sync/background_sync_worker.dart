import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/db/drift_database.dart';
import '../storage/secure_storage.dart';
import '../notifications/notifications_service.dart';
import 'mobile_sync_service.dart';
import '../../features/civil_db_download/data/datasources/database_download_service.dart';
import '../../features/civil_db_download/domain/entities/download_progress.dart';
import '../../features/civil_db_download/presentation/pages/config/download_config.dart';
import '../utils/debug_logger.dart';

/// 🔄 Background Sync Worker - Smart Background Synchronization
///
/// Features:
/// - Runs every 15 minutes (configurable)
/// - WiFi-only constraint (configurable)
/// - Battery-aware (>15%)
/// - Exponential backoff on failures
/// - Priority-based queue processing
class BackgroundSyncWorker {
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
  static const String _downloadUrlInputKey = 'download_url';

  // Configuration
  static const Duration syncInterval = Duration(minutes: 15);
  static const bool requireWifi = false; // Set to true for WiFi-only

  /// Initialize Background Sync
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );

    // Register periodic sync task
    await registerPeriodicSync();

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
      'manual_sync_${DateTime.now().millisecondsSinceEpoch}',
      oneOffFullSyncTaskName,
      constraints: Constraints(networkType: NetworkType.connected),
      initialDelay: Duration.zero,
    );

    DebugLogger.info('🚀 Manual sync triggered');
  }

  static Future<void> triggerSyncDown() async {
    await Workmanager().registerOneOffTask(
      'sync_down_${DateTime.now().millisecondsSinceEpoch}',
      oneOffSyncDownTaskName,
      constraints: Constraints(networkType: NetworkType.connected),
      initialDelay: Duration.zero,
    );
  }

  static Future<void> triggerSyncUp() async {
    await Workmanager().registerOneOffTask(
      'sync_up_${DateTime.now().millisecondsSinceEpoch}',
      oneOffSyncUpTaskName,
      constraints: Constraints(networkType: NetworkType.connected),
      initialDelay: Duration.zero,
    );
  }

  static Future<void> triggerCivilDbDownload({String? downloadUrl}) async {
    await Workmanager().registerOneOffTask(
      'civil_download_${DateTime.now().millisecondsSinceEpoch}',
      oneOffDbDownloadTaskName,
      constraints: Constraints(networkType: NetworkType.connected),
      initialDelay: Duration.zero,
      inputData: {
        _downloadUrlInputKey:
            (downloadUrl == null || downloadUrl.trim().isEmpty) ? DownloadConfig.downloadUrl : downloadUrl.trim(),
      },
    );
  }

  /// Check if sync should run
  static Future<bool> shouldRunSync() async {
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
      DebugLogger.info('🔄 Background sync started: $task');

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
      final syncService = MobileSyncService(db, SecureStorage());

      try {
        if (task == BackgroundSyncWorker.oneOffSyncDownTaskName) {
          final result = await syncService.syncDown();
          return Future.value(result.success);
        }
        if (task == BackgroundSyncWorker.oneOffSyncUpTaskName) {
          final result = await syncService.syncUp();
          return Future.value(result.success);
        }

        final down = await syncService.syncDown();
        final up = await syncService.syncUp();
        return Future.value(down.success && up.success);
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
