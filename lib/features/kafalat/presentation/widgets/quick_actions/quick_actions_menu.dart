import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../pages/sponsorship_charts_page.dart';
import '../../pages/advanced_filters_page.dart';
import '../../pages/export_page.dart';
import '../../pages/smart_notifications_page.dart';
import '../../pages/theme_settings_page.dart';
import '../../pages/additional_features_pages.dart';

/// قائمة Quick Actions للميزات المتقدمة المقترحة
///
/// تعرض القائمة 10 ميزات رئيسية:
/// - التحليلات والرسوم البيانية
/// - الفلاتر المتقدمة
/// - التصدير (Excel/PDF)
/// - الإشعارات الذكية
/// - تحسينات تجربة المستخدم
/// - إدارة الصلاحيات
/// - ميزات الموبايل
/// - الثيمات والمظهر
/// - المزامنة الفورية
/// - لوحة التحكم المتقدمة
class QuickActionsMenu extends StatelessWidget {
  const QuickActionsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(isMobile ? 12.w : 16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                Icons.rocket_launch_rounded,
                color: theme.colorScheme.primary,
                size: isMobile ? 20.sp : 24.sp,
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  'الميزات المتقدمة',
                  style: (isMobile ? theme.textTheme.titleMedium : theme.textTheme.titleLarge)?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12.h : 16.h),

          // Quick Actions Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth < 600
                  ? 2 // Mobile
                  : constraints.maxWidth < 900
                      ? 3 // Tablet
                      : 5; // Desktop

              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: isMobile ? 8.w : 12.w,
                crossAxisSpacing: isMobile ? 8.w : 12.w,
                childAspectRatio: isMobile ? 1.0 : 0.95,
                children: [
                  _QuickActionCard(
                    icon: Icons.show_chart,
                    title: 'التحليلات',
                    subtitle: 'رسوم بيانية',
                    color: Colors.blue,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SponsorshipChartsPage(),
                      ),
                    ),
                  ),
                  _QuickActionCard(
                    icon: Icons.filter_alt_outlined,
                    title: 'الفلاتر',
                    subtitle: 'بحث متقدم',
                    color: Colors.purple,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AdvancedFiltersPage(),
                      ),
                    ),
                  ),
                  _QuickActionCard(
                    icon: Icons.file_download_outlined,
                    title: 'التصدير',
                    subtitle: 'Excel/PDF',
                    color: Colors.green,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ExportPage(),
                      ),
                    ),
                  ),
                  _QuickActionCard(
                    icon: Icons.notifications_outlined,
                    title: 'الإشعارات',
                    subtitle: 'تنبيهات ذكية',
                    color: Colors.orange,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SmartNotificationsPage(),
                      ),
                    ),
                  ),
                  _QuickActionCard(
                    icon: Icons.palette_outlined,
                    title: 'المظهر',
                    subtitle: 'ثيمات',
                    color: Colors.pink,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ThemeSettingsPage(),
                      ),
                    ),
                  ),
                  _QuickActionCard(
                    icon: Icons.sync,
                    title: 'المزامنة',
                    subtitle: 'تحديث فوري',
                    color: Colors.cyan,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SyncSettingsPage(),
                      ),
                    ),
                  ),
                  _QuickActionCard(
                    icon: Icons.lock_outline,
                    title: 'الصلاحيات',
                    subtitle: 'إدارة الوصول',
                    color: Colors.red,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PermissionsPage(),
                      ),
                    ),
                  ),
                  _QuickActionCard(
                    icon: Icons.phone_android,
                    title: 'موبايل',
                    subtitle: 'ميزات خاصة',
                    color: Colors.indigo,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MobileFeaturesPage(),
                      ),
                    ),
                  ),
                  _QuickActionCard(
                    icon: Icons.dashboard_customize,
                    title: 'لوحة التحكم',
                    subtitle: 'تخصيص شامل',
                    color: Colors.teal,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AdvancedDashboardPage(),
                      ),
                    ),
                  ),
                  _QuickActionCard(
                    icon: Icons.auto_awesome,
                    title: 'UX',
                    subtitle: 'تجربة محسنة',
                    color: Colors.amber,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const UXEnhancementsPage(),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// بطاقة Quick Action واحدة
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 10.w : 12.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(isMobile ? 8.w : 10.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: color,
                size: isMobile ? 22.sp : 26.sp,
              ),
            ),
            SizedBox(height: isMobile ? 6.h : 8.h),

            // Title
            Text(
              title,
              style: (isMobile ? theme.textTheme.bodyMedium : theme.textTheme.bodyLarge)?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.h),

            // Subtitle
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontSize: isMobile ? 10.sp : 11.sp,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
