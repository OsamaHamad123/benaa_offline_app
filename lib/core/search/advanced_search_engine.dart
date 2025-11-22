import 'package:flutter/foundation.dart';

/// 🔍 محرك البحث المتقدم
class AdvancedSearchEngine {
  /// بحث ضبابي (Fuzzy Search)
  static List<T> fuzzySearch<T>(
    List<T> items,
    String query,
    String Function(T item) getText, {
    double threshold = 0.6,
  }) {
    if (query.isEmpty) return items;

    final results = <_SearchResult<T>>[];

    for (final item in items) {
      final text = getText(item).toLowerCase();
      final score = _calculateSimilarity(query.toLowerCase(), text);

      if (score >= threshold) {
        results.add(_SearchResult(item: item, score: score));
      }
    }

    // ترتيب حسب الأفضلية
    results.sort((a, b) => b.score.compareTo(a.score));

    return results.map((r) => r.item).toList();
  }

  /// بحث متعدد الحقول
  static List<T> multiFieldSearch<T>(
    List<T> items,
    String query,
    List<String Function(T item)> getters, {
    List<double>? weights,
  }) {
    if (query.isEmpty) return items;

    final actualWeights = weights ?? List.filled(getters.length, 1.0);
    final results = <_SearchResult<T>>[];

    for (final item in items) {
      double totalScore = 0;
      double totalWeight = 0;

      for (var i = 0; i < getters.length; i++) {
        final text = getters[i](item).toLowerCase();
        final score = _calculateSimilarity(query.toLowerCase(), text);
        final weight = actualWeights[i];

        totalScore += score * weight;
        totalWeight += weight;
      }

      final avgScore = totalScore / totalWeight;
      if (avgScore > 0.3) {
        results.add(_SearchResult(item: item, score: avgScore));
      }
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    return results.map((r) => r.item).toList();
  }

  /// بحث بالفلترة المتقدمة
  static List<T> advancedFilter<T>(
    List<T> items,
    List<bool Function(T item)> filters, {
    FilterMode mode = FilterMode.and,
  }) {
    return items.where((item) {
      if (mode == FilterMode.and) {
        return filters.every((filter) => filter(item));
      } else {
        return filters.any((filter) => filter(item));
      }
    }).toList();
  }

  /// بحث مع ترتيب مخصص
  static List<T> searchWithSort<T>(
    List<T> items,
    String query,
    String Function(T item) getText,
    int Function(T a, T b) comparator,
  ) {
    final results = fuzzySearch(items, query, getText);
    results.sort(comparator);
    return results;
  }

  /// بحث بالصوتيات (Phonetic)
  static List<T> phoneticSearch<T>(
    List<T> items,
    String query,
    String Function(T item) getText,
  ) {
    if (query.isEmpty) return items;

    final queryPhonetic = _toPhonetic(query);
    final results = <_SearchResult<T>>[];

    for (final item in items) {
      final text = getText(item);
      final textPhonetic = _toPhonetic(text);

      final score = _calculateSimilarity(queryPhonetic, textPhonetic);
      if (score > 0.5) {
        results.add(_SearchResult(item: item, score: score));
      }
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    return results.map((r) => r.item).toList();
  }

  /// حساب التشابه (Levenshtein Distance)
  static double _calculateSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    // Contains check (exact match)
    if (s2.contains(s1)) return 0.9;

    // Levenshtein distance
    final distance = _levenshteinDistance(s1, s2);
    final maxLength = s1.length > s2.length ? s1.length : s2.length;

    return 1.0 - (distance / maxLength);
  }

  /// Levenshtein Distance
  static int _levenshteinDistance(String s1, String s2) {
    final len1 = s1.length;
    final len2 = s2.length;

    final matrix = List.generate(len1 + 1, (i) => List.filled(len2 + 1, 0));

    for (var i = 0; i <= len1; i++) {
      matrix[i][0] = i;
    }

    for (var j = 0; j <= len2; j++) {
      matrix[0][j] = j;
    }

    for (var i = 1; i <= len1; i++) {
      for (var j = 1; j <= len2; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1, // deletion
          matrix[i][j - 1] + 1, // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[len1][len2];
  }

  /// تحويل لصوتي (مبسط للعربية)
  static String _toPhonetic(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll(RegExp(r'[ًٌٍَُِّْ]'), ''); // إزالة التشكيل
  }
}

/// نتيجة البحث
class _SearchResult<T> {
  final T item;
  final double score;

  _SearchResult({required this.item, required this.score});
}

/// وضع الفلترة
enum FilterMode {
  and, // كل الشروط
  or, // أي شرط
}

/// مساعد البحث في القوائم
class SearchHelper {
  /// بحث في قائمة النصوص
  static List<String> searchInList(
    List<String> items,
    String query, {
    bool caseSensitive = false,
  }) {
    if (query.isEmpty) return items;

    final searchQuery = caseSensitive ? query : query.toLowerCase();

    return items.where((item) {
      final text = caseSensitive ? item : item.toLowerCase();
      return text.contains(searchQuery);
    }).toList();
  }

  /// بحث بالبادئة
  static List<String> searchByPrefix(
    List<String> items,
    String prefix, {
    bool caseSensitive = false,
  }) {
    if (prefix.isEmpty) return items;

    final searchPrefix = caseSensitive ? prefix : prefix.toLowerCase();

    return items.where((item) {
      final text = caseSensitive ? item : item.toLowerCase();
      return text.startsWith(searchPrefix);
    }).toList();
  }

  /// بحث بالنهاية
  static List<String> searchBySuffix(
    List<String> items,
    String suffix, {
    bool caseSensitive = false,
  }) {
    if (suffix.isEmpty) return items;

    final searchSuffix = caseSensitive ? suffix : suffix.toLowerCase();

    return items.where((item) {
      final text = caseSensitive ? item : item.toLowerCase();
      return text.endsWith(searchSuffix);
    }).toList();
  }

  /// بحث بالـ Regular Expression
  static List<String> searchByRegex(List<String> items, String pattern) {
    if (pattern.isEmpty) return items;

    try {
      final regex = RegExp(pattern);
      return items.where((item) => regex.hasMatch(item)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Invalid regex pattern: $pattern');
      }
      return [];
    }
  }
}
