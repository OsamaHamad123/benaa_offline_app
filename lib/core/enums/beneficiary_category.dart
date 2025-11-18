/// Enum for beneficiary categories
enum BeneficiaryCategory {
  orphans('أيتام', 1),
  poor('فقراء', 2),
  widows('أرامل', 3),
  disabled('معاقين', 4);

  const BeneficiaryCategory(this.arabicLabel, this.id);

  final String arabicLabel;
  final int id;

  /// Get category from ID
  static BeneficiaryCategory? fromId(int id) {
    try {
      return BeneficiaryCategory.values.firstWhere(
        (category) => category.id == id,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get category from Arabic label
  static BeneficiaryCategory? fromLabel(String label) {
    try {
      return BeneficiaryCategory.values.firstWhere(
        (category) => category.arabicLabel == label,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get all category labels
  static List<String> get allLabels {
    return BeneficiaryCategory.values.map((c) => c.arabicLabel).toList();
  }

  /// Get all category IDs
  static List<int> get allIds {
    return BeneficiaryCategory.values.map((c) => c.id).toList();
  }
}
