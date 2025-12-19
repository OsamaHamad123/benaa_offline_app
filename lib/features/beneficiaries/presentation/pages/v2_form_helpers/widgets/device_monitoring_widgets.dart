import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ⚡ Battery & Performance Monitor for Field Devices
///
/// Monitor device resources during field work

class BatteryPerformanceMonitor extends StatefulWidget {
  final int batteryLevel;
  final bool isLowPowerMode;
  final VoidCallback? onEnablePowerSaving;

  const BatteryPerformanceMonitor({
    super.key,
    required this.batteryLevel,
    this.isLowPowerMode = false,
    this.onEnablePowerSaving,
  });

  @override
  State<BatteryPerformanceMonitor> createState() =>
      _BatteryPerformanceMonitorState();
}

class _BatteryPerformanceMonitorState extends State<BatteryPerformanceMonitor> {
  bool _showWarning = false;

  @override
  void didUpdateWidget(BatteryPerformanceMonitor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.batteryLevel <= 20 && !_showWarning) {
      setState(() => _showWarning = true);
      _showLowBatteryDialog();
    }
  }

  void _showLowBatteryDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.battery_alert_rounded,
          color: Colors.orange,
          size: 48.sp,
        ),
        title: const Text('بطارية منخفضة'),
        content: Text(
          'البطارية ${widget.batteryLevel}%\nقم بتفعيل وضع توفير الطاقة للاستمرار في العمل الميداني',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لاحقاً'),
          ),
          if (widget.onEnablePowerSaving != null)
            ElevatedButton(
              onPressed: () {
                widget.onEnablePowerSaving!();
                Navigator.pop(context);
              },
              child: const Text('تفعيل التوفير'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLow = widget.batteryLevel <= 20;
    final isMedium = widget.batteryLevel <= 50;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isLow
            ? Colors.red.shade50
            : isMedium
                ? Colors.orange.shade50
                : Colors.green.shade50,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.isLowPowerMode
                ? Icons.battery_saver_rounded
                : isLow
                    ? Icons.battery_alert_rounded
                    : isMedium
                        ? Icons.battery_3_bar_rounded
                        : Icons.battery_full_rounded,
            size: 18.sp,
            color: isLow
                ? Colors.red
                : isMedium
                    ? Colors.orange
                    : Colors.green,
          ),
          SizedBox(width: 6.w),
          Text(
            '${widget.batteryLevel}%',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isLow
                  ? Colors.red.shade700
                  : isMedium
                      ? Colors.orange.shade700
                      : Colors.green.shade700,
            ),
          ),
          if (widget.isLowPowerMode) ...[
            SizedBox(width: 4.w),
            Icon(Icons.check_circle, size: 14.sp, color: Colors.green),
          ],
        ],
      ),
    );
  }
}

/// 💾 Storage Space Monitor
class StorageSpaceMonitor extends StatelessWidget {
  final double usedGB;
  final double totalGB;
  final VoidCallback? onClearCache;

  const StorageSpaceMonitor({
    super.key,
    required this.usedGB,
    required this.totalGB,
    this.onClearCache,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (usedGB / totalGB * 100).clamp(0, 100).toInt();
    final isLow = percentage > 80;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isLow ? Colors.orange.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isLow ? Colors.orange.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.sd_storage_rounded,
                    size: 20.sp,
                    color: isLow ? Colors.orange : Colors.grey.shade700,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'مساحة التخزين',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '${usedGB.toStringAsFixed(1)} / ${totalGB.toStringAsFixed(1)} GB',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          LinearProgressIndicator(
            value: usedGB / totalGB,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(
              isLow ? Colors.orange : Colors.blue,
            ),
            minHeight: 8.h,
            borderRadius: BorderRadius.circular(4.r),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$percentage% مستخدم',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isLow ? Colors.orange.shade700 : Colors.grey.shade600,
                ),
              ),
              if (isLow && onClearCache != null)
                TextButton.icon(
                  onPressed: onClearCache,
                  icon: const Icon(Icons.cleaning_services_rounded, size: 16),
                  label: const Text('تنظيف'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 📊 Data Sync Progress
class DataSyncProgress extends StatelessWidget {
  final int totalRecords;
  final int syncedRecords;
  final bool isSyncing;
  final String? errorMessage;

  const DataSyncProgress({
    super.key,
    required this.totalRecords,
    required this.syncedRecords,
    this.isSyncing = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: errorMessage != null
            ? Colors.red.shade50
            : isSyncing
                ? Colors.blue.shade50
                : Colors.green.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: errorMessage != null
              ? Colors.red.shade200
              : isSyncing
                  ? Colors.blue.shade200
                  : Colors.green.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isSyncing)
                SizedBox(
                  width: 16.w,
                  height: 16.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.blue.shade700),
                  ),
                )
              else
                Icon(
                  errorMessage != null
                      ? Icons.error_rounded
                      : Icons.cloud_done_rounded,
                  size: 20.sp,
                  color: errorMessage != null
                      ? Colors.red.shade700
                      : Colors.green.shade700,
                ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  errorMessage != null
                      ? 'فشل المزامنة'
                      : isSyncing
                          ? 'جاري المزامنة...'
                          : 'تمت المزامنة',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$syncedRecords / $totalRecords',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
          if (isSyncing || errorMessage != null) ...[
            SizedBox(height: 12.h),
            LinearProgressIndicator(
              value: totalRecords > 0 ? syncedRecords / totalRecords : 0,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(
                errorMessage != null ? Colors.red : Colors.blue,
              ),
              minHeight: 6.h,
              borderRadius: BorderRadius.circular(3.r),
            ),
            if (errorMessage != null) ...[
              SizedBox(height: 8.h),
              Text(
                errorMessage!,
                style: TextStyle(fontSize: 11.sp, color: Colors.red.shade700),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
