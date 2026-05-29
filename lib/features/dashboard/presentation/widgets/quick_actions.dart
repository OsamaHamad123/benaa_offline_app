import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_utils_v2.dart';
import '../../../../core/widgets/micro_interactions.dart';
import '../../../../theme/app_colors.dart';
import '../utils/dashboard_colors.dart'; // ✅ Dashboard Colors
import '../utils/dashboard_text_styles.dart'; // ✅ Dashboard Text Styles
import '../utils/dashboard_spacing.dart'; // ✅ Dashboard Spacing
import '../utils/dashboard_haptics.dart'; // ✅ Dashboard Haptics

/// Quick Action Card - Modern card design for quick actions
class QuickActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int? badge; // Badge counter (optional)
  final bool emphasized;

  const QuickActionCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badge,
    this.emphasized = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final compact = MediaQuery.sizeOf(context).width < 380;

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
              color: color.withAlpha(isDark ? 82 : (emphasized ? 90 : 58)),
            ),
          ),
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withAlpha(isDark ? (emphasized ? 52 : 34) : (emphasized ? 24 : 12)),
                  color.withAlpha(isDark ? (emphasized ? 26 : 16) : (emphasized ? 10 : 4)),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: compact ? 10.w : 12.w, vertical: compact ? 10.h : 12.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon Container with Badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: compact ? 46.w : 50.w,
                        height: compact ? 46.w : 50.w,
                        decoration: BoxDecoration(
                          color: color.withAlpha(isDark ? (emphasized ? 76 : 58) : (emphasized ? 58 : 42)),
                          borderRadius: BorderRadius.circular(13.r),
                          border: Border.all(
                            color: color.withAlpha(isDark ? 112 : 92),
                            width: emphasized ? 1.2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withAlpha(isDark ? 64 : 42),
                              blurRadius: emphasized ? 8 : 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: isDark ? Colors.white : color,
                          size: compact ? 21.sp : 23.sp,
                        ),
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
                  SizedBox(height: compact ? 8.h : DashboardSpacing.small),
                  Text(
                    label,
                    style: DashboardTextStyles.cardSubtitle.copyWith(
                      fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      fontSize: compact ? 11.sp : 11.5.sp,
                      height: 1.15,
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
        // الإجراءات الأساسية الستة — مرتبة حسب الأهمية
        QuickActionCard(
          label: 'إضافة مستفيد',
          icon: Icons.person_add_rounded,
          color: DashboardColors.totalBeneficiaries,
          emphasized: true,
          onTap: onAddBeneficiaryTap ?? () {},
        ),
        QuickActionCard(
          label: 'المستفيدون',
          icon: Icons.people_rounded,
          color: AppColors.success,
          onTap: onSearchTap ?? () {},
        ),
        QuickActionCard(
          label: 'زيارات اليوم',
          icon: Icons.event_note_rounded,
          color: DashboardColors.disabled,
          onTap: onVisitsTap ?? () {},
        ),
        QuickActionCard(
          label: 'الكفالات',
          icon: Icons.volunteer_activism_rounded,
          color: AppColors.accent,
          onTap: onKafalatTap ?? () {},
        ),
        QuickActionCard(
          label: 'الجمعيات',
          icon: Icons.business_rounded,
          color: DashboardColors.widows,
          badge: associationsBadge,
          onTap: onAssociationsTap ?? () {},
        ),
        QuickActionCard(
          label: 'المزامنة',
          icon: Icons.sync_rounded,
          color: DashboardColors.normal,
          emphasized: syncBadge != null && syncBadge! > 0,
          badge: syncBadge,
          onTap: onSyncTap ?? () {},
        ),
      ],
    );
  }
}
