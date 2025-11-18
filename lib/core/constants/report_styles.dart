import 'package:flutter/material.dart';

/// UI styling constants for the Reports feature
class ReportStyles {
  ReportStyles._();

  // Card Gradients
  static const LinearGradient summaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)], // Indigo to Purple
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient genderGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)], // Blue gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient governorateGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)], // Green gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient categoryGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)], // Orange/Amber gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient ageGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFDB2777)], // Pink gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient syncGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)], // Purple gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Card Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 5,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> cardShadowHover = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  // Icon sizes
  static const double cardIconSize = 32.0;
  static const double modalIconSize = 24.0;

  // Border Radius
  static const BorderRadius cardBorderRadius = BorderRadius.all(
    Radius.circular(16),
  );
  static const BorderRadius modalBorderRadius = BorderRadius.vertical(
    top: Radius.circular(20),
  );

  // Spacing
  static const double cardPadding = 16.0;
  static const double cardMargin = 12.0;
  static const double modalPadding = 16.0;

  // Elevation
  static const double cardElevation = 4.0;
  static const double cardElevationHover = 8.0;

  // Animation Durations
  static const Duration cardHoverDuration = Duration(milliseconds: 200);
  static const Duration chartAnimationDuration = Duration(milliseconds: 600);
  static const Duration countUpDuration = Duration(milliseconds: 1500);
  static const Duration shimmerDuration = Duration(milliseconds: 1500);

  // Chart Colors
  static const Color chartGridColor = Color(0xFFE5E7EB);
  static const Color chartTextColor = Color(0xFF6B7280);
  static const Color chartBackgroundColor = Colors.transparent;

  // Text Styles
  static const TextStyle cardTitleStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white70,
  );

  static const TextStyle cardValueStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle modalTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle detailsHeaderStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
}
