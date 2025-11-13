import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Widget لعرض حالة فارغة
///
/// استخدامات:
/// - قوائم فارغة
/// - نتائج بحث فارغة
/// - لا توجد بيانات
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isCompact;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isMobile = mediaQuery.size.width < 600;

    return Center(
      child: Padding(
        padding: EdgeInsets.all((isCompact ? 24 : 32).r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all((isCompact ? 20 : 24).r),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: (isCompact ? 48 : (isMobile ? 56 : 64)).sp,
                color: theme.colorScheme.primary.withOpacity(0.5),
              ),
            ),
            SizedBox(height: (isCompact ? 16 : 24).h),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: (isCompact ? 18 : (isMobile ? 20 : 24)).sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: (isCompact ? 8 : 12).h),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontSize: (isCompact ? 13 : 14).sp,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: (isCompact ? 20 : 24).h),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: (isCompact ? 20 : 24).w,
                    vertical: (isCompact ? 12 : 14).h,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// نسخة مصغرة للاستخدام داخل Cards
class EmptyStateCompact extends StatelessWidget {
  final IconData icon;
  final String message;

  const EmptyStateCompact({
    super.key,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 40,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
