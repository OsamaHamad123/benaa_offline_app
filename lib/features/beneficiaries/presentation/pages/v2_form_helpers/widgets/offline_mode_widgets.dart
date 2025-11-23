import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 🌐 Offline Mode Indicator & Manager
///
/// Shows connection status and manages offline operations

class OfflineModeIndicator extends StatelessWidget {
  final bool isOffline;
  final int pendingChanges;
  final VoidCallback? onTapSync;

  const OfflineModeIndicator({
    super.key,
    required this.isOffline,
    this.pendingChanges = 0,
    this.onTapSync,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOffline && pendingChanges == 0) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTapSync,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isOffline ? Colors.orange.shade50 : Colors.green.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isOffline ? Colors.orange.shade200 : Colors.green.shade200,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOffline ? Icons.cloud_off_rounded : Icons.cloud_done_rounded,
              size: 20.sp,
              color: isOffline ? Colors.orange.shade700 : Colors.green.shade700,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isOffline ? 'وضع عدم الاتصال' : 'متصل',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: isOffline
                          ? Colors.orange.shade700
                          : Colors.green.shade700,
                    ),
                  ),
                  if (pendingChanges > 0) ...[
                    SizedBox(height: 2.h),
                    Text(
                      '$pendingChanges تغيير بانتظار المزامنة',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (pendingChanges > 0 && !isOffline) ...[
              SizedBox(width: 8.w),
              Icon(Icons.sync_rounded, size: 18.sp, color: Colors.blue),
            ],
          ],
        ),
      ),
    );
  }
}

/// 📶 Connection Status Manager
class ConnectionStatusManager extends StatelessWidget {
  final bool isConnected;
  final DateTime? lastSync;
  final int pendingUploads;
  final VoidCallback? onSync;

  const ConnectionStatusManager({
    super.key,
    required this.isConnected,
    this.lastSync,
    this.pendingUploads = 0,
    this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isConnected ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                color: isConnected ? Colors.green : Colors.red,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isConnected ? 'متصل بالإنترنت' : 'غير متصل',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (lastSync != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        'آخر مزامنة: ${_formatLastSync(lastSync!)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (pendingUploads > 0) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.upload_rounded,
                    size: 20.sp,
                    color: Colors.orange.shade700,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      '$pendingUploads سجل بانتظار الرفع',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                  if (isConnected && onSync != null)
                    TextButton.icon(
                      onPressed: onSync,
                      icon: const Icon(Icons.sync_rounded, size: 18),
                      label: const Text('مزامنة'),
                      style: TextButton.styleFrom(foregroundColor: Colors.blue),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatLastSync(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return 'منذ ${difference.inDays} يوم';
    }
  }
}

/// 💾 Data Cache Size Indicator
class DataCacheIndicator extends StatelessWidget {
  final int cachedRecords;
  final String cacheSize;
  final VoidCallback? onClearCache;

  const DataCacheIndicator({
    super.key,
    required this.cachedRecords,
    required this.cacheSize,
    this.onClearCache,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.storage_rounded, color: Colors.blue, size: 24.sp),
      title: Text(
        'البيانات المخزنة محلياً',
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '$cachedRecords سجل • $cacheSize',
        style: TextStyle(fontSize: 12.sp),
      ),
      trailing: onClearCache != null
          ? TextButton(onPressed: onClearCache, child: const Text('مسح'))
          : null,
    );
  }
}
