import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/auth/role_provider.dart';
import '../../../../core/providers/providers.dart' as core_providers;
import '../providers.dart';
import '../utils/dashboard_text_styles.dart';
import 'monitoring_dashboard.dart';
import '../../../../core/drafts/form_draft_manager.dart';

/// Dashboard AppBar - الشريط العلوي للداشبورد
///
/// يعرض:
/// - زر البحث
/// - شارة الإشعارات
/// - قائمة منسدلة للإجراءات الثانوية (مزامنة، ملف شخصي)
/// - أدوات المراقبة للمدير فقط (admin or kDebugMode)
class DashboardAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSyncTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSearchTap;

  const DashboardAppBar({
    required this.title,
    super.key,
    this.onNotificationTap,
    this.onSyncTap,
    this.onProfileTap,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(core_providers.sharedPreferencesProvider);

    final notificationCount = prefsAsync.maybeWhen(
      data: (_) {
        final state = ref.watch(dashboardProvider);
        return state.todayStats?.pendingTasks ?? 0;
      },
      orElse: () => 0,
    );

    // أدوات المراقبة: للمدير فقط أو في debug mode
    final isAdmin = ref.watch(isAdminProvider);
    final showAdminTools = isAdmin || kDebugMode;

    return AppBar(
      title: Text(
        title,
        style: DashboardTextStyles.sectionTitle.copyWith(
          fontSize: 19.sp,
          color: Colors.white,
        ),
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
        // مسودات النماذج
        const DraftIndicator(),

        // زر البحث — مع مسافة واضحة
        Padding(
          padding: EdgeInsets.only(right: 4.w),
          child: IconButton(
            constraints: BoxConstraints(minWidth: 48.w, minHeight: 48.h),
            icon: const Icon(Icons.search_rounded),
            onPressed: onSearchTap,
            tooltip: 'بحث',
          ),
        ),

        // الإشعارات مع شارة العدد
        Padding(
          padding: EdgeInsets.only(right: 4.w),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                constraints: BoxConstraints(minWidth: 48.w, minHeight: 48.h),
                icon: const Icon(Icons.notifications_outlined),
                onPressed: onNotificationTap,
                tooltip: 'الإشعارات',
              ),
              if (notificationCount > 0)
                Positioned(
                  right: 6.w,
                  top: 6.h,
                  child: IgnorePointer(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints: BoxConstraints(minWidth: 18.w, minHeight: 16.h),
                      child: Text(
                        notificationCount > 9 ? '9+' : '$notificationCount',
                        style: DashboardTextStyles.badge.copyWith(fontSize: 10.sp),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // قائمة الإجراءات الثانوية (··· ثلاث نقاط)
        Padding(
          padding: EdgeInsets.only(right: 8.w),
          child: PopupMenuButton<_AppBarAction>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            tooltip: 'المزيد من الخيارات',
            constraints: BoxConstraints(minWidth: 48.w, minHeight: 48.h),
            onSelected: (action) => _handleAction(context, action),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: _AppBarAction.sync,
                child: ListTile(
                  leading: Icon(Icons.sync_rounded),
                  title: Text('المزامنة'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: _AppBarAction.profile,
                child: ListTile(
                  leading: Icon(Icons.person_outline_rounded),
                  title: Text('الملف الشخصي'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              if (showAdminTools) ...[
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: _AppBarAction.monitoring,
                  child: ListTile(
                    leading: Icon(Icons.analytics_outlined, color: Colors.orange),
                    title: Text('لوحة المراقبة'),
                    subtitle: Text('للمدير فقط'),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _handleAction(BuildContext context, _AppBarAction action) {
    switch (action) {
      case _AppBarAction.sync:
        onSyncTap?.call();
      case _AppBarAction.profile:
        onProfileTap?.call();
      case _AppBarAction.monitoring:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MonitoringDashboard()),
        );
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

enum _AppBarAction { sync, profile, monitoring }
