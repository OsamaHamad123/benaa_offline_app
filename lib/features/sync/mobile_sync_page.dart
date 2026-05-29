import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/providers/providers.dart';
import '../../core/backend/backend_config.dart';
import '../../core/sync/mobile_sync_service.dart';
import '../../core/sync/background_sync_worker.dart';
import '../../core/analytics/ux_flow_analytics.dart';
import '../../core/analytics/ux_feature_flags.dart';
import '../../core/widgets/modern_sliver_app_bar.dart';
import 'presentation/widgets/sync_section_card.dart';
import 'presentation/widgets/sync_status_banner.dart';
import 'presentation/widgets/sync_ui_tokens.dart';
import 'presentation/widgets/sync_history_viewer.dart';
import 'presentation/viewmodels/mobile_sync_dashboard_loader.dart';
import '../../core/error_handling/error_handler.dart';
import '../taxonomies/presentation/providers/taxonomy_providers.dart';
import '../taxonomies/domain/entities/taxonomy.dart';
import '../taxonomies/domain/entities/taxonomy_group.dart';
import '../taxonomies/domain/contracts/beneficiary_taxonomy_contract.dart';
import '../taxonomies/domain/services/taxonomy_integrity_guard.dart';
import '../associations/presentation/providers/associations_provider.dart';
import '../kafalat/presentation/providers/kafalat_providers.dart';
import 'presentation/providers/file_id_providers.dart';
import 'presentation/providers/mobile_sync_operations_providers.dart';
import 'presentation/providers/sync_progress_providers.dart';
import 'domain/repositories/file_id_reservation_repository.dart';
import 'services/firebase_beneficiary_upload_service.dart';
import '../dashboard/presentation/providers/dashboard_providers.dart';
import '../dashboard/presentation/providers.dart' show dashboardProvider;

/// ========================================================================
/// 📱 Mobile Sync Page - صفحة مزامنة البيانات مع Mobile API
/// ========================================================================

class MobileSyncPage extends ConsumerStatefulWidget {
  const MobileSyncPage({super.key});

  @override
  ConsumerState<MobileSyncPage> createState() => _MobileSyncPageState();
}

class _MobileSyncPageState extends ConsumerState<MobileSyncPage> with WidgetsBindingObserver {
  static const String _taxonomySeedVersion = 'gaza_v1';
  static const String _syncProgressStorageKey = 'sync_progress_state_v1';
  MobileSyncStatus? _status;
  MobileSyncResult? _lastResult;
  DateTime? _lastResultAt;
  String? _lastResultOperation;
  String? _lastResultSource;
  Map<String, int>? _stats;
  FileIdDiagnostics? _fileIdDiagnostics;
  BeneficiaryUploadSummary? _lastBeneficiaryUploadSummary;
  String? _beneficiariesLastSyncError;
  int? _remoteBeneficiariesCount;
  DateTime? _lastUploadAt;
  DateTime? _lastDownloadAt;
  StreamSubscription<MobileSyncStatus>? _syncStatusSubscription;
  _SyncViewMode _syncViewMode = _SyncViewMode.operational;
  bool _showDetailedStatsInOperational = false;
  DateTime? _syncHubOpenedAt;
  DateTime? _syncFunnelTriggeredAt;
  String? _syncFunnelTrigger;
  final Map<String, int> _syncTriggerCounts = <String, int>{};
  final Map<String, DateTime> _syncFirstTriggerAt = <String, DateTime>{};

  String? _lastSyncResumeOperation;
  ProviderSubscription<SyncProgressState>? _syncProgressPersistenceSub;
  DateTime? _lastDashboardRefreshAt;
  bool _dashboardRefreshInFlight = false;

  @override
  void initState() {
    super.initState();
    _startSyncHubSession();
    WidgetsBinding.instance.addObserver(this);
    _bindSyncProgressPersistence();
    unawaited(_restorePersistedSyncProgress());
    _listenToSyncStatus();
    _refreshDashboardData();
  }

  void _bindSyncProgressPersistence() {
    _syncProgressPersistenceSub?.close();
    _syncProgressPersistenceSub = ref.listenManual<SyncProgressState>(
      syncProgressProvider,
      (_, next) {
        unawaited(_persistSyncProgress(next));
      },
      fireImmediately: true,
    );
  }

  Future<void> _persistSyncProgress(SyncProgressState state) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(_syncProgressStorageKey, jsonEncode(state.toJson()));
  }

  Future<void> _restorePersistedSyncProgress() async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final raw = prefs.getString(_syncProgressStorageKey);
      if (raw == null || raw.trim().isEmpty) {
        return;
      }

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return;
      }

      final snapshot = SyncProgressState.fromJson(decoded);
      if (snapshot.operation == 'idle' && snapshot.phase == 'idle') {
        return;
      }

      if (!mounted) return;
      ref.read(syncControllerProvider.notifier).restore(snapshot);
      _lastSyncResumeOperation = snapshot.operation;
    } catch (_) {
      // Ignore invalid snapshots and continue with fresh state.
    }
  }

  void _startSyncHubSession() {
    developer.log('[SyncPage] opened', name: 'SyncPage');
    _syncHubOpenedAt = DateTime.now();
    _syncFunnelTriggeredAt = null;
    _syncFunnelTrigger = null;
    _syncTriggerCounts.clear();
    _syncFirstTriggerAt.clear();
    UxFlowAnalytics.trackSyncHubOpened(viewMode: _syncViewMode.name);
  }

  void _trackSyncFunnelTrigger(String trigger) {
    final now = DateTime.now();
    _syncFunnelTrigger = trigger;
    _syncFunnelTriggeredAt = now;

    final currentCount = (_syncTriggerCounts[trigger] ?? 0) + 1;
    _syncTriggerCounts[trigger] = currentCount;
    _syncFirstTriggerAt.putIfAbsent(trigger, () => now);

    if (currentCount > 1) {
      final firstAt = _syncFirstTriggerAt[trigger] ?? now;
      UxFlowAnalytics.trackSyncManualRetryLoop(
        trigger: trigger,
        loopCount: currentCount,
        elapsedSinceFirstTriggerMs: now.difference(firstAt).inMilliseconds,
      );
    }

    final openedAt = _syncHubOpenedAt;
    UxFlowAnalytics.trackSyncFunnelTriggered(
      trigger: trigger,
      elapsedFromOpenMs: openedAt == null ? null : now.difference(openedAt).inMilliseconds,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshDashboardData());
    }
  }

  void _listenToSyncStatus() {
    final service = ref.read(mobileSyncServiceProvider);
    _syncStatusSubscription?.cancel();
    _syncStatusSubscription = service.statusStream.listen((status) {
      final previousStatus = _status;
      final syncProgressController = ref.read(syncControllerProvider.notifier);
      final syncProgress = ref.read(syncProgressProvider);

      if (syncProgress.isRunning && syncProgress.operation != 'taxonomy_upload') {
        final baseTotal = syncProgress.total <= 0 ? 100 : syncProgress.total;
        final mappedProcessed = (status.progress * baseTotal).round();
        syncProgressController.update(
          phase: status.isSyncing ? 'uploading' : syncProgress.phase,
          total: baseTotal,
          processed: mappedProcessed,
          message: status.currentOperation,
        );
      }

      if (mounted) {
        setState(() {
          _status = status;
        });

        final justFinished = (previousStatus?.isSyncing ?? false) && !status.isSyncing;
        if (justFinished) {
          final now = DateTime.now();
          final openedAt = _syncHubOpenedAt;
          final triggeredAt = _syncFunnelTriggeredAt;
          final trigger = _syncFunnelTrigger ?? 'unknown';
          final isSuccess = (status.lastError == null || status.lastError!.trim().isEmpty);

          UxFlowAnalytics.trackSyncFunnelCompleted(
            trigger: trigger,
            success: isSuccess,
            elapsedFromTriggerMs: triggeredAt == null ? null : now.difference(triggeredAt).inMilliseconds,
            elapsedFromOpenMs: openedAt == null ? null : now.difference(openedAt).inMilliseconds,
            errorCategory: isSuccess ? null : 'sync_error',
          );

          _syncFunnelTrigger = null;
          _syncFunnelTriggeredAt = null;

          if (syncProgress.isRunning && syncProgress.operation != 'taxonomy_upload') {
            final hasError = (status.lastError ?? '').trim().isNotEmpty;
            if (hasError) {
              syncProgressController.fail(
                phase: 'failed',
                errorCode: 'sync_error',
                errorMessage: status.lastError,
                message: status.currentOperation,
              );
            } else {
              syncProgressController.complete(message: status.currentOperation);
            }
          }
        }

        if (!status.isSyncing) {
          unawaited(_refreshDashboardData());
        }
      }
    });
  }

  Future<void> _refreshDashboardData({bool force = false}) async {
    if (!force && _dashboardRefreshInFlight) {
      return;
    }

    final now = DateTime.now();
    if (!force && _lastDashboardRefreshAt != null && now.difference(_lastDashboardRefreshAt!).inSeconds < 2) {
      return;
    }

    _dashboardRefreshInFlight = true;
    final db = ref.read(databaseProvider);
    final fileIdService = ref.read(fileIdServiceProvider);
    try {
      final data = await MobileSyncDashboardLoader.load(db: db, fileIdService: fileIdService);
      final lastUpload = await db.syncMetadataDao.getLastSyncTime('beneficiaries_upload');
      final lastDownload = await db.syncMetadataDao.getLastSyncTime('beneficiaries_download');

      if (!mounted) return;

      int? remoteCount;
      if (BackendConfig.current.flavor == BackendFlavor.firebase) {
        remoteCount = await ref.read(firebaseBeneficiaryUploadServiceProvider).getRemoteBeneficiariesCount();
      }

      developer.log(
        '[SyncDashboard] metrics loaded localCount=${data.stats['ben_total'] ?? 0} remoteCount=${remoteCount ?? -1} pending=${data.stats['total_pending_uploads'] ?? 0} visitsPending=${data.stats['visits_needsSync'] ?? 0}',
        name: 'SyncDashboard',
      );

      if (!mounted) return;

      setState(() {
        _lastResult = data.lastResult;
        _lastResultAt = data.lastResultAt;
        _lastResultOperation = data.lastResultOperation;
        _lastResultSource = data.lastResultSource;
        _stats = data.stats;
        _fileIdDiagnostics = data.fileIdDiagnostics;
        _beneficiariesLastSyncError = data.beneficiariesLastSyncError;
        _remoteBeneficiariesCount = remoteCount;
        _lastUploadAt = lastUpload;
        _lastDownloadAt = lastDownload;
      });
      _lastDashboardRefreshAt = now;

      // Invalidate Dashboard metrics so the Home screen reflects updated counts.
      // dashboardSummaryProvider is autoDispose with 30s keepAlive — invalidating
      // forces an immediate re-fetch on next watch rather than waiting for timer.
      ref.invalidate(dashboardSummaryProvider);
      unawaited(ref.read(dashboardProvider.notifier).refresh());
    } finally {
      _dashboardRefreshInFlight = false;
    }
  }

  Future<void> _runContractParityBackfill() async {
    try {
      final db = ref.read(databaseProvider);
      final result = await MobileSyncDashboardLoader.backfillContractParity(db);
      await _refreshDashboardData();
      if (!mounted) return;
      EnhancedSnackbar.showSuccess(
        context,
        message:
            '✅ Contract parity backfill: re_people=${result.rePeopleFilled}, dead_people=${result.deadPeopleFilled}, attachments=${result.attachmentsFilled}',
      );
    } catch (e) {
      if (!mounted) return;
      EnhancedSnackbar.showError(context, message: '❌ فشل backfill parity: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _syncStatusSubscription?.cancel();
    _syncStatusSubscription = null;
    _syncProgressPersistenceSub?.close();
    _syncProgressPersistenceSub = null;
    super.dispose();
  }

  Future<bool> _hasInternetConnection() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Future<void> _runWithForegroundSyncGuard(Future<void> Function() task) async {
    await WakelockPlus.enable();
    if (mounted) {
      EnhancedSnackbar.showInfo(
        context,
        message: 'يرجى إبقاء التطبيق مفتوحاً أثناء المزامنة',
      );
    }
    try {
      await task();
    } finally {
      await WakelockPlus.disable();
    }
  }

  String _humanizeFirebaseError(Object error) {
    final raw = error.toString().toLowerCase();
    if (raw.contains('permission-denied')) {
      return 'لا توجد صلاحية للوصول إلى Firestore. تحقق من القواعد وحساب المستخدم.';
    }
    if (raw.contains('unauthenticated')) {
      return 'انتهت الجلسة. يرجى تسجيل الدخول مجدداً.';
    }
    if (raw.contains('unavailable') || raw.contains('network') || raw.contains('offline')) {
      return 'انقطع الاتصال، يمكن إعادة المحاولة.';
    }
    return error.toString();
  }

  Future<BeneficiaryDownloadSummary?> _runFirebaseDownload({
    required SyncProgressController syncProgressController,
    bool showSnackbars = true,
  }) async {
    final firebaseService = ref.read(firebaseBeneficiaryUploadServiceProvider);
    final summary = await firebaseService.syncDownBeneficiariesFromFirebase(
      onProgress: (progress) async {
        syncProgressController.update(
          phase: progress.phase,
          total: progress.total,
          processed: progress.processed,
          created: progress.created,
          updated: progress.updated,
          failed: progress.failed,
          skipped: progress.skipped,
          pending: progress.total - progress.processed,
          currentItemId: progress.currentRemoteId,
          message: progress.message,
          errorCode: progress.errorCode,
          errorMessage: progress.errorMessage,
        );
      },
    );

    if (summary.pausedByNetwork) {
      syncProgressController.pause(
        phase: 'paused_due_to_network',
        errorCode: 'offline',
        errorMessage: 'لا يوجد اتصال مستقر بالإنترنت.',
        message: 'انقطع الاتصال، يمكنك إعادة المحاولة.',
      );
      if (mounted && showSnackbars) {
        EnhancedSnackbar.showError(context, message: '❌ لا يوجد اتصال مستقر بالإنترنت.');
      }
      return null;
    }

    if (summary.failed > 0) {
      syncProgressController.fail(
        phase: 'failed',
        errorCode: 'partial_failure',
        errorMessage: 'فشل تنزيل ${summary.failed} سجل',
        message: 'اكتمل التنزيل مع أخطاء جزئية.',
      );
      if (mounted && showSnackbars) {
        EnhancedSnackbar.showError(context, message: '❌ اكتمل التنزيل مع بعض الأخطاء.');
      }
      return summary;
    }

    return summary;
  }

  Future<BeneficiaryUploadSummary?> _runFirebaseUpload({
    required SyncProgressController syncProgressController,
    bool showSnackbars = true,
  }) async {
    final diagnosticsBefore = await ref.read(fileIdServiceProvider).getDiagnostics();
    syncProgressController.update(
      phase: 'preparing',
      processed: 0,
      fileNumbersAvailable: diagnosticsBefore?.availableCount,
      pendingAssignedFileNumbers: diagnosticsBefore?.usedUnsyncedCount,
      message: 'جاري تجهيز رفع المستفيدين...',
    );

    final uploadService = ref.read(firebaseBeneficiaryUploadServiceProvider);
    final summary = await uploadService.uploadPendingBeneficiaries(
      onProgress: (progress) async {
        syncProgressController.update(
          phase: progress.phase,
          total: progress.total,
          processed: progress.processed,
          created: progress.uploaded,
          failed: progress.failed,
          skipped: progress.skipped,
          pending: progress.total - progress.processed,
          confirmedFileNumbers: progress.fileNumbersConfirmed,
          currentItemId: progress.currentLocalId,
          message: progress.message,
          errorCode: progress.errorCode,
          errorMessage: progress.errorMessage,
        );
      },
    );

    if (mounted) {
      setState(() {
        _lastBeneficiaryUploadSummary = summary;
      });
    }

    final diagnosticsAfter = await ref.read(fileIdServiceProvider).getDiagnostics();

    if (summary.hadNoPending) {
      syncProgressController.complete(message: 'لا توجد تغييرات لرفعها');
      if (mounted && showSnackbars) {
        EnhancedSnackbar.showInfo(context, message: 'لا توجد تغييرات لرفعها');
      }
      return summary;
    }

    if (summary.pausedByNetwork) {
      syncProgressController.pause(
        phase: 'paused_due_to_network',
        errorCode: 'offline',
        errorMessage: 'انقطع الاتصال أثناء الرفع.',
        message: 'انقطع الاتصال، يمكنك المتابعة عند رجوع الإنترنت',
      );
      if (mounted && showSnackbars) {
        EnhancedSnackbar.showError(context, message: '❌ لا يوجد اتصال مستقر بالإنترنت.');
      }
      return null;
    }

    if (summary.failed == 0) {
      syncProgressController.update(
        phase: 'beneficiary_upload',
        total: summary.totalPending,
        processed: summary.totalPending,
        created: summary.uploaded,
        failed: summary.failed,
        skipped: summary.skipped,
        pending: 0,
        fileNumbersAvailable: diagnosticsAfter?.availableCount,
        pendingAssignedFileNumbers: diagnosticsAfter?.usedUnsyncedCount,
        confirmedFileNumbers: summary.fileNumbersConfirmed,
        failedFileNumberConfirmations: summary.failed,
        message: diagnosticsAfter == null
            ? 'تم رفع كل المستفيدين بنجاح'
            : 'تم رفع ${summary.uploaded} من ${summary.totalPending}',
      );
      return summary;
    }

    syncProgressController.fail(
      phase: 'failed',
      errorCode: 'partial_failure',
      errorMessage: 'فشل رفع ${summary.failed} مستفيد',
      message: 'فشل رفع ${summary.failed} مستفيد، يمكنك إعادة المحاولة',
    );

    if (mounted && showSnackbars) {
      EnhancedSnackbar.showError(context, message: '❌ فشل رفع ${summary.failed} مستفيد، يمكنك إعادة المحاولة');
    }
    return summary;
  }

  Future<void> _syncDown() async {
    if (!await _hasInternetConnection()) {
      ref.read(syncControllerProvider.notifier).pause(
            phase: 'paused_due_to_network',
            errorCode: 'offline',
            errorMessage: 'لا يوجد اتصال مستقر بالإنترنت. سيتم الاستكمال لاحقاً.',
            message: 'لا يوجد اتصال مستقر بالإنترنت. سيتم الاستكمال لاحقاً.',
          );
      if (mounted) {
        EnhancedSnackbar.showError(context, message: '❌ لا يوجد اتصال مستقر بالإنترنت.');
      }
      return;
    }

    _trackSyncFunnelTrigger('sync_down');
    _lastSyncResumeOperation = 'full_download';

    final syncProgressController = ref.read(syncControllerProvider.notifier);
    syncProgressController.start(
      operation: 'beneficiary_download',
      phase: 'preparing',
      total: 1,
      message: 'جاري التحضير لتنزيل البيانات من Firebase...',
    );

    await _runWithForegroundSyncGuard(() async {
      if (BackendConfig.current.flavor == BackendFlavor.firebase) {
        if (mounted) {
          EnhancedSnackbar.showInfo(context, message: 'سيتم تنفيذ المزامنة داخل التطبيق الآن');
        }
        final summary = await _runFirebaseDownload(
          syncProgressController: syncProgressController,
          showSnackbars: true,
        );

        if (summary != null && summary.failed == 0) {
          syncProgressController.complete(message: 'اكتمل تنزيل البيانات من Firebase بنجاح.');
          if (mounted) {
            EnhancedSnackbar.showSuccess(
              context,
              message: '✅ تم تنزيل ${summary.remoteFetched} سجل (جديد: ${summary.created}, تحديث: ${summary.updated})',
            );
          }
        }
      } else {
        final scheduled = await BackgroundSyncWorker.triggerSyncDown();
        if (scheduled) {
          if (!mounted) return;
          setState(() {
            _status = MobileSyncStatus(
              isSyncing: true,
              currentOperation: 'تمت جدولة مزامنة التنزيل بالخلفية',
              progress: 0,
            );
          });
          if (mounted) {
            EnhancedSnackbar.showSuccess(context, message: '✅ تمت جدولة Sync Down بالخلفية');
          }
          return;
        }

        final service = ref.read(mobileSyncServiceProvider);
        final result = await service.syncDown();
        if (result.success) {
          syncProgressController.complete(message: 'اكتمل تنزيل البيانات بنجاح.');
          if (mounted) {
            EnhancedSnackbar.showSuccess(context, message: '✅ اكتمل تنزيل البيانات بنجاح');
          }
        } else {
          final isNetwork = ((result.errorCategory ?? '').toLowerCase() == 'network') ||
              ((result.error ?? '').toLowerCase().contains('unavailable'));
          if (isNetwork) {
            syncProgressController.pause(
              phase: 'paused_due_to_network',
              errorCode: result.errorCategory ?? 'unavailable',
              errorMessage: result.error ?? 'انقطع الاتصال أثناء التنزيل.',
              message: 'انقطع الاتصال، يمكنك المتابعة عند رجوع الإنترنت',
            );
          } else {
            syncProgressController.fail(
              phase: 'failed',
              errorCode: result.errorCategory,
              errorMessage: result.error,
              message: 'فشل تنزيل البيانات.',
            );
          }

          if (mounted) {
            EnhancedSnackbar.showError(context, message: '❌ ${result.error ?? 'فشل تنزيل البيانات'}');
          }
        }
      }

      await _refreshDashboardData(force: true);
    });
  }

  Future<void> _syncUp() async {
    await _syncTaxonomyMasterDataForUpload(
      trigger: 'sync_page_upload_changes',
      force: false,
    );

    if (!await _hasInternetConnection()) {
      ref.read(syncControllerProvider.notifier).pause(
            phase: 'paused_due_to_network',
            errorCode: 'offline',
            errorMessage: 'لا يوجد اتصال مستقر بالإنترنت. سيتم الاستكمال لاحقاً.',
            message: 'لا يوجد اتصال مستقر بالإنترنت. سيتم الاستكمال لاحقاً.',
          );
      if (mounted) {
        EnhancedSnackbar.showError(context, message: '❌ لا يوجد اتصال مستقر بالإنترنت.');
      }
      return;
    }

    _trackSyncFunnelTrigger('sync_up');
    _lastSyncResumeOperation = 'full_upload';

    final registry = ref.read(syncCollectionRegistryProvider);
    final totalPending = await registry.totalPendingChanges(remoteBeneficiariesCount: _remoteBeneficiariesCount);

    if (totalPending == 0) {
      ref.read(syncControllerProvider.notifier).complete(message: 'لا توجد تغييرات لرفعها');
      if (mounted) {
        EnhancedSnackbar.showInfo(context, message: 'لا توجد تغييرات لرفعها');
      }
      await _refreshDashboardData(force: true);
      return;
    }

    developer.log('[SyncUpload] started totalPending=$totalPending', name: 'SyncUpload');

    final syncProgressController = ref.read(syncControllerProvider.notifier);
    syncProgressController.start(
      operation: 'full_upload',
      phase: 'preparing',
      total: totalPending,
      message: 'جاري تجهيز رفع جميع التغييرات...',
    );

    await _runWithForegroundSyncGuard(() async {
      final result = await registry.uploadAllPendingChangesToFirebase();

      if (result.noData) {
        syncProgressController.complete(message: 'لا توجد تغييرات لرفعها');
        if (mounted) {
          EnhancedSnackbar.showInfo(context, message: 'لا توجد تغييرات لرفعها');
        }
      } else if (result.totalFailed == 0) {
        syncProgressController.update(
          phase: 'uploading',
          total: result.totalPending,
          processed: result.totalPending,
          created: result.totalUploaded,
          failed: result.totalFailed,
          pending: 0,
          message: 'اكتمل رفع جميع التغييرات بنجاح',
        );
        syncProgressController.complete(message: 'اكتمل رفع التغييرات بنجاح.');
        if (mounted) {
          EnhancedSnackbar.showSuccess(
            context,
            message: '✅ اكتمل رفع ${result.totalUploaded} تغيير',
          );
        }
      } else {
        syncProgressController.fail(
          phase: 'failed',
          errorCode: 'partial_failure',
          errorMessage: 'فشل رفع ${result.totalFailed} عنصر',
          message: 'اكتمل الرفع مع بعض الأخطاء',
        );
        if (mounted) {
          EnhancedSnackbar.showError(context, message: '❌ اكتمل الرفع مع ${result.totalFailed} أخطاء');
        }
      }

      await _refreshDashboardData(force: true);
      ref.invalidate(fileNumberPoolStatusProvider);
    });
  }

  Future<void> _syncTaxonomies() async {
    await ref.read(taxonomySyncNotifierProvider.notifier).sync();

    if (!mounted) return;

    final syncStatus = ref.read(taxonomySyncStatusProvider);
    final errorMessage = ref.read(taxonomyErrorMessageProvider);

    if (syncStatus == TaxonomySyncStatus.success) {
      EnhancedSnackbar.showSuccess(
        context,
        message: '✅ تمت مزامنة التصنيفات بنجاح',
      );
      return;
    }

    EnhancedSnackbar.showError(
      context,
      message: '❌ فشل مزامنة التصنيفات: ${errorMessage ?? 'خطأ غير معروف'}',
    );
  }

  Future<void> _uploadCedarFileNumbers() async {
    if (!await _hasInternetConnection()) {
      ref.read(syncControllerProvider.notifier).pause(
            phase: 'paused_due_to_network',
            errorCode: 'offline',
            errorMessage: 'لا يوجد اتصال مستقر بالإنترنت. سيتم الاستكمال لاحقاً.',
            message: 'لا يوجد اتصال مستقر بالإنترنت. سيتم الاستكمال لاحقاً.',
          );
      if (mounted) {
        EnhancedSnackbar.showError(context, message: '❌ لا يوجد اتصال مستقر بالإنترنت.');
      }
      return;
    }

    final syncProgressController = ref.read(syncControllerProvider.notifier);
    syncProgressController.start(
      operation: 'cedar_file_numbers_upload',
      phase: 'reserving_block',
      total: 500,
      message: 'جاري حجز أرقام الملفات...',
    );

    try {
      final fileIdService = ref.read(fileIdServiceProvider);
      await fileIdService.debugFileNumberFirestoreAccess(year: 2026);

      final result = await fileIdService.uploadCedarFileNumbers(
        blockSize: 500,
        year: 2026,
        onProgress: (progress) async {
          syncProgressController.update(
            phase: progress.phase,
            total: progress.total,
            processed: progress.processed,
            fileNumbersAvailable: progress.available,
            reservedBlockSize: progress.total,
            fileNumberRangeStart: progress.rangeStart,
            fileNumberRangeEnd: progress.rangeEnd,
            message: progress.phase == 'completed' ? 'تم حجز ${progress.total} رقم ملف' : 'جاري حجز أرقام الملفات...',
          );
        },
      );

      syncProgressController.complete(
        phase: 'completed',
        message:
            'تم حجز ${result.reservedCount} رقم ملف. النطاق: ${result.rangeStart} إلى ${result.rangeEnd}. الأرقام المتاحة محلياً: ${result.availableCount}',
      );

      await _refreshDashboardData();
      ref.invalidate(fileNumberPoolStatusProvider);

      if (!mounted) return;
      EnhancedSnackbar.showSuccess(
        context,
        message:
            '✅ تم حجز ${result.reservedCount} رقم ملف\nالنطاق: ${result.rangeStart} إلى ${result.rangeEnd}\nالأرقام المتاحة محلياً: ${result.availableCount}',
      );
    } catch (e) {
      syncProgressController.fail(
        phase: 'failed',
        errorCode: 'cedar_upload_failed',
        errorMessage: e.toString(),
        message: 'فشل رفع/حجز أرقام الملفات الأساسية.',
      );
      if (!mounted) return;
      EnhancedSnackbar.showError(context, message: '❌ فشل رفع أرقام الملفات الأساسية: $e');
    }
  }

  Future<void> _syncNowOfficial() async {
    await _syncTaxonomyMasterDataForUpload(
      trigger: 'sync_page_full_sync',
      force: false,
    );

    if (!await _hasInternetConnection()) {
      ref.read(syncControllerProvider.notifier).pause(
            phase: 'paused_due_to_network',
            errorCode: 'offline',
            errorMessage: 'لا يوجد اتصال مستقر بالإنترنت. سيتم الاستكمال لاحقاً.',
            message: 'لا يوجد اتصال مستقر بالإنترنت. سيتم الاستكمال لاحقاً.',
          );
      if (mounted) {
        EnhancedSnackbar.showError(context, message: '❌ لا يوجد اتصال مستقر بالإنترنت.');
      }
      return;
    }

    _trackSyncFunnelTrigger('sync_now_full');
    _lastSyncResumeOperation = 'full_sync';

    final syncProgressController = ref.read(syncControllerProvider.notifier);
    syncProgressController.start(
      operation: 'full_sync',
      phase: 'preparing',
      total: 100,
      message: 'جاري تنفيذ المزامنة الشاملة...',
    );

    await _runWithForegroundSyncGuard(() async {
      if (BackendConfig.current.flavor == BackendFlavor.firebase) {
        if (mounted) {
          EnhancedSnackbar.showInfo(context, message: 'سيتم تنفيذ المزامنة داخل التطبيق الآن');
        }

        developer.log('[FullSync] step=taxonomy status=started', name: 'FullSync');
        syncProgressController.update(phase: 'preparing', processed: 5, message: 'مزامنة التصنيفات الأساسية...');
        await _syncTaxonomyMasterDataForUpload(
          trigger: 'sync_page_full_sync_taxonomy_step',
          force: false,
          showSuccessSnackbar: false,
        );
        developer.log('[FullSync] step=taxonomy status=completed', name: 'FullSync');

        developer.log('[FullSync] step=file_numbers status=started', name: 'FullSync');
        syncProgressController.update(
          phase: 'confirming_file_numbers',
          processed: 20,
          message: 'التأكد من توفر أرقام الملفات...',
        );
        final fileNumberSyncResult = await ref.read(fileIdServiceProvider).syncDownFileNumberState();
        if (fileNumberSyncResult.success) {
          developer.log('[FullSync] step=file_numbers status=completed', name: 'FullSync');
        } else if (fileNumberSyncResult.isWarning) {
          developer.log(
            '[FullSync] step=file_numbers status=warning(${fileNumberSyncResult.errorCode ?? 'warning'})',
            name: 'FullSync',
          );
          syncProgressController.update(
            phase: 'confirming_file_numbers',
            processed: 22,
            message: fileNumberSyncResult.message,
            errorCode: fileNumberSyncResult.errorCode,
            errorMessage: fileNumberSyncResult.message,
          );
          if (mounted) {
            EnhancedSnackbar.showInfo(context, message: '⚠️ ${fileNumberSyncResult.message}');
          }
        } else {
          developer.log('[FullSync] step=file_numbers status=failed', name: 'FullSync');
          syncProgressController.fail(
            phase: 'failed',
            errorCode: fileNumberSyncResult.errorCode ?? 'file_numbers_sync_failed',
            errorMessage: fileNumberSyncResult.message,
            message: 'فشل مزامنة أرقام الملفات.',
          );
          if (mounted) {
            EnhancedSnackbar.showError(context, message: '❌ فشل مزامنة أرقام الملفات: ${fileNumberSyncResult.message}');
          }
          return;
        }

        developer.log('[FullSync] step=upload status=started', name: 'FullSync');
        syncProgressController.update(phase: 'uploading', processed: 35, message: 'جاري رفع التغييرات...');
        final uploadSummary = await _runFirebaseUpload(
          syncProgressController: syncProgressController,
          showSnackbars: false,
        );
        if (uploadSummary == null || uploadSummary.failed > 0) {
          developer.log('[FullSync] step=upload status=failed', name: 'FullSync');
          if (mounted) {
            EnhancedSnackbar.showError(context, message: '❌ فشل خطوة رفع المستفيدين أثناء المزامنة الكاملة.');
          }
          return;
        }
        developer.log('[FullSync] step=upload status=completed', name: 'FullSync');

        developer.log('[FullSync] step=modules_upload status=started', name: 'FullSync');
        syncProgressController.update(
          phase: 'uploading',
          processed: 55,
          message: 'جاري رفع الجمعيات/الكفالات/الزيارات/المتابعات...',
        );
        final modulesUploadSummary = await ref.read(syncFirestoreModulesUseCaseProvider).uploadAll();
        final modulesUploadFailed = modulesUploadSummary.aggregate.failed;
        if (modulesUploadFailed > 0) {
          developer.log('[FullSync] step=modules_upload status=failed', name: 'FullSync');
          syncProgressController.fail(
            phase: 'failed',
            errorCode: 'modules_upload_failed',
            errorMessage: 'فشل رفع $modulesUploadFailed سجل في وحدات الجمعيات/الكفالات/الزيارات',
            message: 'فشلت مزامنة الوحدات الإضافية أثناء الرفع.',
          );
          if (mounted) {
            EnhancedSnackbar.showError(context, message: '❌ فشلت مزامنة الوحدات الإضافية أثناء الرفع.');
          }
          return;
        }
        developer.log('[FullSync] step=modules_upload status=completed', name: 'FullSync');

        developer.log('[FullSync] step=download status=started', name: 'FullSync');
        syncProgressController.update(phase: 'downloading', processed: 75, message: 'جاري تنزيل التغييرات...');
        final downSummary = await _runFirebaseDownload(
          syncProgressController: syncProgressController,
          showSnackbars: false,
        );
        if (downSummary == null || downSummary.failed > 0) {
          developer.log('[FullSync] step=download status=failed', name: 'FullSync');
          if (mounted) {
            EnhancedSnackbar.showError(context, message: '❌ فشلت خطوة تنزيل المستفيدين أثناء المزامنة الكاملة.');
          }
          return;
        }
        developer.log('[FullSync] step=download status=completed', name: 'FullSync');

        developer.log('[FullSync] step=modules_download status=started', name: 'FullSync');
        syncProgressController.update(
          phase: 'downloading',
          processed: 90,
          message: 'جاري تنزيل الجمعيات/الكفالات/الزيارات/المتابعات...',
        );
        final modulesDownloadSummary = await ref.read(syncFirestoreModulesUseCaseProvider).downloadAll();
        final modulesDownloadFailed = modulesDownloadSummary.aggregate.failed;
        if (modulesDownloadFailed > 0) {
          developer.log('[FullSync] step=modules_download status=failed', name: 'FullSync');
          final failedNames = modulesDownloadSummary.failedModules.map((m) => m.moduleName).join(', ');
          syncProgressController.update(
            phase: 'downloading',
            processed: 96,
            errorCode: 'modules_download_partial_failure',
            errorMessage: 'فشل تنزيل بعض الوحدات: $failedNames',
            message: 'تم تنزيل المستفيدين، لكن فشل تنزيل بعض الوحدات: $failedNames',
          );
          if (mounted) {
            EnhancedSnackbar.showInfo(
              context,
              message:
                  '⚠️ تم تنزيل المستفيدين، لكن فشل تنزيل بعض الوحدات: ${failedNames.isEmpty ? 'غير محدد' : failedNames}',
            );
          }
        } else {
          developer.log('[FullSync] step=modules_download status=completed', name: 'FullSync');
        }

        await ref.read(databaseProvider).syncMetadataDao.updateSyncSuccess(
              'full_sync',
              totalSynced: 1,
              syncTime: DateTime.now(),
            );

        syncProgressController.complete(message: 'اكتملت المزامنة الشاملة بنجاح.');
        await _refreshDashboardData(force: true);
        if (mounted) {
          EnhancedSnackbar.showSuccess(context, message: '✅ اكتملت المزامنة الشاملة بنجاح');
        }
      } else {
        final scheduled = await BackgroundSyncWorker.triggerManualSync();
        if (scheduled) {
          if (!mounted) return;
          setState(() {
            _status = MobileSyncStatus(
              isSyncing: true,
              currentOperation: 'تمت جدولة المزامنة الشاملة بالخلفية',
              progress: 0,
            );
          });

          EnhancedSnackbar.showSuccess(
            context,
            message: '✅ تمت جدولة المزامنة الشاملة بالخلفية',
          );
          return;
        }

        final service = ref.read(mobileSyncServiceProvider);
        syncProgressController.update(phase: 'downloading', message: 'جاري تنزيل البيانات...');
        final down = await service.syncDown();
        if (!down.success) {
          final isNetwork = ((down.errorCategory ?? '').toLowerCase() == 'network') ||
              ((down.error ?? '').toLowerCase().contains('unavailable'));
          if (isNetwork) {
            syncProgressController.pause(
              phase: 'paused_due_to_network',
              errorCode: down.errorCategory ?? 'unavailable',
              errorMessage: down.error,
              message: 'انقطع الاتصال أثناء التنزيل، يمكنك المتابعة لاحقاً.',
            );
          } else {
            syncProgressController.fail(
              phase: 'failed',
              errorCode: down.errorCategory,
              errorMessage: down.error,
              message: 'فشل جزء التنزيل في المزامنة الشاملة.',
            );
          }
          if (mounted) {
            EnhancedSnackbar.showError(context, message: '❌ ${down.error ?? 'فشل تنزيل البيانات'}');
          }
          return;
        }

        syncProgressController.update(phase: 'uploading', processed: 65, message: 'جاري رفع التغييرات...');
        final up = await service.syncUp();
        if (up.success) {
          syncProgressController.complete(message: 'اكتملت المزامنة الشاملة بنجاح.');
          if (mounted) {
            EnhancedSnackbar.showSuccess(context, message: '✅ اكتملت المزامنة الشاملة بنجاح');
          }
        } else {
          final isNetwork = ((up.errorCategory ?? '').toLowerCase() == 'network') ||
              ((up.error ?? '').toLowerCase().contains('unavailable'));
          if (isNetwork) {
            syncProgressController.pause(
              phase: 'paused_due_to_network',
              errorCode: up.errorCategory ?? 'unavailable',
              errorMessage: up.error,
              message: 'انقطع الاتصال أثناء الرفع، يمكنك المتابعة لاحقاً.',
            );
          } else {
            syncProgressController.fail(
              phase: 'failed',
              errorCode: up.errorCategory,
              errorMessage: up.error,
              message: 'فشل جزء الرفع في المزامنة الشاملة.',
            );
          }

          if (mounted) {
            EnhancedSnackbar.showError(context, message: '❌ ${up.error ?? 'فشل رفع التغييرات'}');
          }
        }
      }
    });
  }

  Future<void> _resetBeneficiariesAndRestore() async {
    final uploadService = ref.read(firebaseBeneficiaryUploadServiceProvider);
    final pending = await uploadService.getPendingUploadsCount();

    if (!mounted) {
      return;
    }

    final force = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            final hasPending = pending > 0;
            return AlertDialog(
              title: const Text('مسح البيانات المحلية وإعادة التنزيل'),
              content: Text(
                hasPending
                    ? 'يوجد $pending سجل بانتظار الرفع. سيتم حذف البيانات المحلية غير المرفوعة. هل أنت متأكد؟'
                    : 'سيتم حذف البيانات المحلية غير المرفوعة. هل أنت متأكد؟',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(hasPending ? 'متابعة بالقوة' : 'تأكيد'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!mounted) {
      return;
    }

    if (pending > 0 && !force) {
      EnhancedSnackbar.showInfo(context, message: 'تم إلغاء العملية لحماية البيانات غير المرفوعة.');
      return;
    }

    final syncController = ref.read(syncControllerProvider.notifier);
    syncController.start(
      operation: 'beneficiary_download',
      phase: 'preparing',
      total: 1,
      message: 'جاري مسح البيانات المحلية للمستفيدين...',
    );

    try {
      final resetSummary = await uploadService.resetBeneficiariesLocalCache(force: force);

      syncController.update(
        phase: 'downloading',
        total: 1,
        processed: 0,
        message: 'تم مسح ${resetSummary.deletedBeneficiaries} سجل محلياً. جاري إعادة التنزيل...',
      );

      final downSummary = await uploadService.syncDownBeneficiariesFromFirebase(
        onProgress: (progress) async {
          syncController.update(
            phase: progress.phase,
            total: progress.total,
            processed: progress.processed,
            created: progress.created,
            updated: progress.updated,
            skipped: progress.skipped,
            failed: progress.failed,
            pending: progress.total - progress.processed,
            message: progress.message,
            errorCode: progress.errorCode,
            errorMessage: progress.errorMessage,
            currentItemId: progress.currentRemoteId,
          );
        },
      );

      if (downSummary.failed > 0) {
        syncController.fail(
          phase: 'failed',
          errorCode: 'partial_failure',
          errorMessage: 'فشل تنزيل ${downSummary.failed} سجل.',
          message: 'اكتملت الاستعادة مع أخطاء جزئية.',
        );
        if (mounted) {
          EnhancedSnackbar.showError(context, message: '❌ اكتملت الاستعادة مع بعض الأخطاء.');
        }
      } else {
        syncController.complete(message: 'اكتملت استعادة البيانات من Firebase.');
        if (mounted) {
          EnhancedSnackbar.showSuccess(
            context,
            message: '✅ تمت الاستعادة: ${downSummary.created + downSummary.updated} سجل',
          );
        }
      }

      await _refreshDashboardData(force: true);
    } catch (e) {
      syncController.fail(
        phase: 'failed',
        errorCode: 'reset_failed',
        errorMessage: e.toString(),
        message: 'فشلت عملية المسح والاستعادة.',
      );
      if (mounted) {
        EnhancedSnackbar.showError(context, message: '❌ فشلت عملية المسح والاستعادة: $e');
      }
    }
  }

  Future<void> _resetTaxonomiesOnly() async {
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('مسح التصنيفات المحلية'),
        content: const Text(
          'سيتم مسح بيانات التصنيفات المحلية فقط.\n'
          'هذا لا يؤثر على بيانات Firebase ولا يحذف أي بيانات بعيدة.\n\n'
          'هل أنت متأكد؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('مسح محلي'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(firebaseBeneficiaryUploadServiceProvider).resetTaxonomiesLocalCache();
      await _refreshDashboardData(force: true);
      if (mounted) {
        EnhancedSnackbar.showSuccess(context, message: '✅ تم مسح التصنيفات المحلية فقط.');
      }
    } catch (e) {
      if (mounted) {
        EnhancedSnackbar.showError(context, message: '❌ فشل مسح التصنيفات المحلية: $e');
      }
    }
  }

  Future<void> _resetFileNumbersOnly() async {
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('مسح مخزون أرقام الملفات'),
        content: const Text(
          'سيتم مسح مخزون أرقام الملفات المحلي فقط.\n'
          'هذا لا يؤثر على أرقام الملفات المحجوزة في Firebase.\n\n'
          'هل أنت متأكد؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('مسح محلي'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(firebaseBeneficiaryUploadServiceProvider).resetFileNumberPoolLocalCache();
      ref.invalidate(fileNumberPoolStatusProvider);
      if (mounted) {
        EnhancedSnackbar.showSuccess(context, message: '✅ تم مسح مخزون أرقام الملفات المحلي.');
      }
    } catch (e) {
      if (mounted) {
        EnhancedSnackbar.showError(context, message: '❌ فشل مسح مخزون أرقام الملفات: $e');
      }
    }
  }

  Future<void> _checkFirestoreConnection() async {
    try {
      final count = await ref.read(firebaseBeneficiaryUploadServiceProvider).getRemoteBeneficiariesCount();
      if (!mounted) return;
      EnhancedSnackbar.showSuccess(
        context,
        message: '✅ اتصال Firestore سليم. remoteCount=${count ?? 'غير متاح'}',
      );
    } catch (e) {
      if (!mounted) return;
      EnhancedSnackbar.showError(context, message: '❌ فشل اتصال Firestore: ${_humanizeFirebaseError(e)}');
    }
  }

  Future<void> _checkFirestorePermissions() async {
    try {
      final report = await ref.read(firebaseBeneficiaryUploadServiceProvider).runFirestoreHealthChecks();
      if (!mounted) return;

      if (report.readOk && report.writeOk) {
        EnhancedSnackbar.showSuccess(context, message: '✅ صلاحيات Firestore سليمة (read/write).');
        return;
      }

      final readState = report.readOk ? 'ok' : 'failed';
      final writeState = report.writeOk ? 'ok' : 'failed';
      final writePermissionMissing = (report.writeError ?? '').toLowerCase().contains('permission-denied') ||
          (report.writeError ?? '').toLowerCase().contains('permission_denied');

      if (writePermissionMissing) {
        EnhancedSnackbar.showError(
          context,
          message: '❌ Firestore rules missing for sync_health_checks',
        );
        return;
      }

      final details = <String>[
        'read=$readState',
        'write=$writeState',
        if (report.readError != null) 'readError=${report.readError}',
        if (report.writeError != null) 'writeError=${report.writeError}',
      ].join(' | ');

      EnhancedSnackbar.showError(context, message: '❌ فحص الصلاحيات: $details');
    } catch (e) {
      if (!mounted) return;
      EnhancedSnackbar.showError(context, message: '❌ تعذر فحص الصلاحيات: ${_humanizeFirebaseError(e)}');
    }
  }

  Future<void> _seedCedarAssociationsFromSync({bool force = false}) async {
    if ((_status?.isSyncing ?? false) || ref.read(syncProgressProvider).isRunning) {
      if (mounted) {
        EnhancedSnackbar.showInfo(context, message: 'لا يمكن تشغيل Seed أثناء عملية مزامنة جارية.');
      }
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            SizedBox(width: 12),
            Expanded(child: Text('جاري إضافة جمعيات Cedar...')),
          ],
        ),
      ),
    );

    try {
      final result = await ref.read(associationsProvider.notifier).seedCedarAssociations(force: force);
      ref.invalidate(kafalatActiveAssociationsProvider);
      await _refreshDashboardData(force: true);

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      final message =
          'Cedar Associations Seed: created=${result.created} skipped=${result.skipped} updated=${result.updated} failed=${result.failed}';
      EnhancedSnackbar.showSuccess(context, message: message);
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        EnhancedSnackbar.showError(context, message: '❌ فشل تنفيذ Seed الجمعيات: $e');
      }
    }
  }

  ({int score, String level, Color color, String hint}) _buildSyncHealthScore(MobileSyncResult result) {
    var score = 100;

    final failures = result.recordsFailed;
    if (failures > 0) {
      score -= failures >= 10 ? 25 : 10;
    }

    final beneficiariesInserted = result.writeCounters['beneficiaries_inserted'] ?? 0;
    final beneficiariesUpdated = result.writeCounters['beneficiaries_updated'] ?? 0;
    final beneficiariesSkipped = result.writeCounters['beneficiaries_skipped'] ?? 0;
    final benTotal = beneficiariesInserted + beneficiariesUpdated + beneficiariesSkipped;
    if (benTotal > 0) {
      final benSkipRatio = beneficiariesSkipped / benTotal;
      if (benSkipRatio >= 0.40) {
        score -= 25;
      } else if (benSkipRatio >= 0.20) {
        score -= 12;
      }
    }

    if (result.errorCategory != null) {
      score -= 20;
    }

    score = score.clamp(0, 100);

    if (score >= 85) {
      return (score: score, level: 'ممتاز', color: Colors.green, hint: 'المزامنة مستقرة.');
    }
    if (score >= 65) {
      return (score: score, level: 'متوسط', color: Colors.orange, hint: 'يوجد مؤشرات تحتاج متابعة.');
    }
    return (score: score, level: 'ضعيف', color: Colors.red, hint: 'يفضل تصدير التشخيص وفحص الربط.');
  }

  ({_SyncCheckLevel level, String message, Color color}) _buildRelatedConsistencyHint(MobileSyncResult result) {
    final payload = result.payloadCounters;
    final writes = result.writeCounters;

    int payloadValue(String key) => payload[key] ?? 0;
    int writtenCount(String keyPrefix) =>
        (writes['${keyPrefix}_inserted'] ?? 0) + (writes['${keyPrefix}_updated'] ?? 0);
    int skippedCount(String keyPrefix) => writes['${keyPrefix}_skipped'] ?? 0;

    final attachmentsPayload = payloadValue('attachments');
    final attachmentsWritten = writtenCount('attachments');
    final attachmentsSkipped = skippedCount('attachments');

    final familyPayload = payloadValue('family_members');
    final familyWritten = writtenCount('family_members');
    final familySkipped = skippedCount('family_members');

    final deadPayload = payloadValue('dead_people');
    final deadWritten = writtenCount('dead_people');
    final deadSkipped = skippedCount('dead_people');

    final warnings = <String>[];
    final infos = <String>[];

    void evaluateEntity({
      required String label,
      required int payloadCount,
      required int written,
      required int skipped,
    }) {
      if (payloadCount <= 0) {
        infos.add('$label: لا يوجد payload جديد');
        return;
      }

      final unresolved = payloadCount - written;
      if (written == 0 && skipped >= payloadCount) {
        warnings.add('$label: تم استلام $payloadCount لكن لم يُكتب أي سجل محلياً');
        return;
      }

      if (unresolved > 0 && unresolved >= (payloadCount * 0.4)) {
        warnings.add('$label: فجوة واضحة بين payload ($payloadCount) والكتابة ($written)');
      } else {
        infos.add('$label: payload=$payloadCount، مكتوب=$written، متخطي=$skipped');
      }
    }

    evaluateEntity(
      label: 'المرفقات',
      payloadCount: attachmentsPayload,
      written: attachmentsWritten,
      skipped: attachmentsSkipped,
    );
    evaluateEntity(
      label: 'أفراد العائلة',
      payloadCount: familyPayload,
      written: familyWritten,
      skipped: familySkipped,
    );
    evaluateEntity(
      label: 'الأموات',
      payloadCount: deadPayload,
      written: deadWritten,
      skipped: deadSkipped,
    );

    if (warnings.isNotEmpty) {
      return (
        level: _SyncCheckLevel.warn,
        color: Colors.orange,
        message: '⚠️ اتساق المزامنة: ${warnings.join(' | ')}',
      );
    }

    return (
      level: _SyncCheckLevel.ok,
      color: Colors.green,
      message: infos.isEmpty ? '✅ اتساق المزامنة جيد.' : '✅ ${infos.join(' | ')}',
    );
  }

  ({int filled, int total, List<TaxonomyGroup> missing}) _coverageFromStats(
    TaxonomyStatistics stats,
    List<TaxonomyGroup> required,
  ) {
    final countByGroup = stats.countByGroup;

    final missing = <TaxonomyGroup>[];
    for (final group in required) {
      final directCount = countByGroup[group] ?? 0;
      if (directCount > 0) {
        continue;
      }

      final equivalents = equivalentBeneficiaryTaxonomyGroups[group] ?? const <TaxonomyGroup>[];
      final hasEquivalent = equivalents.any((equivalent) => (countByGroup[equivalent] ?? 0) > 0);
      if (!hasEquivalent) {
        missing.add(group);
      }
    }

    return (
      filled: required.length - missing.length,
      total: required.length,
      missing: missing,
    );
  }

  ({int filled, int total, List<TaxonomyGroup> missing}) _requiredCoverageFromStats(TaxonomyStatistics stats) {
    return _coverageFromStats(stats, requiredBeneficiaryTaxonomyGroups);
  }

  ({int filled, int total, List<TaxonomyGroup> missing}) _essentialCoverageFromStats(TaxonomyStatistics stats) {
    return _coverageFromStats(stats, essentialBeneficiaryFormTaxonomyGroups);
  }

  List<TaxonomyGroup> _criticalMissingEssentialGroups(List<TaxonomyGroup> missingEssential) {
    const critical = <TaxonomyGroup>{
      TaxonomyGroup.gender,
      TaxonomyGroup.documentType,
      TaxonomyGroup.deathReason,
      TaxonomyGroup.beneficiaryStatus,
      TaxonomyGroup.category,
      TaxonomyGroup.relationship,
    };

    return missingEssential.where(critical.contains).toList(growable: false);
  }

  ({String likelySource, List<String> localMappingSlugs, List<TaxonomyGroup> missingDocumentedGroups})
      _diagnoseTaxonomyGapSource(TaxonomyStatistics stats) {
    const guard = TaxonomyIntegrityGuard();
    final report = guard.assess(stats);

    String source;
    switch (report.likelySource) {
      case TaxonomyGapSource.localMapping:
        source = 'local_mapping';
        break;
      case TaxonomyGapSource.backendPayload:
        source = 'backend_payload';
        break;
      case TaxonomyGapSource.partialPayloadOrData:
        source = 'partial_payload_or_data';
        break;
      case TaxonomyGapSource.none:
        source = 'none';
        break;
    }

    return (
      likelySource: source,
      localMappingSlugs: report.unresolvedDocumentedSlugs,
      missingDocumentedGroups: report.missingDocumentedGroups,
    );
  }

  String _diagnosisLabel(String source) {
    switch (source) {
      case 'local_mapping':
        return 'خلل ربط محلي';
      case 'backend_payload':
        return 'نقص بيانات من السيرفر';
      case 'partial_payload_or_data':
        return 'نقص بيانات جزئي';
      default:
        return 'لا توجد فجوة حرجة';
    }
  }

  Color _diagnosisColor(String source) {
    switch (source) {
      case 'local_mapping':
        return Colors.orange;
      case 'backend_payload':
        return Colors.red;
      case 'partial_payload_or_data':
        return Colors.deepOrange;
      default:
        return Colors.green;
    }
  }

  Future<void> _exportSyncDiagnostics() async {
    if (_lastResult == null) {
      if (!mounted) return;
      EnhancedSnackbar.showInfo(context, message: 'لا يوجد تقرير مزامنة للتصدير');
      return;
    }

    try {
      final now = DateTime.now();
      Map<String, int>? taxonomyGroupCounts;
      List<String>? missingTaxonomyGroups;
      List<String>? essentialMissingTaxonomyGroups;
      List<String>? criticalMissingTaxonomyGroups;
      String? taxonomyLikelyIssueSource;
      List<String>? unresolvedDocumentedSlugs;
      List<String>? missingDocumentedBackendGroups;
      int? localMappingGapCount;
      int? backendPayloadGapCount;

      try {
        final taxonomyStats = await ref.read(taxonomyStatisticsProvider.future);
        final requiredCoverage = _requiredCoverageFromStats(taxonomyStats);
        final essentialCoverage = _essentialCoverageFromStats(taxonomyStats);
        final criticalMissing = _criticalMissingEssentialGroups(essentialCoverage.missing);
        final diagnosis = _diagnoseTaxonomyGapSource(taxonomyStats);
        taxonomyGroupCounts = {
          for (final entry in taxonomyStats.countByGroup.entries) entry.key.value: entry.value,
        };
        missingTaxonomyGroups = requiredCoverage.missing.map((entry) => entry.arabicName).toList();
        essentialMissingTaxonomyGroups = essentialCoverage.missing.map((entry) => entry.arabicName).toList();
        criticalMissingTaxonomyGroups = criticalMissing.map((entry) => entry.arabicName).toList();
        taxonomyLikelyIssueSource = diagnosis.likelySource;
        unresolvedDocumentedSlugs = diagnosis.localMappingSlugs;
        missingDocumentedBackendGroups = diagnosis.missingDocumentedGroups.map((entry) => entry.value).toList();
        localMappingGapCount = diagnosis.localMappingSlugs.length;
        backendPayloadGapCount = diagnosis.missingDocumentedGroups.length;
      } catch (_) {
        taxonomyGroupCounts = null;
        missingTaxonomyGroups = null;
        essentialMissingTaxonomyGroups = null;
        criticalMissingTaxonomyGroups = null;
        taxonomyLikelyIssueSource = null;
        unresolvedDocumentedSlugs = null;
        missingDocumentedBackendGroups = null;
        localMappingGapCount = null;
        backendPayloadGapCount = null;
      }

      final diagnostics = {
        'attachments_telemetry': {
          'attachments_resolved': (_lastResult!.writeCounters['attachments_inserted'] ?? 0) +
              (_lastResult!.writeCounters['attachments_updated'] ?? 0),
          'preview_failed': (_lastResult!.writeCounters['attachments_skipped'] ?? 0),
          'mapping_skipped': (_lastResult!.writeCounters['attachments_skipped'] ?? 0),
        },
        'generated_at': now.toIso8601String(),
        'sync_status': {
          'is_syncing': _status?.isSyncing ?? false,
          'current_operation': _status?.currentOperation,
          'progress': _status?.progress,
          'last_sync_at': _status?.lastSyncAt?.toIso8601String(),
          'last_error': _status?.lastError,
        },
        'last_result': {
          'success': _lastResult!.success,
          'records_synced': _lastResult!.recordsSynced,
          'records_failed': _lastResult!.recordsFailed,
          'payload_counters': _lastResult!.payloadCounters,
          'write_counters': _lastResult!.writeCounters,
          'error': _lastResult!.error,
          'error_category': _lastResult!.errorCategory,
          'error_context': _lastResult!.errorContext,
        },
        'local_stats': _stats,
        'taxonomy_diagnostics': {
          'group_counts': taxonomyGroupCounts,
          'missing_required_groups': missingTaxonomyGroups,
          'missing_essential_form_groups': essentialMissingTaxonomyGroups,
          'missing_critical_form_groups': criticalMissingTaxonomyGroups,
          'likely_issue_source': taxonomyLikelyIssueSource,
          'unresolved_documented_slugs': unresolvedDocumentedSlugs,
          'missing_documented_backend_groups': missingDocumentedBackendGroups,
          'local_mapping_gap_count': localMappingGapCount,
          'backend_payload_gap_count': backendPayloadGapCount,
        },
        'file_id_diagnostics': _fileIdDiagnostics == null
            ? null
            : {
                'available_count': _fileIdDiagnostics!.availableCount,
                'used_unsynced_count': _fileIdDiagnostics!.usedUnsyncedCount,
                'active_reservation_id': _fileIdDiagnostics!.activeReservationId,
                'active_reservation_remaining': _fileIdDiagnostics!.activeReservationRemaining,
                'last_reserved_at': _fileIdDiagnostics!.lastReservedAt?.toIso8601String(),
                'last_synced_at': _fileIdDiagnostics!.lastSyncedAt?.toIso8601String(),
                'remote_unused_count': _fileIdDiagnostics!.remoteUnusedCount,
                'remote_can_request_more': _fileIdDiagnostics!.remoteCanRequestMore,
                'remote_available_slots': _fileIdDiagnostics!.remoteAvailableSlots,
                'last_login_sync_at': _fileIdDiagnostics!.lastLoginSyncAt?.toIso8601String(),
                'last_refill_error_code': _fileIdDiagnostics!.lastRefillErrorCode,
                'last_refill_error_message': _fileIdDiagnostics!.lastRefillErrorMessage,
              },
        'contract_parity_diagnostics': {
          're_people_contract_rows': _stats?['re_people_contract_rows'],
          're_people_contract_missing': _stats?['re_people_contract_missing'],
          'dead_people_contract_rows': _stats?['dead_people_contract_rows'],
          'dead_people_contract_missing': _stats?['dead_people_contract_missing'],
          'attachments_contract_rows': _stats?['attachments_contract_rows'],
          'attachments_contract_missing': _stats?['attachments_contract_missing'],
          'attachments_contract_download_url_count': _stats?['attachments_contract_download_url_count'],
        },
        'recommended_actions': [
          if (missingTaxonomyGroups?.isNotEmpty ?? false) 'sync_taxonomies',
          if (taxonomyLikelyIssueSource == 'backend_payload') 'review_backend_categories_payload',
          if (taxonomyLikelyIssueSource == 'local_mapping') 'review_taxonomy_group_mapping',
          if ((_lastResult?.errorCategory ?? '').isNotEmpty) 'review_error_context',
          if ((_lastResult?.writeCounters['beneficiaries_skipped'] ?? 0) > 0) 'verify_identity_mapping',
          if ((_stats?['assoc_needsSync'] ?? 0) > 0 || (_stats?['rep_needsSync'] ?? 0) > 0) 'run_associations_sync_up',
          if ((_stats?['sponsorship_needsSync'] ?? 0) > 0) 'run_sponsorships_sync_up',
          if ((_stats?['re_people_contract_missing'] ?? 0) > 0 ||
              (_stats?['dead_people_contract_missing'] ?? 0) > 0 ||
              (_stats?['attachments_contract_missing'] ?? 0) > 0)
            'run_contract_parity_backfill',
          if ((_fileIdDiagnostics?.lastRefillErrorCode ?? '') == 'no_codes_available')
            'create_new_codes_batch_on_server',
        ],
      };

      final appDir = await getApplicationDocumentsDirectory();
      final outputFile =
          File('${appDir.path}${Platform.pathSeparator}sync_diagnostics_${now.millisecondsSinceEpoch}.json');
      await outputFile.writeAsString(const JsonEncoder.withIndent('  ').convert(diagnostics));

      await Share.shareXFiles(
        [XFile(outputFile.path)],
        text: 'Sync diagnostics export',
      );

      UxFlowAnalytics.trackDiagnosticsExport(
        success: true,
        source: 'sync_hub',
        viewMode: _syncViewMode.name,
      );

      if (!mounted) return;
      EnhancedSnackbar.showSuccess(context, message: '✅ تم تصدير تقرير التشخيص');
    } catch (e) {
      UxFlowAnalytics.trackDiagnosticsExport(
        success: false,
        source: 'sync_hub',
        viewMode: _syncViewMode.name,
      );
      if (!mounted) return;
      EnhancedSnackbar.showError(context, message: '❌ فشل تصدير تقرير التشخيص: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final uxFlags = ref.watch(uxFeatureFlagsProvider).valueOrNull ?? const UxFeatureFlags();
    final effectiveSyncViewMode = uxFlags.enableSyncDiagnosticMode ? _syncViewMode : _SyncViewMode.operational;

    final status = _status ?? MobileSyncStatus();
    final taxonomySyncStatus = ref.watch(taxonomySyncStatusProvider);
    final taxonomyErrorMessage = ref.watch(taxonomyErrorMessageProvider);
    final taxonomyStatsAsync = ref.watch(taxonomyStatisticsProvider);
    final taxonomyLastSyncAsync = ref.watch(lastSyncTimeProvider);
    final taxonomySyncAsync = ref.watch(taxonomySyncNotifierProvider);
    final isTaxonomySyncing = taxonomySyncStatus == TaxonomySyncStatus.syncing || taxonomySyncAsync.isLoading;
    final syncProgress = ref.watch(syncProgressProvider);
    final fileNumberPoolStatusAsync = ref.watch(fileNumberPoolStatusProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern App Bar - مكون موحد
          ModernSliverAppBar(
            title: 'مزامنة البيانات',
            icon: Icons.sync_rounded,
            actions: [
              ModernActionButton(
                icon: Icons.history,
                tooltip: 'سجل المزامنة',
                onPressed: () {
                  UxFlowAnalytics.trackSyncFunnelTriggered(trigger: 'open_sync_history');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SyncHistoryViewer(),
                    ),
                  );
                },
              ),
              ModernActionButton(
                icon: Icons.refresh,
                tooltip: 'تحديث الإحصائيات',
                onPressed: () {
                  UxFlowAnalytics.trackSyncFunnelTriggered(trigger: 'refresh_stats');
                  _refreshDashboardData();
                },
              ),
              ModernActionButton(
                icon: Icons.ios_share_rounded,
                tooltip: 'تصدير التشخيص',
                onPressed: _exportSyncDiagnostics,
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSyncHubSummaryCard(status),

                  SizedBox(height: 12.h),

                  _buildViewModeSwitcher(enableDiagnosticMode: uxFlags.enableSyncDiagnosticMode),

                  SizedBox(height: 20.h),

                  // Primary actions
                  _buildSyncButtons(status),

                  SizedBox(height: 20.h),

                  // Status card
                  _buildStatusCard(status),

                  SizedBox(height: 12.h),

                  _buildSyncProgressCard(syncProgress),

                  if (_lastBeneficiaryUploadSummary != null) ...[
                    SizedBox(height: 12.h),
                    _buildBeneficiaryUploadSummaryCard(_lastBeneficiaryUploadSummary!),
                  ],

                  SizedBox(height: 12.h),

                  _buildFileNumberPoolStatusCard(fileNumberPoolStatusAsync),

                  SizedBox(height: 12.h),

                  _buildMaintenanceToolsCard(),

                  SizedBox(height: 12.h),

                  // Operational constraints (secondary)
                  _buildWarningCard(),

                  SizedBox(height: 20.h),

                  if (_stats != null && effectiveSyncViewMode == _SyncViewMode.operational) ...[
                    _buildOperationalStatsSummaryCard(),
                    if (_showDetailedStatsInOperational) ...[
                      SizedBox(height: 12.h),
                      _buildStatsCard(),
                    ],
                    SizedBox(height: 20.h),
                  ],

                  if (_stats != null && effectiveSyncViewMode == _SyncViewMode.diagnostic) ...[
                    _buildStatsCard(),
                    SizedBox(height: 20.h),
                  ],

                  if (effectiveSyncViewMode == _SyncViewMode.diagnostic) ...[
                    _buildTaxonomyDiagnosticsCard(
                      syncStatus: taxonomySyncStatus,
                      errorMessage: taxonomyErrorMessage,
                      statsAsync: taxonomyStatsAsync,
                      lastSyncAsync: taxonomyLastSyncAsync,
                      isSyncing: isTaxonomySyncing,
                    ),
                    SizedBox(height: 20.h),
                    if (_fileIdDiagnostics != null) _buildFileIdDiagnosticsCard(_fileIdDiagnostics!),
                    if (_fileIdDiagnostics != null) SizedBox(height: 20.h),
                    if (_lastResult != null)
                      _buildResultCard(
                        _lastResult!,
                        timestamp: _lastResultAt,
                        operation: _lastResultOperation,
                        source: _lastResultSource,
                      ),
                    SizedBox(height: 20.h),
                    _buildInfoCard(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeSwitcher({required bool enableDiagnosticMode}) {
    return SyncSectionCard(
      title: 'وضع الشاشة',
      icon: Icons.tune_rounded,
      tone: SyncTone.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              Semantics(
                label: 'وضع المزامنة التشغيلي',
                button: true,
                child: ChoiceChip(
                  label: const Text('تشغيلي'),
                  selected: _syncViewMode == _SyncViewMode.operational,
                  onSelected: (_) {
                    setState(() {
                      _syncViewMode = _SyncViewMode.operational;
                    });
                    UxFlowAnalytics.trackSyncModeChanged(mode: _syncViewMode.name);
                  },
                ),
              ),
              Semantics(
                label: 'وضع المزامنة التشخيصي',
                button: true,
                enabled: enableDiagnosticMode,
                child: ChoiceChip(
                  label: const Text('تشخيصي'),
                  selected: _syncViewMode == _SyncViewMode.diagnostic,
                  onSelected: enableDiagnosticMode
                      ? (_) {
                          setState(() {
                            _syncViewMode = _SyncViewMode.diagnostic;
                          });
                          UxFlowAnalytics.trackSyncModeChanged(mode: _syncViewMode.name);
                        }
                      : null,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            !enableDiagnosticMode
                ? 'الوضع التشخيصي معطّل حاليًا عبر rollout flags.'
                : (_syncViewMode == _SyncViewMode.operational
                    ? 'يعرض الإجراءات والحالة الأساسية فقط.'
                    : 'يعرض كل بطاقات التشخيص والتفاصيل التقنية.'),
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard() {
    return const SyncSectionCard(
      title: 'ملاحظات تشغيلية',
      icon: Icons.warning_amber_rounded,
      tone: SyncTone.warning,
      child: Text(
        '• عند التعارض، بيانات السيرفر هي المرجع.\n'
        '• السجلات المحذوفة لا تُرفع تلقائيًا.\n'
        '• استخدم تصدير التشخيص عند تكرار الفشل.',
      ),
    );
  }

  Widget _buildMaintenanceToolsCard() {
    final isSyncing = (_status?.isSyncing ?? false) || ref.watch(syncProgressProvider).isRunning;
    return SyncSectionCard(
      title: 'أدوات الصيانة',
      icon: Icons.build_circle_outlined,
      tone: SyncTone.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: isSyncing ? null : _resetBeneficiariesAndRestore,
            icon: const Icon(Icons.cleaning_services_outlined),
            label: const Text('مسح بيانات المستفيدين محلياً وإعادة التنزيل'),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              OutlinedButton.icon(
                onPressed: isSyncing ? null : _resetTaxonomiesOnly,
                icon: const Icon(Icons.category_outlined),
                label: const Text('Reset التصنيفات فقط'),
              ),
              OutlinedButton.icon(
                onPressed: isSyncing ? null : _resetFileNumbersOnly,
                icon: const Icon(Icons.confirmation_num_outlined),
                label: const Text('Reset أرقام الملفات فقط'),
              ),
              OutlinedButton.icon(
                onPressed: _checkFirestoreConnection,
                icon: const Icon(Icons.wifi_tethering_outlined),
                label: const Text('فحص اتصال Firestore'),
              ),
              OutlinedButton.icon(
                onPressed: _checkFirestorePermissions,
                icon: const Icon(Icons.admin_panel_settings_outlined),
                label: const Text('فحص الصلاحيات'),
              ),
              OutlinedButton.icon(
                onPressed: _exportSyncDiagnostics,
                icon: const Icon(Icons.description_outlined),
                label: const Text('تصدير تقرير المزامنة'),
              ),
              OutlinedButton.icon(
                onPressed: isSyncing ? null : () => _seedCedarAssociationsFromSync(force: false),
                icon: const Icon(Icons.playlist_add_check_circle_outlined),
                label: const Text('إضافة جمعيات Cedar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOperationalStatsSummaryCard() {
    final stats = _stats;
    if (stats == null) return const SizedBox.shrink();

    final benNeedsSync = stats['ben_needsSync'] ?? 0;
    final benPending = stats['ben_pending'] ?? 0;
    final benModified = stats['ben_modified'] ?? 0;
    final benFailed = stats['ben_failed'] ?? 0;
    final benReadyToUpload = benPending + benModified + benFailed;
    final assocNeedsSync = stats['assoc_needsSync'] ?? 0;
    final repNeedsSync = stats['rep_needsSync'] ?? 0;
    final sponsorshipNeedsSync = stats['sponsorship_needsSync'] ?? 0;
    final visitsNeedsSync = stats['visits_needsSync'] ?? 0;
    final followupsNeedsSync = (stats['followup_pending'] ?? 0) + (stats['followup_failed'] ?? 0);
    final totalNeedsSync = stats['total_pending_uploads'] ??
        (benNeedsSync + assocNeedsSync + repNeedsSync + sponsorshipNeedsSync + visitsNeedsSync + followupsNeedsSync);

    return SyncSectionCard(
      title: 'ملخص الحالة',
      icon: Icons.assessment_rounded,
      tone: totalNeedsSync > 0 ? SyncTone.warning : SyncTone.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('إجمالي الكيانات', '${stats['total'] ?? 0}'),
          _buildInfoRow(
            'يحتاج مزامنة',
            '$totalNeedsSync',
          ),
          _buildInfoRow('المستفيدون (غير متزامن)', '$benNeedsSync'),
          _buildInfoRow('الزيارات (غير متزامن)', '$visitsNeedsSync'),
          _buildInfoRow('المتابعات (غير متزامن)', '$followupsNeedsSync'),
          Divider(height: 18.h),
          _buildInfoRow('جاهز للرفع الآن (مستفيدون)', '$benReadyToUpload'),
          _buildInfoRow('بانتظار الرفع', '$benPending'),
          _buildInfoRow('محدّث (غير مزامن)', '$benModified'),
          _buildInfoRow('فشل سابق (سيُعاد رفعه)', '$benFailed'),
          if (benReadyToUpload == 0)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                totalNeedsSync == 0
                    ? 'لا توجد تغييرات قابلة للرفع حاليًا.'
                    : 'توجد تغييرات في موديولات أخرى بانتظار الرفع.',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
              ),
            ),
          SizedBox(height: 8.h),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _showDetailedStatsInOperational = !_showDetailedStatsInOperational;
                });
              },
              icon: Icon(_showDetailedStatsInOperational ? Icons.expand_less : Icons.expand_more),
              label: Text(_showDetailedStatsInOperational ? 'إخفاء التفاصيل' : 'عرض التفاصيل'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    if (_stats == null) return const SizedBox.shrink();

    return Column(
      children: [
        SyncSectionCard(
          title: 'إحصائيات المستفيدين',
          icon: Icons.people,
          tone: SyncTone.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatRow('إجمالي المستفيدين', '${_stats!['ben_total']}', Colors.blue),
              _buildStatRow('متزامن', '${_stats!['ben_synced']}', Colors.green),
              _buildStatRow('بانتظار الرفع', '${_stats!['ben_pending']}', Colors.orange),
              _buildStatRow('محدّث (غير مزامن)', '${_stats!['ben_modified']}', Colors.orange),
              _buildStatRow('معزول بسبب فشل الرفع', '${_stats!['ben_failed']}', Colors.red),
              if ((_stats!['ben_failed'] ?? 0) > 0 && _beneficiariesLastSyncError != null) ...[
                SizedBox(height: 8.h),
                Text(
                  'آخر سبب: ${_beneficiariesLastSyncError!.length > 140 ? '${_beneficiariesLastSyncError!.substring(0, 140)}…' : _beneficiariesLastSyncError!}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              Divider(height: 20.h),
              _buildStatRow(
                'يحتاج مزامنة (مستفيدين)',
                '${_stats!['ben_needsSync']}',
                _stats!['ben_needsSync']! > 0 ? Colors.red : Colors.green,
                bold: true,
              ),
              _buildStatRow(
                'يحتاج مزامنة (زيارات)',
                '${_stats!['visits_needsSync'] ?? 0}',
                (_stats!['visits_needsSync'] ?? 0) > 0 ? Colors.red : Colors.green,
              ),
              _buildStatRow(
                'يحتاج مزامنة (متابعات)',
                '${(_stats!['followup_pending'] ?? 0) + (_stats!['followup_failed'] ?? 0)}',
                ((_stats!['followup_pending'] ?? 0) + (_stats!['followup_failed'] ?? 0)) > 0
                    ? Colors.red
                    : Colors.green,
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        SyncSectionCard(
          title: 'إحصائيات الجمعيات',
          icon: Icons.business,
          tone: SyncTone.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatRow('إجمالي الجمعيات', '${_stats!['assoc_total']}', Colors.purple),
              _buildStatRow('جمعيات نشطة', '${_stats!['assoc_active']}', Colors.green),
              _buildStatRow(
                'جمعيات غير نشطة',
                '${_stats!['assoc_total']! - _stats!['assoc_active']!}',
                Colors.grey,
              ),
              Divider(height: 20.h),
              _buildStatRow('إجمالي الموظفين/المندوبين', '${_stats!['rep_total']}', Colors.purple),
              _buildStatRow('موظفون بانتظار الرفع', '${_stats!['rep_pending']}', Colors.orange),
              _buildStatRow('موظفون محدّثون', '${_stats!['rep_modified']}', Colors.orange),
              _buildStatRow(
                'موظفون يحتاجون مزامنة',
                '${_stats!['rep_needsSync']}',
                _stats!['rep_needsSync']! > 0 ? Colors.red : Colors.green,
                bold: true,
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        SyncSectionCard(
          title: 'إحصائيات الكفالات',
          icon: Icons.handshake,
          tone: SyncTone.tertiary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatRow('إجمالي الكفالات', '${_stats!['sponsorship_total']}', Colors.orange),
              _buildStatRow('متزامن', '${_stats!['sponsorship_synced']}', Colors.green),
              _buildStatRow('بانتظار الرفع', '${_stats!['sponsorship_pending']}', Colors.orange),
              _buildStatRow('محدّث (غير مزامن)', '${_stats!['sponsorship_modified']}', Colors.orange),
              Divider(height: 20.h),
              _buildStatRow(
                'يحتاج مزامنة',
                '${_stats!['sponsorship_needsSync']}',
                _stats!['sponsorship_needsSync']! > 0 ? Colors.red : Colors.green,
                bold: true,
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        SyncSectionCard(
          title: 'إحصائيات البيانات المرتبطة',
          icon: Icons.dataset_linked,
          tone: SyncTone.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatRow('المرفقات (محلي)', '${_stats!['attachments_total']}', Colors.teal),
              _buildStatRow('أفراد العائلة (محلي)', '${_stats!['family_members_total']}', Colors.teal),
              _buildStatRow('الأموات (محلي)', '${_stats!['dead_people_total']}', Colors.teal),
              Divider(height: 20.h),
              _buildStatRow('Parity re_people (sidecar)', '${_stats!['re_people_contract_rows'] ?? 0}', Colors.indigo),
              _buildStatRow(
                  'Parity dead_people (sidecar)', '${_stats!['dead_people_contract_rows'] ?? 0}', Colors.indigo),
              _buildStatRow(
                  'Parity attachments (sidecar)', '${_stats!['attachments_contract_rows'] ?? 0}', Colors.indigo),
              _buildStatRow(
                'فجوة parity re_people',
                '${_stats!['re_people_contract_missing'] ?? 0}',
                (_stats!['re_people_contract_missing'] ?? 0) > 0 ? Colors.red : Colors.green,
                bold: true,
              ),
              _buildStatRow(
                'فجوة parity dead_people',
                '${_stats!['dead_people_contract_missing'] ?? 0}',
                (_stats!['dead_people_contract_missing'] ?? 0) > 0 ? Colors.red : Colors.green,
                bold: true,
              ),
              _buildStatRow(
                'فجوة parity attachments',
                '${_stats!['attachments_contract_missing'] ?? 0}',
                (_stats!['attachments_contract_missing'] ?? 0) > 0 ? Colors.red : Colors.green,
                bold: true,
              ),
              if ((_stats!['re_people_contract_missing'] ?? 0) > 0 ||
                  (_stats!['dead_people_contract_missing'] ?? 0) > 0 ||
                  (_stats!['attachments_contract_missing'] ?? 0) > 0) ...[
                SizedBox(height: 10.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: _runContractParityBackfill,
                    icon: const Icon(Icons.auto_fix_high_rounded),
                    label: const Text('تشغيل backfill parity'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    Color color, {
    bool bold = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: color),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(MobileSyncStatus status) {
    final theme = Theme.of(context);
    final currentUser = FirebaseAuth.instance.currentUser;
    final isFirebaseMode = BackendConfig.current.flavor == BackendFlavor.firebase;
    final pendingUploads = _stats?['total_pending_uploads'] ?? 0;
    final failedUploads =
        (_stats?['ben_failed'] ?? 0) + (_stats?['visits_failed'] ?? 0) + (_stats?['sponsorship_failed'] ?? 0);
    final localCount = _stats?['ben_total'] ?? 0;

    String _labelForSource(String value) {
      switch (value) {
        case 'background':
          return 'من الخلفية';
        case 'foreground':
          return 'من الواجهة';
        default:
          return value;
      }
    }

    return SyncSectionCard(
      title: 'حالة المزامنة',
      icon: status.isSyncing ? Icons.sync : Icons.check_circle,
      tone: status.isSyncing ? SyncTone.primary : SyncTone.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isFirebaseMode) ...[
            _buildInfoRow('Firebase', currentUser != null ? 'متصل' : 'غير متصل'),
            _buildInfoRow('المستخدم الحالي', currentUser?.email ?? currentUser?.uid ?? 'غير مسجل'),
            _buildInfoRow('آخر رفع', _lastUploadAt == null ? 'لا يوجد' : _formatDateTime(_lastUploadAt!)),
            _buildInfoRow('آخر تنزيل', _lastDownloadAt == null ? 'لا يوجد' : _formatDateTime(_lastDownloadAt!)),
            _buildInfoRow('بانتظار الرفع', '$pendingUploads'),
            _buildInfoRow('فشل الرفع', '$failedUploads'),
            _buildInfoRow('عدد المستفيدين محلياً', '$localCount'),
            _buildInfoRow('عدد المستفيدين على Firebase', _remoteBeneficiariesCount?.toString() ?? 'غير متاح'),
            SizedBox(height: 10.h),
          ],
          if (!status.isSyncing && _lastResultSource != null && _lastResultSource!.trim().isNotEmpty) ...[
            Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.10),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.45)),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                'آخر نتيجة: ${_labelForSource(_lastResultSource!)}',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.blue[900],
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          SyncStatusBanner(
            message: status.currentOperation.trim().isEmpty ? 'لا يوجد نشاط مزامنة حاليًا' : status.currentOperation,
            tone: status.isSyncing ? SyncTone.primary : SyncTone.success,
            icon: status.isSyncing ? Icons.sync_rounded : Icons.check_circle,
          ),
          if (status.isSyncing) ...[
            SizedBox(height: 12.h),
            LinearProgressIndicator(
              value: status.progress,
              minHeight: 8.h,
              borderRadius: BorderRadius.circular(4.r),
            ),
            SizedBox(height: 4.h),
            Text(
              '${(status.progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 12.sp, color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
          SizedBox(height: 12.h),
          _buildSyncProgressStepper(status),
          if (status.lastSyncAt != null) ...[
            SizedBox(height: 12.h),
            Text(
              'آخر مزامنة: ${_formatDateTime(status.lastSyncAt!)}',
              style: TextStyle(fontSize: 12.sp, color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
          if (status.lastError != null) ...[
            SizedBox(height: 12.h),
            SyncStatusBanner(
              message: status.lastError!.trim().isEmpty ? 'حدث خطأ غير معروف أثناء المزامنة' : status.lastError!,
              tone: SyncTone.error,
              icon: Icons.error,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSyncButtons(MobileSyncStatus status) {
    final theme = Theme.of(context);
    final isSyncing = status.isSyncing || ref.watch(syncProgressProvider).isRunning;
    final taxonomyStats = ref.watch(taxonomyStatisticsProvider).valueOrNull;
    final filePool = ref.watch(fileNumberPoolStatusProvider).valueOrNull;

    final taxonomyFilled = taxonomyStats == null ? null : _requiredCoverageFromStats(taxonomyStats).filled;
    final taxonomyTotal = taxonomyStats == null ? null : _requiredCoverageFromStats(taxonomyStats).total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SyncSectionCard(
          title: 'رفع البيانات',
          icon: Icons.cloud_upload_outlined,
          tone: SyncTone.tertiary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: isSyncing ? null : _syncUp,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('رفع التغييرات'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  backgroundColor: theme.colorScheme.tertiary,
                  foregroundColor: theme.colorScheme.onTertiary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        SyncSectionCard(
          title: 'تنزيل البيانات',
          icon: Icons.cloud_download_outlined,
          tone: SyncTone.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: isSyncing ? null : _syncDown,
                icon: const Icon(Icons.cloud_download),
                label: const Text('تنزيل البيانات من Firebase'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        SyncSectionCard(
          title: 'التصنيفات',
          icon: Icons.category_outlined,
          tone: SyncTone.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (taxonomyFilled != null && taxonomyTotal != null)
                _buildInfoRow('تغطية التصنيفات', '$taxonomyFilled/$taxonomyTotal'),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  ElevatedButton.icon(
                    onPressed: isSyncing ? null : _syncTaxonomies,
                    icon: const Icon(Icons.sync),
                    label: const Text('مزامنة التصنيفات'),
                  ),
                  OutlinedButton.icon(
                    onPressed: isSyncing ? null : _exportSyncDiagnostics,
                    icon: const Icon(Icons.fact_check_outlined),
                    label: const Text('فحص التغطية'),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        SyncSectionCard(
          title: 'أرقام الملفات',
          icon: Icons.confirmation_num_outlined,
          tone: SyncTone.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('المتاح محلياً', '${filePool?.available ?? '-'}'),
              _buildInfoRow('المعيّن محلياً', '${filePool?.pendingAssigned ?? '-'}'),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  ElevatedButton.icon(
                    onPressed: isSyncing ? null : _uploadCedarFileNumbers,
                    icon: const Icon(Icons.confirmation_num_rounded),
                    label: const Text('حجز/رفع أرقام ملفات Cedar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: isSyncing ? null : () => ref.invalidate(fileNumberPoolStatusProvider),
                    icon: const Icon(Icons.search),
                    label: const Text('فحص أرقام الملفات'),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        ElevatedButton.icon(
          onPressed: isSyncing ? null : _syncNowOfficial,
          icon: const Icon(Icons.sync),
          label: const Text('مزامنة كاملة'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }

  Future<void> _syncTaxonomyMasterDataForUpload({
    required String trigger,
    required bool force,
    bool showSuccessSnackbar = false,
  }) async {
    final isRunning = ref.read(isTaxonomyMasterSyncRunningProvider);
    if (isRunning) {
      return;
    }

    ref.read(isTaxonomyMasterSyncRunningProvider.notifier).state = true;
    _lastSyncResumeOperation = 'taxonomy_upload';
    final syncController = ref.read(syncControllerProvider.notifier);
    syncController.start(
      operation: 'taxonomy_upload',
      phase: 'preparing',
      total: 208,
      message: 'جاري رفع التصنيفات الأساسية...',
    );
    try {
      final report = await ref.read(firestoreTaxonomySeederProvider).seedFirestoreTaxonomies(
            force: force,
            trigger: trigger,
            onProgress: (progress) {
              syncController.update(
                phase: progress.phase,
                total: progress.total,
                processed: progress.processed,
                created: progress.created,
                skipped: progress.skipped,
                updated: progress.updated,
                failed: progress.failed,
                pending: progress.pending,
                currentItemId: progress.currentItemId,
                currentGroup: progress.currentGroup,
                message: progress.message,
                errorCode: progress.errorCode,
                errorMessage: progress.errorMessage,
                failures: progress.failures
                    .map(
                      (f) => SyncFailure(
                        itemId: f.documentId,
                        group: f.group,
                        code: f.errorCode,
                        message: f.message,
                      ),
                    )
                    .toList(growable: false),
              );
            },
          );

      await ref.read(taxonomyFirestoreHydratorProvider).hydrateAllGroups();

      final stats = await ref.read(taxonomyStatisticsProvider.future);
      final requiredCoverage = _requiredCoverageFromStats(stats);
      final missingGroups = requiredCoverage.missing.map((entry) => entry.value).toList(growable: false);

      if (missingGroups.isNotEmpty) {
        syncController.fail(
          phase: 'failed',
          errorCode: 'missing_taxonomy_groups',
          errorMessage: missingGroups.join(', '),
          message: 'Missing taxonomy groups after sync.',
        );
      } else if (report.pausedDueToNetwork) {
        syncController.pause(
          phase: 'paused_due_to_network',
          errorCode: 'unavailable',
          errorMessage: report.message,
          message: 'انقطع الاتصال، يمكنك المتابعة عند رجوع الإنترنت',
        );
      } else if (report.pending > 0 || report.failed > 0) {
        syncController.fail(
          phase: 'failed',
          errorCode: 'partial_failure',
          errorMessage: report.message ?? 'Some taxonomy items are still pending.',
          message: 'تمت مزامنة جزئية للتصنيفات.',
        );
      } else {
        syncController.complete(message: 'اكتمل رفع التصنيفات الأساسية بنجاح.');
      }

      if (!mounted) {
        return;
      }

      if (showSuccessSnackbar || report.failed > 0) {
        final suffix = report.failed == 0 ? '' : ' (فشل: ${report.failed})';
        EnhancedSnackbar.showSuccess(
          context,
          message:
              'Taxonomy master sync $_taxonomySeedVersion: prepared=${report.prepared}, created=${report.created}, skipped=${report.skipped}, updated=${report.updated}, pending=${report.pending}$suffix',
        );
      }
    } catch (e) {
      syncController.fail(
        phase: 'failed',
        errorCode: 'exception',
        errorMessage: e.toString(),
        message: 'فشل Taxonomy master sync.',
      );
      if (!mounted) {
        return;
      }
      EnhancedSnackbar.showError(context, message: '❌ فشل Taxonomy master sync: $e');
    } finally {
      ref.read(isTaxonomyMasterSyncRunningProvider.notifier).state = false;
    }
  }

  Future<void> _resumeSyncFromProgressState(SyncProgressState progress) async {
    switch (_lastSyncResumeOperation ?? progress.operation) {
      case 'taxonomy_upload':
        await _syncTaxonomyMasterDataForUpload(
          trigger: 'sync_page_resume_taxonomy_upload',
          force: false,
          showSuccessSnackbar: true,
        );
        break;
      case 'full_download':
        await _syncDown();
        break;
      case 'full_upload':
        await _syncUp();
        break;
      default:
        await _syncNowOfficial();
        break;
    }
  }

  Widget _buildSyncProgressCard(SyncProgressState progress) {
    if (progress.operation == 'idle' && !progress.isRunning && progress.phase == 'idle') {
      return const SizedBox.shrink();
    }

    final percentText = '${(progress.percent * 100).toStringAsFixed(0)}%';
    final canResume = progress.phase == 'paused_due_to_network' || progress.pending > 0;
    final canRetry = progress.phase == 'failed';
    final previewFailures = progress.failures.take(10).toList(growable: false);
    final operationLabel = _operationLabel(progress.operation);
    final phaseLabel = _phaseLabel(progress.phase);

    return SyncSectionCard(
      title: 'تقدم المزامنة',
      icon: progress.isRunning ? Icons.sync_rounded : Icons.task_alt_rounded,
      tone: progress.phase == 'failed'
          ? SyncTone.error
          : (progress.phase == 'paused_due_to_network' ? SyncTone.warning : SyncTone.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(progress.message ?? 'جاري تنفيذ المزامنة...',
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 4.h),
          Text('العملية: $operationLabel', style: TextStyle(fontSize: 12.sp, color: Colors.grey[700])),
          SizedBox(height: 8.h),
          LinearProgressIndicator(
            value: progress.total <= 0 ? null : progress.percent,
            minHeight: 8.h,
            borderRadius: BorderRadius.circular(4.r),
          ),
          SizedBox(height: 8.h),
          Text('$percentText - ${progress.processed}/${progress.total}', style: TextStyle(fontSize: 12.sp)),
          SizedBox(height: 6.h),
          Text('المرحلة: $phaseLabel', style: TextStyle(fontSize: 12.sp)),
          Text(
              'Created: ${progress.created} | Skipped: ${progress.skipped} | Updated: ${progress.updated} | Failed: ${progress.failed}',
              style: TextStyle(fontSize: 12.sp)),
          Text('Pending: ${progress.pending}', style: TextStyle(fontSize: 12.sp)),
          if (progress.fileNumberRangeStart != null && progress.fileNumberRangeEnd != null)
            Text(
              'النطاق: ${progress.fileNumberRangeStart} إلى ${progress.fileNumberRangeEnd}',
              style: TextStyle(fontSize: 12.sp),
            ),
          if (progress.fileNumbersAvailable != null)
            Text(
              'الأرقام المتاحة محلياً: ${progress.fileNumbersAvailable}',
              style: TextStyle(fontSize: 12.sp),
            ),
          if (progress.currentGroup != null || progress.currentItemId != null)
            Text(
              'Group: ${progress.currentGroup ?? '-'} | Item: ${progress.currentItemId ?? '-'}',
              style: TextStyle(fontSize: 12.sp),
            ),
          if (progress.errorMessage != null && progress.errorMessage!.trim().isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              progress.errorMessage!,
              style: TextStyle(fontSize: 12.sp, color: Colors.red[800], fontWeight: FontWeight.w600),
            ),
          ],
          if (previewFailures.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              'آخر الأخطاء (${previewFailures.length}/${progress.failures.length}):',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.red[900]),
            ),
            SizedBox(height: 4.h),
            for (final failure in previewFailures)
              Text(
                '- ${failure.group ?? 'group?'} / ${failure.itemId}: ${failure.code ?? 'error'}',
                style: TextStyle(fontSize: 11.sp, color: Colors.red[800]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              if (canResume)
                OutlinedButton.icon(
                  onPressed: progress.isRunning ? null : () => _resumeSyncFromProgressState(progress),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('متابعة'),
                ),
              if (canRetry)
                OutlinedButton.icon(
                  onPressed: progress.isRunning ? null : () => _resumeSyncFromProgressState(progress),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('إعادة المحاولة'),
                ),
              OutlinedButton.icon(
                onPressed: progress.isRunning
                    ? () {
                        ref.read(syncControllerProvider.notifier).pause(
                              phase: 'paused',
                              message: 'تم إيقاف العملية من المستخدم',
                            );
                      }
                    : null,
                icon: const Icon(Icons.pause_circle_outline_rounded),
                label: const Text('إيقاف'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _phaseLabel(String phase) {
    switch (phase) {
      case 'preparing':
        return 'جاري التحضير';
      case 'uploading':
      case 'beneficiary_upload':
        return 'جاري الرفع';
      case 'downloading':
        return 'جاري التنزيل';
      case 'merging_local':
        return 'جاري الدمج محلياً';
      case 'confirming_file_number':
      case 'confirming_file_numbers':
        return 'جاري تأكيد أرقام الملفات';
      case 'completed':
        return 'اكتملت المزامنة';
      case 'failed':
        return 'فشلت المزامنة';
      case 'paused_due_to_network':
        return 'انقطع الاتصال، يمكن إعادة المحاولة';
      default:
        return phase;
    }
  }

  String _operationLabel(String operation) {
    switch (operation) {
      case 'beneficiary_upload':
        return 'رفع المستفيدين';
      case 'beneficiary_download':
      case 'full_download':
        return 'تنزيل المستفيدين';
      case 'taxonomy_upload':
        return 'رفع التصنيفات';
      case 'taxonomy_download':
        return 'تنزيل التصنيفات';
      case 'cedar_file_numbers_upload':
      case 'file_number_reservation':
        return 'إدارة أرقام الملفات';
      case 'full_sync':
      case 'background_sync':
        return 'مزامنة كاملة';
      case 'association_upload':
        return 'رفع الجمعيات';
      case 'sponsorship_upload':
        return 'رفع الكفالات';
      case 'visit_upload':
        return 'رفع الزيارات';
      case 'followup_upload':
        return 'رفع المتابعات';
      default:
        return operation;
    }
  }

  Widget _buildBeneficiaryUploadSummaryCard(BeneficiaryUploadSummary summary) {
    final tone = summary.failed > 0 ? SyncTone.warning : SyncTone.success;
    final title = summary.failed > 0 ? 'ملخص رفع التغييرات (جزئي)' : 'ملخص رفع التغييرات';

    return SyncSectionCard(
      title: title,
      icon: Icons.fact_check_rounded,
      tone: tone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('إجمالي المعلق: ${summary.totalPending}',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 4.h),
          Text('تم الرفع بنجاح: ${summary.uploaded}', style: TextStyle(fontSize: 12.sp)),
          Text('فشل: ${summary.failed}', style: TextStyle(fontSize: 12.sp)),
          Text('تم التخطي: ${summary.skipped}', style: TextStyle(fontSize: 12.sp)),
          Text('تم تأكيد أرقام الملفات: ${summary.fileNumbersConfirmed}', style: TextStyle(fontSize: 12.sp)),
          Text('بيانات مرفقات مرفوعة: ${summary.attachmentsUploaded}', style: TextStyle(fontSize: 12.sp)),
          Text('آخر مزامنة: ${_formatDateTime(summary.completedAt)}', style: TextStyle(fontSize: 12.sp)),
          if (summary.failed > 0) ...[
            SizedBox(height: 8.h),
            Text(
              'فشل رفع ${summary.failed} مستفيد، يمكنك إعادة المحاولة.',
              style: TextStyle(fontSize: 12.sp, color: Colors.orange[900], fontWeight: FontWeight.w700),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTaxonomyDiagnosticsCard({
    required TaxonomySyncStatus syncStatus,
    required String? errorMessage,
    required AsyncValue<TaxonomyStatistics> statsAsync,
    required AsyncValue<DateTime?> lastSyncAsync,
    required bool isSyncing,
  }) {
    String statusLabel;

    switch (syncStatus) {
      case TaxonomySyncStatus.syncing:
        statusLabel = 'جاري المزامنة';
        break;
      case TaxonomySyncStatus.success:
        statusLabel = 'متزامنة';
        break;
      case TaxonomySyncStatus.error:
        statusLabel = 'فشل';
        break;
      case TaxonomySyncStatus.idle:
        statusLabel = 'غير متحقق';
        break;
    }

    return SyncSectionCard(
      title: 'تشخيص التصنيفات',
      icon: Icons.category_rounded,
      tone: SyncTone.tertiary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SyncStatusBanner(
            message: statusLabel,
            tone: syncStatus == TaxonomySyncStatus.error
                ? SyncTone.error
                : (syncStatus == TaxonomySyncStatus.success ? SyncTone.success : SyncTone.primary),
            icon: syncStatus == TaxonomySyncStatus.error
                ? Icons.error_outline
                : (syncStatus == TaxonomySyncStatus.success ? Icons.check_circle_outline : Icons.sync_rounded),
          ),
          SizedBox(height: 12.h),
          statsAsync.when(
            data: (stats) {
              final requiredCoverage = _requiredCoverageFromStats(stats);
              final essentialCoverage = _essentialCoverageFromStats(stats);
              final criticalMissing = _criticalMissingEssentialGroups(essentialCoverage.missing);
              final diagnosis = _diagnoseTaxonomyGapSource(stats);
              final nonEmptyGroups = stats.countByGroup.entries.where((entry) => entry.value > 0).length;
              final missingGroups = requiredCoverage.missing.map((entry) => entry.arabicName).toList();
              final missingEssentialGroups = essentialCoverage.missing.map((entry) => entry.arabicName).toList();
              final missingCriticalGroups = criticalMissing.map((entry) => entry.arabicName).toList();
              final missingDocumentedGroups =
                  diagnosis.missingDocumentedGroups.map((entry) => entry.arabicName).toList();
              final diagnosisColor = _diagnosisColor(diagnosis.likelySource);
              final diagnosisLabel = _diagnosisLabel(diagnosis.likelySource);
              final localMappingGapCount = diagnosis.localMappingSlugs.length;
              final backendPayloadGapCount = diagnosis.missingDocumentedGroups.length;
              final isLocalMappingIssue = diagnosis.likelySource == 'local_mapping';
              final isBackendPayloadIssue = diagnosis.likelySource == 'backend_payload';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: diagnosisColor.withValues(alpha: 0.12),
                      border: Border.all(color: diagnosisColor.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      'المصدر المرجّح: $diagnosisLabel',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: diagnosisColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (isLocalMappingIssue) ...[
                    Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.10),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        '⚠️ مشكلة ربط محلي: بعض slugs الموثقة غير محلولة محليًا. الإجراء: افتح اختبار الربط ثم صدّر التشخيص.',
                        style: TextStyle(fontSize: 11.sp, color: Colors.orange[900], fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                  if (isBackendPayloadIssue) ...[
                    Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        '⛔ نقص من السيرفر: مجموعات موثقة مفقودة في payload. الإجراء: أعد مزامنة التصنيفات ثم صدّر تقرير التشخيص وراجعه مع الـ backend.',
                        style: TextStyle(fontSize: 11.sp, color: Colors.red[900], fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                  _buildInfoRow('إجمالي التصنيفات', '${stats.totalCount}'),
                  _buildInfoRow('النشطة', '${stats.activeCount}'),
                  _buildInfoRow(
                    'تغطية مجموعات المستفيد (أساسي)',
                    '${requiredCoverage.filled}/${requiredCoverage.total}',
                  ),
                  _buildInfoRow(
                    'تغطية فورم المستفيد (Essential)',
                    '${essentialCoverage.filled}/${essentialCoverage.total}',
                  ),
                  _buildInfoRow('المجموعات المعبأة (كل النظام)', '$nonEmptyGroups/${stats.countByGroup.length}'),
                  _buildInfoRow('عدد فجوات الربط المحلي', '$localMappingGapCount'),
                  _buildInfoRow('عدد فجوات Payload من السيرفر', '$backendPayloadGapCount'),
                  if (missingGroups.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    Text(
                      'المجموعات الناقصة (أساسي): ${missingGroups.join('، ')}',
                      style: TextStyle(fontSize: 12.sp, color: Colors.red[800]),
                    ),
                  ],
                  if (missingEssentialGroups.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    Text(
                      'المجموعات الناقصة (Essential): ${missingEssentialGroups.join('، ')}',
                      style: TextStyle(fontSize: 12.sp, color: Colors.red[900]),
                    ),
                  ],
                  if (missingCriticalGroups.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    Text(
                      'نقص حرج للفورم: ${missingCriticalGroups.join('، ')}',
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.red[900]),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'نفّذ مزامنة التصنيفات الآن، وإذا استمر النقص فالمشكلة من بيانات السيرفر.',
                      style: TextStyle(fontSize: 11.sp, color: Colors.red[800]),
                    ),
                  ],
                  if (missingDocumentedGroups.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    Text(
                      'مجموعات موثقة من السيرفر لكنها فارغة محليًا: ${missingDocumentedGroups.join('، ')}',
                      style: TextStyle(fontSize: 11.sp, color: Colors.red[800]),
                    ),
                  ],
                  if (diagnosis.likelySource == 'local_mapping' && diagnosis.localMappingSlugs.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    Text(
                      'سبب مرجح: خلل ربط محلي (slugs غير محلولة): ${diagnosis.localMappingSlugs.join('، ')}',
                      style: TextStyle(fontSize: 11.sp, color: Colors.orange[900]),
                    ),
                  ] else if (diagnosis.likelySource == 'backend_payload') ...[
                    SizedBox(height: 6.h),
                    Text(
                      'سبب مرجح: نقص Payload من السيرفر لبعض المجموعات الموثقة.',
                      style: TextStyle(fontSize: 11.sp, color: Colors.red[900], fontWeight: FontWeight.w600),
                    ),
                  ],
                  if (isLocalMappingIssue || isBackendPayloadIssue) ...[
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _syncTaxonomies,
                          icon: const Icon(Icons.sync_rounded),
                          label: const Text('إعادة مزامنة التصنيفات'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _exportSyncDiagnostics,
                          icon: const Icon(Icons.ios_share_rounded),
                          label: const Text('تصدير التشخيص'),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            },
            loading: () => const LinearProgressIndicator(minHeight: 2),
            error: (e, _) => Text(
              'تعذر تحميل إحصائيات التصنيفات: $e',
              style: TextStyle(fontSize: 12.sp, color: Colors.red[800]),
            ),
          ),
          SizedBox(height: 8.h),
          lastSyncAsync.when(
            data: (time) => _buildInfoRow(
              'آخر مزامنة للتصنيفات',
              time != null ? _formatDateTime(time) : 'لا يوجد',
            ),
            loading: () => _buildInfoRow('آخر مزامنة للتصنيفات', '...'),
            error: (_, __) => _buildInfoRow('آخر مزامنة للتصنيفات', 'غير متاحة'),
          ),
          if (errorMessage != null && errorMessage.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              'الخطأ الأخير: $errorMessage',
              style: TextStyle(fontSize: 12.sp, color: Colors.red[900]),
            ),
          ],
          SizedBox(height: 12.h),
          ElevatedButton.icon(
            onPressed: isSyncing ? null : _syncTaxonomies,
            icon: const Icon(Icons.sync_rounded),
            label: Text(isSyncing ? 'جاري مزامنة التصنيفات...' : 'مزامنة التصنيفات الآن'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(
    MobileSyncResult result, {
    DateTime? timestamp,
    String? operation,
    String? source,
  }) {
    final theme = Theme.of(context);
    final health = _buildSyncHealthScore(result);
    final relatedConsistency = _buildRelatedConsistencyHint(result);
    final beneficiariesError = _beneficiariesLastSyncError?.trim();

    String? displayError = result.error?.trim();
    if (displayError != null && displayError.isEmpty) {
      displayError = null;
    }

    if ((displayError == null || displayError == 'sync_up_partial_failure') &&
        beneficiariesError != null &&
        beneficiariesError.isNotEmpty) {
      displayError = 'beneficiaries: $beneficiariesError';
    }

    if (displayError != null && displayError.contains('backend_failed_count=')) {
      final localIdsMatch = RegExp(r'local_ids=([^,}]+(?:,[^,}]+)*)').firstMatch(displayError);
      final fileIdsMatch = RegExp(r'file_ids=([^,}]+(?:,[^,}]+)*)').firstMatch(displayError);
      final localIds = localIdsMatch?.group(1);
      final fileIds = fileIdsMatch?.group(1);

      displayError = [
        'فشل جزئي من السيرفر أثناء رفع المستفيدين (تم رفض بعض السجلات).',
        if (localIds != null && localIds.isNotEmpty) 'local_ids=$localIds',
        if (fileIds != null && fileIds.isNotEmpty) 'file_ids=$fileIds',
      ].join(' ');
    }

    String _labelForOperation(String value) {
      switch (value) {
        case 'sync_up':
          return 'رفع';
        case 'sync_down':
          return 'تنزيل';
        default:
          return value;
      }
    }

    String _labelForSource(String value) {
      switch (value) {
        case 'background':
          return 'من الخلفية';
        default:
          return value;
      }
    }

    return SyncSectionCard(
      title: 'نتيجة آخر مزامنة',
      icon: result.success ? Icons.check_circle : Icons.error,
      tone: result.success ? SyncTone.success : SyncTone.error,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (source != null && source.trim().isNotEmpty) ...[
            Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.10),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.45)),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                'المصدر: ${_labelForSource(source)}',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.blue[900],
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(
                '• صحة المزامنة: ${health.score}/100 (${health.level})',
                style: TextStyle(fontSize: 13.sp, color: health.color, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Text(
            '  ${health.hint}',
            style: TextStyle(fontSize: 12.sp, color: health.color),
          ),
          SizedBox(height: 8.h),
          Text(
            relatedConsistency.message,
            style: TextStyle(
              fontSize: 12.sp,
              color: relatedConsistency.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (health.score < 65 || result.errorCategory != null) ...[
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                OutlinedButton.icon(
                  onPressed: _exportSyncDiagnostics,
                  icon: const Icon(Icons.ios_share_rounded),
                  label: const Text('تصدير التشخيص'),
                ),
                OutlinedButton.icon(
                  onPressed: _syncTaxonomies,
                  icon: const Icon(Icons.sync_rounded),
                  label: const Text('مزامنة التصنيفات'),
                ),
              ],
            ),
          ],
          SizedBox(height: 8.h),
          Text(
            '• عدد السجلات: ${result.recordsSynced}',
            style: TextStyle(fontSize: 14.sp),
          ),
          if (result.payloadCounters.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              '• عداد payload:',
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
            ),
            Text(
              '  - beneficiaries: ${result.payloadCounters['beneficiaries'] ?? 0}',
              style: TextStyle(fontSize: 13.sp),
            ),
            Text(
              '  - attachments: ${result.payloadCounters['attachments'] ?? 0}',
              style: TextStyle(fontSize: 13.sp),
            ),
            Text(
              '  - family_members: ${result.payloadCounters['family_members'] ?? 0}',
              style: TextStyle(fontSize: 13.sp),
            ),
            Text(
              '  - dead_people: ${result.payloadCounters['dead_people'] ?? 0}',
              style: TextStyle(fontSize: 13.sp),
            ),
            if ((result.payloadCounters['sponsors'] ?? 0) > 0 ||
                (result.payloadCounters['sponsorships'] ?? 0) > 0 ||
                (result.payloadCounters['associations_up'] ?? 0) > 0 ||
                (result.payloadCounters['sponsorships_up'] ?? 0) > 0 ||
                (result.payloadCounters['taxonomies_sync_runs'] ?? 0) > 0 ||
                (result.payloadCounters['file_id_reservation_checks'] ?? 0) > 0 ||
                (result.payloadCounters['file_id_usage_sync_runs'] ?? 0) > 0) ...[
              SizedBox(height: 6.h),
              Text(
                '• وحدات إضافية:',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
              ),
              Text(
                '  - taxonomies_sync_runs: ${result.payloadCounters['taxonomies_sync_runs'] ?? 0}',
                style: TextStyle(fontSize: 13.sp),
              ),
              Text(
                '  - file_id_reservation_checks: ${result.payloadCounters['file_id_reservation_checks'] ?? 0}',
                style: TextStyle(fontSize: 13.sp),
              ),
              Text(
                '  - file_id_usage_sync_runs: ${result.payloadCounters['file_id_usage_sync_runs'] ?? 0}',
                style: TextStyle(fontSize: 13.sp),
              ),
              Text(
                '  - sponsors: ${result.payloadCounters['sponsors'] ?? 0}',
                style: TextStyle(fontSize: 13.sp),
              ),
              Text(
                '  - sponsorships: ${result.payloadCounters['sponsorships'] ?? 0}',
                style: TextStyle(fontSize: 13.sp),
              ),
              Text(
                '  - associations_up: ${result.payloadCounters['associations_up'] ?? 0}',
                style: TextStyle(fontSize: 13.sp),
              ),
              Text(
                '  - sponsorships_up: ${result.payloadCounters['sponsorships_up'] ?? 0}',
                style: TextStyle(fontSize: 13.sp),
              ),
            ],
          ],
          if (result.recordsFailed > 0)
            Text(
              '• فشل: ${result.recordsFailed}',
              style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.error),
            ),
          if (operation != null && operation.trim().isNotEmpty)
            Text(
              '• نوع العملية: ${_labelForOperation(operation)}',
              style: TextStyle(fontSize: 13.sp),
            ),
          if (timestamp != null)
            Text(
              '• وقت النتيجة: ${_formatDateTime(timestamp)}',
              style: TextStyle(fontSize: 13.sp),
            ),
          if (result.writeCounters.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              '• عداد الكتابة (inserted/updated/skipped):',
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
            ),
            for (final entry in result.writeCounters.entries)
              Text(
                '  - ${entry.key}: ${entry.value}',
                style: TextStyle(fontSize: 12.sp),
              ),
          ],
          if (displayError != null)
            Text(
              '• خطأ: $displayError',
              style: TextStyle(fontSize: 13.sp, color: theme.colorScheme.error),
            ),
          if (result.errorCategory != null)
            Text(
              '• التصنيف: ${result.errorCategory}',
              style: TextStyle(fontSize: 12.sp, color: theme.colorScheme.error),
            ),
          if (result.errorContext != null)
            Text(
              '• السياق: ${result.errorContext}',
              style: TextStyle(fontSize: 12.sp, color: theme.colorScheme.error),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildFileIdDiagnosticsCard(FileIdDiagnostics diagnostics) {
    final lastRefillIssue = diagnostics.lastRefillErrorMessage?.trim();
    final available = diagnostics.availableCount;
    final isCritical = available <= 0;
    final isWarning = !isCritical && available < 50;

    return SyncSectionCard(
      title: 'تشخيص أرقام الملفات',
      icon: Icons.confirmation_num_outlined,
      tone: SyncTone.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCritical)
            Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: SyncStatusBanner(
                message: 'حرج: لا توجد أرقام ملفات متاحة محلياً',
                tone: SyncTone.error,
                icon: Icons.error_outline_rounded,
              ),
            ),
          if (isWarning)
            Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: SyncStatusBanner(
                message: 'تحذير: الأرقام المتاحة محلياً منخفضة ($available)',
                tone: SyncTone.warning,
                icon: Icons.warning_amber_rounded,
              ),
            ),
          if (lastRefillIssue != null && lastRefillIssue.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: SyncStatusBanner(
                message: '${diagnostics.lastRefillErrorCode ?? 'refill_issue'}: $lastRefillIssue',
                tone: SyncTone.warning,
                icon: Icons.warning_amber_rounded,
              ),
            ),
          _buildInfoRow('المتوفر محليًا', diagnostics.availableCount.toString()),
          _buildInfoRow('المستخدم غير المرفوع', diagnostics.usedUnsyncedCount.toString()),
          _buildInfoRow('المتوفر على السيرفر للجهاز', diagnostics.remoteUnusedCount?.toString() ?? 'غير متاح'),
          _buildInfoRow(
            'يمكن طلب المزيد من السيرفر',
            diagnostics.remoteCanRequestMore == null ? 'غير متاح' : (diagnostics.remoteCanRequestMore! ? 'نعم' : 'لا'),
          ),
          _buildInfoRow('الفتحات المتاحة للطلب', diagnostics.remoteAvailableSlots?.toString() ?? 'غير متاح'),
          _buildInfoRow(
            'رقم الحجز النشط',
            diagnostics.activeReservationId?.toString() ?? 'غير متاح',
          ),
          _buildInfoRow(
            'المتبقي في الحجز',
            diagnostics.activeReservationRemaining?.toString() ?? 'غير متاح',
          ),
          _buildInfoRow(
            'آخر حجز',
            diagnostics.lastReservedAt != null ? _formatDateTime(diagnostics.lastReservedAt!) : 'لا يوجد',
          ),
          _buildInfoRow(
            'آخر مزامنة استخدام',
            diagnostics.lastSyncedAt != null ? _formatDateTime(diagnostics.lastSyncedAt!) : 'لا يوجد',
          ),
          _buildInfoRow(
            'آخر login-sync',
            diagnostics.lastLoginSyncAt != null ? _formatDateTime(diagnostics.lastLoginSyncAt!) : 'لا يوجد',
          ),
        ],
      ),
    );
  }

  Widget _buildFileNumberPoolStatusCard(AsyncValue<FileNumberPoolStatus> poolStatusAsync) {
    return poolStatusAsync.when(
      data: (pool) {
        return SyncSectionCard(
          title: 'أرقام الملفات',
          icon: Icons.confirmation_num_outlined,
          tone: pool.critical ? SyncTone.error : (pool.warning ? SyncTone.warning : SyncTone.success),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (pool.critical)
                Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: const SyncStatusBanner(
                    message: 'لا توجد أرقام ملفات متاحة. الرجاء رفع/حجز أرقام ملفات من السيرفر.',
                    tone: SyncTone.error,
                    icon: Icons.error_outline_rounded,
                  ),
                ),
              if (!pool.critical && pool.warning)
                Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: const SyncStatusBanner(
                    message: 'تنبيه: أرقام الملفات أوشكت على النفاد.',
                    tone: SyncTone.warning,
                    icon: Icons.warning_amber_rounded,
                  ),
                ),
              _buildInfoRow('Available locally', pool.available.toString()),
              _buildInfoRow('Assigned locally', pool.pendingAssigned.toString()),
              _buildInfoRow('Synced', pool.synced.toString()),
              _buildInfoRow('Conflicts', pool.conflicts.toString()),
              _buildInfoRow(
                'Current reserved range',
                (pool.rangeStart != null && pool.rangeEnd != null)
                    ? '${pool.rangeStart} → ${pool.rangeEnd}'
                    : 'غير متاح',
              ),
            ],
          ),
        );
      },
      loading: () => const SyncSectionCard(
        title: 'أرقام الملفات',
        icon: Icons.confirmation_num_outlined,
        tone: SyncTone.surface,
        child: LinearProgressIndicator(),
      ),
      error: (error, _) => SyncSectionCard(
        title: 'أرقام الملفات',
        icon: Icons.confirmation_num_outlined,
        tone: SyncTone.warning,
        child: Text('تعذر تحميل حالة أرقام الملفات: $error'),
      ),
    );
  }

  Widget _buildInfoCard() {
    final isFirebaseMode = BackendConfig.current.flavor == BackendFlavor.firebase;
    return SyncSectionCard(
      title: 'معلومات الاتصال',
      icon: Icons.info,
      tone: SyncTone.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('وضع backend', isFirebaseMode ? 'firebase' : 'legacy'),
          _buildInfoRow('المصدر', isFirebaseMode ? 'Cloud Firestore' : 'Legacy API'),
          _buildInfoRow('المجموعة', isFirebaseMode ? 'beneficiaries' : 'sy_benaa_application'),
          _buildInfoRow('التشفير', 'HTTPS'),
        ],
      ),
    );
  }

  Widget _buildSyncHubSummaryCard(MobileSyncStatus status) {
    final theme = Theme.of(context);
    final hasResult = _lastResult != null;
    final health = hasResult ? _buildSyncHealthScore(_lastResult!) : null;

    final statusText = status.isSyncing
        ? 'جارية الآن'
        : (hasResult ? (_lastResult!.success ? 'مكتملة بنجاح' : 'مكتملة مع مشاكل') : 'غير متحقق');

    return Card(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      child: Padding(
        padding: EdgeInsets.all(SyncUiTokens.contentPadding.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.hub_rounded, color: theme.colorScheme.primary, size: 22.sp),
                SizedBox(width: 8.w),
                Text(
                  'Sync Hub',
                  style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            _buildInfoRow('الحالة', statusText),
            _buildInfoRow('آخر مزامنة', status.lastSyncAt != null ? _formatDateTime(status.lastSyncAt!) : 'لا يوجد'),
            if (health != null) _buildInfoRow('صحة المزامنة', '${health.score}/100 (${health.level})'),
            SizedBox(height: 10.h),
            SyncStatusBanner(
              message: status.currentOperation,
              tone: status.isSyncing
                  ? SyncTone.primary
                  : (_lastResult?.success == true ? SyncTone.success : SyncTone.warning),
              icon: status.isSyncing ? Icons.sync_rounded : Icons.info_outline,
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: status.isSyncing ? null : _syncNowOfficial,
                icon: const Icon(Icons.sync),
                label: const Text(
                  'مزامنة كاملة',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncProgressStepper(MobileSyncStatus status) {
    final steps = <({String label, double threshold})>[
      (label: 'تهيئة', threshold: 0.0),
      (label: 'التصنيفات', threshold: 0.2),
      (label: 'التنزيل/الرفع الأساسي', threshold: 0.6),
      (label: 'البيانات المرتبطة', threshold: 0.8),
      (label: 'اكتملت', threshold: 1.0),
    ];

    final progress = status.progress.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مراحل المزامنة',
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.grey[800]),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            for (final step in steps)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: progress >= step.threshold
                      ? Colors.green.withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: progress >= step.threshold ? Colors.green : Colors.grey,
                  ),
                ),
                child: Text(
                  step.label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: progress >= step.threshold ? Colors.green[800] : Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final normalizedValue = _normalizeMixedValue(value);
    final valueDirection = _resolveMixedDirection(normalizedValue);

    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              normalizedValue,
              textDirection: valueDirection,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13.sp, color: Colors.blue[800]),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  TextDirection _resolveMixedDirection(String text) {
    final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    return hasArabic ? TextDirection.rtl : TextDirection.ltr;
  }

  String _normalizeMixedValue(String value) {
    if (value.trim().isEmpty) {
      return 'غير متاح';
    }

    return value.replaceAllMapped(RegExp(r'[0-9]{1,}[0-9/:.\-]*'), (match) => '\u200E${match.group(0)}\u200E').trim();
  }
}

enum _SyncCheckLevel { ok, warn }

enum _SyncViewMode { operational, diagnostic }
