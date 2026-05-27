class FileNumberFormatter {
  const FileNumberFormatter._();

  static String format({
    required String prefix,
    required int year,
    required int number,
  }) {
    final normalizedPrefix = prefix.trim().toUpperCase();
    final safeYear = year < 1 ? DateTime.now().year : year;
    final safeNumber = number < 1 ? 1 : number;
    final padded = safeNumber.toString().padLeft(6, '0');
    return '$normalizedPrefix-$safeYear-$padded';
  }

  static bool isFormatted(String value) {
    final text = value.trim().toUpperCase();
    return RegExp(r'^[A-Z]{2,6}-\d{4}-\d{6}$').hasMatch(text);
  }

  static bool isValidCandidate(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return false;
    if (isFormatted(text)) return true;
    return int.tryParse(text) != null;
  }

  static int? extractSequence(String? fileNumber) {
    final text = (fileNumber ?? '').trim();
    if (text.isEmpty) return null;

    if (isFormatted(text)) {
      final parts = text.split('-');
      if (parts.length != 3) return null;
      return int.tryParse(parts[2]);
    }

    return int.tryParse(text);
  }
}
