import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 🔔 Smart Notifications Page - الإشعارات الذكية
///
/// ميزات:
/// - إشعارات للكفالات المنتهية قريباً
/// - التجديدات المطلوبة
/// - المتأخرات
class SmartNotificationsPage extends StatelessWidget {
  const SmartNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    // Adaptive max width for better readability on large screens
    final maxWidth = isTablet ? 700.0 : (isMobile ? double.infinity : 800.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات الذكية'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
            tooltip: 'الإعدادات',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: ListView(
            padding: EdgeInsets.all(isMobile ? 16.w : 24.w),
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    size: isMobile ? 32.sp : 40.sp,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'مركز الإشعارات',
                      style: (isMobile ? theme.textTheme.headlineSmall : theme.textTheme.headlineMedium)?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 16.h : 24.h),

              // Notification Settings Cards
              _NotificationSettingCard(
                icon: Icons.alarm,
                title: 'كفالات منتهية قريباً',
                subtitle: 'تنبيه قبل 7 أيام من انتهاء الكفالة',
                enabled: true,
                color: Colors.orange,
                onToggle: (value) {},
              ),
              SizedBox(height: 12.h),
              _NotificationSettingCard(
                icon: Icons.update,
                title: 'تجديدات مطلوبة',
                subtitle: 'تذكير بالكفالات التي تحتاج تجديد',
                enabled: true,
                color: Colors.blue,
                onToggle: (value) {},
              ),
              SizedBox(height: 12.h),
              _NotificationSettingCard(
                icon: Icons.warning,
                title: 'مدفوعات متأخرة',
                subtitle: 'تنبيه للمدفوعات المتأخرة عن موعدها',
                enabled: false,
                color: Colors.red,
                onToggle: (value) {},
              ),
              SizedBox(height: 12.h),
              _NotificationSettingCard(
                icon: Icons.info,
                title: 'تحديثات النظام',
                subtitle: 'إشعارات حول التحديثات والميزات الجديدة',
                enabled: true,
                color: Colors.green,
                onToggle: (value) {},
              ),

              SizedBox(height: isMobile ? 24.h : 32.h),

              // Recent Notifications
              Text(
                'الإشعارات الأخيرة',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12.h),

              _NotificationTile(
                icon: Icons.alarm,
                title: 'كفالة تنتهي قريباً',
                message: 'كفالة محمد أحمد ستنتهي خلال 5 أيام',
                time: 'منذ ساعتين',
                isRead: false,
              ),
              _NotificationTile(
                icon: Icons.update,
                title: 'تجديد مطلوب',
                message: 'كفالة فاطمة علي تحتاج تجديد',
                time: 'منذ 4 ساعات',
                isRead: true,
              ),
              _NotificationTile(
                icon: Icons.check_circle,
                title: 'تم التجديد بنجاح',
                message: 'تم تجديد كفالة أحمد محمود بنجاح',
                time: 'أمس',
                isRead: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationSettingCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final Color color;
  final ValueChanged<bool> onToggle;

  const _NotificationSettingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.color,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: onToggle,
            activeColor: color,
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String time;
  final bool isRead;

  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isRead ? theme.colorScheme.surface : theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20.sp,
            color: theme.colorScheme.primary,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  time,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
          if (!isRead)
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
