import 'package:benaa_offline_app/data/db/drift_database.dart';
import 'package:benaa_offline_app/features/dashboard/domain/usecases/log_activity.dart';

/// UseCase: إنشاء مستفيد جديد + تسجيل Activity تلقائياً
///
/// يجمع بين:
/// 1. إضافة المستفيد إلى قاعدة البيانات
/// 2. تسجيل Activity (نشاط) لهذه العملية
class CreateBeneficiaryWithActivity {
  final AppDatabase database;
  final LogActivity logActivity;

  CreateBeneficiaryWithActivity({
    required this.database,
    required this.logActivity,
  });

  Future<void> call({
    required BeneficiariesCompanion beneficiary,
    required String beneficiaryName,
  }) async {
    // 1. إنشاء المستفيد
    await database.beneficiariesDao.insertBeneficiary(beneficiary);

    // 2. تسجيل Activity
    final beneficiaryId = beneficiary.id.value;
    await logActivity(
      type: 'beneficiary',
      description: 'تم إضافة مستفيد جديد',
      beneficiaryId: beneficiaryId.toString(),
      beneficiaryName: beneficiaryName,
      metadata: {
        'action': 'create',
        'national_id': beneficiary.idNumber.value,
        'file_no': beneficiary.fileIdNumber.value,
        'category': beneficiary.sectionId.value,
      },
    );
  }
}
