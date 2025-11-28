import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/dashboard/domain/entities/activity.dart' as domain;
import 'package:benaa_offline_app/features/dashboard/data/datasources/activity_local_datasource.dart';
import 'package:benaa_offline_app/features/dashboard/data/repositories/activity_repository_impl.dart';

class MockActivityLocalDataSource implements ActivityLocalDataSource {
  final List<domain.Activity> activities = [];
  bool shouldThrowError = false;

  @override
  Future<List<domain.Activity>> getAllActivities() async {
    if (shouldThrowError) throw Exception('Database error');
    return List.from(activities);
  }

  @override
  Future<List<domain.Activity>> getActivitiesByType(String type) async {
    if (shouldThrowError) throw Exception('Database error');
    return activities.where((a) => a.type == type).toList();
  }

  @override
  Future<List<domain.Activity>> getActivitiesForBeneficiary(
    String beneficiaryId,
  ) async {
    if (shouldThrowError) throw Exception('Database error');
    return activities.where((a) => a.beneficiaryId == beneficiaryId).toList();
  }

  @override
  Future<void> logActivity(domain.Activity activity) async {
    if (shouldThrowError) throw Exception('Database error');
    activities.add(activity);
  }

  @override
  Future<void> deleteActivity(String activityId) async {
    if (shouldThrowError) throw Exception('Database error');
    activities.removeWhere((a) => a.id == activityId);
  }

  @override
  Future<void> clearAllActivities() async {
    if (shouldThrowError) throw Exception('Database error');
    activities.clear();
  }

  @override
  Future<int> getActivitiesCount() async {
    if (shouldThrowError) throw Exception('Database error');
    return activities.length;
  }
}

void main() {
  late ActivityRepositoryImpl repository;
  late MockActivityLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockActivityLocalDataSource();
    repository = ActivityRepositoryImpl(mockDataSource);
  });

  group('getAllActivities', () {
    test('should return all activities from datasource', () async {
      // arrange
      final tActivities = [
        domain.Activity(
          id: '1',
          type: 'beneficiary',
          description: 'Test activity 1',
          timestamp: DateTime.now(),
        ),
        domain.Activity(
          id: '2',
          type: 'visit',
          description: 'Test activity 2',
          timestamp: DateTime.now(),
        ),
      ];
      mockDataSource.activities.addAll(tActivities);

      // act
      final result = await repository.getAllActivities();

      // assert
      final data = result.getOrThrow();
      expect(data.length, 2);
      expect(data[0].id, '1');
      expect(data[1].id, '2');
    });

    test('should throw exception when datasource fails', () async {
      // arrange
      mockDataSource.shouldThrowError = true;

      // act & assert
      expect(() => repository.getAllActivities(), throwsA(isA<Exception>()));
    });
  });

  group('getActivitiesByType', () {
    test('should return filtered activities by type', () async {
      // arrange
      const tType = 'beneficiary';
      final tActivities = [
        domain.Activity(
          id: '1',
          type: 'beneficiary',
          description: 'Beneficiary activity',
          timestamp: DateTime.now(),
        ),
        domain.Activity(
          id: '2',
          type: 'visit',
          description: 'Visit activity',
          timestamp: DateTime.now(),
        ),
      ];
      mockDataSource.activities.addAll(tActivities);

      // act
      final result = await repository.getActivitiesByType(tType);

      // assert
      final data = result.getOrThrow();
      expect(data.length, 1);
      expect(data[0].type, tType);
    });

    test('should throw exception when datasource fails', () async {
      // arrange
      mockDataSource.shouldThrowError = true;

      // act & assert
      expect(
        () => repository.getActivitiesByType('any'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getActivitiesForBeneficiary', () {
    test('should return activities for specific beneficiary', () async {
      // arrange
      const tBeneficiaryId = 'ben_123';
      final tActivities = [
        domain.Activity(
          id: '1',
          type: 'beneficiary',
          description: 'Activity 1',
          beneficiaryId: tBeneficiaryId,
          timestamp: DateTime.now(),
        ),
        domain.Activity(
          id: '2',
          type: 'visit',
          description: 'Activity 2',
          beneficiaryId: 'ben_456',
          timestamp: DateTime.now(),
        ),
      ];
      mockDataSource.activities.addAll(tActivities);

      // act
      final result = await repository.getActivitiesForBeneficiary(
        tBeneficiaryId,
      );

      // assert
      final data = result.getOrThrow();
      expect(data.length, 1);
      expect(data[0].beneficiaryId, tBeneficiaryId);
    });

    test('should throw exception when datasource fails', () async {
      // arrange
      mockDataSource.shouldThrowError = true;

      // act & assert
      expect(
        () => repository.getActivitiesForBeneficiary('any'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('logActivity', () {
    test('should call datasource to log activity', () async {
      // arrange
      final tActivity = domain.Activity(
        id: '1',
        type: 'beneficiary',
        description: 'Test activity',
        timestamp: DateTime.now(),
      );

      // act
      await repository.logActivity(tActivity);

      // assert
      expect(mockDataSource.activities.length, 1);
      expect(mockDataSource.activities[0].id, '1');
    });

    test('should throw exception when datasource fails', () async {
      // arrange
      mockDataSource.shouldThrowError = true;
      final tActivity = domain.Activity(
        id: '1',
        type: 'beneficiary',
        description: 'Test activity',
        timestamp: DateTime.now(),
      );

      // act & assert
      expect(
        () => repository.logActivity(tActivity),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('deleteActivity', () {
    test('should delete activity from datasource', () async {
      // arrange
      const tActivityId = '1';
      final tActivity = domain.Activity(
        id: tActivityId,
        type: 'beneficiary',
        description: 'Test activity',
        timestamp: DateTime.now(),
      );
      mockDataSource.activities.add(tActivity);

      // act
      await repository.deleteActivity(tActivityId);

      // assert
      expect(mockDataSource.activities.isEmpty, true);
    });

    test('should throw exception when datasource fails', () async {
      // arrange
      mockDataSource.shouldThrowError = true;

      // act & assert
      expect(() => repository.deleteActivity('any'), throwsA(isA<Exception>()));
    });
  });

  group('clearAllActivities', () {
    test('should clear all activities from datasource', () async {
      // arrange
      mockDataSource.activities.addAll([
        domain.Activity(
          id: '1',
          type: 'beneficiary',
          description: 'Test 1',
          timestamp: DateTime.now(),
        ),
        domain.Activity(
          id: '2',
          type: 'visit',
          description: 'Test 2',
          timestamp: DateTime.now(),
        ),
      ]);

      // act
      await repository.clearAllActivities();

      // assert
      expect(mockDataSource.activities.isEmpty, true);
    });

    test('should throw exception when datasource fails', () async {
      // arrange
      mockDataSource.shouldThrowError = true;

      // act & assert
      expect(() => repository.clearAllActivities(), throwsA(isA<Exception>()));
    });
  });

  group('getActivitiesCount', () {
    test('should return count of activities', () async {
      // arrange
      mockDataSource.activities.addAll([
        domain.Activity(
          id: '1',
          type: 'beneficiary',
          description: 'Test 1',
          timestamp: DateTime.now(),
        ),
        domain.Activity(
          id: '2',
          type: 'visit',
          description: 'Test 2',
          timestamp: DateTime.now(),
        ),
        domain.Activity(
          id: '3',
          type: 'sync',
          description: 'Test 3',
          timestamp: DateTime.now(),
        ),
      ]);

      // act
      final result = await repository.getActivitiesCount();

      // assert
      expect(result, 3);
    });

    test('should return 0 when no activities exist', () async {
      // act
      final result = await repository.getActivitiesCount();

      // assert
      expect(result, 0);
    });

    test('should throw exception when datasource fails', () async {
      // arrange
      mockDataSource.shouldThrowError = true;

      // act & assert
      expect(() => repository.getActivitiesCount(), throwsA(isA<Exception>()));
    });
  });
}
