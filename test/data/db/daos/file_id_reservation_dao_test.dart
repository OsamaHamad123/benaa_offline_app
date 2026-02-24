import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/data/db/drift_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('FileIdReservationDao', () {
    test('allocateNextAvailableFromBatch advances counters correctly', () async {
      final dao = database.fileIdReservationDao;

      await dao.upsertActiveReservationBatch(
        reservationId: 101,
        deviceId: 'device-test',
        startId: 5000,
        endId: 5002,
        batchSize: 3,
        usedCount: 0,
        remainingCount: 3,
        nextAvailableId: 5000,
        status: 'active',
      );

      final first = await dao.allocateNextAvailableFromBatch();
      final second = await dao.allocateNextAvailableFromBatch();

      expect(first, 5000);
      expect(second, 5001);

      final pending = await dao.getUnsyncedUsedCountFromBatch();
      expect(pending, 2);
    });

    test('getUnsyncedUsedCountFromBatch sums pending counts across active batches', () async {
      final dao = database.fileIdReservationDao;

      await dao.upsertActiveReservationBatch(
        reservationId: 201,
        deviceId: 'device-test',
        startId: 6000,
        endId: 6009,
        batchSize: 10,
        usedCount: 4,
        remainingCount: 6,
        nextAvailableId: 6004,
        status: 'active',
      );

      await dao.upsertActiveReservationBatch(
        reservationId: 202,
        deviceId: 'device-test',
        startId: 7000,
        endId: 7009,
        batchSize: 10,
        usedCount: 7,
        remainingCount: 3,
        nextAvailableId: 7007,
        status: 'active',
      );

      await dao.markBatchUsedCountSynced(201);

      final pending = await dao.getUnsyncedUsedCountFromBatch();
      expect(pending, 7);
    });
  });
}
