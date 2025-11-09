class TextNormalizer {
  /// Normalizes Arabic text for full-text search
  /// - Removes diacritics (tashkeel)
  /// - Unifies Alef variants
  /// - Unifies Ya variants
  /// - Converts Ta Marbuta to Ha
  /// - Normalizes whitespace
  /// - Converts to lowercase
  static String normalizeArabic(String text) {
    if (text.isEmpty) return text;

    // Remove Arabic diacritics (harakat)
    final diacritics = RegExp(r'[\u064B-\u065F\u0670]');
    var normalized = text.replaceAll(diacritics, '');

    // Unify Alef variants: أ إ آ ا -> ا
    normalized = normalized
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ٱ', 'ا');

    // Unify Ya variants: ى ئ -> ي
    normalized = normalized.replaceAll('ى', 'ي').replaceAll('ئ', 'ي');

    // Convert Ta Marbuta to Ha: ة -> ه
    normalized = normalized.replaceAll('ة', 'ه');

    // Normalize Hamza
    normalized = normalized.replaceAll('ؤ', 'و').replaceAll('ء', '');

    // Normalize whitespace
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Convert to lowercase
    normalized = normalized.toLowerCase();

    return normalized;
  }

  /// Normalizes text for exact matching
  static String normalizeForExactMatch(String text) {
    return normalizeArabic(text).replaceAll(' ', '');
  }

  /// Prepare text for FTS5 MATCH query
  /// Escapes special FTS5 characters and adds wildcards if needed
  static String prepareForFts5(String query) {
    final normalized = normalizeArabic(query);

    // Escape double quotes
    var escaped = normalized.replaceAll('"', '""');

    // If the query has multiple words, wrap in quotes for phrase search
    if (escaped.contains(' ')) {
      return '"$escaped"';
    }

    // For single word, add wildcard for prefix matching
    return '$escaped*';
  }

  /// Highlight matching parts in text
  static String highlightMatches(String text, String query) {
    if (query.isEmpty) return text;

    final normalizedQuery = normalizeArabic(query);
    final words = normalizedQuery
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();

    var result = text;
    for (final word in words) {
      // Simple highlighting - in production you might want to use a more sophisticated approach
      final regex = RegExp(word, caseSensitive: false);
      result = result.replaceAllMapped(
        regex,
        (match) => '**${match.group(0)}**',
      );
    }

    return result;
  }

  /// Check if text contains query (normalized)
  static bool contains(String text, String query) {
    return normalizeArabic(text).contains(normalizeArabic(query));
  }

  /// Calculate simple relevance score based on position and frequency
  static double calculateRelevance(String text, String query) {
    final normalizedText = normalizeArabic(text);
    final normalizedQuery = normalizeArabic(query);

    if (normalizedText == normalizedQuery) return 1.0;
    if (!normalizedText.contains(normalizedQuery)) return 0.0;

    // Higher score for matches at the beginning
    final index = normalizedText.indexOf(normalizedQuery);
    final positionScore = 1.0 - (index / normalizedText.length);

    // Count occurrences
    final occurrences = normalizedQuery.allMatches(normalizedText).length;
    final frequencyScore = occurrences / 10.0; // Normalize

    return (positionScore * 0.7) + (frequencyScore * 0.3);
  }
}
