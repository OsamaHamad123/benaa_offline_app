import 'package:flutter/material.dart';

/// نظام الألوان الموحد للتطبيق
class AppColors {
  AppColors._();

  // ============================================================================
  // PRIMARY COLORS - الألوان الأساسية
  // ============================================================================

  static const Color primary = Color(0xFF1976D2); // أزرق احترافي
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF42A5F5);

  static const Color secondary = Color(0xFF00897B); // تركواز
  static const Color secondaryDark = Color(0xFF00695C);
  static const Color secondaryLight = Color(0xFF4DB6AC);

  static const Color accent = Color(0xFFFF6F00); // برتقالي للعناصر المهمة

  // ============================================================================
  // SEMANTIC COLORS - الألوان الدلالية
  // ============================================================================

  static const Color success = Color(0xFF388E3C);
  static const Color successLight = Color(0xFF66BB6A);
  static const Color successDark = Color(0xFF2E7D32);

  static const Color warning = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFE65100);

  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color errorDark = Color(0xFFC62828);

  static const Color info = Color(0xFF1976D2);
  static const Color infoLight = Color(0xFF42A5F5);
  static const Color infoDark = Color(0xFF0D47A1);

  // ============================================================================
  // NEUTRAL COLORS - الألوان الحيادية
  // ============================================================================

  static const Color background = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBackgroundDark = Color(0xFF2C2C2C);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textHint = Color(0xFF9E9E9E);

  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textDisabledDark = Color(0xFF6E6E6E);

  // Dividers & Borders
  static const Color divider = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF424242);

  static const Color border = Color(0xFFBDBDBD);
  static const Color borderDark = Color(0xFF616161);

  // ============================================================================
  // CATEGORY COLORS - ألوان الفئات
  // ============================================================================

  static const Color orphan = Color(0xFF5E35B1); // بنفسجي للأيتام
  static const Color widow = Color(0xFFE91E63); // وردي للأرامل
  static const Color poor = Color(0xFFFF6F00); // برتقالي للفقراء
  static const Color disabled = Color(0xFF00897B); // تركواز لذوي الاحتياجات

  // ============================================================================
  // STATUS COLORS - ألوان الحالات
  // ============================================================================

  static const Color pending = Color(0xFFFFA726); // برتقالي فاتح
  static const Color synced = Color(0xFF66BB6A); // أخضر
  static const Color syncError = Color(0xFFEF5350); // أحمر
  static const Color offline = Color(0xFF9E9E9E); // رمادي

  // ============================================================================
  // GRADIENT COLORS - التدرجات اللونية
  // ============================================================================

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, successLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [warning, warningLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================================================
  // SHADOW COLORS - ألوان الظلال
  // ============================================================================

  static final Color shadowLight = Colors.black.withOpacity(0.08);
  static final Color shadowMedium = Colors.black.withOpacity(0.12);
  static final Color shadowDark = Colors.black.withOpacity(0.16);

  // ============================================================================
  // OVERLAY COLORS - ألوان التراكب
  // ============================================================================

  static final Color overlay = Colors.black.withOpacity(0.5);
  static final Color overlayLight = Colors.black.withOpacity(0.3);
  static final Color scrim = Colors.black.withOpacity(0.7);
}
