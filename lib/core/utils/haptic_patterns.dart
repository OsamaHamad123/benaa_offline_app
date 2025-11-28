import 'package:flutter/services.dart';

/// 🎮 Haptic Feedback Patterns
///
/// Centralized haptic feedback patterns for consistent UX across the app.
/// Provides semantic haptic feedback for different user interactions.
///
/// Usage:
/// ```dart
/// // Success feedback
/// HapticPatterns.success();
///
/// // Error feedback
/// HapticPatterns.error();
///
/// // Selection feedback
/// HapticPatterns.selection();
/// ```
class HapticPatterns {
  /// ✅ Success - للعمليات الناجحة
  ///
  /// Use for:
  /// - Save success
  /// - Form submission success
  /// - Data sync completed
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
  }

  /// ❌ Error - للأخطاء والفشل
  ///
  /// Use for:
  /// - Validation errors
  /// - Save failures
  /// - Network errors
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  /// ⚠️ Warning - للتحذيرات
  ///
  /// Use for:
  /// - Unsaved changes warning
  /// - Confirmation dialogs
  /// - Destructive actions
  static Future<void> warning() async {
    await HapticFeedback.mediumImpact();
  }

  /// 👆 Selection - للتحديد واللمس
  ///
  /// Use for:
  /// - List item selection
  /// - Tab selection
  /// - Checkbox/Radio toggle
  /// - Dropdown selection
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  /// 🎯 Light Impact - للمسات الخفيفة
  ///
  /// Use for:
  /// - Button press
  /// - Toggle switch
  /// - Minor interactions
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// 💪 Heavy Impact - للمسات القوية
  ///
  /// Use for:
  /// - Delete operations
  /// - Critical actions
  /// - Modal dismiss
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// 🔄 Refresh - لعمليات التحديث
  ///
  /// Use for:
  /// - Pull to refresh
  /// - Data reload
  /// - Manual sync trigger
  static Future<void> refresh() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
  }

  /// 📝 Input - للإدخال النصي
  ///
  /// Use for:
  /// - TextField focus
  /// - Keyboard shortcuts
  /// - Text selection
  static Future<void> input() async {
    await HapticFeedback.selectionClick();
  }

  /// 🔍 Search - لبدء البحث
  ///
  /// Use for:
  /// - Search initiated
  /// - Filter applied
  /// - Sort changed
  static Future<void> search() async {
    await HapticFeedback.lightImpact();
  }

  /// 🗑️ Delete - للحذف
  ///
  /// Use for:
  /// - Item deleted
  /// - Batch delete
  /// - Clear data
  static Future<void> delete() async {
    await HapticFeedback.heavyImpact();
  }

  /// 📤 Submit - للإرسال والحفظ
  ///
  /// Use for:
  /// - Form submit
  /// - Save button
  /// - Send data
  static Future<void> submit() async {
    await HapticFeedback.mediumImpact();
  }

  /// 🎨 Custom Pattern - نمط مخصص
  ///
  /// Create custom haptic patterns for specific use cases.
  static Future<void> custom({
    required List<HapticImpact> impacts,
    Duration delay = const Duration(milliseconds: 100),
  }) async {
    for (int i = 0; i < impacts.length; i++) {
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

      if (i < impacts.length - 1) {
        await Future.delayed(delay);
      }
    }
  }

  /// 🔔 Notification - للإشعارات
  ///
  /// Use for:
  /// - New notification received
  /// - Alert shown
  /// - Toast message
  static Future<void> notification() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
  }

  /// 🎉 Celebration - للنجاحات الكبيرة
  ///
  /// Use for:
  /// - Task completed
  /// - Achievement unlocked
  /// - Milestone reached
  static Future<void> celebration() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.mediumImpact();
  }

  /// 📋 Copy - للنسخ
  ///
  /// Use for:
  /// - Text copied
  /// - Data duplicated
  static Future<void> copy() async {
    await HapticFeedback.selectionClick();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.selectionClick();
  }

  /// ↔️ Swipe - لللمسات السريعة
  ///
  /// Use for:
  /// - Swipe actions
  /// - Page navigation
  /// - Dismissible items
  static Future<void> swipe() async {
    await HapticFeedback.lightImpact();
  }

  /// 🔒 Lock/Unlock - للقفل وفتح القفل
  ///
  /// Use for:
  /// - Screen lock
  /// - Feature unlock
  /// - Permission granted
  static Future<void> lockToggle() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }
}

/// 🎮 Haptic Impact Types
///
/// Types of haptic impacts for custom patterns.
enum HapticImpact {
  light,
  medium,
  heavy,
  selection,
}
