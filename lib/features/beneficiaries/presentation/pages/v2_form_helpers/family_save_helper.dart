import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import '../../../../../data/db/drift_database.dart';

/// 👨‍👩‍👧‍👦 مساعد حفظ وتحميل بيانات أفراد العائلة
class FamilySaveHelper {
  /// ⬇️ تحميل بيانات أفراد العائلة من قاعدة البيانات
  static Future<
    ({List<Map<String, dynamic>> living, List<Map<String, dynamic>> deceased})
  >
  loadFamilyMembers({
    required AppDatabase database,
    required String beneficiaryId,
  }) async {
    try {
      final intBeneficiaryId = int.parse(beneficiaryId);

      // تحميل الأحياء والأموات بالتوازي للأداء
      final results = await Future.wait([
        database.familyMembersDao.getMembersByBeneficiary(intBeneficiaryId),
        database.familyDeceasedDao.getDeceasedByBeneficiary(intBeneficiaryId),
      ]);

      final livingMembers = results[0] as List<FamilyMember>;
      final deceasedMembers = results[1] as List<FamilyDeceased>;

      // تحويل إلى Map
      final livingList = livingMembers
          .map(
            (m) => {
              'id': m.id,
              'fullName': m.fullName,
              'relationship': m.relationship,
              'gender': m.gender,
              'nationalId': m.nationalId,
              'birthDate': m.birthDate,
              'age': m.age,
              'phone': m.phone,
              'maritalStatus': m.maritalStatus,
              'educationLevel': m.educationLevel,
              'occupation': m.occupation,
              'healthStatus': m.healthStatus,
              'hasDisability': m.hasDisability,
              'disabilityType': m.disabilityType,
              'hasChronicDisease': m.hasChronicDisease,
              'chronicDiseaseType': m.chronicDiseaseType,
              'livesWithBeneficiary': m.livesWithBeneficiary,
              'notes': m.notes,
            },
          )
          .toList();

      final deceasedList = deceasedMembers
          .map(
            (d) => {
              'id': d.id,
              'fullName': d.fullName,
              'relationship': d.relationship,
              'gender': d.gender,
              'deathDate': d.deathDate,
              'deathCause': d.deathCause,
              'ageAtDeath': d.ageAtDeath,
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

  /// ⬆️ حفظ أفراد العائلة الأحياء والأموات
  static Future<void> saveFamilyMembers({
    required AppDatabase database,
    required String beneficiaryId,
    required List<Map<String, dynamic>> livingMembers,
    required List<Map<String, dynamic>> deceasedMembers,
  }) async {
    try {
      final intBeneficiaryId = int.parse(beneficiaryId);

      // 🔥 حذف البيانات القديمة أولاً (لتجنب التكرار)
      await database.transaction(() async {
        // حذف الأحياء القدامى
        final oldLiving = await database.familyMembersDao
            .getMembersByBeneficiary(intBeneficiaryId);
        for (final old in oldLiving) {
          await database.familyMembersDao.deleteMember(old.id);
        }

        // حذف الأموات القدامى
        final oldDeceased = await database.familyDeceasedDao
            .getDeceasedByBeneficiary(intBeneficiaryId);
        for (final old in oldDeceased) {
          await database.familyDeceasedDao.deleteDeceased(old.id);
        }

        // ⚡ حفظ الأحياء الجدد بـ Batch (أداء أفضل)
        if (livingMembers.isNotEmpty) {
          await database.batch((batch) {
            for (final member in livingMembers) {
              batch.insert(
                database.familyMembersTable,
                FamilyMembersTableCompanion.insert(
                  beneficiaryId: intBeneficiaryId,
                  fullName: member['fullName'] ?? '',
                  relationship: member['relationship'] ?? '',
                  gender: member['gender'] ?? '',
                  nationalId: Value(member['nationalId']),
                  birthDate: Value(member['birthDate']),
                  age: Value(member['age']),
                  phone: Value(member['phone']),
                  maritalStatus: Value(member['maritalStatus']),
                  educationLevel: Value(member['educationLevel']),
                  occupation: Value(member['occupation']),
                  healthStatus: Value(member['healthStatus']),
                  hasDisability: Value(member['hasDisability'] ?? false),
                  disabilityType: Value(member['disabilityType']),
                  hasChronicDisease: Value(
                    member['hasChronicDisease'] ?? false,
                  ),
                  chronicDiseaseType: Value(member['chronicDiseaseType']),
                  livesWithBeneficiary: Value(
                    member['livesWithBeneficiary'] ?? false,
                  ),
                  notes: Value(member['notes']),
                  syncState: const Value('pending'),
                ),
              );
            }
          });
        }

        // ⚡ حفظ الأموات الجدد بـ Batch (أداء أفضل)
        if (deceasedMembers.isNotEmpty) {
          await database.batch((batch) {
            for (final deceased in deceasedMembers) {
              batch.insert(
                database.familyDeceasedTable,
                FamilyDeceasedTableCompanion.insert(
                  beneficiaryId: intBeneficiaryId,
                  fullName: deceased['fullName'] ?? '',
                  relationship: deceased['relationship'] ?? '',
                  gender: deceased['gender'] ?? '',
                  deathDate: Value(deceased['deathDate']),
                  deathCause: Value(deceased['deathCause']),
                  ageAtDeath: Value(deceased['ageAtDeath']),
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
