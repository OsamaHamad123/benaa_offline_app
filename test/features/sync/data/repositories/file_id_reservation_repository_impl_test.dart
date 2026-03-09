import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/data/db/drift_database.dart';
import 'package:benaa_offline_app/features/sync/data/datasources/file_id_remote_datasource.dart';
import 'package:benaa_offline_app/features/sync/data/repositories/file_id_reservation_repository_impl.dart';

class _FakeFileIdRemoteDataSource implements FileIdRemoteDataSource {
  int loginSyncCalls = 0;
  String? lastDeviceId;
  List<DeviceCodeStatusPayload>? lastDeviceCodes;
  CodesLoginSyncResult loginSyncResult = const CodesLoginSyncResult(
    newCodes: <int>[3139],
  );
  DeviceCodeStats? deviceCodeStats;
  int requestCodesCalls = 0;
  int? lastRequestCodesCount;
  List<int> requestCodesResult = const <int>[];
  int confirmUsageCalls = 0;
  List<ConfirmUsageCodePayload>? lastConfirmUsagePayload;
  CodesConfirmUsageResult confirmUsageResult = const CodesConfirmUsageResult();

  @override
  Future<CodesLoginSyncResult> loginSync({
    required String deviceId,
    required List<DeviceCodeStatusPayload> deviceCodes,
  }) async {
    loginSyncCalls++;
    lastDeviceId = deviceId;
    lastDeviceCodes = deviceCodes;

    return loginSyncResult;
  }

  @override
  Future<CodesConfirmUsageResult> confirmUsageCodes(List<ConfirmUsageCodePayload> codes) async {
    confirmUsageCalls++;
    lastConfirmUsagePayload = codes;
    return confirmUsageResult;
  }

  @override
  Future<({int? reservationId, int? remainingCount})> getActiveReservationStatus() async {
    return (reservationId: null, remainingCount: null);
  }

  @override
  Future<DeviceCodeStats?> getDeviceCodeStats() async {
    return deviceCodeStats;
  }

  @override
  Future<List<int>> requestCodes(int count) async {
    requestCodesCalls++;
    lastRequestCodesCount = count;
    return requestCodesResult;
  }

  @override
  Future<FileIdReservationSnapshot?> reserveBatchSnapshot(int count) async {
    return null;
  }

  @override
  Future<List<int>> reserveIds(int count) async {
    return const <int>[];
  }

  @override
  Future<void> syncUsedCount({required int reservationId, required int usedCount}) async {}

  @override
  Future<void> syncUsedIds(List<int> usedIds) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FileIdReservationRepositoryImpl', () {
    late AppDatabase database;
    late _FakeFileIdRemoteDataSource remote;
    late FileIdReservationRepositoryImpl repository;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      remote = _FakeFileIdRemoteDataSource();
      repository = FileIdReservationRepositoryImpl(
        remoteDataSource: remote,
        localDao: database.fileIdReservationDao,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('login-sync runs even when no active local reservation batch exists', () async {
      final result = await repository.loginSyncCodes();

      expect(result.isSuccess, isTrue);
      expect(remote.loginSyncCalls, 1);
      expect(remote.lastDeviceId, isNotNull);
      expect(remote.lastDeviceId, isNotEmpty);

      final available = await database.fileIdReservationDao.countAvailable();
      expect(available, 1);
    });

    test('login-sync applies confirmed/invalid/conflict/new reconciliation locally', () async {
      await database.fileIdReservationDao.insertReservedIds(const <int>[1001, 1002, 1003]);
      await database.fileIdReservationDao.markAsUsed(
        1001,
        55,
        recordType: 'sponsorship',
        recordId: 777,
      );

      remote.loginSyncResult = const CodesLoginSyncResult(
        confirmedUsed: <int>[1001],
        invalidCodes: <int>[1002],
        conflictCodes: <int>[1003],
        newCodes: <int>[2001],
      );

      final result = await repository.loginSyncCodes();

      expect(result.isSuccess, isTrue);
      expect(remote.loginSyncCalls, 1);

      final payload = remote.lastDeviceCodes;
      expect(payload, isNotNull);
      final usedEntry = payload!.firstWhere((e) => e.code == '001001');
      expect(usedEntry.used, isTrue);
      expect(usedEntry.recordId, '777');

      final syncRows = await database.customSelect(
        'SELECT synced, is_used, record_type FROM local_codes WHERE code = ?',
        variables: [const Variable<String>('001001')],
      ).getSingle();
      expect(syncRows.read<int>('synced'), 1);
      expect(syncRows.read<int>('is_used'), 1);
      expect(syncRows.read<String?>('record_type'), 'sponsorship');

      final invalidRows = await database.customSelect(
        'SELECT COUNT(*) AS cnt FROM local_codes WHERE code = ?',
        variables: [const Variable<String>('001002')],
      ).getSingle();
      expect(invalidRows.read<int>('cnt'), 0);

      final conflictRows = await database.customSelect(
        'SELECT synced, is_used FROM local_codes WHERE code = ?',
        variables: [const Variable<String>('001003')],
      ).getSingle();
      expect(conflictRows.read<int>('is_used'), 1);
      expect(conflictRows.read<int>('synced'), 0);

      final newRows = await database.customSelect(
        'SELECT COUNT(*) AS cnt FROM local_codes WHERE code = ?',
        variables: [const Variable<String>('002001')],
      ).getSingle();
      expect(newRows.read<int>('cnt'), 1);
    });

    test('syncUsedIds sends record_type and record_id to confirm-usage', () async {
      await database.fileIdReservationDao.insertReservedIds(const <int>[3001]);
      await database.fileIdReservationDao.markAsUsed(
        3001,
        12,
        recordType: 'dead_people',
        recordId: 910,
      );

      remote.confirmUsageResult = const CodesConfirmUsageResult(
        confirmed: <int>[3001],
      );

      final result = await repository.syncUsedIds();

      expect(result.isSuccess, isTrue);
      expect(remote.confirmUsageCalls, 1);

      final sent = remote.lastConfirmUsagePayload;
      expect(sent, isNotNull);
      expect(sent!.length, 1);
      expect(sent.first.code, '003001');
      expect(sent.first.recordType, 'dead_people');
      expect(sent.first.recordId, 910);

      final row = await database.customSelect(
        'SELECT synced FROM local_codes WHERE code = ?',
        variables: [const Variable<String>('003001')],
      ).getSingle();
      expect(row.read<int>('synced'), 1);
    });

    test('refillIfNeeded clamps request count to available slots', () async {
      remote.deviceCodeStats = const DeviceCodeStats(
        unusedCount: 50,
        canRequestMore: true,
        availableSlots: 120,
      );
      remote.requestCodesResult = const <int>[9001, 9002];

      final result = await repository.refillIfNeeded(
        lowThreshold: 100,
        requestCount: 500,
      );

      expect(result.isSuccess, isTrue);
      expect(result.getOrThrow(), 2);
      expect(remote.requestCodesCalls, 1);
      expect(remote.lastRequestCodesCount, 120);
    });

    test('refillIfNeeded skips request when available slots are zero', () async {
      remote.deviceCodeStats = const DeviceCodeStats(
        unusedCount: 10,
        canRequestMore: true,
        availableSlots: 0,
      );

      final result = await repository.refillIfNeeded(
        lowThreshold: 100,
        requestCount: 500,
      );

      expect(result.isSuccess, isTrue);
      expect(result.getOrThrow(), 0);
      expect(remote.requestCodesCalls, 0);
    });

    test('refillIfNeeded skips request when requestCount is non-positive', () async {
      remote.deviceCodeStats = const DeviceCodeStats(
        unusedCount: 10,
        canRequestMore: true,
        availableSlots: 300,
      );

      final result = await repository.refillIfNeeded(
        lowThreshold: 100,
        requestCount: -5,
      );

      expect(result.isSuccess, isTrue);
      expect(result.getOrThrow(), 0);
      expect(remote.requestCodesCalls, 0);
    });

    test('refillIfNeeded caps request count to 5000 contract max', () async {
      remote.deviceCodeStats = const DeviceCodeStats(
        unusedCount: 10,
        canRequestMore: true,
      );
      remote.requestCodesResult = const <int>[7001];

      final result = await repository.refillIfNeeded(
        lowThreshold: 100,
        requestCount: 7000,
      );

      expect(result.isSuccess, isTrue);
      expect(result.getOrThrow(), 1);
      expect(remote.requestCodesCalls, 1);
      expect(remote.lastRequestCodesCount, 5000);
    });

    test('refillIfNeeded recovers locally via login-sync when server already has assigned codes', () async {
      remote.deviceCodeStats = const DeviceCodeStats(
        unusedCount: 5000,
        canRequestMore: false,
      );
      remote.loginSyncResult = const CodesLoginSyncResult(
        newCodes: <int>[7101, 7102],
      );

      final result = await repository.refillIfNeeded(
        lowThreshold: 100,
        requestCount: 500,
      );

      expect(result.isSuccess, isTrue);
      expect(result.getOrThrow(), 2);
      expect(remote.loginSyncCalls, 1);
      expect(remote.requestCodesCalls, 0);

      final available = await database.fileIdReservationDao.countAvailable();
      expect(available, 2);
    });

    test('refillIfNeeded falls back to request-codes when device-stats is unavailable', () async {
      remote.deviceCodeStats = null;
      remote.requestCodesResult = const <int>[7201, 7202, 7203];

      final result = await repository.refillIfNeeded(
        lowThreshold: 100,
        requestCount: 500,
      );

      expect(result.isSuccess, isTrue);
      expect(result.getOrThrow(), 3);
      expect(remote.requestCodesCalls, 1);
      expect(remote.lastRequestCodesCount, 500);
    });
  });
}
