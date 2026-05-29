import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Priority levels for the Operational Status Strip.
///
/// Higher priority overrides lower priority in [DashboardOperationalStatus.resolve].
enum DashboardStatusLevel {
  /// All data is synced — no action needed.
  normal,

  /// Non-urgent info — pending uploads queued.
  info,

  /// User attention required — offline or sync issue.
  warning,

  /// Critical — sync failed.
  danger,
}

/// Immutable display model for the Operational Status Strip.
///
/// Created via [resolve] which applies priority ordering:
/// 1. Sync failed ([hasSyncFailure]=true) — [DashboardStatusLevel.danger]
/// 2. Offline — [DashboardStatusLevel.warning]
/// 3. Pending uploads > 0 — [DashboardStatusLevel.info]
/// 4. All good / synced — [DashboardStatusLevel.normal]
class DashboardOperationalStatus {
  final DashboardStatusLevel level;
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;

  const DashboardOperationalStatus({
    required this.level,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
  });

  /// Resolve the highest-priority status from available data.
  ///
  /// [hasSyncFailure] defaults to false — wiring to a failed-upload count
  /// is deferred (Phase 3) since no cheap data source is available.
  static DashboardOperationalStatus resolve({
    required bool isOnline,
    required int pendingSync,
    DateTime? lastSyncTime,
    bool hasSyncFailure = false,
  }) {
    if (hasSyncFailure) return _failed();
    if (!isOnline) return _offline(pendingSync);
    if (pendingSync > 0) return _pending(pendingSync);
    return _synced(lastSyncTime);
  }

  static DashboardOperationalStatus _failed() => const DashboardOperationalStatus(
        level: DashboardStatusLevel.danger,
        icon: Icons.cloud_off_rounded,
        title: 'فشلت المزامنة',
        message: 'افتح مركز المزامنة للمراجعة',
        actionLabel: 'مركز المزامنة',
      );

  static DashboardOperationalStatus _offline(int pending) => DashboardOperationalStatus(
        level: DashboardStatusLevel.warning,
        icon: Icons.wifi_off_rounded,
        title: 'وضع عدم الاتصال',
        message: pending > 0 ? 'بياناتك محفوظة محلياً — $pending سجل ينتظر الرفع' : 'بياناتك محفوظة محلياً',
        actionLabel: null,
      );

  static DashboardOperationalStatus _pending(int count) => DashboardOperationalStatus(
        level: DashboardStatusLevel.info,
        icon: Icons.cloud_upload_outlined,
        title: '$count سجل بانتظار الرفع',
        message: 'انقر لفتح مركز المزامنة',
        actionLabel: 'مزامنة',
      );

  static DashboardOperationalStatus _synced(DateTime? lastSync) {
    final String message;
    if (lastSync == null) {
      message = 'لم تتم مزامنة البيانات بعد';
    } else {
      final diff = DateTime.now().difference(lastSync);
      if (diff.inMinutes < 60) {
        message = 'آخر مزامنة منذ ${diff.inMinutes} دقيقة';
      } else if (diff.inHours < 24) {
        message = 'آخر مزامنة منذ ${diff.inHours} ساعة';
      } else {
        message = 'آخر مزامنة منذ ${diff.inDays} يوم';
      }
    }
    return DashboardOperationalStatus(
      level: DashboardStatusLevel.normal,
      icon: Icons.check_circle_outline_rounded,
      title: 'كل البيانات متزامنة',
      message: message,
    );
  }
}

/// Compact horizontal status strip for the top of the Dashboard home content.
///
/// - Driven by [DashboardOperationalStatus] — no provider dependencies.
/// - RTL-safe: chevron direction adapts to [Directionality].
/// - Accessible: wrapped in [Semantics] with combined title + message label.
/// - Compact: survives text scale 1.5 via [TextOverflow.ellipsis].
/// - Tap navigates to Sync Center (pass [onTap] handler from parent).
class DashboardOperationalStatusStrip extends StatelessWidget {
  final DashboardOperationalStatus status;
  final VoidCallback? onTap;

  const DashboardOperationalStatusStrip({
    super.key,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(status.level);

    return Semantics(
      label: '${status.title}: ${status.message}',
      button: onTap != null,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Icon(status.icon, color: colors.foreground, size: 18.sp),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      status.title,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: colors.foreground,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      status.message,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: colors.foreground.withValues(alpha: 0.85),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onTap != null) ...[
                SizedBox(width: 8.w),
                Icon(
                  Directionality.of(context) == TextDirection.rtl ? Icons.chevron_left : Icons.chevron_right,
                  color: colors.foreground.withValues(alpha: 0.7),
                  size: 16.sp,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  _StripColors _colorsFor(DashboardStatusLevel level) {
    switch (level) {
      case DashboardStatusLevel.normal:
        return _StripColors(
          background: Colors.green.shade50,
          border: Colors.green.shade200,
          foreground: Colors.green.shade800,
        );
      case DashboardStatusLevel.info:
        return _StripColors(
          background: Colors.blue.shade50,
          border: Colors.blue.shade200,
          foreground: Colors.blue.shade800,
        );
      case DashboardStatusLevel.warning:
        return _StripColors(
          background: Colors.orange.shade50,
          border: Colors.orange.shade200,
          foreground: Colors.orange.shade800,
        );
      case DashboardStatusLevel.danger:
        return _StripColors(
          background: Colors.red.shade50,
          border: Colors.red.shade200,
          foreground: Colors.red.shade800,
        );
    }
  }
}

class _StripColors {
  final Color background;
  final Color border;
  final Color foreground;

  const _StripColors({
    required this.background,
    required this.border,
    required this.foreground,
  });
}
