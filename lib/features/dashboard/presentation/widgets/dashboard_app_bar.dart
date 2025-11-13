import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers.dart';

/// Dashboard AppBar - Clean Architecture Version
/// Displays notifications badge and action buttons
class DashboardAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSyncTap;
  final VoidCallback? onProfileTap;

  const DashboardAppBar({
    super.key,
    required this.title,
    this.onNotificationTap,
    this.onSyncTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationCount = ref.watch(notificationsCountProvider);

    return AppBar(
      title: Text(title),
      centerTitle: true,
      actions: [
        // Notifications Badge
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: onNotificationTap,
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
        IconButton(icon: const Icon(Icons.sync), onPressed: onSyncTap),
        // Profile Button
        IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: onProfileTap,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
