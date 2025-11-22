import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/providers/providers.dart' as core_providers;
import '../providers.dart';
import 'monitoring_dashboard.dart';
import '../../../../core/drafts/form_draft_manager.dart';

/// Dashboard AppBar - Clean Architecture Version
/// Displays notifications badge, search, and action buttons
class DashboardAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSyncTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSearchTap;

  const DashboardAppBar({
    super.key,
    required this.title,
    this.onNotificationTap,
    this.onSyncTap,
    this.onProfileTap,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Wait for SharedPreferences to load before accessing dashboard state
    final prefsAsync = ref.watch(core_providers.sharedPreferencesProvider);

    final notificationCount = prefsAsync.maybeWhen(
      data: (_) {
        final state = ref.watch(dashboardProvider);
        return state.todayStats?.pendingTasks ?? 0;
      },
      orElse: () => 0,
    );

    return AppBar(
      title: Text(
        title,
        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade600, Colors.blue.shade700],
          ),
        ),
      ),
      actions: [
        // Monitoring Dashboard (Dev/Admin only)
        IconButton(
          icon: const Icon(Icons.analytics_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MonitoringDashboard()),
            );
          },
          tooltip: 'المراقبة والإحصائيات',
        ),
        // Drafts Indicator
        const DraftIndicator(),
        // Search Button
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: onSearchTap,
          tooltip: 'بحث',
        ),
        // Notifications Badge
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: onNotificationTap,
              tooltip: 'الإشعارات',
            ),
            if (notificationCount > 0)
              Positioned(
                right: 8.w,
                top: 8.h,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  constraints: BoxConstraints(minWidth: 18.w, minHeight: 18.h),
                  child: Text(
                    notificationCount > 9 ? '9+' : '$notificationCount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        // Sync Button
        IconButton(
          icon: const Icon(Icons.sync),
          onPressed: onSyncTap,
          tooltip: 'مزامنة',
        ),
        // Profile Button
        IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: onProfileTap,
          tooltip: 'الملف الشخصي',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
