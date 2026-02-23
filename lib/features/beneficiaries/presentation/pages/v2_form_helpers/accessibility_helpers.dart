import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ♿ Accessibility Helpers
///
/// Semantic labels and announcements for screen readers
class A11yHelpers {
  /// Create semantic label for form field
  static String fieldLabel({
    required String label,
    required bool isRequired,
    String? hint,
    String? error,
  }) {
    final buffer = StringBuffer(label);

    if (isRequired) {
      buffer.write(', حقل مطلوب');
    }

    if (hint != null) {
      buffer.write(', $hint');
    }

    if (error != null) {
      buffer.write(', خطأ: $error');
    }

    return buffer.toString();
  }

  /// Announce validation error
  static void announceError(BuildContext context, String error) {
    // Use SemanticsService to announce
    SemanticsService.announce('خطأ: $error', TextDirection.rtl);
  }

  /// Announce success
  static void announceSuccess(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.rtl);
  }

  /// Create accessible button
  static Widget accessibleButton({
    required Widget child,
    required VoidCallback onPressed,
    required String semanticLabel,
    String? hint,
  }) {
    return Semantics(
      button: true,
      label: semanticLabel,
      hint: hint,
      child: child,
    );
  }

  /// Create accessible text field
  static InputDecoration accessibleDecoration({
    required String label,
    required bool isRequired,
    String? hint,
    String? error,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      labelText: label + (isRequired ? ' *' : ''),
      hintText: hint,
      errorText: error,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20.sp) : null,
      semanticCounterText: '',
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}

/// 🎨 High Contrast Mode Support
class HighContrastTheme {
  /// Get high contrast color scheme
  static ColorScheme getColorScheme(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const ColorScheme.dark(
        primary: Colors.yellow,
        secondary: Colors.cyan,
        error: Colors.red,
        onError: Colors.white,
        surface: Colors.black,
      );
    } else {
      return const ColorScheme.light(
        primary: Colors.blue,
        secondary: Colors.orange,
        onSecondary: Colors.white,
        error: Colors.red,
      );
    }
  }

  /// Check if high contrast is enabled (system setting)
  static bool isHighContrastEnabled(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }
}
