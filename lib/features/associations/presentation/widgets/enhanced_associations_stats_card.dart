import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_utils_v2.dart';

/// 📊 بطاقة إحصائيات محسنة مع نسب مئوية
class EnhancedAssociationsStatsCard extends StatelessWidget {
  final int totalCount;
  final int activeCount;
  final int inactiveCount;

  const EnhancedAssociationsStatsCard({
    required this.totalCount, required this.activeCount, required this.inactiveCount, super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activePercentage = totalCount > 0 ? (activeCount / totalCount * 100).toStringAsFixed(0) : '0';
    final inactivePercentage = totalCount > 0 ? (inactiveCount / totalCount * 100).toStringAsFixed(0) : '0';

    return Card(
      elevation: 6,
      shadowColor: theme.colorScheme.primary.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUtils.largeRadius),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ResponsiveUtils.largeRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        padding: EdgeInsets.all(ResponsiveUtils.mediumSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(ResponsiveUtils.smallSpace),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(ResponsiveUtils.smallRadius),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.analytics_outlined,
                    color: Colors.white,
                    size: ResponsiveUtils.getIconSize(context),
                  ),
                ),
                SizedBox(width: ResponsiveUtils.smallSpace),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إحصائيات الجمعيات',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'نظرة سريعة على البيانات',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: ResponsiveUtils.smallSpace),

            // الإحصائيات - دائماً أفقية باستخدام Wrap للتكيف
            Wrap(
              spacing: ResponsiveUtils.smallSpace,
              runSpacing: ResponsiveUtils.smallSpace,
              alignment: WrapAlignment.spaceEvenly,
              children: [
                _StatItem(
                  icon: Icons.business_center,
                  label: 'الإجمالي',
                  value: totalCount.toString(),
                  color: Colors.blue,
                  percentage: '100%',
                ),
                _StatItem(
                  icon: Icons.check_circle_outline,
                  label: 'نشطة',
                  value: activeCount.toString(),
                  color: Colors.green,
                  percentage: '$activePercentage%',
                ),
                _StatItem(
                  icon: Icons.pause_circle_outline,
                  label: 'معطلة',
                  value: inactiveCount.toString(),
                  color: Colors.orange,
                  percentage: '$inactivePercentage%',
                ),
              ],
            ),
          ],
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
  final String percentage;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(
        minWidth: 90.w,
        maxWidth: 120.w,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 10.h,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // الأيقونة
          Icon(
            icon,
            color: color,
            size: 24.sp,
          ),
          SizedBox(height: 6.h),

          // الرقم
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 22.sp,
            ),
          ),

          // النسبة المئوية
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 6.w,
              vertical: 2.h,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              percentage,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 10.sp,
              ),
            ),
          ),

          SizedBox(height: 4.h),

          // التسمية
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w600,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}
