import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Compact Sync Health Card — حالة المزامنة المختصرة
///
/// Pure StatelessWidget — receives all data as parameters.
/// Uses only cheap data already available in [_buildContent]:
///   - [pendingSync] from stats.pendingSync
///   - [isOnline] from connectivity state
///   - [lastSyncTime] from stats.lastSyncTime (nullable)
///
/// Does NOT run sync — only navigates to Sync Center via [onOpenSync].
/// No failed sync count (no cheap data source — deferred).
class DashboardSyncHealthCard extends StatelessWidget {
  final int pendingSync;
  final bool isOnline;
  final DateTime? lastSyncTime;
  final VoidCallback onOpenSync;

  const DashboardSyncHealthCard({
    required this.pendingSync,
    required this.isOnline,
    required this.onOpenSync,
    this.lastSyncTime,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final syncState = _resolveSyncState();

    return Semantics(
      label: 'حالة المزامنة — ${syncState.statusText}',
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(
            color: syncState.borderColor.withValues(alpha: 0.5),
          ),
        ),
        color: syncState.backgroundColor,
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, colorScheme, syncState),
              SizedBox(height: 12.h),
              _buildStatusRow(context, syncState),
              SizedBox(height: 12.h),
              _buildLastSyncRow(context, colorScheme),
              SizedBox(height: 12.h),
              _buildButton(context, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme, _SyncState syncState) {
    return Row(
      children: [
        Icon(Icons.sync_rounded, size: 20.sp, color: syncState.iconColor),
        SizedBox(width: 8.w),
        Text(
          'حالة المزامنة',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildStatusRow(BuildContext context, _SyncState syncState) {
    return Row(
      children: [
        Icon(syncState.statusIcon, size: 16.sp, color: syncState.iconColor),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            syncState.statusText,
            style: TextStyle(
              fontSize: 13.sp,
              color: syncState.iconColor,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildLastSyncRow(BuildContext context, ColorScheme colorScheme) {
    final lastSyncLabel = _formatLastSync();
    return Row(
      children: [
        Icon(Icons.access_time_rounded, size: 14.sp, color: colorScheme.onSurfaceVariant),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            'آخر مزامنة: $lastSyncLabel',
            style: TextStyle(
              fontSize: 12.sp,
              color: colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildButton(BuildContext context, ColorScheme colorScheme) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: TextButton.icon(
        key: const Key('sync_health_open_sync'),
        onPressed: onOpenSync,
        icon: Icon(Icons.open_in_new_rounded, size: 16.sp),
        label: Text('فتح مركز المزامنة', style: TextStyle(fontSize: 12.sp)),
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        ),
      ),
    );
  }

  _SyncState _resolveSyncState() {
    if (!isOnline) {
      return _SyncState(
        statusText: 'وضع عدم الاتصال — بياناتك محفوظة محلياً',
        statusIcon: Icons.wifi_off_rounded,
        iconColor: Colors.orange.shade700,
        borderColor: Colors.orange.shade300,
        backgroundColor: Colors.orange.shade50,
      );
    }
    if (pendingSync > 0) {
      return _SyncState(
        statusText: '$pendingSync سجل بانتظار الرفع',
        statusIcon: Icons.upload_rounded,
        iconColor: Colors.blue.shade700,
        borderColor: Colors.blue.shade200,
        backgroundColor: Colors.blue.shade50,
      );
    }
    return _SyncState(
      statusText: 'تم تزامن جميع البيانات',
      statusIcon: Icons.check_circle_rounded,
      iconColor: Colors.green.shade700,
      borderColor: Colors.green.shade200,
      backgroundColor: Colors.green.shade50,
    );
  }

  String _formatLastSync() {
    if (lastSyncTime == null) return 'غير متوفر';
    final now = DateTime.now();
    final diff = now.difference(lastSyncTime!);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }
}

class _SyncState {
  final String statusText;
  final IconData statusIcon;
  final Color iconColor;
  final Color borderColor;
  final Color backgroundColor;

  const _SyncState({
    required this.statusText,
    required this.statusIcon,
    required this.iconColor,
    required this.borderColor,
    required this.backgroundColor,
  });
}
