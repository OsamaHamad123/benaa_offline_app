/// Beneficiary Helpers - عمليات مساعدة للمستفيدين
class BeneficiaryHelpers {
  /// Get category color based on section ID
  static ColorInfo getCategoryColorInfo(
    int? sectionId, {
    Map<int, ColorInfo> categoryColorsById = const <int, ColorInfo>{},
  }) {
    if (sectionId != null) {
      final resolved = categoryColorsById[sectionId];
      if (resolved != null) {
        return resolved;
      }
    }

    switch (sectionId) {
      case 1:
        return ColorInfo(primary: 0xFF2196F3, light: 0xFFE3F2FD); // Blue - يتيم
      case 2:
        return ColorInfo(
          primary: 0xFF9C27B0,
          light: 0xFFF3E5F5,
        ); // Purple - فقير
      case 3:
        return ColorInfo(
          primary: 0xFFFF9800,
          light: 0xFFFFF3E0,
        ); // Orange - أرملة
      case 4:
        return ColorInfo(primary: 0xFF009688, light: 0xFFE0F2F1); // Teal - معاق
      default:
        return ColorInfo(primary: 0xFF757575, light: 0xFFEEEEEE); // Grey
    }
  }

  /// Get category label
  static String getCategoryLabel(
    int? sectionId, {
    Map<int, String> categoryLabelsById = const <int, String>{},
  }) {
    if (sectionId != null) {
      final resolved = categoryLabelsById[sectionId];
      if (resolved != null && resolved.trim().isNotEmpty) {
        return resolved;
      }
    }

    switch (sectionId) {
      case 1:
        return 'يتيم';
      case 2:
        return 'فقير';
      case 3:
        return 'أرملة';
      case 4:
        return 'معاق';
      default:
        return sectionId?.toString() ?? '-';
    }
  }

  /// Get marital status label
  static String getMaritalStatusLabel(int? status) {
    if (status == null) return '-';
    switch (status) {
      case 1:
        return 'أعزب';
      case 2:
        return 'متزوج';
      case 3:
        return 'مطلق';
      case 4:
        return 'أرمل';
      default:
        return status.toString();
    }
  }

  /// Get health status label
  static String getHealthStatusLabel(int? status) {
    if (status == null) return '-';
    switch (status) {
      case 1:
        return 'جيدة';
      case 2:
        return 'متوسطة';
      case 3:
        return 'ضعيفة';
      case 4:
        return 'مرض مزمن';
      case 5:
        return 'إعاقة';
      default:
        return status.toString();
    }
  }

  /// Get education level label
  static String getEducationLabel(int? level) {
    if (level == null) return '-';
    switch (level) {
      case 1:
        return 'بدون تعليم';
      case 2:
        return 'ابتدائي';
      case 3:
        return 'إعدادي';
      case 4:
        return 'ثانوي';
      case 5:
        return 'بكالوريوس';
      case 6:
        return 'ماجستير';
      case 7:
        return 'دكتوراه';
      default:
        return level.toString();
    }
  }

  /// Get relationship label
  static String getRelationshipLabel(int? relationship) {
    if (relationship == null) return '-';
    switch (relationship) {
      case 1:
        return 'ابن';
      case 2:
        return 'أرملة';
      case 3:
        return 'أب';
      case 4:
        return 'أم';
      default:
        return relationship.toString();
    }
  }

  /// Get gender label
  static String getGenderLabel(int? gender) {
    if (gender == null) return '-';
    return gender == 1 ? 'ذكر' : 'أنثى';
  }

  /// Get gender icon
  static int getGenderIcon(int? gender) {
    return gender == 1 ? 0xe491 : 0xe4a2; // Icons.person / Icons.person_outline
  }

  /// Get displacement status label
  static String getDisplacementStatusLabel(int? status) {
    if (status == null) return '-';
    switch (status) {
      case 1:
        return 'نازح';
      case 2:
        return 'مقيم';
      case 3:
        return 'عائد';
      default:
        return 'كود: $status';
    }
  }

  /// Get housing status label
  static String getHousingStatusLabel(int? status) {
    if (status == null) return '-';
    switch (status) {
      case 1:
        return 'ملك';
      case 2:
        return 'إيجار';
      case 3:
        return 'سكن مجاني';
      default:
        return 'كود: $status';
    }
  }

  /// Get housing type label
  static String getHousingTypeLabel(int? type) {
    if (type == null) return '-';
    switch (type) {
      case 1:
        return 'شقة';
      case 2:
        return 'بيت';
      case 3:
        return 'غرفة';
      case 4:
        return 'خيمة';
      default:
        return 'كود: $type';
    }
  }

  /// Get employment status label
  static String getEmploymentStatusLabel(int? status) {
    if (status == null) return '-';
    switch (status) {
      case 1:
        return 'موظف';
      case 2:
        return 'عاطل';
      case 3:
        return 'عمل حر';
      case 4:
        return 'متقاعد';
      default:
        return 'كود: $status';
    }
  }

  /// Get province name
  static String getProvinceName(int? province) {
    if (province == null) return '-';
    // TODO: Add real province mapping
    return 'محافظة $province';
  }

  /// Get city name
  static String getCityName(int? city) {
    if (city == null) return '-';
    // TODO: Add real city mapping
    return 'مدينة $city';
  }

  /// Calculate age from birth date
  static int calculateAge(DateTime? birthDate) {
    if (birthDate == null) return 0;
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Format age
  static String formatAge(int age) {
    if (age == 0) return 'غير محدد';
    if (age == 1) return 'سنة واحدة';
    if (age == 2) return 'سنتان';
    if (age < 11) return '$age سنوات';
    return '$age سنة';
  }

  /// Format date time
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'غير محدد';
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Format date only
  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'غير محدد';
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  /// Check if pending sync
  static bool isPending(String syncState) {
    return syncState != 'synced';
  }

  /// Get initials from full name
  static String getInitials(String fullName) {
    if (fullName.isEmpty) return '?';
    final parts = fullName.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return parts[0].substring(0, 1).toUpperCase() + parts[1].substring(0, 1).toUpperCase();
  }
}

/// Color Info - معلومات الألوان
class ColorInfo {
  final int primary;
  final int light;

  ColorInfo({required this.primary, required this.light});
}
