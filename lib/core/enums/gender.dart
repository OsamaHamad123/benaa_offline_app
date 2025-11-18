/// Enum for gender
enum Gender {
  male('ذكور'),
  female('إناث');

  const Gender(this.arabicLabel);

  final String arabicLabel;

  /// Get Gender from Arabic label
  static Gender fromLabel(String label) {
    return Gender.values.firstWhere(
      (gender) => gender.arabicLabel == label,
      orElse: () => Gender.male,
    );
  }

  /// Get Gender from database value (M/F)
  static Gender fromCode(String code) {
    switch (code.toUpperCase()) {
      case 'M':
      case 'ذكر':
        return Gender.male;
      case 'F':
      case 'أنثى':
        return Gender.female;
      default:
        return Gender.male;
    }
  }

  /// Convert to database code
  String toCode() {
    switch (this) {
      case Gender.male:
        return 'M';
      case Gender.female:
        return 'F';
    }
  }
}
