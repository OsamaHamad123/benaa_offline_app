import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Custom AppBar مخصص وجذاب - قابل لإعادة الاستخدام
/// يدعم نظام الألوان الديناميكي من الإعدادات
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final bool centerTitle;
  final double elevation;
  final bool showGradient;

  const CustomAppBar({
    required this.title, super.key,
    this.actions,
    this.leading,
    this.showBackButton = false,
    this.onBackPressed,
    this.bottom,
    this.backgroundColor,
    this.centerTitle = true,
    this.elevation = 0,
    this.showGradient = true,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;

    return Container(
      decoration: showGradient
          ? BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 8.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            )
          : null,
      child: AppBar(
        title: _buildTitle(context),
        centerTitle: centerTitle,
        elevation: elevation,
        backgroundColor: showGradient ? Colors.transparent : backgroundColor,
        foregroundColor: Colors.white,
        leading: _buildLeading(context),
        actions: actions,
        bottom: bottom,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            Icons.apartment_rounded,
            color: Colors.white,
            size: 20.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Flexible(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    if (showBackButton) {
      return IconButton(
        icon: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18.sp,
          ),
        ),
        onPressed: () {
          if (onBackPressed != null) {
            onBackPressed!();
          } else {
            Navigator.of(context).maybePop();
          }
        },
      );
    }

    return null;
  }
}

/// Simple AppBar بدون تدرج لوني - للصفحات الداخلية
class SimpleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const SimpleAppBar({
    required this.title, super.key,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      centerTitle: true,
      elevation: 0,
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp),
              onPressed: () {
                if (onBackPressed != null) {
                  onBackPressed!();
                } else {
                  Navigator.of(context).maybePop();
                }
              },
            )
          : null,
      actions: actions,
    );
  }
}

/// Dashboard AppBar مع Notifications و Sync Button
class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int notificationCount;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSyncTap;
  final VoidCallback? onProfileTap;

  const DashboardAppBar({
    required this.title, super.key,
    this.notificationCount = 0,
    this.onNotificationTap,
    this.onSyncTap,
    this.onProfileTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: title,
      actions: [
        // Sync Button
        _buildActionButton(
          icon: Icons.sync_rounded,
          onTap: onSyncTap,
          tooltip: 'المزامنة',
        ),
        SizedBox(width: 8.w),

        // Notifications Button with Badge
        _buildNotificationButton(context),
        SizedBox(width: 8.w),

        // Profile Button
        _buildProfileButton(context),
        SizedBox(width: 12.w),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: Colors.white, size: 22.sp),
        ),
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return Tooltip(
      message: 'الإشعارات',
      child: InkWell(
        onTap: onNotificationTap,
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.notifications_rounded,
                color: Colors.white,
                size: 22.sp,
              ),
            ),
            if (notificationCount > 0)
              Positioned(
                top: -4.h,
                right: -4.w,
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
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
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Tooltip(
      message: 'الملف الشخصي',
      child: InkWell(
        onTap: onProfileTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.all(2.r),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: CircleAvatar(
            radius: 16.r,
            backgroundColor: Colors.white,
            child: Icon(Icons.person_rounded, color: primaryColor, size: 18.sp),
          ),
        ),
      ),
    );
  }
}

/// Search AppBar مع حقل بحث
class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onBackPressed;
  final VoidCallback? onClear;

  const SearchAppBar({
    super.key,
    this.hintText = 'بحث...',
    this.controller,
    this.onChanged,
    this.onBackPressed,
    this.onClear,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp),
        onPressed: () {
          if (onBackPressed != null) {
            onBackPressed!();
          } else {
            Navigator.of(context).maybePop();
          }
        },
      ),
      title: TextField(
        controller: controller,
        onChanged: onChanged,
        autofocus: true,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey[400]),
        ),
        style: TextStyle(fontSize: 16.sp),
      ),
      actions: [
        if (controller?.text.isNotEmpty ?? false)
          IconButton(
            icon: const Icon(Icons.clear_rounded),
            onPressed: () {
              controller?.clear();
              onClear?.call();
            },
          ),
        IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {}),
      ],
    );
  }
}
