import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 🎨 Reusable Empty State Widget
///
/// Shows when no data is available
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onActionPressed;
  final String? actionLabel;

  const EmptyStateWidget({
    super.key,
    this.title = 'لا توجد بيانات',
    this.subtitle = 'لم يتم العثور على معلومات',
    this.icon = Icons.inbox_outlined,
    this.onActionPressed,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 120.sp, color: Colors.grey[300]),
            SizedBox(height: 24.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            if (onActionPressed != null) ...[
              SizedBox(height: 32.h),
              ElevatedButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.arrow_back),
                label: Text(actionLabel ?? 'رجوع'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 16.h,
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

/// 🚨 Reusable Error State Widget
///
/// Shows when an error occurs with retry option
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onBack;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 120.sp, color: Colors.red[300]),
            SizedBox(height: 24.h),
            Text(
              'حدث خطأ',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                message,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 32.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onBack != null)
                  OutlinedButton.icon(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('رجوع'),
                  ),
                if (onBack != null && onRetry != null) SizedBox(width: 16.w),
                if (onRetry != null)
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ⏳ Reusable Loading Dialog
///
/// Shows loading state during async operations
class LoadingDialog extends StatelessWidget {
  final String message;

  const LoadingDialog({super.key, this.message = 'جاري التحميل...'});

  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          LoadingDialog(message: message ?? 'جاري التحميل...'),
    );
  }

  static void hide(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: 16.h),
              Text(message, style: TextStyle(fontSize: 14.sp)),
            ],
          ),
        ),
      ),
    );
  }
}

/// ✅ Success SnackBar Helper
class SuccessSnackBar {
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }
}

/// ❌ Error SnackBar Helper
class ErrorSnackBar {
  static void show(
    BuildContext context,
    String message, {
    VoidCallback? onRetry,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            SizedBox(width: 12.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        action: onRetry != null
            ? SnackBarAction(
                label: 'إعادة المحاولة',
                onPressed: onRetry,
                textColor: Colors.white,
              )
            : null,
      ),
    );
  }
}

/// 🗑️ Reusable Delete Confirmation Dialog
class DeleteConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;

  const DeleteConfirmationDialog({
    super.key,
    this.title = 'تأكيد الحذف',
    this.content = 'هل أنت متأكد من الحذف؟',
    required this.onConfirm,
  });

  static Future<bool?> show(
    BuildContext context, {
    String? title,
    String? content,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'تأكيد الحذف'),
        content: Text(content ?? 'هل أنت متأكد من الحذف؟'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, true);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('حذف'),
        ),
      ],
    );
  }
}
