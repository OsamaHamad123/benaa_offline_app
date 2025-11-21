import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/search/presentation/widgets/advanced_search_filters.dart';

void main() {
  group('SavedSearchItem', () {
    test('should create saved search item correctly', () {
      final now = DateTime.now();
      final filters = {
        'governorates': ['دمشق', 'حلب'],
        'statuses': ['نشط'],
        'categories': ['عائلات'],
      };

      final item = SavedSearchItem(
        id: '1',
        name: 'بحث مستفيدين دمشق',
        filters: filters,
        createdAt: now,
      );

      expect(item.id, '1');
      expect(item.name, 'بحث مستفيدين دمشق');
      expect(item.filters['governorates'], ['دمشق', 'حلب']);
      expect(item.createdAt, now);
    });

    test('toJson should convert to map correctly', () {
      final now = DateTime(2024, 1, 1, 12, 0);
      final filters = {
        'governorates': ['دمشق'],
        'statuses': ['نشط'],
      };

      final item = SavedSearchItem(
        id: '1',
        name: 'بحث مخصص',
        filters: filters,
        createdAt: now,
      );

      final json = item.toJson();

      expect(json['id'], '1');
      expect(json['name'], 'بحث مخصص');
      expect(json['filters'], filters);
      expect(json['createdAt'], now.toIso8601String());
    });

    test('fromJson should parse correctly', () {
      final json = {
        'id': '1',
        'name': 'بحث مخصص',
        'filters': {
          'governorates': ['دمشق', 'حلب'],
          'statuses': ['نشط'],
        },
        'createdAt': '2024-01-01T12:00:00.000Z',
      };

      final item = SavedSearchItem.fromJson(json);

      expect(item.id, '1');
      expect(item.name, 'بحث مخصص');
      expect(item.filters['governorates'], ['دمشق', 'حلب']);
      expect(item.createdAt, DateTime.parse('2024-01-01T12:00:00.000Z'));
    });

    test('should handle round-trip conversion', () {
      final original = SavedSearchItem(
        id: '123',
        name: 'بحث متقدم',
        filters: {
          'governorates': ['دمشق', 'حلب', 'حمص'],
          'statuses': ['نشط', 'معلق'],
          'categories': ['عائلات', 'أطفال'],
          'ageRange': '18-30',
          'gender': 'male',
        },
        createdAt: DateTime(2024, 6, 15, 10, 30),
      );

      final json = original.toJson();
      final restored = SavedSearchItem.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(
        restored.filters['governorates'],
        original.filters['governorates'],
      );
      expect(restored.filters['ageRange'], original.filters['ageRange']);
      expect(restored.createdAt, original.createdAt);
    });

    test('should handle empty filters', () {
      final item = SavedSearchItem(
        id: '1',
        name: 'بحث فارغ',
        filters: {},
        createdAt: DateTime.now(),
      );

      expect(item.filters, isEmpty);

      final json = item.toJson();
      final restored = SavedSearchItem.fromJson(json);
      expect(restored.filters, isEmpty);
    });

    test('should handle complex filter combinations', () {
      final complexFilters = {
        'governorates': ['دمشق', 'ريف دمشق', 'حلب', 'حمص'],
        'statuses': ['نشط', 'معلق', 'قيد المراجعة'],
        'categories': ['عائلات', 'أطفال', 'مسنين', 'ذوي احتياجات خاصة'],
        'ageRange': '31-50',
        'gender': 'female',
      };

      final item = SavedSearchItem(
        id: 'complex-1',
        name: 'بحث معقد متعدد الفلاتر',
        filters: complexFilters,
        createdAt: DateTime.now(),
      );

      expect(item.filters['governorates'], hasLength(4));
      expect(item.filters['statuses'], hasLength(3));
      expect(item.filters['categories'], hasLength(4));
      expect(item.filters['ageRange'], '31-50');
      expect(item.filters['gender'], 'female');
    });

    test('should preserve Arabic text correctly', () {
      final item = SavedSearchItem(
        id: '1',
        name: 'بحث المستفيدين النشطين في محافظة دمشق',
        filters: {
          'governorates': ['دمشق'],
          'statuses': ['نشط'],
          'categories': ['عائلات', 'أطفال'],
        },
        createdAt: DateTime.now(),
      );

      expect(item.name, contains('المستفيدين'));
      expect(item.name, contains('دمشق'));
      expect(item.filters['governorates']![0], 'دمشق');
      expect(item.filters['statuses']![0], 'نشط');
    });

    test('should handle date parsing edge cases', () {
      final json = <String, dynamic>{
        'id': '1',
        'name': 'Test',
        'filters': <String, dynamic>{},
        'createdAt': '2024-12-31T23:59:59.999Z',
      };

      final item = SavedSearchItem.fromJson(json);
      expect(item.createdAt.year, 2024);
      expect(item.createdAt.month, 12);
      expect(item.createdAt.day, 31);
    });
  });
}
