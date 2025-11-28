import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/dashboard/domain/entities/activity.dart';
import 'package:benaa_offline_app/features/dashboard/domain/repositories/activity_repository.dart';
import 'package:benaa_offline_app/features/dashboard/domain/usecases/log_activity.dart';
import 'package:benaa_offline_app/core/error_handling/result.dart';

class MockActivityRepository implements ActivityRepository {
  final List<Activity> activities = [];

  @override
  Future<Result<List<Activity>>> getAllActivities() async => Success(activities);

  @override
  Future<Result<List<Activity>>> getActivitiesByType(String type) async =>
      Success(activities.where((a) => a.type == type).toList());

  @override
  Future<Result<List<Activity>>> getActivitiesForBeneficiary(
    String beneficiaryId,
  ) async =>
      Success(activities.where((a) => a.beneficiaryId == beneficiaryId).toList());

  @override
  Future<Result<void>> logActivity(Activity activity) async {
    activities.add(activity);
    return const Success(null);
  }

  @override
  Future<Result<void>> deleteActivity(String activityId) async {
    activities.removeWhere((a) => a.id == activityId);
    return const Success(null);
  }

  @override
  Future<Result<void>> clearAllActivities() async {
    activities.clear();
    return const Success(null);
  }

  @override
  Future<Result<int>> getActivitiesCount() async => Success(activities.length);
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
  Future<Result<List<Activity>>> getAllActivities() async => const Failure(DatabaseFailure('Database error'));

  @override
  Future<Result<List<Activity>>> getActivitiesByType(String type) async =>
      const Failure(DatabaseFailure('Database error'));

  @override
  Future<Result<List<Activity>>> getActivitiesForBeneficiary(
    String beneficiaryId,
  ) async =>
      const Failure(DatabaseFailure('Database error'));

  @override
  Future<Result<void>> logActivity(Activity activity) async => const Failure(DatabaseFailure('Database error'));

  @override
  Future<Result<void>> deleteActivity(String activityId) async => const Failure(DatabaseFailure('Database error'));

  @override
  Future<Result<void>> clearAllActivities() async => const Failure(DatabaseFailure('Database error'));

  @override
  Future<Result<int>> getActivitiesCount() async => const Failure(DatabaseFailure('Database error'));
}
