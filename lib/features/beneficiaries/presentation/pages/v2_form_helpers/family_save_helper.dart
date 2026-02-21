import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import '../../../../../data/db/drift_database.dart';
import '../../../../../core/utils/beneficiary_identity_resolver.dart';

/// 👨‍👩‍👧‍👦 مساعد حفظ وتحميل بيانات أفراد العائلة
class FamilySaveHelper {
  /// ⬇️ تحميل بيانات أفراد العائلة من قاعدة البيانات
  static Future<({List<Map<String, dynamic>> living, List<Map<String, dynamic>> deceased})> loadFamilyMembers({
    required AppDatabase database,
    required String beneficiaryId,
  }) async {
    try {
      final intBeneficiaryId = await _resolveBeneficiaryLocalId(
        database: database,
        beneficiaryId: beneficiaryId,
      );

      if (intBeneficiaryId == null) {
        debugPrint('⚠️ [FamilySaveHelper] Could not resolve local beneficiary id for: $beneficiaryId');
        return (
          living: <Map<String, dynamic>>[],
          deceased: <Map<String, dynamic>>[],
        );
      }

      // تحميل الأحياء والأموات بالتوازي للأداء
      final results = await Future.wait([
        database.familyMembersDao.getMembersByBeneficiary(intBeneficiaryId),
        database.familyDeceasedDao.getDeceasedByBeneficiary(intBeneficiaryId),
      ]);

      final livingMembers = results[0] as List<FamilyMember>;
      final deceasedMembers = results[1] as List<FamilyDeceased>;

      // تحويل إلى Map - NEW SCHEMA
      final livingList = livingMembers
          .map(
            (m) => {
              'id': m.id,
              'orphanNationalId': m.orphanNationalId,
              'firstName': m.firstName,
              'secondName': m.secondName,
              'thirdName': m.thirdName,
              'familyName': m.familyName,
              'birthDate': m.birthDate,
              'age': m.age,
              'gender': m.gender,
              'healthStatus': m.healthStatus,
              'attachments': m.attachments,
              'notes': m.notes,
            },
          )
          .toList();

      final deceasedList = deceasedMembers
          .map(
            (d) => {
              'id': d.id,
              'deceasedType': d.deceasedType,
              'firstName': d.firstName,
              'secondName': d.secondName,
              'thirdName': d.thirdName,
              'familyName': d.familyName,
              'nationalId': d.nationalId,
              'deathDate': d.deathDate,
              'deathCause': d.deathCause,
              'documentType': d.documentType,
              'documentPath': d.documentPath,
              'notes': d.notes,
            },
          )
          .toList();

      debugPrint(
        '⬇️ [FamilySaveHelper] Loaded ${livingList.length} living and ${deceasedList.length} deceased members',
      );

      return (living: livingList, deceased: deceasedList);
    } catch (e) {
      debugPrint('❌ [FamilySaveHelper] Error loading family members: $e');
      return (
        living: <Map<String, dynamic>>[],
        deceased: <Map<String, dynamic>>[],
      );
    }
  }

  static Future<int?> _resolveBeneficiaryLocalId({
    required AppDatabase database,
    required String beneficiaryId,
  }) async {
    return BeneficiaryIdentityResolver.resolveLocalBeneficiaryId(
      database: database,
      beneficiaryId: beneficiaryId,
    );
  }

  /// ⬆️ حفظ أفراد العائلة الأحياء والأموات
  static Future<void> saveFamilyMembers({
    required AppDatabase database,
    required String beneficiaryId,
    required List<Map<String, dynamic>> livingMembers,
    required List<Map<String, dynamic>> deceasedMembers,
  }) async {
    try {
      final intBeneficiaryId = await _resolveBeneficiaryLocalId(
        database: database,
        beneficiaryId: beneficiaryId,
      );

      if (intBeneficiaryId == null) {
        throw StateError('Could not resolve local beneficiary id for family save: $beneficiaryId');
      }

      // 🔥 حذف البيانات القديمة أولاً (لتجنب التكرار)
      await database.transaction(() async {
        // حذف الأحياء القدامى
        final oldLiving = await database.familyMembersDao.getMembersByBeneficiary(intBeneficiaryId);
        for (final old in oldLiving) {
          await database.familyMembersDao.deleteMember(old.id);
        }

        // حذف الأموات القدامى
        final oldDeceased = await database.familyDeceasedDao.getDeceasedByBeneficiary(intBeneficiaryId);
        for (final old in oldDeceased) {
          await database.familyDeceasedDao.deleteDeceased(old.id);
        }

        // ⚡ حفظ الأحياء الجدد بـ Batch (أداء أفضل) - NEW SCHEMA
        if (livingMembers.isNotEmpty) {
          await database.batch((batch) {
            for (final member in livingMembers) {
              batch.insert(
                database.familyMembersTable,
                FamilyMembersTableCompanion.insert(
                  beneficiaryId: intBeneficiaryId,
                  orphanNationalId: member['orphanNationalId'] ?? 0,
                  firstName: member['firstName'] ?? '',
                  secondName: Value(member['secondName']),
                  thirdName: Value(member['thirdName']),
                  familyName: member['familyName'] ?? '',
                  birthDate: member['birthDate'] ?? DateTime.now(),
                  age: Value(member['age']),
                  gender: member['gender'] ?? 1, // 1=male
                  healthStatus: member['healthStatus'] ?? 5, // 5=unknown
                  attachments: Value(member['attachments']),
                  notes: Value(member['notes']),
                  syncState: const Value('pending'),
                ),
              );
            }
          });
        }

        // ⚡ حفظ الأموات الجدد بـ Batch (أداء أفضل) - NEW SCHEMA
        if (deceasedMembers.isNotEmpty) {
          await database.batch((batch) {
            for (final deceased in deceasedMembers) {
              batch.insert(
                database.familyDeceasedTable,
                FamilyDeceasedTableCompanion.insert(
                  beneficiaryId: intBeneficiaryId,
                  deceasedType: deceased['deceasedType'] ?? 1, // 1=father
                  firstName: deceased['firstName'] ?? '',
                  secondName: Value(deceased['secondName']),
                  thirdName: Value(deceased['thirdName']),
                  familyName: deceased['familyName'] ?? '',
                  nationalId: deceased['nationalId'] ?? 0,
                  deathDate: deceased['deathDate'] ?? DateTime.now(),
                  deathCause: deceased['deathCause'] ?? 8, // 8=unknown
                  documentType: Value(deceased['documentType']),
                  documentPath: Value(deceased['documentPath']),
                  notes: Value(deceased['notes']),
                  syncState: const Value('pending'),
                ),
              );
            }
          });
        }
      });

      debugPrint(
        '⬆️ [FamilySaveHelper] Saved ${livingMembers.length} living and ${deceasedMembers.length} deceased members',
      );
    } catch (e) {
      debugPrint('❌ [FamilySaveHelper] Error saving family members: $e');
      rethrow;
    }
  }
}
