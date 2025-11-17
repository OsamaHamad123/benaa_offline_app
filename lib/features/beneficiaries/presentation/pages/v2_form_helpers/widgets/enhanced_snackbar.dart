import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 📢 Enhanced Snackbar Helper
///
/// Provides improved snackbars with:
/// - Floating behavior
/// - Action buttons
/// - Undo functionality
/// - Icons
/// - Haptic feedback
class EnhancedSnackbar {
  /// Show success snackbar
  static void showSuccess(
    BuildContext context, {
    required String message,
    VoidCallback? onUndo,
    Duration duration = const Duration(seconds: 3),
  }) {
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(message, style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
        duration: duration,
        action: onUndo != null
            ? SnackBarAction(
                label: 'تراجع',
                textColor: Colors.white,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  onUndo();
                },
              )
            : null,
      ),
    );
  }

  /// Show error snackbar
  static void showError(
    BuildContext context, {
    required String message,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    HapticFeedback.heavyImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_rounded, color: Colors.white, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(message, style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
        duration: duration,
        action: onRetry != null
            ? SnackBarAction(
                label: 'إعادة المحاولة',
                textColor: Colors.white,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  onRetry();
                },
              )
            : null,
      ),
    );
  }

  /// Show warning snackbar
  static void showWarning(
    BuildContext context, {
    required String message,
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 3),
  }) {
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.white, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(message, style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
        duration: duration,
        action: onAction != null && actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onAction();
                },
              )
            : null,
      ),
    );
  }

  /// Show info snackbar
  static void showInfo(
    BuildContext context, {
    required String message,
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 3),
  }) {
    HapticFeedback.selectionClick();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_rounded, color: Colors.white, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(message, style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
        duration: duration,
        action: onAction != null && actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onAction();
                },
              )
            : null,
      ),
    );
  }

  /// Show loading snackbar (doesn't auto-dismiss)
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showLoading(
    BuildContext context, {
    required String message,
  }) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20.w,
              height: 20.h,
              child: CircularProgressIndicator(
                strokeWidth: 2.w,
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(message, style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        ),
        backgroundColor: Colors.grey.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
        duration: const Duration(days: 1), // Won't auto-dismiss
      ),
    );
  }

  /// Dismiss current snackbar
  static void dismiss(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}
