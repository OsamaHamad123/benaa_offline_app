import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/utils/haptic_patterns.dart';

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
    HapticPatterns.light();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 15 * (1 - value)),
              child: Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(message, style: TextStyle(fontSize: 14.sp)),
                    ),
                  ],
                ),
              ),
            );
          },
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
                  HapticPatterns.selection();
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
    HapticPatterns.error();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            // Shake effect for first 200ms
            final shakeOffset = value < 0.5 ? (value * 20 - 10) : 0.0;
            return Transform.translate(
              offset: Offset(shakeOffset, 0),
              child: Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Row(
                  children: [
                    Icon(Icons.error_rounded, color: Colors.white, size: 20.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(message, style: TextStyle(fontSize: 14.sp)),
                    ),
                  ],
                ),
              ),
            );
          },
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
                  HapticPatterns.selection();
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
    HapticPatterns.warning();

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
                  HapticPatterns.light();
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
    HapticPatterns.selection();

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
                  HapticPatterns.light();
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
