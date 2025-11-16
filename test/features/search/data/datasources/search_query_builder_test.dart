import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/search/data/datasources/search_query_builder.dart';
import 'package:benaa_offline_app/core/constants/search_constants.dart';

/// 🧪 Search Query Builder Tests
///
/// Tests for reusable query building helpers
void main() {
  group('SearchQueryBuilder -', () {
    group('generateCompoundVariations()', () {
      test('should generate 3 variations for compound name with space', () {
        final variations = SearchQueryBuilder.generateCompoundVariations(
          'عبد الرحمن',
        );

        expect(variations.length, 3);
        expect(variations[0], 'عبد الرحمن'); // Original
        expect(variations[1], 'عبدالرحمن'); // No space
        expect(variations[2], 'عبد%'); // Prefix only
      });

      test('should generate 2 variations for compound prefix alone', () {
        final variations = SearchQueryBuilder.generateCompoundVariations('عبد');

        expect(variations.length, 2);
        expect(variations[0], 'عبد'); // Exact
        expect(variations[1], 'عبد%'); // Prefix
      });

      test('should generate 1 variation for regular word', () {
        final variations = SearchQueryBuilder.generateCompoundVariations(
          'محمد',
        );

        expect(variations.length, 1);
        expect(variations[0], 'محمد');
      });

      test('should handle ابو with next word', () {
        final variations = SearchQueryBuilder.generateCompoundVariations(
          'ابو بكر',
        );

        expect(variations.length, 3);
        expect(variations[0], 'ابو بكر');
        expect(variations[1], 'ابوبكر');
        expect(variations[2], 'ابو%');
      });

      test('should maintain priority order', () {
        final variations = SearchQueryBuilder.generateCompoundVariations(
          'عبد الله',
        );

        // Priority 1: Full name with space
        expect(variations.first, 'عبد الله');
        // Priority 2: No space
        expect(variations[1], 'عبدالله');
        // Priority 3: Prefix only
        expect(variations.last, 'عبد%');
      });
    });

    group('splitSmartWords()', () {
      test('should keep compound name together', () {
        final result = SearchQueryBuilder.splitSmartWords('عبد الرحمن');

        expect(result.length, 1);
        expect(result[0], 'عبد الرحمن');
      });

      test('should split compound + regular name', () {
        final result = SearchQueryBuilder.splitSmartWords('عبد الرحمن محمد');

        expect(result.length, 2);
        expect(result[0], 'عبد الرحمن');
        expect(result[1], 'محمد');
      });

      test('should handle multiple compound names', () {
        final result = SearchQueryBuilder.splitSmartWords('ابو بكر الصديق');

        expect(result.length, 2);
        expect(result[0], 'ابو بكر');
        expect(result[1], 'الصديق');
      });

      test('should ignore single character words', () {
        final result = SearchQueryBuilder.splitSmartWords('محمد ا احمد');

        expect(result.length, 2);
        expect(result[0], 'محمد');
        expect(result[1], 'احمد');
      });

      test('should handle 4 name parts', () {
        final result = SearchQueryBuilder.splitSmartWords('محمد احمد علي حسن');

        expect(result.length, 4);
        expect(result[0], 'محمد');
        expect(result[1], 'احمد');
        expect(result[2], 'علي');
        expect(result[3], 'حسن');
      });

      test('should handle mixed compound and regular names', () {
        final result = SearchQueryBuilder.splitSmartWords('محمد عبد الله احمد');

        expect(result.length, 3);
        expect(result[0], 'محمد');
        expect(result[1], 'عبد الله');
        expect(result[2], 'احمد');
      });
    });

    group('buildWordConditions()', () {
      test('should build conditions for compound name', () {
        final result = SearchQueryBuilder.buildWordConditions(
          word: 'عبد الرحمن',
          columnName: 'CI_FIRST_ARB',
        );

        expect(result.conditions.length, 3);
        expect(result.parameters.length, 3);

        // Variation 1: Exact match
        expect(result.conditions[0], 'CI_FIRST_ARB = ?');
        expect(result.parameters[0], 'عبد الرحمن');

        // Variation 2: No space
        expect(result.conditions[1], 'CI_FIRST_ARB = ?');
        expect(result.parameters[1], 'عبدالرحمن');

        // Variation 3: Prefix
        expect(result.conditions[2], 'CI_FIRST_ARB LIKE ?');
        expect(result.parameters[2], 'عبد%');
      });

      test('should build conditions for regular word', () {
        final result = SearchQueryBuilder.buildWordConditions(
          word: 'محمد',
          columnName: 'CI_FIRST_ARB',
        );

        expect(result.conditions.length, 1);
        expect(result.conditions[0], 'CI_FIRST_ARB = ?');
        expect(result.parameters[0], 'محمد');
      });
    });

    group('buildMultiWordWhere()', () {
      test('should build WHERE clause for 2 words', () {
        final smartWords = ['محمد', 'احمد'];
        final result = SearchQueryBuilder.buildMultiWordWhere(
          smartWords: smartWords,
        );

        expect(result.whereClause, isNotEmpty);
        expect(result.params, isNotEmpty);

        // Should have AND between words
        expect(result.whereClause.contains(' AND '), true);

        // Should match first and second columns
        expect(result.whereClause.contains('CI_FIRST_ARB'), true);
        expect(result.whereClause.contains('CI_FATHER_ARB'), true);
      });

      test('should handle compound name in multi-word', () {
        final smartWords = ['عبد الرحمن', 'محمد'];
        final result = SearchQueryBuilder.buildMultiWordWhere(
          smartWords: smartWords,
        );

        // Should have variations for compound name
        expect(result.whereClause.contains('OR'), true);
        expect(result.whereClause.contains('AND'), true);

        // Should have parameters for all variations
        expect(result.params.length, greaterThan(2));
      });

      test('should limit to 4 words maximum', () {
        final smartWords = ['محمد', 'احمد', 'علي', 'حسن', 'extra'];
        final result = SearchQueryBuilder.buildMultiWordWhere(
          smartWords: smartWords,
        );

        // Should only process 4 words (maxNameParts)
        expect(result.whereClause.contains('CI_FIRST_ARB'), true);
        expect(result.whereClause.contains('CI_FATHER_ARB'), true);
        expect(result.whereClause.contains('CI_GRAND_FATHER_ARB'), true);
        expect(result.whereClause.contains('CI_FAMILY_ARB'), true);

        // Count AND occurrences (should be 3 for 4 words)
        final andCount = ' AND '.allMatches(result.whereClause).length;
        expect(andCount, 3);
      });
    });

    group('buildSingleWordWhere()', () {
      test('should build WHERE clause searching all columns', () {
        final result = SearchQueryBuilder.buildSingleWordWhere(word: 'محمد');

        expect(result.whereClause, isNotEmpty);

        // Should search in all 4 name columns
        expect(result.whereClause.contains('CI_FIRST_ARB'), true);
        expect(result.whereClause.contains('CI_FATHER_ARB'), true);
        expect(result.whereClause.contains('CI_GRAND_FATHER_ARB'), true);
        expect(result.whereClause.contains('CI_FAMILY_ARB'), true);

        // Should use OR between columns
        expect(result.whereClause.contains(' OR '), true);
      });

      test('should handle compound name variations', () {
        final result = SearchQueryBuilder.buildSingleWordWhere(
          word: 'عبد الرحمن',
        );

        // Should have multiple variations
        expect(result.params.length, greaterThan(4));

        // Should check for exact and prefix matches
        expect(result.params.contains('عبد الرحمن'), true);
        expect(result.params.contains('عبدالرحمن'), true);
        expect(result.params.any((p) => p.toString().startsWith('عبد%')), true);
      });
    });

    group('buildFilters()', () {
      test('should return empty clause when no filters', () {
        final result = SearchQueryBuilder.buildFilters();

        expect(result.clause, isEmpty);
        expect(result.args, isEmpty);
      });

      test('should build governorate filter', () {
        final result = SearchQueryBuilder.buildFilters(governorate: 'دمشق');

        expect(result.clause, ' AND CITY = ?');
        expect(result.args, ['دمشق']);
      });

      test('should build gender filter', () {
        final result = SearchQueryBuilder.buildFilters(genderCode: 1);

        expect(result.clause, ' AND CI_SEX_CD = ?');
        expect(result.args, [1]);
      });

      test('should build combined filters', () {
        final result = SearchQueryBuilder.buildFilters(
          governorate: 'دمشق',
          genderCode: 1,
        );

        expect(result.clause.contains('CITY'), true);
        expect(result.clause.contains('CI_SEX_CD'), true);
        expect(result.args, ['دمشق', 1]);
      });

      test('should ignore empty governorate', () {
        final result = SearchQueryBuilder.buildFilters(governorate: '');

        expect(result.clause, isEmpty);
        expect(result.args, isEmpty);
      });
    });

    group('Utility Methods', () {
      test('extractCount should get first integer value', () {
        final results = [
          {'count': 42},
        ];
        final count = SearchQueryBuilder.extractCount(results);
        expect(count, 42);
      });

      test('extractCount should return 0 for empty results', () {
        final count = SearchQueryBuilder.extractCount([]);
        expect(count, 0);
      });

      test('isPrefixPattern should detect % suffix', () {
        expect(SearchQueryBuilder.isPrefixPattern('عبد%'), true);
        expect(SearchQueryBuilder.isPrefixPattern('عبد'), false);
      });

      test('cleanPrefixPattern should remove % suffix', () {
        expect(SearchQueryBuilder.cleanPrefixPattern('عبد%'), 'عبد');
        expect(SearchQueryBuilder.cleanPrefixPattern('عبد'), 'عبد');
      });
    });
  });
}
