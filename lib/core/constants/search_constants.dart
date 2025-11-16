/// 🔍 Search Configuration Constants
///
/// Centralized constants for search functionality
/// to avoid magic numbers and improve maintainability
class SearchConstants {
  // Prevent instantiation
  SearchConstants._();

  // ============================================================================
  // WORD PROCESSING
  // ============================================================================

  /// Minimum word length for search (shorter words are ignored)
  static const int minWordLength = 2;

  /// Minimum number of words to trigger multi-word search
  static const int minMultiWordCount = 2;

  /// Maximum number of name parts (First, Father, GrandFather, Family)
  static const int maxNameParts = 4;

  // ============================================================================
  // COMPOUND NAMES
  // ============================================================================

  /// Common Arabic compound name prefixes
  /// Used to intelligently combine words like "عبد" + "الرحمن" → "عبد الرحمن"
  static const Set<String> compoundPrefixes = {
    'عبد',
    'ابو',
    'ام',
    'بن',
    'بنت',
    'ال',
  };

  // ============================================================================
  // CACHING
  // ============================================================================

  /// Maximum number of search results to cache
  static const int maxCacheSize = 50;

  /// Cache entry time-to-live (for future implementation)
  static const Duration cacheExpiration = Duration(minutes: 30);

  // ============================================================================
  // PAGINATION
  // ============================================================================

  /// Default number of results per page (optimized for performance)
  static const int defaultPageSize = 6; // ⚡ Reduced to 6 for zero lag!

  /// Page size for mobile devices (smaller screens = lighter UI)
  static const int defaultPageSizeMobile = 5;

  /// Page size for desktop/tablet (larger screens)
  static const int defaultPageSizeDesktop = 10;

  /// Maximum allowed page size
  static const int maxPageSize = 100;

  // ============================================================================
  // DEBOUNCING
  // ============================================================================

  /// Debounce duration for search input (prevents excessive queries)
  static const Duration debounceDuration = Duration(milliseconds: 400);

  // ============================================================================
  // SEARCH SCORING
  // ============================================================================

  /// Score for multi-word smart search (highest priority)
  static const int multiWordScore = 95;

  /// Score for single compound name exact match
  static const int compoundNameScore = 100;

  /// Score for single word exact match
  static const int exactMatchScore = 90;

  /// Score for prefix match
  static const int prefixMatchScore = 85;

  /// Score for contains match (fuzzy search)
  static const int containsMatchScore = 70;

  // ============================================================================
  // NATIONAL ID
  // ============================================================================

  /// Minimum national ID length for validation
  static const int minNationalIdLength = 8;

  /// Maximum national ID length
  static const int maxNationalIdLength = 15;

  // ============================================================================
  // QUERY PATTERNS
  // ============================================================================

  /// Prefix wildcard for SQL LIKE queries
  static const String prefixWildcard = '%';

  /// Infix wildcard pattern for contains search
  static String infixPattern(String term) => '%$term%';

  /// Prefix pattern for starts-with search
  static String prefixPattern(String term) => '$term%';
}
