import 'package:flutter/material.dart';

/// Advanced Color System with Gradients and Contextual Colors
class AppColorSystem {
  // Primary Gradients
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF5B86E5), Color(0xFF36D1DC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const successGradient = LinearGradient(
    colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const warningGradient = LinearGradient(
    colors: [Color(0xFFF2994A), Color(0xFFF2C94C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const dangerGradient = LinearGradient(
    colors: [Color(0xFFEB5757), Color(0xFFF2994A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const purpleGradient = LinearGradient(
    colors: [Color(0xFF9D50BB), Color(0xFF6E48AA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glass Gradients (for glassmorphism)
  static LinearGradient glassGradient(Color baseColor) {
    return LinearGradient(
      colors: [
        baseColor.withOpacity(0.2),
        baseColor.withOpacity(0.1),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Time-based contextual colors
  static Color getTimeBasedColor(DateTime time) {
    final hour = time.hour;
    if (hour >= 6 && hour < 12) {
      return const Color(0xFFF2C94C); // Morning - Amber
    } else if (hour >= 12 && hour < 17) {
      return const Color(0xFF56CCF2); // Afternoon - Blue
    } else if (hour >= 17 && hour < 20) {
      return const Color(0xFFF2994A); // Evening - Orange
    } else {
      return const Color(0xFF6E48AA); // Night - Purple
    }
  }

  // Get gradient based on value/status
  static LinearGradient getStatusGradient(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'completed':
      case 'success':
        return successGradient;
      case 'pending':
      case 'warning':
        return warningGradient;
      case 'error':
      case 'failed':
      case 'urgent':
        return dangerGradient;
      default:
        return primaryGradient;
    }
  }

  // Shimmer colors
  static const shimmerBaseColor = Color(0xFFE0E0E0);
  static const shimmerHighlightColor = Color(0xFFF5F5F5);

  // Dark mode colors (OLED-friendly)
  static const darkBackground = Color(0xFF0A0E27);
  static const darkSurface = Color(0xFF1E1E2E);
  static const darkCard = Color(0xFF2A2A3E);

  // Advanced shadow colors
  static List<BoxShadow> getElevatedShadow({
    Color? color,
    double elevation = 1.0,
  }) {
    final baseColor = color ?? const Color(0xFF5B86E5);
    return [
      BoxShadow(
        color: baseColor.withOpacity(0.1 * elevation),
        blurRadius: 30 * elevation,
        spreadRadius: -5 * elevation,
        offset: Offset(0, 10 * elevation),
      ),
      BoxShadow(
        color: baseColor.withOpacity(0.05 * elevation),
        blurRadius: 60 * elevation,
        spreadRadius: -10 * elevation,
        offset: Offset(0, 20 * elevation),
      ),
    ];
  }

  // Neumorphic shadows
  static List<BoxShadow> getNeumorphicShadow({
    required Color backgroundColor,
    bool isPressed = false,
  }) {
    if (isPressed) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          offset: const Offset(4, 4),
          blurRadius: 8,
          inset: true,
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.1),
          offset: const Offset(-4, -4),
          blurRadius: 8,
          inset: true,
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: Colors.white.withOpacity(0.5),
          offset: const Offset(-4, -4),
          blurRadius: 8,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          offset: const Offset(4, 4),
          blurRadius: 8,
        ),
      ];
    }
  }
}
