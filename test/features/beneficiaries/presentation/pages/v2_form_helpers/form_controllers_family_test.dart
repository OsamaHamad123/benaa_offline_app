import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_controllers.dart';

void main() {
  late BeneficiaryFormControllers formControllers;

  setUp(() {
    formControllers = BeneficiaryFormControllers();
  });

  tearDown(() {
    formControllers.dispose();
  });

  group('BeneficiaryFormControllers - Family Members', () {
    test('should initialize with empty lists', () {
      expect(formControllers.deceasedMembers, isEmpty);
      expect(formControllers.livingMembers, isEmpty);
    });

    test('should add deceased father', () {
      formControllers.deceasedMembers.add({
        'deceasedType': 1,
        'firstName': 'أحمد',
        'familyName': 'محمد',
        'nationalId': 123456789,
      });

      expect(formControllers.deceasedMembers.length, 1);
      expect(formControllers.deceasedMembers.first['deceasedType'], 1);
    });

    test('should add deceased mother', () {
      formControllers.deceasedMembers.add({
        'deceasedType': 2,
        'firstName': 'فاطمة',
        'familyName': 'علي',
        'nationalId': 987654321,
      });

      expect(formControllers.deceasedMembers.length, 1);
      expect(formControllers.deceasedMembers.first['deceasedType'], 2);
    });

    test('should support both parents deceased', () {
      formControllers.deceasedMembers.add({
        'deceasedType': 1,
        'firstName': 'أحمد',
        'familyName': 'محمد',
        'nationalId': 123456789,
      });

      formControllers.deceasedMembers.add({
        'deceasedType': 2,
        'firstName': 'فاطمة',
        'familyName': 'علي',
        'nationalId': 987654321,
      });

      expect(formControllers.deceasedMembers.length, 2);

      final father = formControllers.deceasedMembers
          .where((d) => d['deceasedType'] == 1)
          .firstOrNull;
      final mother = formControllers.deceasedMembers
          .where((d) => d['deceasedType'] == 2)
          .firstOrNull;

      expect(father, isNotNull);
      expect(mother, isNotNull);
      expect(father!['firstName'], 'أحمد');
      expect(mother!['firstName'], 'فاطمة');
    });

    test('should add orphan', () {
      formControllers.livingMembers.add({
        'firstName': 'محمد',
        'familyName': 'أحمد',
        'age': 10,
        'gender': 1,
        'orphanNationalId': 111222333,
      });

      expect(formControllers.livingMembers.length, 1);
      expect(formControllers.livingMembers.first['firstName'], 'محمد');
    });

    test('should add multiple orphans', () {
      formControllers.livingMembers.add({
        'firstName': 'محمد',
        'familyName': 'أحمد',
        'age': 10,
        'gender': 1,
      });

      formControllers.livingMembers.add({
        'firstName': 'فاطمة',
        'familyName': 'أحمد',
        'age': 8,
        'gender': 2,
      });

      formControllers.livingMembers.add({
        'firstName': 'علي',
        'familyName': 'أحمد',
        'age': 6,
        'gender': 1,
      });

      expect(formControllers.livingMembers.length, 3);
    });

    test('should remove deceased member', () {
      formControllers.deceasedMembers.add({
        'deceasedType': 1,
        'firstName': 'أحمد',
        'familyName': 'محمد',
      });

      expect(formControllers.deceasedMembers.length, 1);

      formControllers.deceasedMembers.removeAt(0);

      expect(formControllers.deceasedMembers, isEmpty);
    });

    test('should remove orphan', () {
      formControllers.livingMembers.add({
        'firstName': 'محمد',
        'familyName': 'أحمد',
        'age': 10,
      });

      expect(formControllers.livingMembers.length, 1);

      formControllers.livingMembers.removeAt(0);

      expect(formControllers.livingMembers, isEmpty);
    });

    test('should filter father from deceased members', () {
      formControllers.deceasedMembers.add({
        'deceasedType': 1,
        'firstName': 'أحمد',
        'familyName': 'محمد',
      });

      formControllers.deceasedMembers.add({
        'deceasedType': 2,
        'firstName': 'فاطمة',
        'familyName': 'علي',
      });

      final father = formControllers.deceasedMembers
          .where((d) => d['deceasedType'] == 1)
          .firstOrNull;

      expect(father, isNotNull);
      expect(father!['firstName'], 'أحمد');
    });

    test('should filter mother from deceased members', () {
      formControllers.deceasedMembers.add({
        'deceasedType': 1,
        'firstName': 'أحمد',
        'familyName': 'محمد',
      });

      formControllers.deceasedMembers.add({
        'deceasedType': 2,
        'firstName': 'فاطمة',
        'familyName': 'علي',
      });

      final mother = formControllers.deceasedMembers
          .where((d) => d['deceasedType'] == 2)
          .firstOrNull;

      expect(mother, isNotNull);
      expect(mother!['firstName'], 'فاطمة');
    });

    test('should handle male orphan gender correctly', () {
      formControllers.livingMembers.add({'firstName': 'محمد', 'gender': 1});

      final orphan = formControllers.livingMembers.first;
      expect(orphan['gender'], 1);
    });

    test('should handle female orphan gender correctly', () {
      formControllers.livingMembers.add({'firstName': 'فاطمة', 'gender': 2});

      final orphan = formControllers.livingMembers.first;
      expect(orphan['gender'], 2);
    });

    test('should preserve data when updating orphan', () {
      formControllers.livingMembers.add({'firstName': 'محمد', 'age': 10});

      formControllers.livingMembers[0]['age'] = 11;

      expect(formControllers.livingMembers.first['age'], 11);
    });

    test('should clear all family members', () {
      formControllers.deceasedMembers.add({'deceasedType': 1});
      formControllers.deceasedMembers.add({'deceasedType': 2});
      formControllers.livingMembers.add({'firstName': 'محمد'});
      formControllers.livingMembers.add({'firstName': 'فاطمة'});

      formControllers.deceasedMembers.clear();
      formControllers.livingMembers.clear();

      expect(formControllers.deceasedMembers, isEmpty);
      expect(formControllers.livingMembers, isEmpty);
    });

    test('should handle national ID as integer', () {
      formControllers.deceasedMembers.add({
        'deceasedType': 1,
        'nationalId': 123456789,
      });

      final nationalId = formControllers.deceasedMembers.first['nationalId'];
      expect(nationalId, isA<int>());
      expect(nationalId, 123456789);
    });

    test('should handle orphan national ID as integer', () {
      formControllers.livingMembers.add({
        'firstName': 'محمد',
        'orphanNationalId': 987654321,
      });

      final orphanId = formControllers.livingMembers.first['orphanNationalId'];
      expect(orphanId, isA<int>());
      expect(orphanId, 987654321);
    });
  });

  group('Edge Cases', () {
    test('should handle null values gracefully', () {
      formControllers.deceasedMembers.add({
        'deceasedType': 1,
        'firstName': null,
        'familyName': null,
      });

      expect(formControllers.deceasedMembers.length, 1);
      expect(formControllers.deceasedMembers.first['firstName'], isNull);
    });

    test('should handle empty strings', () {
      formControllers.livingMembers.add({'firstName': '', 'familyName': ''});

      expect(formControllers.livingMembers.length, 1);
      expect(formControllers.livingMembers.first['firstName'], '');
    });

    test('should handle large numbers of orphans', () {
      for (int i = 0; i < 100; i++) {
        formControllers.livingMembers.add({'firstName': 'Name$i', 'age': i});
      }

      expect(formControllers.livingMembers.length, 100);
    });
  });
}
