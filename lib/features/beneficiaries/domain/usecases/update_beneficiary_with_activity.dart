import 'package:benaa_offline_app/data/db/drift_database.dart';
import 'package:benaa_offline_app/features/dashboard/domain/usecases/log_activity.dart';

/// UseCase: تحديث مستفيد + تسجيل Activity تلقائياً
///
/// يجمع بين:
/// 1. تحديث بيانات المستفيد في قاعدة البيانات
/// 2. تسجيل Activity (نشاط) لهذه العملية
class UpdateBeneficiaryWithActivity {
  final AppDatabase database;
  final LogActivity logActivity;

  UpdateBeneficiaryWithActivity({
    required this.database,
    required this.logActivity,
  });

  Future<void> call({
    required int beneficiaryId,
    required BeneficiariesCompanion beneficiary,
    required String beneficiaryName,
  }) async {
    // 1. تحديث المستفيد
    await database.beneficiariesDao.updateBeneficiaryCompanion(
      beneficiaryId,
      beneficiary,
    );

    // 2. تسجيل Activity
    await logActivity(
      type: 'beneficiary',
      description: 'تم تحديث بيانات المستفيد',
      beneficiaryId: beneficiaryId.toString(),
      beneficiaryName: beneficiaryName,
      metadata: {
        'action': 'update',
        'updated_fields': _getUpdatedFields(beneficiary),
      },
    );
  }

  /// استخراج الحقول المحدثة فقط
  List<String> _getUpdatedFields(BeneficiariesCompanion companion) {
    final fields = <String>[];
    if (companion.firstName.present) fields.add('first_name');
    if (companion.fatherName.present) fields.add('father_name');
    if (companion.familyName.present) fields.add('family_name');
    if (companion.idNumber.present) fields.add('id_number');
    if (companion.fileIdNumber.present) fields.add('file_id_number');
    if (companion.province.present) fields.add('province');
    if (companion.sectionId.present) fields.add('section_id');
    if (companion.phoneNumber.present) fields.add('phone_number');
    if (companion.currentAddress.present) fields.add('current_address');
    if (companion.descriptionNeeds.present) fields.add('description_needs');
    return fields;
  }
}
