
import 'package:benaa_offline_app/features/beneficiaries/domain/entities/civil_registry_person.dart';
import 'package:benaa_offline_app/features/beneficiaries/domain/repositories/civil_registry_repository.dart';
import 'package:benaa_offline_app/features/beneficiaries/domain/usecases/fetch_civil_registry_data.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/providers/beneficiary_dependencies.dart' as deps;
import 'package:benaa_offline_app/features/beneficiaries/presentation/providers/civil_registry_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCivilRegistryRepository implements CivilRegistryRepository {
  _FakeCivilRegistryRepository({this.delay = Duration.zero, this.result});

  int getByNationalIdCallCount = 0;
  final Duration delay;
  final CivilRegistryPerson? result;

  @override
  Future<CivilRegistryPerson?> getByNationalId(String nationalId) async {
    getByNationalIdCallCount++;
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    return result;
  }

  @override
  Future<void> clearCache() async {}

  @override
  Future<bool> exists(String nationalId) async => true;

  @override
  Future<List<CivilRegistryPerson>> search({
    String? firstName,
    String? lastName,
    String? motherName,
    DateTime? birthDate,
  }) async {
    return const [];
  }
}

void main() {
  group('CivilRegistryNotifier', () {
    setUp(() {
      CivilRegistryLookupDiagnostics.enabled = false;
      CivilRegistryLookupDiagnostics.clear();
    });

    tearDown(() {
      CivilRegistryLookupDiagnostics.enabled = false;
      CivilRegistryLookupDiagnostics.clear();
    });

    test('skips duplicate concurrent lookup requests for same national ID', () async {
      final fakeRepository = _FakeCivilRegistryRepository(
        delay: const Duration(milliseconds: 120),
        result: const CivilRegistryPerson(
          nationalId: '123456789',
          firstName: 'محمد',
          fatherName: 'أحمد',
          lastName: 'علي',
        ),
      );

      final container = ProviderContainer(
        overrides: [
          deps.fetchCivilRegistryDataUseCaseProvider.overrideWith(
            (ref) async => FetchCivilRegistryDataUseCase(fakeRepository),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(deps.civilRegistryProvider.notifier);

      final firstCall = notifier.fetchByNationalId('123456789');
      final secondCall = notifier.fetchByNationalId('123456789');

      await Future.wait([firstCall, secondCall]);

      expect(fakeRepository.getByNationalIdCallCount, 1);
      expect(container.read(deps.civilRegistryProvider).isSuccess, isTrue);
    });

    test('returns database-not-available error when use case is null', () async {
      final container = ProviderContainer(
        overrides: [
          deps.fetchCivilRegistryDataUseCaseProvider.overrideWith((ref) async => null),
        ],
      );
      addTearDown(container.dispose);

      await container.read(deps.civilRegistryProvider.notifier).fetchByNationalId('123456789');

      final state = container.read(deps.civilRegistryProvider);
      expect(state.isError, isTrue);
      expect(state.errorType, CivilRegistryErrorType.databaseNotAvailable);
    });

    test('throttles repeated same-ID lookups in short bursts', () async {
      final fakeRepository = _FakeCivilRegistryRepository(
        result: const CivilRegistryPerson(
          nationalId: '123456789',
          firstName: 'سارة',
          fatherName: 'محمد',
          lastName: 'حسين',
        ),
      );

      final container = ProviderContainer(
        overrides: [
          deps.fetchCivilRegistryDataUseCaseProvider.overrideWith(
            (ref) async => FetchCivilRegistryDataUseCase(fakeRepository),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(deps.civilRegistryProvider.notifier);

      await notifier.fetchByNationalId('123456789');
      await notifier.fetchByNationalId('123456789');

      expect(fakeRepository.getByNationalIdCallCount, 1);
    });

    test('records diagnostics events when debug tracing is enabled', () async {
      final fakeRepository = _FakeCivilRegistryRepository(
        result: const CivilRegistryPerson(
          nationalId: '123456789',
          firstName: 'عمر',
          fatherName: 'خالد',
          lastName: 'عبدالله',
        ),
      );

      CivilRegistryLookupDiagnostics.enabled = true;

      final container = ProviderContainer(
        overrides: [
          deps.fetchCivilRegistryDataUseCaseProvider.overrideWith(
            (ref) async => FetchCivilRegistryDataUseCase(fakeRepository),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(deps.civilRegistryProvider.notifier);

      await notifier.fetchByNationalId('123456789');
      await notifier.fetchByNationalId('123456789');

      final traces = CivilRegistryLookupDiagnostics.snapshot();
      expect(traces.where((e) => e.phase == 'lookup_success').isNotEmpty, isTrue);
      expect(traces.where((e) => e.phase == 'skipped_throttled').isNotEmpty, isTrue);
    });
  });
}
