import 'package:benaa_offline_app/data/db/drift_database.dart';
import 'package:benaa_offline_app/features/associations/data/datasources/associations_remote_sync_datasource.dart';
import 'package:benaa_offline_app/features/associations/data/models/associations_sync_dto.dart';
import 'package:benaa_offline_app/features/associations/domain/constants/associations_sync_keys.dart';
import 'package:benaa_offline_app/features/sync/domain/usecases/sync_associations_module_usecase.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAssociationsRemoteSyncDataSource extends AssociationsRemoteSyncDataSource {
  _FakeAssociationsRemoteSyncDataSource() : super(Dio());

  SponsorsListResponseDto sponsorsPage = const SponsorsListResponseDto(records: [], hasMore: false);
  EmployeesListResponseDto employeesPage = const EmployeesListResponseDto(records: [], hasMore: false);

  int createSponsorCalls = 0;
  int updateSponsorCalls = 0;
  int createEmployeeCalls = 0;
  int updateEmployeeCalls = 0;
  int batchEmployeeCalls = 0;

  final List<SponsorDto> createdSponsors = <SponsorDto>[];
  final List<SponsorDto> updatedSponsors = <SponsorDto>[];
  final List<AssociationEmployeeDto> createdEmployees = <AssociationEmployeeDto>[];
  final List<AssociationEmployeeDto> updatedEmployees = <AssociationEmployeeDto>[];
  final List<AssociationEmployeeDto> batchedEmployees = <AssociationEmployeeDto>[];

  @override
  Future<SponsorsListResponseDto> fetchSponsors({
    DateTime? updatedAfter,
    List<int>? ids,
    int page = 1,
    int perPage = 100,
  }) async {
    return sponsorsPage;
  }

  @override
  Future<EmployeesListResponseDto> fetchEmployees({
    int? sponsorId,
    List<int>? ids,
    DateTime? updatedAfter,
    int page = 1,
    int perPage = 100,
  }) async {
    return employeesPage;
  }

  @override
  Future<void> createSponsor(SponsorDto sponsor) async {
    createSponsorCalls++;
    createdSponsors.add(sponsor);
  }

  @override
  Future<void> updateSponsor({required int sponsorId, required SponsorDto sponsor}) async {
    updateSponsorCalls++;
    updatedSponsors.add(sponsor);
  }

  @override
  Future<void> createEmployee(AssociationEmployeeDto employee) async {
    createEmployeeCalls++;
    createdEmployees.add(employee);
  }

  @override
  Future<void> updateEmployee({required int employeeId, required AssociationEmployeeDto employee}) async {
    updateEmployeeCalls++;
    updatedEmployees.add(employee);
  }

  @override
  Future<void> batchUpsertEmployees(List<AssociationEmployeeDto> employees) async {
    batchEmployeeCalls++;
    batchedEmployees.addAll(employees);
  }
}

void main() {
  group('SyncAssociationsModuleUseCase', () {
    late AppDatabase database;
    late _FakeAssociationsRemoteSyncDataSource remote;
    late SyncAssociationsModuleUseCase useCase;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      remote = _FakeAssociationsRemoteSyncDataSource();
      useCase = SyncAssociationsModuleUseCase(
        database: database,
        remote: remote,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('syncDown should upsert sponsors/employees and persist sponsor profile + metadata', () async {
      remote.sponsorsPage = SponsorsListResponseDto(
        records: [
          SponsorDto(
            id: 101,
            fileId: '501',
            sponsorName: 'جمعية الأمل',
            sponsorShortName: 'الأمل',
            sponsorPhoneNumber: '+970590000001',
            sponsorEmail: 'amal@example.org',
            sponsorAddress: 'غزة - شارع الجلاء',
            sponsorBankNameId: 7,
            sponsorBankName: 'بنك فلسطين',
            sponsorAccountBankNumber: 'ACC-1',
            sponsorBankSwiftCode: 'PALSPS22',
            countryCode: 'PS',
            countryName: 'Palestine',
            updatedAt: DateTime.parse('2026-02-24T10:00:00.000Z'),
          ),
        ],
        hasMore: false,
        syncTimestamp: DateTime.parse('2026-02-24T10:00:00.000Z'),
      );

      remote.employeesPage = EmployeesListResponseDto(
        records: [
          AssociationEmployeeDto(
            id: 301,
            sponsorId: 101,
            employeeName: 'محمد أحمد',
            updatedAt: DateTime.parse('2026-02-24T10:05:00.000Z'),
          ),
        ],
        hasMore: false,
        syncTimestamp: DateTime.parse('2026-02-24T10:05:00.000Z'),
      );

      final result = await useCase.syncDown();

      expect(result.uploaded, 2);
      expect(result.failed, 0);

      final sponsor = await database.associationsDao.getAssociationByServerId(101);
      expect(sponsor, isNotNull);
      expect(sponsor!.name, 'جمعية الأمل');
      expect(sponsor.syncState, 'synced');

      final profile = await database.associationsDao.getSponsorProfileByAssociationId(sponsor.id);
      expect(profile, isNotNull);
      expect(profile!['country_code'], 'PS');
      expect(profile['sponsor_bank_name_id'], 7);
      expect(profile['sponsor_address'], contains('غزة'));

      final rep = await database.associationsDao.getRepresentativeByServerId(301);
      expect(rep, isNotNull);
      expect(rep!.name, 'محمد أحمد');
      expect(rep.syncState, 'synced');

      final sponsorsLastSync = await database.syncMetadataDao.getLastSyncTime(AssociationsSyncKeys.sponsorsEntity);
      final employeesLastSync = await database.syncMetadataDao.getLastSyncTime(AssociationsSyncKeys.employeesEntity);
      expect(sponsorsLastSync, isNotNull);
      expect(employeesLastSync, isNotNull);
    });

    test('syncUp should send pending sponsor/employee and mark them synced', () async {
      final now = DateTime.now();

      await database.associationsDao.addAssociation(
        AssociationsCompanion.insert(
          id: 'local-assoc-1',
          name: 'جمعية النور',
          phone: '+970590000002',
          bankName: 'بنك القدس',
          accountNumber: 'ACC-2',
          createdAt: now,
          updatedAt: now,
          syncState: const drift.Value('pending'),
        ),
      );

      await database.associationsDao.upsertSponsorProfile(
        associationId: 'local-assoc-1',
        sponsorAddress: 'خان يونس',
        countryCode: 'PS',
        countryName: 'Palestine',
        sponsorBankNameId: 9,
      );

      await database.associationsDao.addRepresentative(
        AssociationRepresentativesCompanion.insert(
          id: 'local-rep-1',
          name: 'فاطمة محمد',
          createdAt: now,
          updatedAt: now,
          syncState: const drift.Value('pending'),
        ),
      );

      final result = await useCase.syncUp(employeeBatchThreshold: 99);

      expect(result.failed, 0);
      expect(result.uploaded, 2);
      expect(remote.createSponsorCalls, 1);
      expect(remote.createEmployeeCalls, 1);
      expect(remote.batchEmployeeCalls, 0);

      final assoc = await database.associationsDao.getAssociationById('local-assoc-1');
      final rep = await database.associationsDao.getRepresentativeById('local-rep-1');
      expect(assoc, isNotNull);
      expect(rep, isNotNull);
      expect(assoc!.syncState, 'synced');
      expect(rep!.syncState, 'synced');

      expect(remote.createdSponsors.single.countryCode, 'PS');
      expect(remote.createdSponsors.single.sponsorBankNameId, 9);
      expect(remote.createdSponsors.single.sponsorAddress, 'خان يونس');
    });

    test('syncUp should use employee batch endpoint when threshold is reached', () async {
      final now = DateTime.now();

      await database.associationsDao.addRepresentative(
        AssociationRepresentativesCompanion.insert(
          id: 'rep-a',
          name: 'موظف A',
          createdAt: now,
          updatedAt: now,
          syncState: const drift.Value('pending'),
        ),
      );
      await database.associationsDao.addRepresentative(
        AssociationRepresentativesCompanion.insert(
          id: 'rep-b',
          name: 'موظف B',
          createdAt: now,
          updatedAt: now,
          syncState: const drift.Value('pending'),
        ),
      );

      final result = await useCase.syncUp(employeeBatchThreshold: 1);

      expect(result.failed, 0);
      expect(result.uploaded, 2);
      expect(remote.batchEmployeeCalls, 1);
      expect(remote.batchedEmployees.length, 2);
      expect(remote.createEmployeeCalls, 0);

      final repA = await database.associationsDao.getRepresentativeById('rep-a');
      final repB = await database.associationsDao.getRepresentativeById('rep-b');
      expect(repA!.syncState, 'synced');
      expect(repB!.syncState, 'synced');
    });
  });
}
