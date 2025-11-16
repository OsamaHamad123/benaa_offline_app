import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/core/constants/search_constants.dart';

/// 🧪 Search Constants Tests
///
/// Validates all search configuration constants
void main() {
  group('SearchConstants -', () {
    group('Word Processing', () {
      test('minWordLength should be 2', () {
        expect(SearchConstants.minWordLength, 2);
      });

      test('minMultiWordCount should be 2', () {
        expect(SearchConstants.minMultiWordCount, 2);
      });

      test('maxNameParts should be 4', () {
        expect(SearchConstants.maxNameParts, 4);
      });
    });

    group('Compound Names', () {
      test('compoundPrefixes should contain common Arabic prefixes', () {
        expect(SearchConstants.compoundPrefixes, contains('عبد'));
        expect(SearchConstants.compoundPrefixes, contains('ابو'));
        expect(SearchConstants.compoundPrefixes, contains('ام'));
        expect(SearchConstants.compoundPrefixes, contains('بن'));
        expect(SearchConstants.compoundPrefixes, contains('بنت'));
        expect(SearchConstants.compoundPrefixes, contains('ال'));
      });

      test('compoundPrefixes should have 6 elements', () {
        expect(SearchConstants.compoundPrefixes.length, 6);
      });
    });

    group('Caching', () {
      test('maxCacheSize should be 50', () {
        expect(SearchConstants.maxCacheSize, 50);
      });

      test('cacheExpiration should be 30 minutes', () {
        expect(SearchConstants.cacheExpiration, const Duration(minutes: 30));
      });
    });

    group('Pagination', () {
      test('defaultPageSize should be 6 (zero lag!)', () {
        expect(SearchConstants.defaultPageSize, 6);
      });

      test('defaultPageSizeMobile should be 5', () {
        expect(SearchConstants.defaultPageSizeMobile, 5);
      });

      test('defaultPageSizeDesktop should be 10', () {
        expect(SearchConstants.defaultPageSizeDesktop, 10);
      });

      test('maxPageSize should be 100', () {
        expect(SearchConstants.maxPageSize, 100);
      });

      test('maxPageSize should be greater than all page sizes', () {
        expect(
          SearchConstants.maxPageSize,
          greaterThan(SearchConstants.defaultPageSize),
        );
        expect(
          SearchConstants.maxPageSize,
          greaterThan(SearchConstants.defaultPageSizeMobile),
        );
        expect(
          SearchConstants.maxPageSize,
          greaterThan(SearchConstants.defaultPageSizeDesktop),
        );
      });
    });

    group('Debouncing', () {
      test('debounceDuration should be 400ms', () {
        expect(
          SearchConstants.debounceDuration,
          const Duration(milliseconds: 400),
        );
      });
    });

    group('Search Scoring', () {
      test('multiWordScore should be highest', () {
        expect(SearchConstants.multiWordScore, 95);
      });

      test('compoundNameScore should be 100', () {
        expect(SearchConstants.compoundNameScore, 100);
      });

      test('exactMatchScore should be 90', () {
        expect(SearchConstants.exactMatchScore, 90);
      });

      test('prefixMatchScore should be 85', () {
        expect(SearchConstants.prefixMatchScore, 85);
      });

      test('containsMatchScore should be 70', () {
        expect(SearchConstants.containsMatchScore, 70);
      });

      test('scores should be in descending order of priority', () {
        expect(
          SearchConstants.compoundNameScore,
          greaterThanOrEqualTo(SearchConstants.multiWordScore),
        );
        expect(
          SearchConstants.multiWordScore,
          greaterThan(SearchConstants.exactMatchScore),
        );
        expect(
          SearchConstants.exactMatchScore,
          greaterThan(SearchConstants.prefixMatchScore),
        );
        expect(
          SearchConstants.prefixMatchScore,
          greaterThan(SearchConstants.containsMatchScore),
        );
      });
    });

    group('National ID', () {
      test('minNationalIdLength should be 8', () {
        expect(SearchConstants.minNationalIdLength, 8);
      });

      test('maxNationalIdLength should be 15', () {
        expect(SearchConstants.maxNationalIdLength, 15);
      });

      test(
        'maxNationalIdLength should be greater than minNationalIdLength',
        () {
          expect(
            SearchConstants.maxNationalIdLength,
            greaterThan(SearchConstants.minNationalIdLength),
          );
        },
      );
    });

    group('Query Patterns', () {
      test('prefixWildcard should be %', () {
        expect(SearchConstants.prefixWildcard, '%');
      });

      test('infixPattern should wrap term with %', () {
        expect(SearchConstants.infixPattern('test'), '%test%');
        expect(SearchConstants.infixPattern('محمد'), '%محمد%');
      });

      test('prefixPattern should append % to term', () {
        expect(SearchConstants.prefixPattern('test'), 'test%');
        expect(SearchConstants.prefixPattern('عبد'), 'عبد%');
      });

      test('infixPattern should handle empty string', () {
        expect(SearchConstants.infixPattern(''), '%%');
      });

      test('prefixPattern should handle empty string', () {
        expect(SearchConstants.prefixPattern(''), '%');
      });
    });
  });
}
