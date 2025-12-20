import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 🎨 Custom Empty State Widget
///
/// Widget موحد لعرض حالة "لا توجد بيانات" في جميع أنحاء التطبيق
///
/// Example:
/// ```dart
/// if (items.isEmpty) {
///   return CustomEmptyState(
///     icon: Icons.people_outline,
///     title: 'لا يوجد مستفيدين',
///     message: 'ابدأ بإضافة أول مستفيد',
///     onAction: () => _addBeneficiary(),
///     actionLabel: 'إضافة مستفيد',
///   );
/// }
/// ```
class CustomEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final VoidCallback? onAction;
  final String? actionLabel;
  final Color? iconColor;
  final double? iconSize;

  const CustomEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.onAction,
    this.actionLabel,
    this.iconColor,
    this.iconSize,
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
            // أيقونة
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.grey[400])?.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize ?? 64.sp,
                color: iconColor ?? Colors.grey[400],
              ),
            ),

            SizedBox(height: 24.h),

            // العنوان
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            // الرسالة (اختيارية)
            if (message != null) ...[
              SizedBox(height: 12.h),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // زر الإجراء (اختياري)
            if (onAction != null && actionLabel != null) ...[
              SizedBox(height: 32.h),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
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
}

/// 🔍 Empty State للبحث
class EmptySearchState extends StatelessWidget {
  final String query;
  final VoidCallback? onClearSearch;

  const EmptySearchState({super.key, required this.query, this.onClearSearch});

  @override
  Widget build(BuildContext context) {
    return CustomEmptyState(
      icon: Icons.search_off,
      iconColor: Colors.blue[300],
      title: 'لا توجد نتائج',
      message: 'لم نجد أي نتائج لـ "$query"\nحاول استخدام كلمات مفتاحية أخرى',
      onAction: onClearSearch,
      actionLabel: onClearSearch != null ? 'مسح البحث' : null,
    );
  }
}

/// 📋 Empty State للقوائم
class EmptyListState extends StatelessWidget {
  final String itemName;
  final IconData? icon;
  final VoidCallback? onAdd;

  const EmptyListState({
    super.key,
    required this.itemName,
    this.icon,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return CustomEmptyState(
      icon: icon ?? Icons.inbox,
      iconColor: Colors.grey[400],
      title: 'لا يوجد $itemName',
      message: 'ابدأ بإضافة أول $itemName',
      onAction: onAdd,
      actionLabel: onAdd != null ? 'إضافة $itemName' : null,
    );
  }
}

/// ⚠️ Empty State للأخطاء
class ErrorState extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;

  const ErrorState({super.key, this.errorMessage, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return CustomEmptyState(
      icon: Icons.error_outline,
      iconColor: Colors.red[300],
      title: 'حدث خطأ',
      message: errorMessage ??
          'حدث خطأ أثناء تحميل البيانات\nالرجاء المحاولة مرة أخرى',
      onAction: onRetry,
      actionLabel: onRetry != null ? 'إعادة المحاولة' : null,
    );
  }
}

/// 🌐 Empty State لانقطاع الاتصال
class NoConnectionState extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoConnectionState({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return CustomEmptyState(
      icon: Icons.wifi_off,
      iconColor: Colors.orange[300],
      title: 'لا يوجد اتصال بالإنترنت',
      message: 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى',
      onAction: onRetry,
      actionLabel: onRetry != null ? 'إعادة المحاولة' : null,
    );
  }
}
