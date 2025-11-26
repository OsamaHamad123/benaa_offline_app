import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/dashboard/domain/entities/activity.dart';
import 'package:benaa_offline_app/features/dashboard/domain/repositories/activity_repository.dart';
import 'package:benaa_offline_app/features/dashboard/domain/usecases/log_activity.dart';

class MockActivityRepository implements ActivityRepository {
  final List<Activity> activities = [];

  @override
  Future<List<Activity>> getAllActivities() async => activities;

  @override
  Future<List<Activity>> getActivitiesByType(String type) async =>
      activities.where((a) => a.type == type).toList();

  @override
  Future<List<Activity>> getActivitiesForBeneficiary(
    String beneficiaryId,
  ) async => activities.where((a) => a.beneficiaryId == beneficiaryId).toList();

  @override
  Future<void> logActivity(Activity activity) async {
    activities.add(activity);
  }

  @override
  Future<void> deleteActivity(String activityId) async {
    activities.removeWhere((a) => a.id == activityId);
  }

  @override
  Future<void> clearAllActivities() async {
    activities.clear();
  }

  @override
  Future<int> getActivitiesCount() async => activities.length;
}

void main() {
  late LogActivity useCase;
  late MockActivityRepository mockRepository;

  setUp(() {
    mockRepository = MockActivityRepository();
    useCase = LogActivity(mockRepository);
  });

  group('LogActivity UseCase', () {
    const tType = 'beneficiary';
    const tDescription = 'تم إضافة مستفيد جديد';
    const tBeneficiaryId = 'ben_123';
    const tBeneficiaryName = 'محمد أحمد';
    final tMetadata = {'field': 'value'};

    test('should log activity successfully', () async {
      // act
      await useCase(
        type: tType,
        description: tDescription,
        beneficiaryId: tBeneficiaryId,
        beneficiaryName: tBeneficiaryName,
        metadata: tMetadata,
      );

      // assert
      expect(mockRepository.activities.length, 1);
      expect(mockRepository.activities[0].type, tType);
    });

    test('should create activity with correct data', () async {
      // act
      await useCase(
        type: tType,
        description: tDescription,
        beneficiaryId: tBeneficiaryId,
        beneficiaryName: tBeneficiaryName,
        metadata: tMetadata,
      );

      // assert
      final activity = mockRepository.activities[0];
      expect(activity.type, tType);
      expect(activity.description, tDescription);
      expect(activity.beneficiaryId, tBeneficiaryId);
      expect(activity.beneficiaryName, tBeneficiaryName);
      expect(activity.metadata, tMetadata);
    });

    test('should create activity without optional parameters', () async {
      // act
      await useCase(type: tType, description: tDescription);

      // assert
      final activity = mockRepository.activities[0];
      expect(activity.type, tType);
      expect(activity.description, tDescription);
      expect(activity.beneficiaryId, isNull);
      expect(activity.beneficiaryName, isNull);
      expect(activity.metadata, isNull);
    });

    test('should throw exception when repository fails', () async {
      // arrange - Create failing repository
      final failingRepo = _FailingRepository();
      final failingUseCase = LogActivity(failingRepo);

      // act & assert
      expect(
        () => failingUseCase(type: tType, description: tDescription),
        throwsA(isA<Exception>()),
      );
    });
  });
}

class _FailingRepository implements ActivityRepository {
  @override
  Future<List<Activity>> getAllActivities() async =>
      throw Exception('Database error');

  @override
  Future<List<Activity>> getActivitiesByType(String type) async =>
      throw Exception('Database error');

  @override
  Future<List<Activity>> getActivitiesForBeneficiary(
    String beneficiaryId,
  ) async => throw Exception('Database error');

  @override
  Future<void> logActivity(Activity activity) async =>
      throw Exception('Database error');

  @override
  Future<void> deleteActivity(String activityId) async =>
      throw Exception('Database error');

  @override
  Future<void> clearAllActivities() async => throw Exception('Database error');

  @override
  Future<int> getActivitiesCount() async => throw Exception('Database error');
}
