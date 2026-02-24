import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Quick Stats Card - Shows beneficiary statistics
class QuickStatsCard extends StatelessWidget {
  final int visitsCount;
  final int attachmentsCount;
  final String lastVisitDate;

  const QuickStatsCard({
    required this.visitsCount,
    required this.attachmentsCount,
    required this.lastVisitDate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'إحصائيات سريعة: $visitsCount زيارة, $attachmentsCount مرفق, آخر زيارة $lastVisitDate',
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                icon: Icons.event_available,
                label: 'الزيارات',
                value: visitsCount.toString(),
                color: colorScheme.primary,
              ),
              _VerticalDivider(),
              _StatItem(
                icon: Icons.attach_file,
                label: 'المرفقات',
                value: attachmentsCount.toString(),
                color: colorScheme.tertiary,
              ),
              _VerticalDivider(),
              _StatItem(
                icon: Icons.access_time,
                label: 'آخر زيارة',
                value: lastVisitDate,
                color: colorScheme.secondary,
                isSmallText: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isSmallText;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isSmallText = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmallText ? 11.sp : 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 50.h, width: 1.w, color: Theme.of(context).colorScheme.outlineVariant);
  }
}
