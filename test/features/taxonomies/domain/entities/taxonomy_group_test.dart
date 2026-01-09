import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/taxonomies/domain/entities/taxonomy_group.dart';

void main() {
  group('TaxonomyGroup Enum', () {
    test('should have 15 taxonomy groups', () {
      expect(TaxonomyGroup.values.length, 15);
    });

    test('governorate should have correct values', () {
      expect(TaxonomyGroup.governorate.value, 'governorate');
      expect(TaxonomyGroup.governorate.arabicName, 'المحافظات');
      expect(TaxonomyGroup.governorate.prefix, 'gov');
    });

    test('category should have correct values', () {
      expect(TaxonomyGroup.category.value, 'category');
      expect(TaxonomyGroup.category.arabicName, 'الفئات');
      expect(TaxonomyGroup.category.prefix, 'cat');
    });

    test('maritalStatus should have correct values', () {
      expect(TaxonomyGroup.maritalStatus.value, 'marital_status');
      expect(TaxonomyGroup.maritalStatus.arabicName, 'الحالة الاجتماعية');
      expect(TaxonomyGroup.maritalStatus.prefix, 'mar');
    });

    test('gender should have correct values', () {
      expect(TaxonomyGroup.gender.value, 'gender');
      expect(TaxonomyGroup.gender.arabicName, 'الجنس');
      expect(TaxonomyGroup.gender.prefix, 'gen');
    });
  });

  group('TaxonomyGroup.fromString', () {
    test('should return correct group for valid string', () {
      expect(TaxonomyGroup.fromString('governorate'), TaxonomyGroup.governorate);
      expect(TaxonomyGroup.fromString('category'), TaxonomyGroup.category);
      expect(TaxonomyGroup.fromString('marital_status'), TaxonomyGroup.maritalStatus);
      expect(TaxonomyGroup.fromString('gender'), TaxonomyGroup.gender);
      expect(TaxonomyGroup.fromString('education_level'), TaxonomyGroup.educationLevel);
    });

    test('should return null for null input', () {
      expect(TaxonomyGroup.fromString(null), null);
    });

    test('should return category as default for invalid string', () {
      expect(TaxonomyGroup.fromString('invalid_group'), TaxonomyGroup.category);
    });
  });

  group('TaxonomyGroup.isValidGroup', () {
    test('should return true for valid group strings', () {
      expect(TaxonomyGroup.isValidGroup('governorate'), true);
      expect(TaxonomyGroup.isValidGroup('category'), true);
      expect(TaxonomyGroup.isValidGroup('marital_status'), true);
      expect(TaxonomyGroup.isValidGroup('health_status'), true);
    });

    test('should return false for invalid group strings', () {
      expect(TaxonomyGroup.isValidGroup('invalid'), false);
      expect(TaxonomyGroup.isValidGroup(''), false);
      expect(TaxonomyGroup.isValidGroup('GOVERNORATE'), false); // case sensitive
    });
  });

  group('TaxonomyGroup toString', () {
    test('should return the value string', () {
      expect(TaxonomyGroup.governorate.toString(), 'governorate');
      expect(TaxonomyGroup.maritalStatus.toString(), 'marital_status');
    });
  });

  group('TaxonomyGroupExtension', () {
    test('isRequired should return true for essential groups', () {
      expect(TaxonomyGroup.governorate.isRequired, true);
      expect(TaxonomyGroup.category.isRequired, true);
      expect(TaxonomyGroup.gender.isRequired, true);
    });

    test('isRequired should return false for optional groups', () {
      expect(TaxonomyGroup.maritalStatus.isRequired, false);
      expect(TaxonomyGroup.educationLevel.isRequired, false);
      expect(TaxonomyGroup.healthStatus.isRequired, false);
    });

    test('isEditable should return false for gender', () {
      expect(TaxonomyGroup.gender.isEditable, false);
    });

    test('isEditable should return true for other groups', () {
      expect(TaxonomyGroup.governorate.isEditable, true);
      expect(TaxonomyGroup.category.isEditable, true);
      expect(TaxonomyGroup.maritalStatus.isEditable, true);
    });

    test('iconName should return correct icons', () {
      expect(TaxonomyGroup.governorate.iconName, 'location_city');
      expect(TaxonomyGroup.category.iconName, 'category');
      expect(TaxonomyGroup.gender.iconName, 'wc');
    });
  });

  group('All TaxonomyGroup values coverage', () {
    test('should include all expected groups', () {
      final expectedGroups = [
        'governorate',
        'category',
        'marital_status',
        'education_level',
        'health_status',
        'housing_type',
        'housing_status',
        'disability_type',
        'income_source',
        'association_type',
        'sponsorship_type',
        'gender',
        'visit_type',
        'assistance_type',
        'beneficiary_status',
      ];

      for (final groupValue in expectedGroups) {
        expect(
          TaxonomyGroup.values.any((g) => g.value == groupValue),
          true,
          reason: '$groupValue should exist in TaxonomyGroup',
        );
      }
    });

    test('each group should have unique value', () {
      final values = TaxonomyGroup.values.map((g) => g.value).toList();
      expect(values.length, values.toSet().length);
    });

    test('each group should have unique prefix', () {
      final prefixes = TaxonomyGroup.values.map((g) => g.prefix).toList();
      expect(prefixes.length, prefixes.toSet().length);
    });
  });
}
