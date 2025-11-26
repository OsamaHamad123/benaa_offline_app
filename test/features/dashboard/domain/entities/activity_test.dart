import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/dashboard/domain/entities/activity.dart';

void main() {
  group('Activity Entity', () {
    final tActivity = Activity(
      id: '1',
      type: 'beneficiary',
      description: 'تم إضافة مستفيد جديد',
      timestamp: DateTime(2024, 1, 1, 10, 30),
      beneficiaryId: 'ben_123',
      beneficiaryName: 'محمد أحمد',
      metadata: {'field1': 'value1', 'field2': 'value2'},
    );

    test('should be a valid Activity instance', () {
      // assert
      expect(tActivity.id, '1');
      expect(tActivity.type, 'beneficiary');
      expect(tActivity.description, 'تم إضافة مستفيد جديد');
      expect(tActivity.timestamp, DateTime(2024, 1, 1, 10, 30));
      expect(tActivity.beneficiaryId, 'ben_123');
      expect(tActivity.beneficiaryName, 'محمد أحمد');
      expect(tActivity.metadata, isNotNull);
      expect(tActivity.metadata!['field1'], 'value1');
    });

    test('should support equatable comparison', () {
      // arrange
      final activity1 = Activity(
        id: '1',
        type: 'beneficiary',
        description: 'تم إضافة مستفيد',
        timestamp: DateTime(2024, 1, 1),
      );

      final activity2 = Activity(
        id: '1',
        type: 'beneficiary',
        description: 'تم إضافة مستفيد',
        timestamp: DateTime(2024, 1, 1),
      );

      final activity3 = Activity(
        id: '2',
        type: 'visit',
        description: 'تم تسجيل زيارة',
        timestamp: DateTime(2024, 1, 2),
      );

      // assert
      expect(activity1, equals(activity2));
      expect(activity1, isNot(equals(activity3)));
    });

    test('should create activity without optional fields', () {
      // arrange
      final minimalActivity = Activity(
        id: '1',
        type: 'sync',
        description: 'تم المزامنة',
        timestamp: DateTime(2024, 1, 1),
      );

      // assert
      expect(minimalActivity.id, '1');
      expect(minimalActivity.type, 'sync');
      expect(minimalActivity.beneficiaryId, isNull);
      expect(minimalActivity.beneficiaryName, isNull);
      expect(minimalActivity.metadata, isNull);
    });

    test('should contain all fields in props for equatable', () {
      // arrange
      final activity1 = Activity(
        id: '1',
        type: 'beneficiary',
        description: 'تم إضافة مستفيد',
        timestamp: DateTime(2024, 1, 1),
        beneficiaryId: 'ben_123',
        beneficiaryName: 'محمد',
        metadata: {'key': 'value'},
      );

      final activity2 = Activity(
        id: '1',
        type: 'beneficiary',
        description: 'تم إضافة مستفيد',
        timestamp: DateTime(2024, 1, 1),
        beneficiaryId: 'ben_123',
        beneficiaryName: 'أحمد', // Different name
        metadata: {'key': 'value'},
      );

      // assert - should be different because beneficiaryName differs
      expect(activity1, isNot(equals(activity2)));
    });
  });
}
