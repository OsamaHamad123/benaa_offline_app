import 'package:flutter/material.dart';

/// Color constants for beneficiary categories
class CategoryColors {
  // Private constructor to prevent instantiation
  CategoryColors._();

  // Category ID color mapping
  static const Map<int, Color> categoryMap = {
    1: Colors.purple, // Orphans
    2: Colors.green, // Poor
    3: Colors.orange, // Both
    4: Colors.blue, // Other/Unknown
  };

  // Category name to color mapping (Arabic names)
  static const Map<String, Color> categoryNameMap = {
    'أيتام': Colors.purple, // Orphans
    'فقراء': Colors.green, // Poor
    'أيتام وفقراء': Colors.orange, // Both
    'أرامل': Colors.orange, // Widows
    'معاقين': Colors.blue, // Disabled
    'أخرى': Colors.grey, // Other
  };

  /// Get color for a specific category ID
  static Color getColor(int categoryId) {
    return categoryMap[categoryId] ?? Colors.grey;
  }

  /// Get color for a category by name
  static Color getColorByName(String categoryName) {
    return categoryNameMap[categoryName] ?? Colors.grey;
  }

  /// Category names mapping (for reference)
  static const Map<int, String> categoryNames = {
    1: 'أيتام', // Orphans
    2: 'فقراء', // Poor
    3: 'أيتام وفقراء', // Both
    4: 'أخرى', // Other
  };
}

/// Color constants for gender categories
class GenderColors {
  GenderColors._();

  static const Color male = Colors.blue;
  static const Color female = Color(0xFFE91E63); // Pink

  static Color getColor(String gender) {
    final value = gender.toLowerCase();
    if (value == 'ذكر' || value == 'ذكور' || value == 'male') {
      return male;
    } else if (value == 'أنثى' || value == 'إناث' || value == 'female') {
      return female;
    }
    return Colors.grey;
  }
}

/// Color constants for age brackets
class AgeBracketColors {
  AgeBracketColors._();

  static const Color age0to12 = Colors.blue;
  static const Color age13to18 = Colors.purple;
  static const Color age19to35 = Colors.green;
  static const Color age36to50 = Colors.orange;
  static const Color age51Plus = Colors.red;

  static Color getColor(String ageBracket) {
    return switch (ageBracket) {
      '0-12' => age0to12,
      '13-18' => age13to18,
      '19-35' => age19to35,
      '36-50' => age36to50,
      '51+' => age51Plus,
      _ => Colors.grey,
    };
  }
}

/// Color constants for sync status
class SyncStatusColors {
  SyncStatusColors._();

  static const Color synced = Colors.green;
  static const Color pending = Colors.orange;
  static const Color failed = Colors.red;

  static Color getColor(String status) {
    if (status.toLowerCase().contains('synced') ||
        status.toLowerCase().contains('متزامن')) {
      return synced;
    } else if (status.toLowerCase().contains('pending') ||
        status.toLowerCase().contains('معلق')) {
      return pending;
    } else if (status.toLowerCase().contains('failed') ||
        status.toLowerCase().contains('فشل')) {
      return failed;
    }
    return Colors.grey;
  }
}
