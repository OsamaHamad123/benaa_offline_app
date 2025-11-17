import '../entities/beneficiary.dart';

/// Beneficiary Domain Helpers - عمليات مساعدة للمستفيدين (Domain Layer)
class BeneficiaryDomainHelpers {
  /// Get category color based on category
  static ColorInfo getCategoryColorInfo(BeneficiaryCategory? category) {
    if (category == null) {
      return ColorInfo(primary: 0xFF757575, light: 0xFFEEEEEE);
    }

    switch (category) {
      case BeneficiaryCategory.orphan:
        return ColorInfo(primary: 0xFF2196F3, light: 0xFFE3F2FD); // Blue
      case BeneficiaryCategory.poor:
        return ColorInfo(primary: 0xFF9C27B0, light: 0xFFF3E5F5); // Purple
      case BeneficiaryCategory.widow:
        return ColorInfo(primary: 0xFFFF9800, light: 0xFFFFF3E0); // Orange
      case BeneficiaryCategory.disabled:
        return ColorInfo(primary: 0xFF009688, light: 0xFFE0F2F1); // Teal
      default:
        return ColorInfo(primary: 0xFF757575, light: 0xFFEEEEEE); // Grey
    }
  }

  /// Get category label
  static String getCategoryLabel(BeneficiaryCategory? category) {
    return category?.arabicLabel ?? '-';
  }

  /// Get marital status label
  static String getMaritalStatusLabel(MaritalStatus? status) {
    return status?.arabicLabel ?? '-';
  }

  /// Get health status label
  static String getHealthStatusLabel(HealthStatus? status) {
    return status?.arabicLabel ?? '-';
  }

  /// Get education level label
  static String getEducationLabel(EducationLevel? level) {
    return level?.arabicLabel ?? '-';
  }

  /// Get gender label
  static String getGenderLabel(Gender? gender) {
    return gender?.arabicLabel ?? '-';
  }

  /// Get gender icon
  static int getGenderIcon(Gender? gender) {
    return gender == Gender.male
        ? 0xe491
        : 0xe4a2; // Icons.person / Icons.person_outline
  }

  /// Get displacement status label
  static String getDisplacementStatusLabel(DisplacementStatus? status) {
    return status?.arabicLabel ?? '-';
  }

  /// Get housing status label
  static String getHousingStatusLabel(HousingStatus? status) {
    return status?.arabicLabel ?? '-';
  }

  /// Get housing type label
  static String getHousingTypeLabel(HousingType? type) {
    return type?.arabicLabel ?? '-';
  }

  /// Get employment status label
  static String getEmploymentStatusLabel(EmploymentStatus? status) {
    return status?.arabicLabel ?? '-';
  }

  /// Get governorate name
  static String getGovernorateName(String? governorate) {
    if (governorate == null || governorate.isEmpty) return '-';
    // TODO: Add real governorate mapping
    return 'محافظة $governorate';
  }

  /// Get district name
  static String getDistrictName(String? district) {
    if (district == null || district.isEmpty) return '-';
    // TODO: Add real district mapping
    return 'مدينة $district';
  }

  /// Format age
  static String formatAge(int? age) {
    if (age == null || age == 0) return 'غير محدد';
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
  static bool isPending(bool needsSync) {
    return needsSync;
  }

  /// Get initials from full name
  static String getInitials(String fullName) {
    if (fullName.isEmpty) return '?';
    final parts = fullName.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return parts[0].substring(0, 1).toUpperCase() +
        parts[1].substring(0, 1).toUpperCase();
  }
}

/// Color Info - معلومات الألوان
class ColorInfo {
  final int primary;
  final int light;

  ColorInfo({required this.primary, required this.light});
}
