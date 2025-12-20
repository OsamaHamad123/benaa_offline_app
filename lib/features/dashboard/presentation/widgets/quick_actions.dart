import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_utils_v2.dart';
import '../../../../core/widgets/micro_interactions.dart';
import '../../../../theme/app_colors.dart';
import '../utils/dashboard_colors.dart'; // ✅ Dashboard Colors
import '../utils/dashboard_text_styles.dart'; // ✅ Dashboard Text Styles
import '../utils/dashboard_spacing.dart'; // ✅ Dashboard Spacing
import '../utils/dashboard_haptics.dart'; // ✅ Dashboard Haptics
import '../../../../core/utils/haptic_patterns.dart';

/// Quick Action Card - Modern card design for quick actions
class QuickActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int? badge; // Badge counter (optional)

  const QuickActionCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badge,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: '$label${badge != null && badge! > 0 ? ', لديك $badge إشعار' : ''}',
      hint: 'اضغط للانتقال إلى $label',
      button: true,
      child: MicroInteractions.bounceButton(
        onTap: () {
          DashboardHaptics.onQuickAction();
          onTap();
        },
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(
              color: color.withAlpha(51),
            ),
          ),
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withAlpha(isDark ? 38 : 13),
                  color.withAlpha(isDark ? 20 : 5),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon Container with Badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withAlpha(179)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              color: color.withAlpha(77),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(icon, color: Colors.white, size: 28.sp),
                      ),
                      // Badge
                      if (badge != null && badge! > 0)
                        Positioned(
                          top: -6,
                          right: -6,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 7.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: isDark ? AppColors.surfaceDark : Colors.white,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.error.withAlpha(102),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
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
                  SizedBox(height: DashboardSpacing.small),
                  Text(
                    label,
                    style: DashboardTextStyles.cardSubtitle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Legacy support - Keep old name for backward compatibility
class QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int? badge;

  const QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badge,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return QuickActionCard(
      label: label,
      icon: icon,
      color: color,
      onTap: onTap,
      badge: badge,
    );
  }
}

/// Quick Actions Grid - Modern Grid Layout for action cards
class QuickActionsGrid extends StatelessWidget {
  final VoidCallback? onAddBeneficiaryTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onSyncTap;
  final VoidCallback? onReportsTap;
  final VoidCallback? onCivilRegistryTap;
  final VoidCallback? onVisitsTap;
  final VoidCallback? onAssociationsTap;
  final VoidCallback? onKafalatTap;
  final int? syncBadge;
  final int? reportsBadge;
  final int? associationsBadge;

  const QuickActionsGrid({
    super.key,
    this.onAddBeneficiaryTap,
    this.onSearchTap,
    this.onSyncTap,
    this.onReportsTap,
    this.onCivilRegistryTap,
    this.onVisitsTap,
    this.onAssociationsTap,
    this.onKafalatTap,
    this.syncBadge,
    this.reportsBadge,
    this.associationsBadge,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = ResponsiveUtils.getCrossAxisCount(
      context,
    );

    final childAspectRatio = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 1.1,
      tablet: 1.15,
      desktop: 1.2,
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
        QuickActionCard(
          label: 'إضافة مستفيد',
          icon: Icons.person_add_rounded,
          color: DashboardColors.totalBeneficiaries,
          onTap: onAddBeneficiaryTap ?? () {},
        ),
        if (onKafalatTap != null)
          QuickActionCard(
            label: 'الكفالات',
            icon: Icons.volunteer_activism_rounded,
            color: AppColors.accent,
            onTap: onKafalatTap!,
          ),
        QuickActionCard(
          label: 'البحث',
          icon: Icons.search_rounded,
          color: AppColors.success,
          onTap: onSearchTap ?? () {},
        ),
        QuickActionCard(
          label: 'المزامنة',
          icon: Icons.sync_rounded,
          color: DashboardColors.normal,
          badge: syncBadge,
          onTap: onSyncTap ?? () {},
        ),
        QuickActionCard(
          label: 'التقارير',
          icon: Icons.assessment_rounded,
          color: DashboardColors.widows,
          badge: reportsBadge,
          onTap: onReportsTap ?? () {},
        ),
        QuickActionCard(
          label: 'السجل المدني',
          icon: Icons.account_balance_rounded,
          color: DashboardColors.poor,
          onTap: onCivilRegistryTap ?? () {},
        ),
        if (onVisitsTap != null)
          QuickActionCard(
            label: 'الزيارات',
            icon: Icons.event_note_rounded,
            color: DashboardColors.disabled,
            onTap: onVisitsTap!,
          ),
        if (onAssociationsTap != null)
          QuickActionCard(
            label: 'الجمعيات',
            icon: Icons.business_rounded,
            color: const Color(0xFF9C27B0), // Purple
            badge: associationsBadge,
            onTap: onAssociationsTap!,
          ),
      ],
    );
  }
}

/// Compact Grid version - للاستخدام في الأماكن الضيقة
class QuickActionsGridCompact extends StatelessWidget {
  final VoidCallback? onAddBeneficiaryTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onSyncTap;
  final VoidCallback? onReportsTap;
  final VoidCallback? onCivilRegistryTap;
  final VoidCallback? onVisitsTap;
  final VoidCallback? onKafalatTap;
  final int? syncBadge;
  final int? reportsBadge;

  const QuickActionsGridCompact({
    super.key,
    this.onAddBeneficiaryTap,
    this.onKafalatTap,
    this.onSearchTap,
    this.onSyncTap,
    this.onReportsTap,
    this.onCivilRegistryTap,
    this.onVisitsTap,
    this.syncBadge,
    this.reportsBadge,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = ResponsiveUtils.getCrossAxisCount(
      context,
      mobile: 3,
      tablet: 4,
      desktop: 6,
    );

    final childAspectRatio = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 0.9,
      tablet: 1.0,
      desktop: 1.1,
    );

    final spacing = ResponsiveUtils.getResponsiveSpacing(context) * 0.8;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      childAspectRatio: childAspectRatio,
      children: [
        QuickActionCard(
          label: 'إضافة مستفيد',
          icon: Icons.person_add_rounded,
          color: DashboardColors.totalBeneficiaries,
          onTap: onAddBeneficiaryTap ?? () {},
        ),
        if (onKafalatTap != null)
          QuickActionCard(
            label: 'الكفالات',
            icon: Icons.volunteer_activism_rounded,
            color: AppColors.accent,
            onTap: onKafalatTap!,
          ),
        QuickActionCard(
          label: 'البحث',
          icon: Icons.search_rounded,
          color: DashboardColors.success,
          onTap: onSearchTap ?? () {},
        ),
        QuickActionCard(
          label: 'المزامنة',
          icon: Icons.sync_rounded,
          color: DashboardColors.normal,
          badge: syncBadge,
          onTap: onSyncTap ?? () {},
        ),
        QuickActionCard(
          label: 'التقارير',
          icon: Icons.assessment_rounded,
          color: DashboardColors.widows,
          badge: reportsBadge,
          onTap: onReportsTap ?? () {},
        ),
        QuickActionCard(
          label: 'السجل المدني',
          icon: Icons.account_balance_rounded,
          color: DashboardColors.poor,
          onTap: onCivilRegistryTap ?? () {},
        ),
        if (onVisitsTap != null)
          QuickActionCard(
            label: 'الزيارات',
            icon: Icons.event_note_rounded,
            color: DashboardColors.disabled,
            onTap: onVisitsTap!,
          ),
      ],
    );
  }
}
