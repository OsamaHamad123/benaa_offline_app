import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/data/db/drift_database.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('SponsorshipsDao delete sync tracking', () {
    test('deleteSponsorship(trackSyncDelete: true) adds sponsorship tombstone when serverId exists', () async {
      final beneficiaryId = await database.into(database.beneficiaries).insert(
            BeneficiariesCompanion.insert(
              idNumber: 123456789,
              phoneNumber: 599000001,
              altPhoneNumber: 599000002,
              firstName: const Value('Test'),
              fatherName: const Value('Beneficiary'),
              grandFatherName: const Value('Unit'),
              familyName: const Value('Case'),
            ),
          );

      await database.into(database.associations).insert(
            AssociationsCompanion.insert(
              id: 'assoc-1',
              name: 'Association One',
              phone: '0599000000',
              bankName: 'Bank',
              accountNumber: 'ACC-1',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );

      final fileNo = await database.into(database.sponsorships).insert(
            SponsorshipsCompanion.insert(
              beneficiaryId: beneficiaryId,
              associationId: 'assoc-1',
              serverId: const Value(88),
              syncState: const Value('synced'),
            ),
          );

      final deleted = await database.sponsorshipsDao.deleteSponsorship(
        fileNo: fileNo,
        trackSyncDelete: true,
      );

      expect(deleted, 1);

      final pending = await database.syncDao.getPendingTombstones(entityType: 'sponsorships');
      expect(pending.length, 1);
      expect(pending.first['entity_id'], '88');

      final payload = jsonDecode(pending.first['payload'] as String) as Map<String, dynamic>;
      expect(payload['server_id'], 88);
      expect(payload['local_file_no'], fileNo);
    });

    test('deleteSponsorship(trackSyncDelete: false) does not add tombstone', () async {
      final beneficiaryId = await database.into(database.beneficiaries).insert(
            BeneficiariesCompanion.insert(
              idNumber: 223456789,
              phoneNumber: 599000011,
              altPhoneNumber: 599000012,
              firstName: const Value('No'),
              fatherName: const Value('Tombstone'),
              grandFatherName: const Value('Expected'),
              familyName: const Value('Case'),
            ),
          );

      await database.into(database.associations).insert(
            AssociationsCompanion.insert(
              id: 'assoc-2',
              name: 'Association Two',
              phone: '0599000001',
              bankName: 'Bank',
              accountNumber: 'ACC-2',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );

      final fileNo = await database.into(database.sponsorships).insert(
            SponsorshipsCompanion.insert(
              beneficiaryId: beneficiaryId,
              associationId: 'assoc-2',
              serverId: const Value(99),
              syncState: const Value('synced'),
            ),
          );

      final deleted = await database.sponsorshipsDao.deleteSponsorship(
        fileNo: fileNo,
        trackSyncDelete: false,
      );

      expect(deleted, 1);

      final pending = await database.syncDao.getPendingTombstones(entityType: 'sponsorships');
      expect(pending, isEmpty);
    });
  });
}
