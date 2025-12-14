import '../../../domain/entities/civil_person.dart';

/// 🎯 Smart Search Suggestions Generator
///
/// يولد اقتراحات ذكية بناءً على:
/// - تاريخ البحث
/// - الأنماط الشائعة
/// - التصحيح التلقائي
class SmartSuggestionsGenerator {
  SmartSuggestionsGenerator._();

  /// Generate smart suggestions based on query
  static List<String> generateSuggestions({
    required String query,
    required List<CivilPerson> recentResults,
    int maxSuggestions = 5,
  }) {
    final suggestions = <String>[];

    if (query.isEmpty) return suggestions;

    // 1. من النتائج الأخيرة
    for (final person in recentResults) {
      if (person.fullName.contains(query)) {
        suggestions.add(person.fullName);
      }
      if (suggestions.length >= maxSuggestions) break;
    }

    // 2. اقتراحات أسماء شائعة
    if (suggestions.length < maxSuggestions) {
      suggestions.addAll(_getCommonNameSuggestions(query));
    }

    // 3. تصحيح تلقائي للأخطاء الشائعة
    if (suggestions.isEmpty) {
      final corrected = _autoCorrect(query);
      if (corrected != query) {
        suggestions.add(corrected);
      }
    }

    return suggestions.take(maxSuggestions).toList();
  }

  /// Common Iraqi names for suggestions
  static List<String> _getCommonNameSuggestions(String query) {
    final commonNames = [
      'محمد أحمد علي',
      'علي حسن محمد',
      'أحمد محمد علي',
      'حسن علي محمد',
      'عمر أحمد علي',
      'خالد محمد أحمد',
      'فاطمة أحمد محمد',
      'زينب حسن علي',
      'مريم محمد أحمد',
      'نور علي حسن',
    ];

    return commonNames.where((name) => name.contains(query)).toList();
  }

  /// Auto-correct common typing mistakes
  static String _autoCorrect(String query) {
    final corrections = {
      'محمد': ['محمد', 'محمد', 'محمه', 'مجمد'],
      'أحمد': ['احمد', 'احمد', 'اجمد'],
      'علي': ['على', 'علي', 'عاي'],
      'حسن': ['حسن', 'حسين', 'حسان'],
      'فاطمة': ['فاطمه', 'فاطمة', 'فاطمت'],
    };

    for (final entry in corrections.entries) {
      for (final mistake in entry.value) {
        if (query.contains(mistake)) {
          return query.replaceAll(mistake, entry.key);
        }
      }
    }

    return query;
  }

  /// Calculate search relevance score
  static double calculateRelevanceScore(CivilPerson person, String query) {
    double score = 0.0;
    final lowerQuery = query.toLowerCase();
    final lowerName = person.fullName.toLowerCase();

    // Exact match = highest score
    if (lowerName == lowerQuery) {
      score = 100.0;
    }
    // Starts with query = high score
    else if (lowerName.startsWith(lowerQuery)) {
      score = 80.0;
    }
    // Contains query = medium score
    else if (lowerName.contains(lowerQuery)) {
      score = 60.0;
    }
    // Partial match = low score
    else {
      final queryWords = lowerQuery.split(' ');
      final nameWords = lowerName.split(' ');
      final matchCount = queryWords.where((q) => nameWords.any((n) => n.contains(q))).length;
      score = (matchCount / queryWords.length) * 40.0;
    }

    return score;
  }

  /// Sort results by relevance
  static List<CivilPerson> sortByRelevance(
    List<CivilPerson> results,
    String query,
  ) {
    final scored = results.map((person) {
      return MapEntry(person, calculateRelevanceScore(person, query));
    }).toList();

    scored.sort((a, b) => b.value.compareTo(a.value));

    return scored.map((e) => e.key).toList();
  }
}
