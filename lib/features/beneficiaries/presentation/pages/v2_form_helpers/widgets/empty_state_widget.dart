import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 📭 Empty State Widget
///
/// Beautiful empty states for different scenarios

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: (iconColor ?? theme.colorScheme.primary).withOpacity(
                  0.1,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64.sp,
                color: iconColor ?? theme.colorScheme.primary,
              ),
            ),

            SizedBox(height: 24.h),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            // Subtitle
            if (subtitle != null) ...[
              SizedBox(height: 8.h),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Action Button
            if (actionText != null && onAction != null) ...[
              SizedBox(height: 24.h),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 👥 Empty Family Members
  factory EmptyStateWidget.noFamilyMembers({VoidCallback? onAdd}) {
    return EmptyStateWidget(
      icon: Icons.family_restroom_rounded,
      title: 'لا يوجد أفراد عائلة',
      subtitle: 'أضف أفراد العائلة للمستفيد',
      actionText: onAdd != null ? 'إضافة فرد' : null,
      onAction: onAdd,
    );
  }

  /// 📎 Empty Attachments
  factory EmptyStateWidget.noAttachments({VoidCallback? onAdd}) {
    return EmptyStateWidget(
      icon: Icons.attach_file_rounded,
      title: 'لا توجد مرفقات',
      subtitle: 'أضف المستندات والصور المطلوبة',
      actionText: onAdd != null ? 'إضافة مرفق' : null,
      onAction: onAdd,
    );
  }

  /// 🔍 No Search Results
  factory EmptyStateWidget.noSearchResults() {
    return const EmptyStateWidget(
      icon: Icons.search_off_rounded,
      title: 'لا توجد نتائج',
      subtitle: 'جرب استخدام كلمات مختلفة',
      iconColor: Colors.orange,
    );
  }

  /// ⚠️ Error State
  factory EmptyStateWidget.error({String? message, VoidCallback? onRetry}) {
    return EmptyStateWidget(
      icon: Icons.error_outline_rounded,
      title: 'حدث خطأ',
      subtitle: message ?? 'حاول مرة أخرى',
      actionText: onRetry != null ? 'إعادة المحاولة' : null,
      onAction: onRetry,
      iconColor: Colors.red,
    );
  }

  /// 📝 No Notes
  factory EmptyStateWidget.noNotes() {
    return const EmptyStateWidget(
      icon: Icons.sticky_note_2_outlined,
      title: 'لا توجد ملاحظات',
      subtitle: 'أضف ملاحظاتك هنا',
    );
  }
}
