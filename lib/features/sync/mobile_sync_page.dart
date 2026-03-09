import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/providers/providers.dart';
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
import 'presentation/providers/file_id_providers.dart';
import 'presentation/providers/mobile_sync_operations_providers.dart';
import 'domain/repositories/file_id_reservation_repository.dart';

/// ========================================================================
/// 📱 Mobile Sync Page - صفحة مزامنة البيانات مع Mobile API
/// ========================================================================

class MobileSyncPage extends ConsumerStatefulWidget {
  const MobileSyncPage({super.key});

  @override
  ConsumerState<MobileSyncPage> createState() => _MobileSyncPageState();
}

class _MobileSyncPageState extends ConsumerState<MobileSyncPage> with WidgetsBindingObserver {
  MobileSyncStatus? _status;
  MobileSyncResult? _lastResult;
  DateTime? _lastResultAt;
  String? _lastResultOperation;
  String? _lastResultSource;
  Map<String, int>? _stats;
  FileIdDiagnostics? _fileIdDiagnostics;
  String? _beneficiariesLastSyncError;
  StreamSubscription<MobileSyncStatus>? _syncStatusSubscription;
  _SyncViewMode _syncViewMode = _SyncViewMode.operational;
  bool _showDetailedStatsInOperational = false;
  DateTime? _syncHubOpenedAt;
  DateTime? _syncFunnelTriggeredAt;
  String? _syncFunnelTrigger;
  final Map<String, int> _syncTriggerCounts = <String, int>{};
  final Map<String, DateTime> _syncFirstTriggerAt = <String, DateTime>{};

  @override
  void initState() {
    super.initState();
    _startSyncHubSession();
    WidgetsBinding.instance.addObserver(this);
    _listenToSyncStatus();
    _refreshDashboardData();
  }

  void _startSyncHubSession() {
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
        }

        if (!status.isSyncing) {
          unawaited(_refreshDashboardData());
        }
      }
    });
  }

  Future<void> _refreshDashboardData() async {
    final db = ref.read(databaseProvider);
    final fileIdService = ref.read(fileIdServiceProvider);
    final data = await MobileSyncDashboardLoader.load(db: db, fileIdService: fileIdService);
    if (!mounted) return;

    setState(() {
      _lastResult = data.lastResult;
      _lastResultAt = data.lastResultAt;
      _lastResultOperation = data.lastResultOperation;
      _lastResultSource = data.lastResultSource;
      _stats = data.stats;
      _fileIdDiagnostics = data.fileIdDiagnostics;
      _beneficiariesLastSyncError = data.beneficiariesLastSyncError;
    });
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
    super.dispose();
  }

  Future<void> _syncDown() async {
    _trackSyncFunnelTrigger('sync_down');
    await BackgroundSyncWorker.triggerSyncDown();

    if (!mounted) return;
    setState(() {
      _status = MobileSyncStatus(
        isSyncing: true,
        currentOperation: 'تمت جدولة مزامنة التنزيل بالخلفية',
        progress: 0,
      );
    });

    EnhancedSnackbar.showSuccess(
      context,
      message: '✅ تمت جدولة Sync Down بالخلفية (تستمر حتى بعد إغلاق التطبيق)',
    );
  }

  Future<void> _syncUp() async {
    _trackSyncFunnelTrigger('sync_up');
    await BackgroundSyncWorker.triggerSyncUp();

    if (!mounted) return;
    setState(() {
      _status = MobileSyncStatus(
        isSyncing: true,
        currentOperation: 'تمت جدولة مزامنة الرفع بالخلفية',
        progress: 0,
      );
    });

    EnhancedSnackbar.showSuccess(
      context,
      message: '✅ تمت جدولة Sync Up بالخلفية (تستمر حتى بعد إغلاق التطبيق)',
    );
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

  Future<void> _syncNowOfficial() async {
    _trackSyncFunnelTrigger('sync_now_full');
    await BackgroundSyncWorker.triggerManualSync();

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
      message: '✅ تمت جدولة المزامنة الشاملة بالخلفية (تستمر حتى بعد إغلاق التطبيق)',
    );
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
    final totalNeedsSync = benNeedsSync + assocNeedsSync + repNeedsSync + sponsorshipNeedsSync;

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
          Divider(height: 18.h),
          _buildInfoRow('جاهز للرفع الآن (مستفيدون)', '$benReadyToUpload'),
          _buildInfoRow('بانتظار الرفع', '$benPending'),
          _buildInfoRow('محدّث (غير مزامن)', '$benModified'),
          _buildInfoRow('فشل سابق (سيُعاد رفعه)', '$benFailed'),
          if (benReadyToUpload == 0)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                'لا توجد تغييرات مستفيدين قابلة للرفع حاليًا.',
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
                'يحتاج مزامنة',
                '${_stats!['ben_needsSync']}',
                _stats!['ben_needsSync']! > 0 ? Colors.red : Colors.green,
                bold: true,
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
    final isSyncing = status.isSyncing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: isSyncing ? null : _syncNowOfficial,
          icon: const Icon(Icons.sync),
          label: const Text(
            'مزامنة الآن (شاملة)',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
        ),

        SizedBox(height: 10.h),

        // Sync Down button (secondary)
        ElevatedButton.icon(
          onPressed: isSyncing ? null : _syncDown,
          icon: const Icon(Icons.cloud_download),
          label: const Text(
            'تنزيل البيانات من السيرفر',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
          ),
        ),

        SizedBox(height: 12.h),

        // Sync Up button (secondary)
        ElevatedButton.icon(
          onPressed: isSyncing ? null : _syncUp,
          icon: const Icon(Icons.cloud_upload),
          label: const Text(
            'رفع التغييرات للسيرفر',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            backgroundColor: theme.colorScheme.tertiary,
            foregroundColor: theme.colorScheme.onTertiary,
          ),
        ),
      ],
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

    return SyncSectionCard(
      title: 'تشخيص أرقام الملفات',
      icon: Icons.confirmation_num_outlined,
      tone: SyncTone.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

  Widget _buildInfoCard() {
    return SyncSectionCard(
      title: 'معلومات الاتصال',
      icon: Icons.info,
      tone: SyncTone.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('السيرفر', 'palestine.benaadev.org'),
          _buildInfoRow('قاعدة البيانات', 'u983550065_sy_test'),
          _buildInfoRow('الجدول', 'sy_benaa_application'),
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
                  'مزامنة الآن (الإجراء الرئيسي)',
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
