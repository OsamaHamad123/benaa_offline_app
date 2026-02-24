import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 💾 Sync Status Badge - مؤشر حالة المزامنة
class SyncStatusBadge extends StatelessWidget {
  final String syncState;
  final double size;
  final bool showLabel;

  const SyncStatusBadge({
    required this.syncState,
    super.key,
    this.size = 20,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final config = _getSyncConfig(syncState, colorScheme);

    if (showLabel) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: config.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: config.color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(config.icon, color: config.color, size: size.sp),
            SizedBox(width: 4.w),
            Text(
              config.label,
              style: TextStyle(
                fontSize: 11.sp,
                color: config.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(6.r),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(config.icon, color: config.color, size: size.sp),
    );
  }

  _SyncConfig _getSyncConfig(String state, ColorScheme colorScheme) {
    switch (state) {
      case 'synced':
        return _SyncConfig(
          color: colorScheme.secondary,
          icon: Icons.check_circle,
          label: 'مزامن',
        );
      case 'failed':
        return _SyncConfig(
          color: colorScheme.error,
          icon: Icons.error,
          label: 'فشل',
        );
      case 'syncing':
        return _SyncConfig(
          color: colorScheme.primary,
          icon: Icons.sync,
          label: 'جاري المزامنة',
        );
      default:
        return _SyncConfig(
          color: colorScheme.tertiary,
          icon: Icons.cloud_upload_outlined,
          label: 'قيد الانتظار',
        );
    }
  }
}

class _SyncConfig {
  final Color color;
  final IconData icon;
  final String label;

  _SyncConfig({required this.color, required this.icon, required this.label});
}
