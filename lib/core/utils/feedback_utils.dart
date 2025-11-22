import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 📱 Haptic Patterns - أنماط اهتزاز متقدمة
class HapticPatterns {
  HapticPatterns._();

  /// نجاح ✅
  static Future<void> success() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
  }

  /// خطأ ❌
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  /// تحذير ⚠️
  static Future<void> warning() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
  }

  /// تحديد (Selection)
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  /// نقرة خفيفة
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// نقرة متوسطة
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// نقرة قوية
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// تأكيد طويل
  static Future<void> longPress() async {
    await HapticFeedback.vibrate();
  }

  /// نمط مخصص
  static Future<void> custom({
    required List<int> pattern,
    required List<HapticImpact> impacts,
  }) async {
    for (var i = 0; i < pattern.length; i++) {
      if (i < impacts.length) {
        switch (impacts[i]) {
          case HapticImpact.light:
            await HapticFeedback.lightImpact();
            break;
          case HapticImpact.medium:
            await HapticFeedback.mediumImpact();
            break;
          case HapticImpact.heavy:
            await HapticFeedback.heavyImpact();
            break;
          case HapticImpact.selection:
            await HapticFeedback.selectionClick();
            break;
        }
      }
      if (i < pattern.length - 1) {
        await Future.delayed(Duration(milliseconds: pattern[i]));
      }
    }
  }
}

enum HapticImpact { light, medium, heavy, selection }

/// 🎨 Visual Feedback - تأثيرات بصرية
class VisualFeedback {
  VisualFeedback._();

  /// عرض Snackbar نجاح
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    HapticPatterns.success();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  /// عرض Snackbar خطأ
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    HapticPatterns.error();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        action: action,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  /// عرض Snackbar معلومات
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    HapticPatterns.light();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info, color: Colors.white, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  /// عرض Snackbar تحذير
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    HapticPatterns.warning();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning, color: Colors.white, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }
}
