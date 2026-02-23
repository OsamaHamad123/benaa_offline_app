import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/associations_reports_provider.dart';

/// 📊 لوحة الإحصائيات الرئيسية
class StatsDashboardWidget extends StatelessWidget {
  final AssociationsStats stats;

  const StatsDashboardWidget({required this.stats, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dashboard,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'ملخص الإحصائيات',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: [
                _StatCard(
                  icon: Icons.account_balance,
                  label: 'إجمالي الجمعيات',
                  value: '${stats.total}',
                  color: Colors.blue,
                ),
                _StatCard(
                  icon: Icons.check_circle,
                  label: 'النشطة',
                  value: '${stats.active}',
                  subtitle: '${stats.activePercentage.toStringAsFixed(0)}%',
                  color: Colors.green,
                ),
                _StatCard(
                  icon: Icons.cancel,
                  label: 'المعطلة',
                  value: '${stats.inactive}',
                  subtitle: '${stats.inactivePercentage.toStringAsFixed(0)}%',
                  color: Colors.orange,
                ),
                _StatCard(
                  icon: Icons.fiber_new,
                  label: 'مضاف حديثاً',
                  value: '${stats.recentlyAdded}',
                  subtitle: 'آخر 30 يوم',
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color, this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minWidth: 90.w,
        maxWidth: 120.w,
      ),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4.h),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 9.sp,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
