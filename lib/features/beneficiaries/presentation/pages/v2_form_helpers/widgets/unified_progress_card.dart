import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/utils/responsive_utils_v2.dart';

/// 📋 Unified Progress Card
///
/// Combines tab progress and field completion in one card
/// Responsive design with adaptive sizes for different devices
class UnifiedProgressCard extends StatelessWidget {
  final int currentTab;
  final int totalTabs;
  final int completedFields;
  final int totalFields;
  final String currentTabTitle;

  const UnifiedProgressCard({
    super.key,
    required this.currentTab,
    required this.totalTabs,
    required this.completedFields,
    required this.totalFields,
    required this.currentTabTitle,
  });

  double get tabProgress => (currentTab + 1) / totalTabs;
  double get fieldsProgress =>
      totalFields > 0 ? completedFields / totalFields : 0.0;
  double get overallProgress => (tabProgress + fieldsProgress) / 2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTabletOrDesktop =
        ResponsiveUtils.isTablet(context) || ResponsiveUtils.isDesktop(context);

    // Responsive sizes
    final circleSize = isTabletOrDesktop ? 70.0 : 60.0;
    final titleFontSize = isTabletOrDesktop ? 16.sp : 15.sp;
    final subtitleFontSize = isTabletOrDesktop ? 13.sp : 12.sp;
    final percentFontSize = isTabletOrDesktop ? 18.sp : 16.sp;

    return RepaintBoundary(
      child: Card(
        elevation: 2,
        margin: ResponsiveUtils.getHorizontalPadding(
          context,
        ).add(EdgeInsets.symmetric(vertical: ResponsiveUtils.smallSpace)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(ResponsiveUtils.mediumSpace),
          child: Column(
            children: [
              // Header Row
              Row(
                children: [
                  // Overall Progress Circle
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: circleSize,
                        height: circleSize,
                        child: CircularProgressIndicator(
                          value: overallProgress,
                          strokeWidth: isTabletOrDesktop ? 6 : 5,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(
                            _getProgressColor(overallProgress),
                          ),
                        ),
                      ),
                      Text(
                        '${(overallProgress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: percentFontSize,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(width: ResponsiveUtils.mediumSpace),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentTabTitle,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: ResponsiveUtils.xSmallSpace),
                        Text(
                          'التبويب ${currentTab + 1} من $totalTabs',
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: ResponsiveUtils.xSmallSpace),
                        Text(
                          'الحقول: $completedFields / $totalFields',
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status Icon
                  Icon(
                    overallProgress >= 0.8
                        ? Icons.check_circle_rounded
                        : overallProgress >= 0.5
                        ? Icons.access_time_rounded
                        : Icons.info_rounded,
                    color: _getProgressColor(overallProgress),
                    size: isTabletOrDesktop ? 30 : 28,
                  ),
                ],
              ),

              SizedBox(height: ResponsiveUtils.smallSpace),

              // Progress Bars
              Row(
                children: [
                  Expanded(
                    child: _buildProgressBar(
                      context: context,
                      label: 'التبويبات',
                      progress: tabProgress,
                      color: Colors.blue,
                      isTabletOrDesktop: isTabletOrDesktop,
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.smallSpace),
                  Expanded(
                    child: _buildProgressBar(
                      context: context,
                      label: 'الحقول',
                      progress: fieldsProgress,
                      color: _getProgressColor(fieldsProgress),
                      isTabletOrDesktop: isTabletOrDesktop,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar({
    required BuildContext context,
    required String label,
    required double progress,
    required Color color,
    required bool isTabletOrDesktop,
  }) {
    final labelFontSize = isTabletOrDesktop ? 12.sp : 11.sp;
    final percentFontSize = isTabletOrDesktop ? 11.sp : 10.sp;
    final barHeight = isTabletOrDesktop ? 8.0 : 6.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: labelFontSize,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: ResponsiveUtils.xSmallSpace),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: barHeight,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          '${(progress * 100).toInt()}%',
          style: TextStyle(
            fontSize: percentFontSize,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return Colors.green;
    if (progress >= 0.5) return Colors.orange;
    return Colors.red;
  }
}
