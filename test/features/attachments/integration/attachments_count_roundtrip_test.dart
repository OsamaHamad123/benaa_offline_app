import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:benaa_offline_app/data/db/drift_database.dart';
import 'package:benaa_offline_app/features/attachments/data/datasources/attachment_datasource.dart';

void main() {
  group('Attachments integration - count roundtrip', () {
    late AppDatabase database;
    late AttachmentDataSource dataSource;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      dataSource = AttachmentDataSource(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('returns all stored attachments for beneficiary with exact count', () async {
      const beneficiaryId = '1001';
      final now = DateTime(2026, 2, 24, 10, 0, 0);

      Future<void> insertAttachment({
        required String id,
        required String fileName,
        required String type,
      }) async {
        await database.into(database.attachments).insert(
              AttachmentsCompanion.insert(
                id: id,
                beneficiaryId: beneficiaryId,
                fileName: fileName,
                filePath: '/tmp/$fileName',
                type: type,
                fileSize: 1234,
                createdAt: now,
                updatedAt: now,
              ),
            );
      }

      await insertAttachment(id: 'a-1', fileName: 'id_card.jpg', type: 'image');
      await insertAttachment(id: 'a-2', fileName: 'report.pdf', type: 'pdf');
      await insertAttachment(id: 'a-3', fileName: 'other.bin', type: 'other');

      final dbRows = await database.attachmentsDao.getBeneficiaryAttachments(beneficiaryId);
      final models = await dataSource.getBeneficiaryAttachments(beneficiaryId);

      expect(models.length, dbRows.length);
      expect(models.length, 3);
      expect(models.map((e) => e.id).toSet(), {'a-1', 'a-2', 'a-3'});
      expect(models.map((e) => e.type.name).toSet(), {'image', 'pdf', 'other'});
    });
  });
}
