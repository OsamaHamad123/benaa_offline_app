import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_test/flutter_test.dart';

import 'package:benaa_offline_app/data/db/drift_database.dart';
import 'package:benaa_offline_app/features/sync/data/repositories/mobile_sync_related_entities_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late MobileSyncRelatedEntitiesRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = MobileSyncRelatedEntitiesRepository(database: database);
  });

  Future<int> seedBeneficiary({required String fileId}) async {
    return database.into(database.beneficiaries).insert(
          BeneficiariesCompanion.insert(
            idNumber: 123456789,
            phoneNumber: 599111111,
            altPhoneNumber: 599222222,
            firstName: const drift.Value('اختبار'),
            fatherName: const drift.Value('مستفيد'),
            grandFatherName: const drift.Value('واحد'),
            familyName: const drift.Value('تجريبي'),
            fileIdNumber: drift.Value(fileId),
          ),
        );
  }

  tearDown(() async {
    await database.close();
  });

  group('MobileSyncRelatedEntitiesRepository guardian bank accounts', () {
    test('upsertGuardianBankAccount inserts a new row and marks it synced', () async {
      final outcome = await repository.upsertGuardianBankAccount({
        'id': 501,
        'guardian_registration': 1001,
        'bank_name': 3,
        'bank_name_label': 'Bank A',
        'iban_usd': 'PS001',
        'iban_shekel': 'PS002',
        're_id_number': '999',
        're_guardian_name': 'Guardian One',
        're_phone_number': '0599000000',
        'person_owner_identity_number': '123456789',
        'check_account': 1,
      });

      expect(outcome, SyncRelatedWriteOutcome.inserted);

      final rows = await database
          .customSelect(
            'SELECT server_id, guardian_registration, bank_name_id, sync_state, is_approved '
            'FROM guardian_bank_accounts WHERE server_id = 501',
          )
          .get();

      expect(rows, hasLength(1));
      expect(rows.first.read<int>('guardian_registration'), 1001);
      expect(rows.first.read<int?>('bank_name_id'), 3);
      expect(rows.first.read<String>('sync_state'), 'synced');
      expect(rows.first.read<int>('is_approved'), 1);
    });

    test('upsertGuardianBankAccount updates existing row by server id', () async {
      await repository.upsertGuardianBankAccount({
        'id': 700,
        'guardian_registration': 2002,
        'iban_usd': 'OLD_IBAN',
        'check_account': 0,
      });

      final outcome = await repository.upsertGuardianBankAccount({
        'id': 700,
        'guardian_registration': 2002,
        'iban_usd': 'NEW_IBAN',
        'check_account': 1,
      });

      expect(outcome, SyncRelatedWriteOutcome.updated);

      final row = await database
          .customSelect(
            'SELECT iban_usd, check_account, is_approved, sync_state '
            'FROM guardian_bank_accounts WHERE server_id = 700',
          )
          .getSingle();

      expect(row.read<String?>('iban_usd'), 'NEW_IBAN');
      expect(row.read<int>('check_account'), 1);
      expect(row.read<int>('is_approved'), 1);
      expect(row.read<String>('sync_state'), 'synced');
    });

    test('deleteGuardianBankAccountFromServerRow deletes by server id or guardian registration', () async {
      await repository.upsertGuardianBankAccount({
        'id': 801,
        'guardian_registration': 3003,
        'iban_usd': 'A',
      });

      final deletedByServer = await repository.deleteGuardianBankAccountFromServerRow({
        'id': 801,
      });
      expect(deletedByServer, isTrue);

      final afterServerDelete = await database
          .customSelect(
            'SELECT COUNT(*) AS cnt FROM guardian_bank_accounts WHERE server_id = 801',
          )
          .getSingle();
      expect(afterServerDelete.read<int>('cnt'), 0);

      await database.customStatement(
        'INSERT INTO guardian_bank_accounts '
        '(guardian_registration, iban_usd, sync_state) VALUES (?, ?, ?)',
        [4004, 'B', 'pending'],
      );

      final deletedByGuardian = await repository.deleteGuardianBankAccountFromServerRow({
        'guardian_registration': 4004,
      });
      expect(deletedByGuardian, isTrue);

      final afterGuardianDelete = await database
          .customSelect(
            'SELECT COUNT(*) AS cnt FROM guardian_bank_accounts WHERE guardian_registration = 4004',
          )
          .getSingle();
      expect(afterGuardianDelete.read<int>('cnt'), 0);
    });

    test('upsertGuardianBankAccount skips invalid rows without guardian registration', () async {
      final outcome = await repository.upsertGuardianBankAccount({
        'id': 900,
        'iban_usd': 'PS_NO_GUARDIAN',
      });

      expect(outcome, SyncRelatedWriteOutcome.skipped);
    });
  });

  group('MobileSyncRelatedEntitiesRepository re_people', () {
    test('upsertFamilyMember maps contract fields and updates same server row', () async {
      final beneficiaryId = await seedBeneficiary(fileId: '1001');

      final firstOutcome = await repository.upsertFamilyMember(
        {
          'id': 61,
          'registration_id': 1001,
          'person_id': '456789123',
          'first_name': 'ليان',
          'first_name_normalized': 'ليان',
          'second_name': 'محمود',
          'second_name_normalized': 'محمود',
          'third_name': 'أحمد',
          'third_name_normalized': 'احمد',
          'last_name': 'النجار',
          'last_name_normalized': 'النجار',
          'person_birth_date': '2016-05-10',
          'person_gender': 'female',
          'person_health_status': 'مريض',
          'person_health_status_name': 'مريض',
          'sponsorship_status': 2,
          'sponsorship_status_name': 'غير مكفول',
          'person_type_of_guarantee': 4,
          'person_type_of_guarantee_name': 'كفالة خاصة',
          'person_note': 'طالب متفوق',
        },
        localBeneficiaryId: beneficiaryId,
      );

      expect(firstOutcome, SyncRelatedWriteOutcome.inserted);

      final secondOutcome = await repository.upsertFamilyMember(
        {
          'id': 61,
          'registration_id': 1001,
          'person_id': '456789123',
          'first_name': 'ليان-محدث',
          'person_health_status': 'سليم',
          'sponsorship_status': 1,
        },
        localBeneficiaryId: beneficiaryId,
      );

      expect(secondOutcome, SyncRelatedWriteOutcome.updated);

      final rows = await (database.select(database.familyMembersTable)
            ..where((t) => t.serverId.equals(61) & t.beneficiaryId.equals(beneficiaryId)))
          .get();

      expect(rows, hasLength(1));
      expect(rows.first.firstName, 'ليان-محدث');
      expect(rows.first.orphanNationalId, 456789123);
      expect(rows.first.gender, 2);
      expect(rows.first.healthStatus, 1);
      expect(rows.first.sponsorshipStatus, 1);
      expect(rows.first.sponsorshipType, 4);
      expect(rows.first.guaranteeType, 4);
      expect(rows.first.syncState, 'synced');

      final parityRow = await database.customSelect(
        'SELECT first_name_normalized, person_health_status_name, sponsorship_status_name '
        'FROM re_people_contract_fields WHERE family_member_id = ?',
        variables: [drift.Variable<int>(rows.first.id)],
      ).getSingle();
      expect(parityRow.read<String?>('first_name_normalized'), 'ليان');
      expect(parityRow.read<String?>('person_health_status_name'), 'مريض');
      expect(parityRow.read<String?>('sponsorship_status_name'), 'غير مكفول');
    });
  });

  group('MobileSyncRelatedEntitiesRepository dead_people', () {
    test('upsertFamilyDeceased splits father/mother payload and preserves per-parent fields', () async {
      final beneficiaryId = await seedBeneficiary(fileId: '2001');

      final outcome = await repository.upsertFamilyDeceased(
        {
          'id': 700,
          're_file_id': '2001',
          'deceased_parents': {
            'father': {
              'first_name': 'أحمد',
              'second_name': 'محمد',
              'last_name': 'النجار',
              'id_number': 111111111,
              'death_date': '2024-10-15',
              'death_reason': 1,
              'death_reason_name': 'شهيد',
            },
            'mother': {
              'first_name': 'فاطمة',
              'second_name': 'خالد',
              'last_name': 'النجار',
              'id_number': 222222222,
              'death_date': '2023-05-20',
              'death_reason': 2,
              'death_reason_name': 'وفاة طبيعية',
            },
          },
        },
        localBeneficiaryId: beneficiaryId,
      );

      expect(outcome, SyncRelatedWriteOutcome.inserted);

      final rows = await (database.select(database.familyDeceasedTable)
            ..where((t) => t.beneficiaryId.equals(beneficiaryId))
            ..orderBy([(t) => drift.OrderingTerm.asc(t.deceasedType)]))
          .get();

      expect(rows, hasLength(2));
      final father = rows.firstWhere((r) => r.deceasedType == 1);
      final mother = rows.firstWhere((r) => r.deceasedType == 2);

      expect(father.firstName, 'أحمد');
      expect(father.nationalId, 111111111);
      expect(father.deathCause, 1);
      expect(father.serverId, 7001);

      expect(mother.firstName, 'فاطمة');
      expect(mother.nationalId, 222222222);
      expect(mother.deathCause, 2);
      expect(mother.serverId, 7002);

      final fatherParity = await database.customSelect(
        'SELECT re_file_id, death_reason_name FROM dead_people_contract_fields WHERE family_deceased_id = ?',
        variables: [drift.Variable<int>(father.id)],
      ).getSingle();
      expect(fatherParity.read<String?>('re_file_id'), '2001');
      expect(fatherParity.read<String?>('death_reason_name'), 'شهيد');
    });

    test('upsertFamilyDeceased prunes explicitly empty parent branch', () async {
      final beneficiaryId = await seedBeneficiary(fileId: '2002');

      await repository.upsertFamilyDeceased(
        {
          'id': 701,
          'father': {
            'first_name': 'أحمد',
            'last_name': 'النجار',
            'id_number': 111111111,
          },
          'mother': {
            'first_name': 'فاطمة',
            'last_name': 'النجار',
            'id_number': 222222222,
          },
        },
        localBeneficiaryId: beneficiaryId,
      );

      final pruneOutcome = await repository.upsertFamilyDeceased(
        {
          'id': 702,
          'father': {
            'first_name': '',
            'last_name': '',
            'id_number': 0,
          },
          'mother': {
            'first_name': 'فاطمة',
            'last_name': 'النجار',
            'id_number': 222222222,
            'death_reason': 2,
          },
        },
        localBeneficiaryId: beneficiaryId,
      );

      expect(pruneOutcome, anyOf(SyncRelatedWriteOutcome.inserted, SyncRelatedWriteOutcome.updated));

      final rows = await (database.select(database.familyDeceasedTable)
            ..where((t) => t.beneficiaryId.equals(beneficiaryId))
            ..orderBy([(t) => drift.OrderingTerm.asc(t.deceasedType)]))
          .get();

      expect(rows.any((r) => r.deceasedType == 1), isFalse);
      final mothers = rows.where((r) => r.deceasedType == 2).toList(growable: false);
      expect(mothers, isNotEmpty);
      expect(mothers.last.firstName, 'فاطمة');
    });

    test('upsertFamilyDeceased returns skipped when payload has no meaningful parent data', () async {
      final beneficiaryId = await seedBeneficiary(fileId: '2003');

      final outcome = await repository.upsertFamilyDeceased(
        {
          'id': 703,
          'father': {
            'first_name': '',
            'last_name': '',
            'id_number': 0,
          },
          'mother': {
            'first_name': '',
            'last_name': '',
            'id_number': 0,
          },
        },
        localBeneficiaryId: beneficiaryId,
      );

      expect(outcome, SyncRelatedWriteOutcome.skipped);

      final rows = await (database.select(database.familyDeceasedTable)
            ..where((t) => t.beneficiaryId.equals(beneficiaryId)))
          .get();
      expect(rows, isEmpty);
    });
  });

  group('MobileSyncRelatedEntitiesRepository attachments', () {
    test('upsertAttachment stores contract metadata sidecar fields', () async {
      final beneficiaryId = await seedBeneficiary(fileId: '3001');

      final outcome = await repository.upsertAttachment(
        {
          'id': 9901,
          'person_identity_number': '123456789',
          'stored_file_name': 'proof_3001.pdf',
          'file_path': 'uploads/3001/proof_3001.pdf',
          'mime_type': 'application/pdf',
          'file_type': 'شهادة',
          'download_url': '/api/mobile/database/attachments/9901/download',
          'google_drive_file_id': 'drive-123',
          'google_drive_path': '/docs/3001/proof_3001.pdf',
          'uploaded_to_drive_at': '2026-03-09T10:00:00Z',
        },
        localBeneficiaryId: beneficiaryId,
        sequence: 0,
      );

      expect(outcome, SyncRelatedWriteOutcome.inserted);

      final sidecar = await database.customSelect(
        'SELECT server_attachment_id, mime_type, file_type_label, download_url, google_drive_file_id '
        'FROM attachments_contract_fields WHERE attachment_id = ?',
        variables: [const drift.Variable<String>('srv_att_9901')],
      ).getSingle();

      expect(sidecar.read<int?>('server_attachment_id'), 9901);
      expect(sidecar.read<String?>('mime_type'), 'application/pdf');
      expect(sidecar.read<String?>('file_type_label'), 'شهادة');
      expect(sidecar.read<String?>('download_url'), '/api/mobile/database/attachments/9901/download');
      expect(sidecar.read<String?>('google_drive_file_id'), 'drive-123');
    });

    test('deleteAttachmentFromServerRow returns false when no matching local record exists', () async {
      final deleted = await repository.deleteAttachmentFromServerRow({
        'id': 123456,
        'download_url': '/api/mobile/database/attachments/123456/download',
      });

      expect(deleted, isFalse);
    });
  });
}
