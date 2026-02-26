import 'package:flutter/material.dart';

/// 🎨 Beneficiary Form Colors - Material 3 Compliant
///
/// Centralized color system for the beneficiary form
class BeneficiaryFormColors {
  BeneficiaryFormColors._();

  // ═══════════════════════════════════════════════════════════════════════════
  // Tab Colors (Material 3 Adaptive)
  // ═══════════════════════════════════════════════════════════════════════════

  static Color tabActive(BuildContext context) => Theme.of(context).colorScheme.primary;

  static Color tabInactive(BuildContext context) => Theme.of(context).colorScheme.onSurfaceVariant;

  static Color tabBackground(BuildContext context) => Theme.of(context).colorScheme.surfaceContainerHighest;

  static Color tabIndicator(BuildContext context) => Theme.of(context).colorScheme.primary;

  // ═══════════════════════════════════════════════════════════════════════════
  // Status Colors
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // ═══════════════════════════════════════════════════════════════════════════
  // Category Colors (للمستفيدين)
  // ═══════════════════════════════════════════════════════════════════════════

  static const Map<String, Color> categoryColors = {
    'orphan': Color(0xFF2196F3), // Blue - يتيم
    'widow': Color(0xFF9C27B0), // Purple - أرملة
    'poor': Color(0xFFFF9800), // Orange - فقير
    'disabled': Color(0xFF009688), // Teal - معاق
    'displaced': Color(0xFF795548), // Brown - نازح
    'elderly': Color(0xFF607D8B), // Blue Grey - مسن
  };

  /// Get category color with fallback
  static Color getCategoryColor(
    String category, {
    Map<String, Color> overrides = const <String, Color>{},
  }) {
    final resolved = overrides[category];
    if (resolved != null) {
      return resolved;
    }
    return categoryColors[category] ?? const Color(0xFF757575);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Progress Colors
  // ═══════════════════════════════════════════════════════════════════════════

  static Color progressEmpty(BuildContext context) => Theme.of(context).colorScheme.surfaceContainerHighest;

  static Color progressPartial(BuildContext context) => Theme.of(context).colorScheme.primary;

  static const Color progressComplete = success;

  /// Get progress color based on percentage
  static Color getProgressColor(BuildContext context, int percentage) {
    if (percentage == 100) return progressComplete;
    if (percentage > 0) return progressPartial(context);
    return progressEmpty(context);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Field States
  // ═══════════════════════════════════════════════════════════════════════════

  static Color fieldFocused(BuildContext context) => Theme.of(context).colorScheme.primary;

  static Color fieldError(BuildContext context) => Theme.of(context).colorScheme.error;

  static Color fieldDisabled(BuildContext context) => Theme.of(context).colorScheme.onSurface.withOpacity(0.38);

  // ═══════════════════════════════════════════════════════════════════════════
  // Helper Methods
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get semantic color for status
  static Color getStatusColor(String status) {
    switch (status) {
      case 'success':
      case 'completed':
      case 'active':
        return success;
      case 'warning':
      case 'pending':
        return warning;
      case 'error':
      case 'failed':
        return error;
      case 'info':
      case 'draft':
        return info;
      default:
        return const Color(0xFF757575);
    }
  }

  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Get contrast color (black or white)
  static Color getContrastColor(Color backgroundColor) {
    // Calculate luminance
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

/// 🎨 Form Color Extensions
extension FormColorExtensions on BuildContext {
  /// Quick access to form colors
  BeneficiaryFormColorsHelper get formColors => BeneficiaryFormColorsHelper(this);
}

/// Helper class for context-based colors
class BeneficiaryFormColorsHelper {
  final BuildContext context;

  BeneficiaryFormColorsHelper(this.context);

  Color get tabActive => BeneficiaryFormColors.tabActive(context);
  Color get tabInactive => BeneficiaryFormColors.tabInactive(context);
  Color get tabBackground => BeneficiaryFormColors.tabBackground(context);
  Color get tabIndicator => BeneficiaryFormColors.tabIndicator(context);

  Color get progressEmpty => BeneficiaryFormColors.progressEmpty(context);
  Color get progressPartial => BeneficiaryFormColors.progressPartial(context);
  Color get progressComplete => BeneficiaryFormColors.progressComplete;

  Color get fieldFocused => BeneficiaryFormColors.fieldFocused(context);
  Color get fieldError => BeneficiaryFormColors.fieldError(context);
  Color get fieldDisabled => BeneficiaryFormColors.fieldDisabled(context);

  Color getCategoryColor(String category) => BeneficiaryFormColors.getCategoryColor(category);

  Color getProgressColor(int percentage) => BeneficiaryFormColors.getProgressColor(context, percentage);
}
