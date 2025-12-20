import 'package:flutter/material.dart';

/// Dashboard Colors - نظام ألوان موحد للداشبورد
class DashboardColors {
  // Prevent instantiation
  DashboardColors._();

  // Stats Colors
  static const Color totalBeneficiaries = Color(0xFF2196F3); // Blue
  static const Color orphans = Color(0xFFFF9800); // Orange
  static const Color widows = Color(0xFF9C27B0); // Purple
  static const Color poor = Color(0xFF4CAF50); // Green
  static const Color disabled = Color(0xFFE91E63); // Pink

  // Status Colors
  static const Color urgent = Color(0xFFF44336); // Red
  static const Color normal = Color(0xFF03A9F4); // Light Blue
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color warning = Color(0xFFFF9800); // Orange

  // Section Backgrounds
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg = Color(0xFFFFFFFF);

  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF2196F3),
    Color(0xFFFF9800),
    Color(0xFF4CAF50),
    Color(0xFF9C27B0),
    Color(0xFFF44336),
    Color(0xFF00BCD4),
  ];

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFF44336), Color(0xFFD32F2F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
