/// ⚙️ Selection persistence helper
class SelectionPersistence {
  static Set<int>? _savedSelection;

  /// حفظ الـ selection
  static void saveSelection(Set<int> selection) {
    _savedSelection = Set.from(selection);
  }

  /// استرجاع الـ selection
  static Set<int>? restoreSelection() {
    return _savedSelection;
  }

  /// مسح الـ selection المحفوظة
  static void clearSavedSelection() {
    _savedSelection = null;
  }

  /// التحقق من وجود selection محفوظة
  static bool hasSavedSelection() {
    return _savedSelection != null && _savedSelection!.isNotEmpty;
  }
}
