/// 📝 Text Normalization Service - Arabic text processing
///
/// Single Responsibility: Normalize Arabic text for search
class TextNormalizationService {
  /// Normalize Arabic text for searching
  ///
  /// Removes diacritics, normalizes alef variants, ta marbuta, alef maksura.
  /// Handles hamza variants based on keepHamza flag.
  static String normalize(String? text, {bool keepHamza = true}) {
    if (text == null) return '';
    var s = text.trim().toLowerCase();
    if (s.isEmpty) return '';

    // Remove Arabic diacritics (tashkeel) and Quranic marks
    s = s.replaceAll(
      RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]'),
      '',
    );

    // Remove tatweel
    s = s.replaceAll('ـ', '');

    // Normalize alef variants: أ إ آ ٱ -> ا
    s = s.replaceAll(RegExp(r'[أإآٱ]'), 'ا');

    // Alef maksura -> ي
    s = s.replaceAll('ى', 'ي');

    // Ta marbuta -> ه
    s = s.replaceAll('ة', 'ه');

    // Hamza variants on letters -> practical mapping
    if (keepHamza) {
      s = s.replaceAll('ؤ', 'ء');
      s = s.replaceAll('ئ', 'ء');
    } else {
      s = s.replaceAll('ؤ', 'و');
      s = s.replaceAll('ئ', 'ي');
      s = s.replaceAll('ء', '');
    }

    // Remove non-Arabic letters but keep spaces
    s = s.replaceAll(RegExp(r'[^\u0600-\u06FF\s]'), ' ');

    // Collapse multiple spaces and trim
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

    return s;
  }

  /// Build normalized full name from database row
  static String buildNormalizedName(Map<String, Object?> row) {
    final parts = <String>[];
    final fields = [
      row['CI_FIRST_ARB'] as String?,
      row['CI_FATHER_ARB'] as String?,
      row['CI_GRAND_FATHER_ARB'] as String?,
      row['CI_FAMILY_ARB'] as String?,
    ];

    for (final value in fields) {
      if (value != null && value.trim().isNotEmpty) {
        parts.add(value.trim());
      }
    }

    if (parts.isEmpty) {
      return '';
    }

    return normalize(parts.join(' '), keepHamza: false);
  }

  /// Build FTS match query from normalized text
  ///
  /// Converts "محمد احمد" to "name_norm:محمد* name_norm:احمد*"
  static String? buildFtsMatchQuery(String normalized) {
    final tokens = normalized
        .split(' ')
        .where((token) => token.isNotEmpty)
        .toList();

    if (tokens.isEmpty) {
      return null;
    }

    return tokens.map((token) => 'name_norm:$token*').join(' ');
  }
}
