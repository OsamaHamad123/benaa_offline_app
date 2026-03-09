import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:benaa_offline_app/data/db/drift_database.dart';
import 'package:benaa_offline_app/features/sync/presentation/viewmodels/mobile_sync_dashboard_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('backfillContractParity fills missing sidecar rows from local related entities', () async {
    final beneficiaryId = await database.into(database.beneficiaries).insert(
          BeneficiariesCompanion.insert(
            idNumber: 123456789,
            phoneNumber: 599111111,
            altPhoneNumber: 599222222,
            firstName: const drift.Value('مستفيد'),
            fatherName: const drift.Value('تجربة'),
            grandFatherName: const drift.Value('واحد'),
            familyName: const drift.Value('اختبار'),
            fileIdNumber: const drift.Value('7777'),
          ),
        );

    await database.into(database.familyMembersTable).insert(
          FamilyMembersTableCompanion.insert(
            beneficiaryId: beneficiaryId,
            orphanNationalId: 111222333,
            firstName: 'ابن',
            familyName: 'العائلة',
            birthDate: DateTime(2015, 1, 1),
            gender: 1,
            healthStatus: 1,
          ),
        );

    await database.into(database.familyDeceasedTable).insert(
          FamilyDeceasedTableCompanion.insert(
            beneficiaryId: beneficiaryId,
            deceasedType: 1,
            firstName: 'الأب',
            familyName: 'العائلة',
            nationalId: 222333444,
            deathDate: DateTime(2024, 1, 1),
            deathCause: 2,
          ),
        );

    await database.into(database.attachments).insert(
          AttachmentsCompanion.insert(
            id: 'att_local_1',
            beneficiaryId: beneficiaryId.toString(),
            fileName: 'doc.pdf',
            filePath: '/tmp/doc.pdf',
            type: 'pdf',
            fileSize: 128,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            serverUrl: const drift.Value('/api/mobile/database/attachments/1/download'),
          ),
        );

    final result = await MobileSyncDashboardLoader.backfillContractParity(database);

    expect(result.rePeopleFilled, 1);
    expect(result.deadPeopleFilled, 1);
    expect(result.attachmentsFilled, 1);

    final reCount = await database.customSelect('SELECT COUNT(*) AS cnt FROM re_people_contract_fields').getSingle();
    final deadCount =
        await database.customSelect('SELECT COUNT(*) AS cnt FROM dead_people_contract_fields').getSingle();
    final attCount = await database.customSelect('SELECT COUNT(*) AS cnt FROM attachments_contract_fields').getSingle();

    expect(reCount.read<int>('cnt'), 1);
    expect(deadCount.read<int>('cnt'), 1);
    expect(attCount.read<int>('cnt'), 1);
  });
}
