import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/providers/providers.dart' as core_providers;
import '../../../../core/theme/app_color_system.dart';
import '../providers.dart';

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

    // Get time-based color for dynamic gradient
    final timeBasedColor = AppColorSystem.getTimeBasedColor(DateTime.now());

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            timeBasedColor,
            timeBasedColor.withOpacity(0.8),
            Colors.blue.shade700,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        boxShadow: AppColorSystem.getElevatedShadow(
          color: timeBasedColor,
          elevation: 3.0,
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
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
                    constraints: BoxConstraints(
                      minWidth: 18.w,
                      minHeight: 18.h,
                    ),
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
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
