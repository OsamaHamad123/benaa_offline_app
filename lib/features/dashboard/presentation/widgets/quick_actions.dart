import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_utils.dart';

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

    return Card(
      elevation: 2,
      shadowColor: color.withOpacity(0.25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Container with Badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.15),
                          color.withOpacity(0.25),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(icon, color: color, size: 30.sp),
                  ),
                  // Badge
                  if (badge != null && badge! > 0)
                    Positioned(
                      top: -6,
                      right: -6,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Text(
                          badge! > 99 ? '99+' : '$badge',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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

  const QuickActionsGrid({
    super.key,
    this.onAddBeneficiaryTap,
    this.onSearchTap,
    this.onSyncTap,
    this.onReportsTap,
    this.onCivilRegistryTap,
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
      mobile: 1.25,
      tablet: 1.4,
      desktop: 1.25,
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
          color: Colors.blue,
          onTap: onAddBeneficiaryTap ?? () {},
        ),
        QuickActionButton(
          label: 'البحث',
          icon: Icons.search,
          color: Colors.green,
          onTap: onSearchTap ?? () {},
        ),
        QuickActionButton(
          label: 'المزامنة',
          icon: Icons.sync,
          color: Colors.orange,
          onTap: onSyncTap ?? () {},
        ),
        QuickActionButton(
          label: 'التقارير',
          icon: Icons.bar_chart,
          color: Colors.purple,
          onTap: onReportsTap ?? () {},
        ),
        QuickActionButton(
          label: 'السجل المدني',
          icon: Icons.account_balance,
          color: Colors.teal,
          onTap: onCivilRegistryTap ?? () {},
        ),
      ],
    );
  }
}
