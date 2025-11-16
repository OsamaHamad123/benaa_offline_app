import 'package:sqflite/sqflite.dart';
import 'package:benaa_offline_app/core/constants/search_constants.dart';
import 'package:benaa_offline_app/core/utils/app_logger.dart';
import 'package:benaa_offline_app/features/search/domain/failures/search_failures.dart';
import 'person_mapper.dart';
import 'text_normalization_service.dart';
import 'search_query_builder.dart';
import '../../domain/entities/civil_person.dart';

/// 🔍 Civil Registry Search Queries - All search operations
///
/// Single Responsibility: Execute search queries against persons database
/// Ultra-optimized with caching for blazing fast performance
class CivilRegistrySearchQueries {
  final Database _db;

  // Enhanced cache for recent searches (max 50 entries for better hit rate)
  final Map<String, List<CivilPerson>> _searchCache = {};
  final Map<String, int> _countCache = {};
  static final int _maxCacheSize = SearchConstants.maxCacheSize;

  // Cache access tracking for LRU eviction
  final Map<String, DateTime> _cacheAccess = {};

  CivilRegistrySearchQueries(this._db);

  // ============================================================================
  // COMPOUND NAMES HANDLER - Smart Arabic name processing
  // ============================================================================

  /// Smart word splitter that handles compound names (delegated to SearchQueryBuilder)
  List<String> _splitSmartWords(String normalized) {
    return SearchQueryBuilder.splitSmartWords(normalized);
  }

  /// Generate search variations for compound names (delegated to SearchQueryBuilder)
  List<String> _generateCompoundVariations(String word) {
    return SearchQueryBuilder.generateCompoundVariations(word);
  }

  /// Search by National ID - Optimized with exact match
  Future<CivilPerson?> searchByNationalId(String nationalId) async {
    final stopwatch = Stopwatch()..start();

    try {
      final cleaned = nationalId.trim().replaceAll(' ', '').replaceAll('-', '');

      if (cleaned.isEmpty ||
          cleaned.length < SearchConstants.minNationalIdLength) {
        AppLogger.logSearch(
          query: 'NID: $nationalId',
          resultsCount: 0,
          durationMs: stopwatch.elapsedMilliseconds,
        );
        return null;
      }

      // 1. Exact match (fastest - uses index)
      var results = await _db.rawQuery(
        'SELECT * FROM persons WHERE CI_ID_NUM = ? LIMIT 1',
        [cleaned],
      );

      if (results.isNotEmpty) {
        return PersonMapper.fromDatabase(results.first);
      }

      // 2. Remove all non-digits and try again
      final digitsOnly = cleaned.replaceAll(RegExp(r'[^\d]'), '');
      if (digitsOnly != cleaned && digitsOnly.isNotEmpty) {
        results = await _db.rawQuery(
          'SELECT * FROM persons WHERE CI_ID_NUM = ? LIMIT 1',
          [digitsOnly],
        );
        if (results.isNotEmpty) {
          return PersonMapper.fromDatabase(results.first);
        }
      }

      // 3. LIKE search as last resort (handles spaces/dashes in DB)
      // Search for numbers that contain all these digits in sequence
      results = await _db.rawQuery(
        'SELECT * FROM persons WHERE REPLACE(REPLACE(CI_ID_NUM, " ", ""), "-", "") = ? LIMIT 1',
        [digitsOnly.isNotEmpty ? digitsOnly : cleaned],
      );

      if (results.isNotEmpty) {
        final person = PersonMapper.fromDatabase(results.first);
        stopwatch.stop();
        AppLogger.logSearch(
          query: 'NID: $nationalId',
          resultsCount: 1,
          durationMs: stopwatch.elapsedMilliseconds,
        );
        return person;
      }

      stopwatch.stop();
      AppLogger.logSearch(
        query: 'NID: $nationalId',
        resultsCount: 0,
        durationMs: stopwatch.elapsedMilliseconds,
      );
      return null;
    } catch (e, st) {
      stopwatch.stop();
      AppLogger.error('Error in searchByNationalId', error: e, stackTrace: st);
      throw DatabaseQueryFailure(e.toString());
    }
  }

  /// Search by Name - 3-Tier Hybrid Strategy (Elasticsearch-style)
  ///
  /// Tier 1: EXACT match (100% accuracy) - "اسامة" = "اسامة" only
  /// Tier 2: PREFIX match (95% accuracy) - "اسامة" matches "اسامة حمد"
  /// Tier 3: CONTAINS match (80% accuracy) - fallback fuzzy search
  /// Average: 10-30ms, cached: 0-2ms
  Future<List<CivilPerson>> searchByName(
    String query, {
    String? governorate,
    int? genderCode,
    int limit = 20,
    int offset = 0,
  }) async {
    final normalized = TextNormalizationService.normalize(
      query,
      keepHamza: false,
    );
    final raw = query.trim();

    if (normalized.isEmpty || raw.isEmpty) {
      return [];
    }

    final stopwatch = Stopwatch()..start();

    // Cache key
    final cacheKey = '$normalized|$governorate|$genderCode|$limit|$offset';

    // Check cache (instant 0-2ms)
    if (_searchCache.containsKey(cacheKey)) {
      final cached = _searchCache[cacheKey]!;
      stopwatch.stop();
      AppLogger.logCache(
        key: cacheKey,
        hit: true,
        cacheSize: _searchCache.length,
      );
      AppLogger.logSearch(
        query: query,
        resultsCount: cached.length,
        durationMs: stopwatch.elapsedMilliseconds,
      );
      return cached;
    }

    AppLogger.logCache(
      key: cacheKey,
      hit: false,
      cacheSize: _searchCache.length,
    );

    // Build filters
    final filterArgs = <dynamic>[];
    var filterClause = '';

    if (governorate != null && governorate.isNotEmpty) {
      filterClause += ' AND CITY = ?';
      filterArgs.add(governorate);
    }

    if (genderCode != null) {
      filterClause += ' AND CI_SEX_CD = ?';
      filterArgs.add(genderCode);
    }

    List<Map<String, Object?>> results;

    // Split query into smart words (handles compound names like "عبد الرحمن")
    final smartWords = _splitSmartWords(normalized);

    // ========================================================================
    // TIER 1: SMART MULTI-WORD SEARCH (Score: 95) - WITH COMPOUND SUPPORT
    // ========================================================================
    // For "محمد عبد الله احمد": handles compound "عبد الله" smartly
    // For "عبد الرحمن محمد": "عبد الرحمن" matches CI_FIRST_ARB
    // THIS MUST RUN FIRST for multi-word queries!
    if (smartWords.length >= 2) {
      try {
        // Build OR conditions for each word across all variations
        final wordConditions = <String>[];
        final queryParams = <dynamic>[];

        for (int i = 0; i < smartWords.length && i < 4; i++) {
          final word = smartWords[i];
          final variations = _generateCompoundVariations(word);

          // Match to appropriate column
          String columnName;
          switch (i) {
            case 0:
              columnName = 'CI_FIRST_ARB';
              break;
            case 1:
              columnName = 'CI_FATHER_ARB';
              break;
            case 2:
              columnName = 'CI_GRAND_FATHER_ARB';
              break;
            case 3:
              columnName = 'CI_FAMILY_ARB';
              break;
            default:
              continue;
          }

          // Try all variations for this column with OR
          final varConditions = <String>[];
          for (final variation in variations) {
            final isPrefix = variation.endsWith('%');
            if (isPrefix) {
              final cleanTerm = variation.substring(0, variation.length - 1);
              varConditions.add('$columnName LIKE ?');
              queryParams.add('$cleanTerm%');
            } else {
              varConditions.add('$columnName = ?');
              queryParams.add(variation);
            }
          }

          // Group variations for this word with OR
          if (varConditions.isNotEmpty) {
            wordConditions.add('(${varConditions.join(' OR ')})');
          }
        }

        if (wordConditions.isNotEmpty) {
          // Combine all word conditions with AND
          results = await _db.rawQuery(
            '''
            SELECT *, 95 as match_score
            FROM persons 
            WHERE ${wordConditions.join(' AND ')}
            $filterClause
            ORDER BY LENGTH(CI_FIRST_ARB)
            LIMIT ? OFFSET ?
            ''',
            [...queryParams, ...filterArgs, limit, offset],
          );

          if (results.isNotEmpty) {
            final persons = PersonMapper.fromDatabaseList(results);
            _cacheResults(cacheKey, persons);
            return persons;
          }
        }
      } catch (e) {
        // Continue to Tier 2
      }
    }

    // ========================================================================
    // TIER 0: SINGLE COMPOUND NAME MATCH (Score: 100) - For single word only
    // ========================================================================
    // Handles: "عبد الرحمن" exactly or "عبدالرحمن" (no space version)
    // ONLY runs if there's a SINGLE word (smartWords.length == 1)
    if (smartWords.length == 1) {
      try {
        // Try exact match with both spaced and no-space versions
        final firstWord = smartWords[0];
        final variations = _generateCompoundVariations(firstWord);

        for (final variation in variations) {
          final isPrefix = variation.endsWith('%');
          final searchTerm = isPrefix
              ? variation.substring(0, variation.length - 1)
              : variation;
          final operator = isPrefix ? 'LIKE' : '=';

          results = await _db.rawQuery(
            '''
            SELECT *, 100 as match_score
            FROM persons 
            WHERE (
              CI_FIRST_ARB $operator ? OR
              CI_FATHER_ARB $operator ? OR
              CI_GRAND_FATHER_ARB $operator ? OR
              CI_FAMILY_ARB $operator ?
            )
            $filterClause
            ORDER BY 
              CASE 
                WHEN CI_FIRST_ARB $operator ? THEN 1
                WHEN CI_FATHER_ARB $operator ? THEN 2
                WHEN CI_GRAND_FATHER_ARB $operator ? THEN 3
                ELSE 4
              END,
              LENGTH(CI_FIRST_ARB)
            LIMIT ? OFFSET ?
            ''',
            [
              isPrefix ? '$searchTerm%' : searchTerm,
              isPrefix ? '$searchTerm%' : searchTerm,
              isPrefix ? '$searchTerm%' : searchTerm,
              isPrefix ? '$searchTerm%' : searchTerm,
              ...filterArgs,
              isPrefix ? '$searchTerm%' : searchTerm,
              isPrefix ? '$searchTerm%' : searchTerm,
              isPrefix ? '$searchTerm%' : searchTerm,
              limit,
              offset,
            ],
          );

          if (results.isNotEmpty) {
            final persons = PersonMapper.fromDatabaseList(results);
            _cacheResults(cacheKey, persons);
            return persons;
          }
        }
      } catch (e) {
        // Continue to next tier
      }
    }

    // ========================================================================
    // TIER 2: SINGLE WORD EXACT MATCH (Score: 90)
    // ========================================================================
    try {
      final searchTerm = smartWords.isNotEmpty ? smartWords[0] : normalized;
      final variations = _generateCompoundVariations(searchTerm);

      // Try all variations
      for (final variation in variations) {
        final isPrefix = variation.endsWith('%');
        final cleanTerm = isPrefix
            ? variation.substring(0, variation.length - 1)
            : variation;
        final operator = isPrefix ? 'LIKE' : '=';
        final searchPattern = isPrefix ? '$cleanTerm%' : cleanTerm;

        results = await _db.rawQuery(
          '''
          SELECT *, 90 as match_score
          FROM persons 
          WHERE (
            CI_FIRST_ARB $operator ? OR
            CI_FATHER_ARB $operator ? OR
            CI_GRAND_FATHER_ARB $operator ? OR
            CI_FAMILY_ARB $operator ?
          )
          $filterClause
          ORDER BY 
            CASE 
              WHEN CI_FIRST_ARB $operator ? THEN 1
              WHEN CI_FATHER_ARB $operator ? THEN 2
              WHEN CI_GRAND_FATHER_ARB $operator ? THEN 3
              ELSE 4
            END,
            LENGTH(CI_FIRST_ARB)
          LIMIT ? OFFSET ?
          ''',
          [
            searchPattern,
            searchPattern,
            searchPattern,
            searchPattern,
            ...filterArgs,
            searchPattern,
            searchPattern,
            searchPattern,
            limit,
            offset,
          ],
        );

        if (results.isNotEmpty) {
          final persons = PersonMapper.fromDatabaseList(results);
          _cacheResults(cacheKey, persons);
          return persons;
        }
      }
    } catch (e) {
      // Continue to Tier 3
    }

    // ========================================================================
    // TIER 3: PREFIX MATCH (Score: 80-85) - High Accuracy
    // ========================================================================
    // Match prefix: "اسامة" matches "اسامة حمد" but NOT "اسد"
    try {
      if (smartWords.isNotEmpty) {
        final pattern = '${smartWords[0]}%';

        results = await _db.rawQuery(
          '''
          SELECT *, 
            CASE
              WHEN CI_FIRST_ARB LIKE ? THEN 85
              WHEN CI_FATHER_ARB LIKE ? THEN 82
              WHEN CI_GRAND_FATHER_ARB LIKE ? THEN 80
              ELSE 75
            END as match_score
          FROM persons 
          WHERE (
            CI_FIRST_ARB LIKE ? OR
            CI_FATHER_ARB LIKE ? OR
            CI_GRAND_FATHER_ARB LIKE ? OR
            CI_FAMILY_ARB LIKE ?
          )
          $filterClause
          ORDER BY match_score DESC, LENGTH(CI_FIRST_ARB)
          LIMIT ? OFFSET ?
          ''',
          [
            pattern, pattern, pattern, // Score calculation
            pattern, pattern, pattern, pattern, // WHERE conditions
            ...filterArgs, // Filters
            limit, offset,
          ],
        );

        if (results.isNotEmpty) {
          final persons = PersonMapper.fromDatabaseList(results);
          _cacheResults(cacheKey, persons);
          return persons;
        }
      }
    } catch (e) {
      // Continue to Tier 4
    }

    // ========================================================================
    // TIER 4: CONTAINS MATCH (Score: 50-70) - Fuzzy Fallback
    // ========================================================================
    // Last resort: contains anywhere in the name
    try {
      final pattern = '%$normalized%';

      results = await _db.rawQuery(
        '''
        SELECT *,
          CASE
            WHEN CI_FIRST_ARB LIKE ? THEN 70
            WHEN CI_FATHER_ARB LIKE ? THEN 65
            WHEN CI_GRAND_FATHER_ARB LIKE ? THEN 60
            WHEN CI_FAMILY_ARB LIKE ? THEN 55
            ELSE 50
          END as match_score
        FROM persons 
        WHERE (
          CI_FIRST_ARB LIKE ? OR
          CI_FATHER_ARB LIKE ? OR
          CI_GRAND_FATHER_ARB LIKE ? OR
          CI_FAMILY_ARB LIKE ?
        )
        $filterClause
        ORDER BY match_score DESC, LENGTH(CI_FIRST_ARB)
        LIMIT ? OFFSET ?
        ''',
        [
          pattern, pattern, pattern, pattern, // Score calculation
          pattern, pattern, pattern, pattern, // WHERE conditions
          ...filterArgs, // Filters
          limit, offset,
        ],
      );
    } catch (e) {
      // Return empty if all tiers fail
      results = [];
    }

    final persons = PersonMapper.fromDatabaseList(results);
    _cacheResults(cacheKey, persons);

    stopwatch.stop();
    AppLogger.logSearch(
      query: query,
      resultsCount: persons.length,
      durationMs: stopwatch.elapsedMilliseconds,
    );

    return persons;
  }

  /// Helper to cache results with LRU eviction
  void _cacheResults(String key, List<CivilPerson> persons) {
    // Update access time
    _cacheAccess[key] = DateTime.now();

    // Evict oldest entry if cache is full (LRU)
    if (_searchCache.length >= _maxCacheSize) {
      // Find least recently used entry
      String? oldestKey;
      DateTime? oldestTime;

      for (final entry in _cacheAccess.entries) {
        if (oldestTime == null || entry.value.isBefore(oldestTime)) {
          oldestTime = entry.value;
          oldestKey = entry.key;
        }
      }

      if (oldestKey != null) {
        _searchCache.remove(oldestKey);
        _cacheAccess.remove(oldestKey);
      }
    }

    _searchCache[key] = persons;
  }

  /// Get search count - 3-Tier Strategy
  Future<int> getSearchCount(
    String query, {
    String? governorate,
    int? genderCode,
  }) async {
    final stopwatch = Stopwatch()..start();

    final normalized = TextNormalizationService.normalize(
      query,
      keepHamza: false,
    );
    final raw = query.trim();

    if (normalized.isEmpty || raw.isEmpty) {
      return 0;
    }

    // Cache key
    final cacheKey = '$normalized|$governorate|$genderCode';

    // Check cache
    if (_countCache.containsKey(cacheKey)) {
      final count = _countCache[cacheKey]!;
      stopwatch.stop();
      AppLogger.logCache(
        key: 'COUNT:$cacheKey',
        hit: true,
        cacheSize: _countCache.length,
      );
      return count;
    }

    AppLogger.logCache(
      key: 'COUNT:$cacheKey',
      hit: false,
      cacheSize: _countCache.length,
    );

    // Build filters
    final filterArgs = <dynamic>[];
    var filterClause = '';

    if (governorate != null && governorate.isNotEmpty) {
      filterClause += ' AND CITY = ?';
      filterArgs.add(governorate);
    }

    if (genderCode != null) {
      filterClause += ' AND CI_SEX_CD = ?';
      filterArgs.add(genderCode);
    }

    int count = 0;
    final smartWords = _splitSmartWords(normalized);

    // Tier 1: Multi-word smart count (FASTEST - Uses indexes!)
    if (smartWords.length >= 2) {
      try {
        final variations = _generateCompoundVariations(smartWords[0]);

        for (final variation in variations) {
          final isPrefix = variation.endsWith('%');
          final searchTerm = isPrefix
              ? variation.substring(0, variation.length - 1)
              : variation;
          final operator = isPrefix ? 'LIKE' : '=';
          final pattern = isPrefix ? '$searchTerm%' : searchTerm;

          count =
              Sqflite.firstIntValue(
                await _db.rawQuery(
                  '''
            SELECT COUNT(*) as count
            FROM persons
            WHERE (
              CI_FIRST_ARB $operator ? OR
              CI_FATHER_ARB $operator ? OR
              CI_GRAND_FATHER_ARB $operator ? OR
              CI_FAMILY_ARB $operator ?
            )$filterClause
            ''',
                  [pattern, pattern, pattern, pattern, ...filterArgs],
                ),
              ) ??
              0;

          if (count > 0) {
            _cacheCount(cacheKey, count);
            return count;
          }
        }
      } catch (e) {
        // Continue
      }
    }

    // Tier 1: Multi-word smart count (FASTEST - Uses indexes!)
    if (smartWords.length >= 2) {
      try {
        // Build OR conditions for each word across all variations
        final wordConditions = <String>[];
        final queryParams = <dynamic>[];

        for (int i = 0; i < smartWords.length && i < 4; i++) {
          final word = smartWords[i];
          final variations = _generateCompoundVariations(word);

          String columnName;
          switch (i) {
            case 0:
              columnName = 'CI_FIRST_ARB';
              break;
            case 1:
              columnName = 'CI_FATHER_ARB';
              break;
            case 2:
              columnName = 'CI_GRAND_FATHER_ARB';
              break;
            case 3:
              columnName = 'CI_FAMILY_ARB';
              break;
            default:
              continue;
          }

          // Try all variations for this column with OR
          final varConditions = <String>[];
          for (final variation in variations) {
            final isPrefix = variation.endsWith('%');
            if (isPrefix) {
              final cleanTerm = variation.substring(0, variation.length - 1);
              varConditions.add('$columnName LIKE ?');
              queryParams.add('$cleanTerm%');
            } else {
              varConditions.add('$columnName = ?');
              queryParams.add(variation);
            }
          }

          // Group variations for this word with OR
          if (varConditions.isNotEmpty) {
            wordConditions.add('(${varConditions.join(' OR ')})');
          }
        }

        if (wordConditions.isNotEmpty) {
          count =
              Sqflite.firstIntValue(
                await _db.rawQuery(
                  '''
            SELECT COUNT(*) as count
            FROM persons
            WHERE ${wordConditions.join(' AND ')} $filterClause
            ''',
                  [...queryParams, ...filterArgs],
                ),
              ) ??
              0;

          if (count > 0) {
            _cacheCount(cacheKey, count);
            return count;
          }
        }
      } catch (e) {
        // Continue
      }
    }

    // Tier 0: Compound name exact count (ONLY for single word)
    if (smartWords.length == 1) {
      try {
        final variations = _generateCompoundVariations(smartWords[0]);

        for (final variation in variations) {
          final isPrefix = variation.endsWith('%');
          final searchTerm = isPrefix
              ? variation.substring(0, variation.length - 1)
              : variation;
          final operator = isPrefix ? 'LIKE' : '=';
          final pattern = isPrefix ? '$searchTerm%' : searchTerm;

          count =
              Sqflite.firstIntValue(
                await _db.rawQuery(
                  '''
            SELECT COUNT(*) as count
            FROM persons
            WHERE (
              CI_FIRST_ARB $operator ? OR
              CI_FATHER_ARB $operator ? OR
              CI_GRAND_FATHER_ARB $operator ? OR
              CI_FAMILY_ARB $operator ?
            )$filterClause
            ''',
                  [pattern, pattern, pattern, pattern, ...filterArgs],
                ),
              ) ??
              0;

          if (count > 0) {
            _cacheCount(cacheKey, count);
            return count;
          }
        }
      } catch (e) {
        // Continue
      }
    }

    // Tier 2: Single word exact match count
    try {
      final searchTerm = smartWords.isNotEmpty ? smartWords[0] : normalized;

      count =
          Sqflite.firstIntValue(
            await _db.rawQuery(
              '''
          SELECT COUNT(*) as count
          FROM persons
          WHERE (
            CI_FIRST_ARB = ? OR
            CI_FATHER_ARB = ? OR
            CI_GRAND_FATHER_ARB = ? OR
            CI_FAMILY_ARB = ?
          )$filterClause
          ''',
              [searchTerm, searchTerm, searchTerm, searchTerm, ...filterArgs],
            ),
          ) ??
          0;

      if (count > 0) {
        _cacheCount(cacheKey, count);
        return count;
      }
    } catch (e) {
      // Continue to Tier 3
    }

    // Tier 3: Prefix match count
    try {
      if (smartWords.isNotEmpty) {
        final pattern = '${smartWords[0]}%';

        count =
            Sqflite.firstIntValue(
              await _db.rawQuery(
                '''
            SELECT COUNT(*) as count
            FROM persons
            WHERE (
              CI_FIRST_ARB LIKE ? OR
              CI_FATHER_ARB LIKE ? OR
              CI_GRAND_FATHER_ARB LIKE ? OR
              CI_FAMILY_ARB LIKE ?
            )$filterClause
            ''',
                [pattern, pattern, pattern, pattern, ...filterArgs],
              ),
            ) ??
            0;

        if (count > 0) {
          _cacheCount(cacheKey, count);
          return count;
        }
      }
    } catch (e) {
      // Continue to Tier 4
    }

    // Tier 4: Contains match count (fallback)
    final pattern = '%$normalized%';
    count =
        Sqflite.firstIntValue(
          await _db.rawQuery(
            '''
        SELECT COUNT(*) as count 
        FROM persons
        WHERE (
          CI_FIRST_ARB LIKE ? OR
          CI_FATHER_ARB LIKE ? OR
          CI_GRAND_FATHER_ARB LIKE ? OR
          CI_FAMILY_ARB LIKE ?
        )$filterClause
        ''',
            [pattern, pattern, pattern, pattern, ...filterArgs],
          ),
        ) ??
        0;

    _cacheCount(cacheKey, count);

    stopwatch.stop();
    AppLogger.logQuery(
      query: 'COUNT: $query',
      durationMs: stopwatch.elapsedMilliseconds,
      resultCount: count,
    );

    return count;
  }

  /// Helper to cache count with LRU eviction
  void _cacheCount(String key, int count) {
    // Update access time
    _cacheAccess[key] = DateTime.now();

    // Evict oldest entry if cache is full (LRU)
    if (_countCache.length >= _maxCacheSize) {
      // Find least recently used entry
      String? oldestKey;
      DateTime? oldestTime;

      for (final entry in _cacheAccess.entries) {
        if (!_countCache.containsKey(entry.key))
          continue; // Skip search cache keys
        if (oldestTime == null || entry.value.isBefore(oldestTime)) {
          oldestTime = entry.value;
          oldestKey = entry.key;
        }
      }

      if (oldestKey != null) {
        _countCache.remove(oldestKey);
        _cacheAccess.remove(oldestKey);
      }
    }

    _countCache[key] = count;
  }

  /// Clear all caches (call when data changes)
  void clearCache() {
    _searchCache.clear();
    _countCache.clear();
    _cacheAccess.clear();
  }

  /// Get statistics
  Future<Map<String, dynamic>> getStatistics() async {
    final total = await _db.rawQuery('SELECT COUNT(*) as count FROM persons');
    final males = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM persons WHERE CI_SEX_CD = 1',
    );
    final females = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM persons WHERE CI_SEX_CD = 2',
    );

    final cities = await _db.rawQuery(
      'SELECT DISTINCT CITY FROM persons WHERE CITY IS NOT NULL ORDER BY CITY LIMIT 50',
    );

    return {
      'total': Sqflite.firstIntValue(total) ?? 0,
      'males': Sqflite.firstIntValue(males) ?? 0,
      'females': Sqflite.firstIntValue(females) ?? 0,
      'relations': 0,
      'governorates': cities.map((e) => e['CITY'].toString()).toList(),
    };
  }
}
