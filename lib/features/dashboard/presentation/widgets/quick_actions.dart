import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_utils_v2.dart';
import '../../../../core/widgets/micro_interactions.dart';
import '../../../../theme/app_colors.dart';
import '../../../../core/utils/haptic_patterns.dart';

/// Quick Action Button - Reusable action button with Badge support
class QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int? badge; // Badge counter (optional)

  const QuickActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MicroInteractions.bounceButton(
      onTap: () {
        HapticPatterns.selection();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.08), color.withOpacity(0.12)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
          child: Row(
            children: [
              // Icon Container with Badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 24.sp),
                  ),
                  // Badge
                  if (badge != null && badge! > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Text(
                          badge! > 99 ? '99+' : '$badge',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quick Actions Grid - Grid of action buttons
class QuickActionsGrid extends StatelessWidget {
  final VoidCallback? onAddBeneficiaryTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onSyncTap;
  final VoidCallback? onReportsTap;
  final VoidCallback? onCivilRegistryTap;

  final VoidCallback? onVisitsTap;

  const QuickActionsGrid({
    super.key,
    this.onAddBeneficiaryTap,
    this.onSearchTap,
    this.onSyncTap,
    this.onReportsTap,
    this.onCivilRegistryTap,
    this.onVisitsTap,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);

    return Column(
      children: [
        QuickActionButton(
          label: 'إضافة مستفيد',
          icon: Icons.person_add,
          color: AppColors.info,
          onTap: onAddBeneficiaryTap ?? () {},
        ),
        SizedBox(height: spacing),
        QuickActionButton(
          label: 'البحث',
          icon: Icons.search,
          color: AppColors.success,
          onTap: onSearchTap ?? () {},
        ),
        SizedBox(height: spacing),
        QuickActionButton(
          label: 'المزامنة',
          icon: Icons.sync,
          color: AppColors.warning,
          onTap: onSyncTap ?? () {},
        ),
        SizedBox(height: spacing),
        QuickActionButton(
          label: 'التقارير',
          icon: Icons.bar_chart,
          color: AppColors.orphan,
          onTap: onReportsTap ?? () {},
        ),
        SizedBox(height: spacing),
        QuickActionButton(
          label: 'السجل المدني',
          icon: Icons.account_balance,
          color: AppColors.disabled,
          onTap: onCivilRegistryTap ?? () {},
        ),
        if (onVisitsTap != null) ...[
          SizedBox(height: spacing),
          QuickActionButton(
            label: 'الزيارات',
            icon: Icons.event_note,
            color: const Color(0xFF9C27B0),
            onTap: onVisitsTap!,
          ),
        ],
      ],
    );
  }
}

/// Grid version - للاستخدام في الأماكن التي تحتاج grid
class QuickActionsGridCompact extends StatelessWidget {
  final VoidCallback? onAddBeneficiaryTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onSyncTap;
  final VoidCallback? onReportsTap;
  final VoidCallback? onCivilRegistryTap;
  final VoidCallback? onVisitsTap;

  const QuickActionsGridCompact({
    super.key,
    this.onAddBeneficiaryTap,
    this.onSearchTap,
    this.onSyncTap,
    this.onReportsTap,
    this.onCivilRegistryTap,
    this.onVisitsTap,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = ResponsiveUtils.getCrossAxisCount(
      context,
      mobile: 2,
      tablet: 3,
      desktop: 4,
    );

    final childAspectRatio = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 2.8,
      tablet: 3.0,
      desktop: 3.2,
    );

    final spacing = ResponsiveUtils.getResponsiveSpacing(context);

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      childAspectRatio: childAspectRatio,
      children: [
        QuickActionButton(
          label: 'إضافة مستفيد',
          icon: Icons.person_add,
          color: AppColors.info,
          onTap: onAddBeneficiaryTap ?? () {},
        ),
        QuickActionButton(
          label: 'البحث',
          icon: Icons.search,
          color: AppColors.success,
          onTap: onSearchTap ?? () {},
        ),
        QuickActionButton(
          label: 'المزامنة',
          icon: Icons.sync,
          color: AppColors.warning,
          onTap: onSyncTap ?? () {},
        ),
        QuickActionButton(
          label: 'التقارير',
          icon: Icons.bar_chart,
          color: AppColors.orphan,
          onTap: onReportsTap ?? () {},
        ),
        QuickActionButton(
          label: 'السجل المدني',
          icon: Icons.account_balance,
          color: AppColors.disabled,
          onTap: onCivilRegistryTap ?? () {},
        ),
        if (onVisitsTap != null)
          QuickActionButton(
            label: 'الزيارات',
            icon: Icons.event_note,
            color: const Color(0xFF9C27B0),
            onTap: onVisitsTap!,
          ),
      ],
    );
  }
}
