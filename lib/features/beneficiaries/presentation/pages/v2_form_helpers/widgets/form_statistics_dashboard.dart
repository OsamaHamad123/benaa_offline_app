import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/utils/responsive_utils_v2.dart';

/// 📊 Statistics Dashboard Widget
///
/// Shows form statistics in a beautiful card layout
class FormStatisticsDashboard extends StatelessWidget {
  final int totalFields;
  final int completedFields;
  final int requiredFields;
  final int optionalFields;
  final Duration? timeSpent;

  const FormStatisticsDashboard({
    required this.totalFields, required this.completedFields, required this.requiredFields, required this.optionalFields, super.key,
    this.timeSpent,
  });

  double get completionPercentage =>
      totalFields > 0 ? (completedFields / totalFields) * 100 : 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTabletOrDesktop =
        ResponsiveUtils.isTablet(context) || ResponsiveUtils.isDesktop(context);

    return Container(
      margin: ResponsiveUtils.getHorizontalPadding(
        context,
      ).add(EdgeInsets.symmetric(vertical: ResponsiveUtils.smallSpace)),
      padding: EdgeInsets.all(ResponsiveUtils.mediumSpace),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer.withOpacity(0.3),
            theme.colorScheme.surfaceContainerHighest.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: theme.colorScheme.primary,
                size: isTabletOrDesktop ? 26.0 : 24.0,
              ),
              SizedBox(width: ResponsiveUtils.smallSpace),
              Text(
                'إحصائيات النموذج',
                style: TextStyle(
                  fontSize: isTabletOrDesktop ? 18.sp : 16.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.mediumSpace),

          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'نسبة الإكمال',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    '${completionPercentage.toInt()}%',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveUtils.smallSpace),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: LinearProgressIndicator(
                  value: completionPercentage / 100,
                  minHeight: isTabletOrDesktop ? 10 : 8,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(
                    _getProgressColor(completionPercentage),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.mediumSpace),

          // Stats Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: ResponsiveUtils.smallSpace,
            crossAxisSpacing: ResponsiveUtils.smallSpace,
            childAspectRatio: isTabletOrDesktop ? 2.5 : 2.2,
            children: [
              _StatItem(
                icon: Icons.check_circle_outline,
                label: 'مكتمل',
                value: '$completedFields',
                color: Colors.green,
              ),
              _StatItem(
                icon: Icons.pending_outlined,
                label: 'متبقي',
                value: '${totalFields - completedFields}',
                color: Colors.orange,
              ),
              _StatItem(
                icon: Icons.star_outline,
                label: 'مطلوب',
                value: '$requiredFields',
                color: Colors.red,
              ),
              _StatItem(
                icon: Icons.info_outline,
                label: 'اختياري',
                value: '$optionalFields',
                color: Colors.blue,
              ),
            ],
          ),

          if (timeSpent != null) ...[
            SizedBox(height: ResponsiveUtils.smallSpace),
            Divider(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
            SizedBox(height: ResponsiveUtils.smallSpace),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: ResponsiveUtils.xSmallSpace),
                Text(
                  'الوقت المستغرق: ${_formatDuration(timeSpent!)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours س $minutes د';
    }
    return '$minutes دقيقة';
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
