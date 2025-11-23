import 'package:flutter/material.dart';

/// 🛡️ Safe Opacity Helper
///
/// Ensures opacity values are always within valid range (0.0 to 1.0)
/// to prevent assertion errors
class SafeOpacityHelper {
  SafeOpacityHelper._();

  /// Clamps opacity value to valid range
  /// Returns 0.0 if value is null
  static double clampOpacity(double? value) {
    if (value == null) return 0.0;
    return value.clamp(0.0, 1.0);
  }

  /// Safely gets animation value with clamping
  static double getAnimationValue(Animation<double>? animation) {
    if (animation == null) return 0.0;
    return clampOpacity(animation.value);
  }

  /// Creates safe opacity widget with guaranteed valid value
  static Widget safeOpacity({required double? opacity, required Widget child}) {
    return Opacity(opacity: clampOpacity(opacity), child: child);
  }

  /// Creates safe color with alpha
  static Color safeColorWithOpacity(Color color, double? opacity) {
    return color.withOpacity(clampOpacity(opacity));
  }

  /// Creates safe color with alpha using withValues
  static Color safeColorWithAlpha(Color color, double? alpha) {
    return color.withValues(alpha: clampOpacity(alpha));
  }
}

/// Extension for safe opacity operations
extension SafeOpacityExtension on Color {
  /// Safe withOpacity that clamps value
  Color safeWithOpacity(double? opacity) {
    return SafeOpacityHelper.safeColorWithOpacity(this, opacity);
  }

  /// Safe withValues alpha that clamps value
  Color safeWithAlpha(double? alpha) {
    return SafeOpacityHelper.safeColorWithAlpha(this, alpha);
  }
}

/// Extension for Animation<double>
extension SafeAnimationExtension on Animation<double> {
  /// Get safe value with clamping
  double get safeValue => SafeOpacityHelper.getAnimationValue(this);
}
