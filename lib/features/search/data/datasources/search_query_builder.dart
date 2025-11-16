import 'package:benaa_offline_app/core/constants/search_constants.dart';
import 'package:sqflite/sqflite.dart';

/// 🔧 Search Query Builder Helpers
///
/// Reusable helper functions to build SQL queries
/// Eliminates code duplication across search operations
class SearchQueryBuilder {
  // Prevent instantiation
  SearchQueryBuilder._();

  // ============================================================================
  // COMPOUND NAME VARIATIONS
  // ============================================================================

  /// Generate search variations for compound names
  /// "عبد الرحمن" generates (in priority order):
  /// - "عبد الرحمن" (full compound - HIGHEST PRIORITY)
  /// - "عبدالرحمن" (no space)
  /// - "عبد%" (prefix only - LOWEST PRIORITY)
  static List<String> generateCompoundVariations(String word) {
    final variations = <String>[];

    if (word.contains(' ')) {
      // Priority 1: Original with space (most specific)
      variations.add(word);

      // Priority 2: No-space version
      variations.add(word.replaceAll(' ', ''));

      // Priority 3: Prefix-only for broader search
      final firstPart = word.split(' ').first;
      if (SearchConstants.compoundPrefixes.contains(firstPart)) {
        variations.add('$firstPart${SearchConstants.prefixWildcard}');
      }
    } else if (SearchConstants.compoundPrefixes.contains(word)) {
      // If someone types just "عبد", search for both exact and prefix
      variations.add(word); // Exact first
      variations.add(SearchConstants.prefixPattern(word)); // Prefix second
    } else {
      // Regular word - just return as-is
      variations.add(word);
    }

    return variations;
  }

  // ============================================================================
  // WORD SPLITTING
  // ============================================================================

  /// Smart word splitter that handles compound names
  /// Examples:
  /// - "عبد الرحمن" → ["عبد الرحمن"] (kept together)
  /// - "محمد عبد الله" → ["محمد", "عبد الله"]
  /// - "ابو بكر الصديق" → ["ابو بكر", "الصديق"]
  static List<String> splitSmartWords(String normalized) {
    final words = normalized.split(' ');
    final smartWords = <String>[];

    int i = 0;
    while (i < words.length) {
      final word = words[i];

      // Check if this is a compound prefix and we have a next word
      if (SearchConstants.compoundPrefixes.contains(word) &&
          i + 1 < words.length) {
        // Combine with next word: "عبد" + "الرحمن" = "عبد الرحمن"
        smartWords.add('$word ${words[i + 1]}');
        i += 2; // Skip next word as we already combined it
      } else if (word.length >= SearchConstants.minWordLength) {
        smartWords.add(word);
        i++;
      } else {
        i++; // Skip single character words
      }
    }

    return smartWords;
  }

  // ============================================================================
  // QUERY CONDITION BUILDERS
  // ============================================================================

  /// Build column conditions for a word with all its variations
  /// Returns: (conditions, parameters)
  static ({List<String> conditions, List<dynamic> parameters})
  buildWordConditions({required String word, required String columnName}) {
    final variations = generateCompoundVariations(word);
    final conditions = <String>[];
    final parameters = <dynamic>[];

    for (final variation in variations) {
      final isPrefix = variation.endsWith(SearchConstants.prefixWildcard);
      if (isPrefix) {
        final cleanTerm = variation.substring(0, variation.length - 1);
        conditions.add('$columnName LIKE ?');
        parameters.add(SearchConstants.prefixPattern(cleanTerm));
      } else {
        conditions.add('$columnName = ?');
        parameters.add(variation);
      }
    }

    return (conditions: conditions, parameters: parameters);
  }

  /// Build multi-word WHERE clause with compound name support
  /// Returns: (whereClause, queryParams)
  static ({String whereClause, List<dynamic> params}) buildMultiWordWhere({
    required List<String> smartWords,
  }) {
    final wordConditions = <String>[];
    final queryParams = <dynamic>[];

    for (
      int i = 0;
      i < smartWords.length && i < SearchConstants.maxNameParts;
      i++
    ) {
      final word = smartWords[i];

      // Get column name based on position
      final columnName = _getColumnNameByIndex(i);
      if (columnName == null) continue;

      // Build conditions for this word with all variations
      final result = buildWordConditions(word: word, columnName: columnName);

      // Group variations for this word with OR
      if (result.conditions.isNotEmpty) {
        wordConditions.add('(${result.conditions.join(' OR ')})');
        queryParams.addAll(result.parameters);
      }
    }

    // Combine all word conditions with AND
    final whereClause = wordConditions.isNotEmpty
        ? wordConditions.join(' AND ')
        : '';

    return (whereClause: whereClause, params: queryParams);
  }

  /// Build single word WHERE clause (searches in any column)
  /// Returns: (whereClause, queryParams)
  static ({String whereClause, List<dynamic> params}) buildSingleWordWhere({
    required String word,
  }) {
    final variations = generateCompoundVariations(word);
    final allConditions = <String>[];
    final allParams = <dynamic>[];

    for (final variation in variations) {
      final isPrefix = variation.endsWith(SearchConstants.prefixWildcard);
      final cleanTerm = isPrefix
          ? variation.substring(0, variation.length - 1)
          : variation;
      final operator = isPrefix ? 'LIKE' : '=';
      final pattern = isPrefix
          ? SearchConstants.prefixPattern(cleanTerm)
          : cleanTerm;

      // Check all columns
      final conditions = <String>[];
      for (final col in _allNameColumns) {
        conditions.add('$col $operator ?');
        allParams.add(pattern);
      }

      allConditions.add('(${conditions.join(' OR ')})');
    }

    final whereClause = allConditions.isNotEmpty
        ? allConditions.join(' OR ')
        : '';

    return (whereClause: whereClause, params: allParams);
  }

  // ============================================================================
  // FILTER BUILDERS
  // ============================================================================

  /// Build filter clause and arguments for governorate/gender
  static ({String clause, List<dynamic> args}) buildFilters({
    String? governorate,
    int? genderCode,
  }) {
    final args = <dynamic>[];
    var clause = '';

    if (governorate != null && governorate.isNotEmpty) {
      clause += ' AND CITY = ?';
      args.add(governorate);
    }

    if (genderCode != null) {
      clause += ' AND CI_SEX_CD = ?';
      args.add(genderCode);
    }

    return (clause: clause, args: args);
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  /// Get column name by index (0 = First, 1 = Father, 2 = GrandFather, 3 = Family)
  static String? _getColumnNameByIndex(int index) {
    switch (index) {
      case 0:
        return 'CI_FIRST_ARB';
      case 1:
        return 'CI_FATHER_ARB';
      case 2:
        return 'CI_GRAND_FATHER_ARB';
      case 3:
        return 'CI_FAMILY_ARB';
      default:
        return null;
    }
  }

  /// All name columns for searching
  static const List<String> _allNameColumns = [
    'CI_FIRST_ARB',
    'CI_FATHER_ARB',
    'CI_GRAND_FATHER_ARB',
    'CI_FAMILY_ARB',
  ];

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Extract first integer value from query result
  static int extractCount(List<Map<String, Object?>> results) {
    return Sqflite.firstIntValue(results) ?? 0;
  }

  /// Check if a variation is a prefix pattern
  static bool isPrefixPattern(String variation) {
    return variation.endsWith(SearchConstants.prefixWildcard);
  }

  /// Clean prefix pattern to get the actual term
  static String cleanPrefixPattern(String pattern) {
    return pattern.endsWith(SearchConstants.prefixWildcard)
        ? pattern.substring(0, pattern.length - 1)
        : pattern;
  }
}
