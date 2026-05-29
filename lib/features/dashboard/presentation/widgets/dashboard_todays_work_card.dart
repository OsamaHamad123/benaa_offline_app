import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../features/dashboard/domain/entities/dashboard_statistics.dart';

/// Today's Work Card — ملخص عمل اليوم للعمال الميدانيين
///
/// Pure StatelessWidget — receives all data as parameters.
/// Uses only cheap data already embedded in [TodayStats] / [DashboardStatistics].
/// No new DB queries, no provider watch inside this widget.
class DashboardTodaysWorkCard extends StatelessWidget {
  final TodayStats todayStats;
  final VoidCallback onViewVisits;
  final VoidCallback? onAddVisit;
  final VoidCallback? onViewUrgent;

  const DashboardTodaysWorkCard({
    required this.todayStats,
    required this.onViewVisits,
    this.onAddVisit,
    this.onViewUrgent,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: 'عمل اليوم — ${todayStats.completedVisits} زيارة، ${todayStats.pendingTasks} مهام معلقة',
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, colorScheme),
              SizedBox(height: 16.h),
              _buildRows(context, colorScheme),
              if (todayStats.pendingTasks == 0 && todayStats.completedVisits == 0) ...[
                SizedBox(height: 12.h),
                _buildEmptyState(colorScheme),
              ],
              SizedBox(height: 12.h),
              _buildActions(context, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(
          Icons.today_rounded,
          size: 20.sp,
          color: colorScheme.primary,
        ),
        SizedBox(width: 8.w),
        Text(
          'عمل اليوم',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildRows(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        _WorkRow(
          icon: Icons.home_work_rounded,
          iconColor: Colors.teal.shade600,
          label: 'زيارات اليوم',
          value: todayStats.completedVisits > 0
              ? '${todayStats.completedVisits} زيارة مكتملة'
              : 'لا توجد زيارات مسجلة اليوم',
          isZero: todayStats.completedVisits == 0,
        ),
        SizedBox(height: 10.h),
        _WorkRow(
          icon: Icons.warning_amber_rounded,
          iconColor: todayStats.pendingTasks > 0 ? Colors.orange.shade700 : Colors.green.shade600,
          label: 'حالات تحتاج متابعة',
          value: todayStats.pendingTasks > 0
              ? '${todayStats.pendingTasks} حالة بانتظار المتابعة'
              : 'أحسنت! لا توجد حالات عاجلة اليوم',
          isZero: todayStats.pendingTasks == 0,
        ),
        if (todayStats.newBeneficiaries > 0) ...[
          SizedBox(height: 10.h),
          _WorkRow(
            icon: Icons.person_add_rounded,
            iconColor: Colors.blue.shade600,
            label: 'مستفيدون جدد اليوم',
            value: '${todayStats.newBeneficiaries} مستفيد جديد',
            isZero: false,
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 18.sp),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            'أحسنت! لا توجد حالات عاجلة اليوم',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.green.shade700,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onAddVisit != null) ...[
          OutlinedButton.icon(
            onPressed: onAddVisit,
            icon: Icon(Icons.add, size: 16.sp),
            label: Text('تسجيل زيارة', style: TextStyle(fontSize: 12.sp)),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              side: BorderSide(color: colorScheme.primary),
            ),
          ),
          SizedBox(width: 8.w),
        ],
        TextButton.icon(
          key: const Key('todays_work_view_all'),
          onPressed: onViewVisits,
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl ? Icons.arrow_back : Icons.arrow_forward,
            size: 16.sp,
          ),
          label: Text('عرض الكل', style: TextStyle(fontSize: 12.sp)),
        ),
      ],
    );
  }
}

class _WorkRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool isZero;

  const _WorkRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.isZero,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18.sp, color: iconColor),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isZero ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
                  fontWeight: isZero ? FontWeight.w400 : FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
