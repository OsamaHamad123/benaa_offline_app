import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/providers/providers.dart';
import '../../core/sync/mobile_sync_service.dart';
import '../../core/widgets/modern_sliver_app_bar.dart';
import 'presentation/widgets/sync_history_viewer.dart';

/// ========================================================================
/// 📱 Mobile Sync Page - صفحة مزامنة البيانات مع Mobile API
/// ========================================================================

final mobileSyncServiceProvider = Provider<MobileSyncService>((ref) {
  final database = ref.watch(databaseProvider);
  return MobileSyncService(database);
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

  @override
  void initState() {
    super.initState();
    _listenToSyncStatus();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final db = ref.read(databaseProvider);

    // Count beneficiaries by sync state
    final total = await db.select(db.beneficiaries).get();
    final pending = total.where((b) => b.syncState == 'pending').length;
    final modified = total.where((b) => b.syncState == 'modified').length;
    final synced = total.where((b) => b.syncState == 'synced').length;

    if (mounted) {
      setState(() {
        _stats = {
          'total': total.length,
          'pending': pending,
          'modified': modified,
          'synced': synced,
          'needsSync': pending + modified,
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

    if (mounted) {
      setState(() {
        _lastResult = result;
      });

      // Reload stats
      await _loadStats();

      if (result.success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ تم تنزيل ${result.recordsSynced} مستفيد بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ فشل التنزيل: ${result.error}'),
            backgroundColor: Colors.red,
          ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ تم رفع ${result.recordsSynced} مستفيد بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '⚠️ تم رفع ${result.recordsSynced} (فشل ${result.recordsFailed})',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _status ?? MobileSyncStatus();

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
              '• المرفقات لا تتزامن (نصوص فقط)\n'
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

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'إحصائيات البيانات المحلية',
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
              '${_stats!['total']}',
              Colors.blue,
            ),
            _buildStatRow('متزامن', '${_stats!['synced']}', Colors.green),
            _buildStatRow(
              'بانتظار الرفع',
              '${_stats!['pending']}',
              Colors.orange,
            ),
            _buildStatRow(
              'محدّث (غير مزامن)',
              '${_stats!['modified']}',
              Colors.orange,
            ),
            Divider(height: 20.h),
            _buildStatRow(
              'يحتاج مزامنة',
              '${_stats!['needsSync']}',
              _stats!['needsSync']! > 0 ? Colors.red : Colors.green,
              bold: true,
            ),
          ],
        ),
      ),
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

  Widget _buildResultCard(MobileSyncResult result) {
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
            Text(
              '• عدد السجلات: ${result.recordsSynced}',
              style: TextStyle(fontSize: 14.sp),
            ),
            if (result.recordsFailed > 0)
              Text(
                '• فشل: ${result.recordsFailed}',
                style: TextStyle(fontSize: 14.sp, color: Colors.red),
              ),
            if (result.error != null)
              Text(
                '• خطأ: ${result.error}',
                style: TextStyle(fontSize: 13.sp, color: Colors.red[800]),
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
