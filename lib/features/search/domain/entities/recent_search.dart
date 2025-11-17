/// 🔍 Recent Search Entity - Domain Layer
///
/// Clean Architecture: Pure domain entity (no dependencies)
class RecentSearch {
  final String query;
  final DateTime searchedAt;
  final int resultsCount;

  const RecentSearch({
    required this.query,
    required this.searchedAt,
    required this.resultsCount,
  });

  /// Create from JSON (for local storage)
  factory RecentSearch.fromJson(Map<String, dynamic> json) {
    return RecentSearch(
      query: json['query'] as String,
      searchedAt: DateTime.parse(json['searchedAt'] as String),
      resultsCount: json['resultsCount'] as int,
    );
  }

  /// Convert to JSON (for local storage)
  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'searchedAt': searchedAt.toIso8601String(),
      'resultsCount': resultsCount,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecentSearch &&
          runtimeType == other.runtimeType &&
          query == other.query;

  @override
  int get hashCode => query.hashCode;
}
