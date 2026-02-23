import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/providers/providers.dart';
import '../../core/sync/mobile_sync_service.dart';
import '../auth/presentation/providers/auth_providers.dart';
import '../../core/widgets/modern_sliver_app_bar.dart';
import 'presentation/widgets/sync_history_viewer.dart';
import '../../core/error_handling/error_handler.dart';
import '../taxonomies/presentation/providers/taxonomy_providers.dart';
import '../taxonomies/presentation/providers/taxonomy_bridge_providers.dart';
import '../taxonomies/domain/entities/taxonomy.dart';
import '../taxonomies/presentation/pages/taxonomy_binding_test_page.dart';
import 'presentation/providers/file_id_providers.dart';
import 'domain/repositories/file_id_reservation_repository.dart';

/// ========================================================================
/// 📱 Mobile Sync Page - صفحة مزامنة البيانات مع Mobile API
/// ========================================================================

final mobileSyncServiceProvider = Provider<MobileSyncService>((ref) {
  final database = ref.watch(databaseProvider);
  final apiClient = ref.watch(apiClientProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  final fileIdService = ref.watch(fileIdServiceProvider);
  final taxonomyRepository = ref.watch(taxonomyRepositoryProvider);

  return MobileSyncService(
    database,
    secureStorage,
    dio: apiClient.dio,
    fileIdService: fileIdService,
    taxonomyRepository: taxonomyRepository,
  );
});

class MobileSyncPage extends ConsumerStatefulWidget {
  const MobileSyncPage({super.key});

  @override
  ConsumerState<MobileSyncPage> createState() => _MobileSyncPageState();
}

class _MobileSyncPageState extends ConsumerState<MobileSyncPage> {
  MobileSyncStatus? _status;
  MobileSyncResult? _lastResult;
  Map<String, int>? _stats;
  FileIdDiagnostics? _fileIdDiagnostics;

  @override
  void initState() {
    super.initState();
    _listenToSyncStatus();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final db = ref.read(databaseProvider);

    // Count beneficiaries by sync state
    final beneficiaries = await db.select(db.beneficiaries).get();
    final benPending = beneficiaries.where((b) => b.syncState == 'pending').length;
    final benModified = beneficiaries.where((b) => b.syncState == 'modified').length;
    final benSynced = beneficiaries.where((b) => b.syncState == 'synced').length;

    // Count associations (assuming they have similar sync tracking)
    final associations = await db.select(db.associations).get();
    final assocTotal = associations.length;
    // Note: If associations don't have syncState, we'll count them as synced
    final assocSynced = associations.where((a) => a.isActive).length;

    final fileIdService = ref.read(fileIdServiceProvider);
    final fileIdDiagnostics = await fileIdService.getDiagnostics();

    if (mounted) {
      setState(() {
        _fileIdDiagnostics = fileIdDiagnostics;
        _stats = {
          // Beneficiaries
          'ben_total': beneficiaries.length,
          'ben_pending': benPending,
          'ben_modified': benModified,
          'ben_synced': benSynced,
          'ben_needsSync': benPending + benModified,

          // Associations
          'assoc_total': assocTotal,
          'assoc_active': assocSynced,

          // Combined totals
          'total': beneficiaries.length + assocTotal,
          'needsSync': benPending + benModified,
        };
      });
    }
  }

  void _listenToSyncStatus() {
    final service = ref.read(mobileSyncServiceProvider);
    service.statusStream.listen((status) {
      if (mounted) {
        setState(() {
          _status = status;
        });
      }
    });
  }

  Future<void> _syncDown() async {
    final service = ref.read(mobileSyncServiceProvider);
    final result = await service.syncDown();

    // Force taxonomy sync through notifier to guarantee provider invalidation + UI refresh.
    await ref.read(taxonomySyncNotifierProvider.notifier).sync();
    ref.invalidate(bridgeTaxonomiesIndexOnceProvider);

    final taxonomyStatus = ref.read(taxonomySyncStatusProvider);
    final taxonomyError = ref.read(taxonomyErrorMessageProvider);

    if (mounted) {
      setState(() {
        _lastResult = result;
      });

      // Reload stats
      await _loadStats();

      if (result.success) {
        if (!mounted) return;
        final skippedWarning = _buildSkippedThresholdWarning(result);
        if (skippedWarning != null) {
          EnhancedSnackbar.showWarning(
            context,
            message: skippedWarning,
          );
        }
        if (taxonomyStatus == TaxonomySyncStatus.success) {
          EnhancedSnackbar.showSuccess(
            context,
            message: '✅ تم تنزيل ${result.recordsSynced} سجل ومزامنة التصنيفات بنجاح',
          );
        } else {
          EnhancedSnackbar.showWarning(
            context,
            message:
                '⚠️ تم تنزيل ${result.recordsSynced} سجل لكن التصنيفات لم تتحدث: ${taxonomyError ?? 'تحقق من الاتصال'}',
          );
        }
      } else {
        if (!mounted) return;
        EnhancedSnackbar.showError(
          context,
          message: '❌ فشل التنزيل: ${result.error}',
        );
      }
    }
  }

  Future<void> _syncUp() async {
    final service = ref.read(mobileSyncServiceProvider);
    final result = await service.syncUp();

    if (mounted) {
      setState(() {
        _lastResult = result;
      });

      // Reload stats
      await _loadStats();

      if (result.success) {
        if (!mounted) return;
        EnhancedSnackbar.showSuccess(
          context,
          message: '✅ تم رفع ${result.recordsSynced} سجل (مستفيدين وجمعيات) بنجاح',
        );
      } else {
        if (!mounted) return;
        EnhancedSnackbar.showWarning(
          context,
          message: '⚠️ تم رفع ${result.recordsSynced} (فشل ${result.recordsFailed})',
        );
      }
    }
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

  String? _buildSkippedThresholdWarning(MobileSyncResult result) {
    if (result.writeCounters.isEmpty) return null;

    int counter(String key) => result.writeCounters[key] ?? 0;

    final beneficiariesInserted = counter('beneficiaries_inserted');
    final beneficiariesUpdated = counter('beneficiaries_updated');
    final beneficiariesSkipped = counter('beneficiaries_skipped');
    final beneficiariesTotal = beneficiariesInserted + beneficiariesUpdated + beneficiariesSkipped;

    // Critical signal: high skip ratio on beneficiaries themselves.
    if (beneficiariesTotal >= 50 && beneficiariesSkipped >= 20) {
      final ratio = beneficiariesSkipped / beneficiariesTotal;
      if (ratio >= 0.20) {
        return '⚠️ تم تخطي $beneficiariesSkipped من أصل $beneficiariesTotal من سجلات المستفيدين (${(ratio * 100).toStringAsFixed(1)}%). افحص مطابقة المعرفات.';
      }
    }

    final attachmentsInserted = counter('attachments_inserted');
    final attachmentsUpdated = counter('attachments_updated');
    final attachmentsSkipped = counter('attachments_skipped');

    final familyInserted = counter('family_members_inserted');
    final familyUpdated = counter('family_members_updated');
    final familySkipped = counter('family_members_skipped');

    final deadInserted = counter('dead_people_inserted');
    final deadUpdated = counter('dead_people_updated');
    final deadSkipped = counter('dead_people_skipped');

    final relatedApplied =
        attachmentsInserted + attachmentsUpdated + familyInserted + familyUpdated + deadInserted + deadUpdated;
    final relatedSkipped = attachmentsSkipped + familySkipped + deadSkipped;

    // Related rows may legitimately include records for beneficiaries outside local scope.
    // Warn only in severe mismatch scenarios to avoid noisy false alarms.
    if (relatedSkipped >= 500 && relatedApplied == 0 && result.recordsSynced > 0) {
      return '⚠️ تم تخطي عدد كبير من العلاقات/المرفقات ($relatedSkipped) بدون أي كتابة مرتبطة. هذا قد يشير لخلل في ربط المستفيد (local/server).';
    }

    return null;
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

      try {
        final taxonomyStats = await ref.read(taxonomyStatisticsProvider.future);
        taxonomyGroupCounts = {
          for (final entry in taxonomyStats.countByGroup.entries) entry.key.value: entry.value,
        };
        missingTaxonomyGroups = taxonomyStats.countByGroup.entries
            .where((entry) => entry.value == 0)
            .map((entry) => entry.key.arabicName)
            .toList();
      } catch (_) {
        taxonomyGroupCounts = null;
        missingTaxonomyGroups = null;
      }

      final diagnostics = {
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
          'missing_groups': missingTaxonomyGroups,
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
              },
        'recommended_actions': [
          if (missingTaxonomyGroups?.isNotEmpty ?? false) 'sync_taxonomies',
          if ((_lastResult?.errorCategory ?? '').isNotEmpty) 'review_error_context',
          if ((_lastResult?.writeCounters['beneficiaries_skipped'] ?? 0) > 0) 'verify_identity_mapping',
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

      if (!mounted) return;
      EnhancedSnackbar.showSuccess(context, message: '✅ تم تصدير تقرير التشخيص');
    } catch (e) {
      if (!mounted) return;
      EnhancedSnackbar.showError(context, message: '❌ فشل تصدير تقرير التشخيص: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                onPressed: _loadStats,
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
                  // Warning card
                  _buildWarningCard(),

                  SizedBox(height: 20.h),

                  // Stats card (if available)
                  if (_stats != null) _buildStatsCard(),

                  if (_stats != null) SizedBox(height: 20.h),

                  // Status card
                  _buildStatusCard(status),

                  SizedBox(height: 20.h),

                  // Taxonomy diagnostics card
                  _buildTaxonomyDiagnosticsCard(
                    syncStatus: taxonomySyncStatus,
                    errorMessage: taxonomyErrorMessage,
                    statsAsync: taxonomyStatsAsync,
                    lastSyncAsync: taxonomyLastSyncAsync,
                    isSyncing: isTaxonomySyncing,
                  ),

                  SizedBox(height: 20.h),

                  // File ID diagnostics card
                  if (_fileIdDiagnostics != null) _buildFileIdDiagnosticsCard(_fileIdDiagnostics!),

                  if (_fileIdDiagnostics != null) SizedBox(height: 20.h),

                  // Sync buttons
                  _buildSyncButtons(status),

                  SizedBox(height: 20.h),

                  // Last result
                  if (_lastResult != null) _buildResultCard(_lastResult!),

                  SizedBox(height: 20.h),

                  // Info card
                  _buildInfoCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard() {
    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.orange, size: 24.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    '⚠️ مزامنة مؤقتة - قيود مهمة',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[900],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              '• لا يوجد authentication (مؤقت)\n'
              '• المرفقات تتزامن الآن (Multipart)\n'
              '• في حالة التعارض، بيانات السيرفر تفوز\n'
              '• السجلات المحذوفة لا تتزامن',
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.orange[800],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    if (_stats == null) return const SizedBox.shrink();

    return Column(
      children: [
        // 📊 Beneficiaries Stats Card
        Card(
          color: Colors.blue[50],
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.people, color: Colors.blue, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'إحصائيات المستفيدين',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                _buildStatRow(
                  'إجمالي المستفيدين',
                  '${_stats!['ben_total']}',
                  Colors.blue,
                ),
                _buildStatRow('متزامن', '${_stats!['ben_synced']}', Colors.green),
                _buildStatRow(
                  'بانتظار الرفع',
                  '${_stats!['ben_pending']}',
                  Colors.orange,
                ),
                _buildStatRow(
                  'محدّث (غير مزامن)',
                  '${_stats!['ben_modified']}',
                  Colors.orange,
                ),
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
        ),

        SizedBox(height: 12.h),

        // 🏢 Associations Stats Card
        Card(
          color: Colors.purple[50],
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.business, color: Colors.purple, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'إحصائيات الجمعيات',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                _buildStatRow(
                  'إجمالي الجمعيات',
                  '${_stats!['assoc_total']}',
                  Colors.purple,
                ),
                _buildStatRow(
                  'جمعيات نشطة',
                  '${_stats!['assoc_active']}',
                  Colors.green,
                ),
                _buildStatRow(
                  'جمعيات غير نشطة',
                  '${_stats!['assoc_total']! - _stats!['assoc_active']!}',
                  Colors.grey,
                ),
              ],
            ),
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
              color: color.withOpacity(0.2),
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
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'حالة المزامنة',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),

            // Current operation
            Row(
              children: [
                Icon(
                  status.isSyncing ? Icons.sync : Icons.check_circle,
                  color: status.isSyncing ? Colors.blue : Colors.green,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    status.currentOperation,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ],
            ),

            // Progress bar
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
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
            ],

            // Last sync time
            if (status.lastSyncAt != null) ...[
              SizedBox(height: 12.h),
              Text(
                'آخر مزامنة: ${_formatDateTime(status.lastSyncAt!)}',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
            ],

            // Last error
            if (status.lastError != null) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 16.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        status.lastError!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.red[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSyncButtons(MobileSyncStatus status) {
    final isSyncing = status.isSyncing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sync Down button
        ElevatedButton.icon(
          onPressed: isSyncing ? null : _syncDown,
          icon: const Icon(Icons.cloud_download),
          label: const Text('تنزيل البيانات من السيرفر'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey,
          ),
        ),

        SizedBox(height: 12.h),

        // Sync Up button
        ElevatedButton.icon(
          onPressed: isSyncing ? null : _syncUp,
          icon: const Icon(Icons.cloud_upload),
          label: const Text('رفع التغييرات للسيرفر'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey,
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
    Color statusColor;
    String statusLabel;

    switch (syncStatus) {
      case TaxonomySyncStatus.syncing:
        statusColor = Colors.blue;
        statusLabel = 'جاري المزامنة';
        break;
      case TaxonomySyncStatus.success:
        statusColor = Colors.green;
        statusLabel = 'متزامنة';
        break;
      case TaxonomySyncStatus.error:
        statusColor = Colors.red;
        statusLabel = 'فشل';
        break;
      case TaxonomySyncStatus.idle:
        statusColor = Colors.grey;
        statusLabel = 'غير متحقق';
        break;
    }

    return Card(
      color: Colors.teal[50],
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.category_rounded, color: Colors.teal, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'تشخيص التصنيفات',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            statsAsync.when(
              data: (stats) {
                final nonEmptyGroups = stats.countByGroup.entries.where((entry) => entry.value > 0).length;
                final missingGroups = stats.countByGroup.entries
                    .where((entry) => entry.value == 0)
                    .map((entry) => entry.key.arabicName)
                    .toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('إجمالي التصنيفات', '${stats.totalCount}'),
                    _buildInfoRow('النشطة', '${stats.activeCount}'),
                    _buildInfoRow('المجموعات المعبأة', '$nonEmptyGroups/${stats.countByGroup.length}'),
                    if (missingGroups.isNotEmpty) ...[
                      SizedBox(height: 6.h),
                      Text(
                        'المجموعات غير المعبأة: ${missingGroups.join('، ')}',
                        style: TextStyle(fontSize: 12.sp, color: Colors.red[800]),
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
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey,
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
            SizedBox(height: 8.h),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TaxonomyBindingTestPage(),
                  ),
                );
              },
              icon: const Icon(Icons.science_rounded),
              label: const Text('فتح صفحة اختبار الربط'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(MobileSyncResult result) {
    final health = _buildSyncHealthScore(result);

    return Card(
      color: result.success ? Colors.green[50] : Colors.red[50],
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  result.success ? Icons.check_circle : Icons.error,
                  color: result.success ? Colors.green : Colors.red,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'نتيجة آخر مزامنة',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
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
            ],
            if (result.recordsFailed > 0)
              Text(
                '• فشل: ${result.recordsFailed}',
                style: TextStyle(fontSize: 14.sp, color: Colors.red),
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
            if (result.error != null)
              Text(
                '• خطأ: ${result.error}',
                style: TextStyle(fontSize: 13.sp, color: Colors.red[800]),
              ),
            if (result.errorCategory != null)
              Text(
                '• التصنيف: ${result.errorCategory}',
                style: TextStyle(fontSize: 12.sp, color: Colors.red[700]),
              ),
            if (result.errorContext != null)
              Text(
                '• السياق: ${result.errorContext}',
                style: TextStyle(fontSize: 12.sp, color: Colors.red[700]),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileIdDiagnosticsCard(FileIdDiagnostics diagnostics) {
    return Card(
      color: Colors.indigo[50],
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.confirmation_num_outlined, color: Colors.indigo, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'تشخيص أرقام الملفات',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            _buildInfoRow('المتوفر محليًا', diagnostics.availableCount.toString()),
            _buildInfoRow('المستخدم غير المرفوع', diagnostics.usedUnsyncedCount.toString()),
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
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'معلومات الاتصال',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _buildInfoRow('السيرفر', 'palestine.benaadev.org'),
            _buildInfoRow('قاعدة البيانات', 'u983550065_sy_test'),
            _buildInfoRow('الجدول', 'sy_benaa_application'),
            _buildInfoRow('التشفير', 'HTTPS'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
              value,
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
}
