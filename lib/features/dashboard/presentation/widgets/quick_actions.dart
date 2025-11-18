import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_utils.dart';

/// Quick Action Button - Reusable action button
class QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32.sp),
              ),
              SizedBox(height: 12.h),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
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
      mobile: 1.3,
      tablet: 1.2,
      desktop: 1.1,
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
