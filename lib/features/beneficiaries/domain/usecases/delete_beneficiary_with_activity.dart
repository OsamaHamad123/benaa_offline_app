import 'package:benaa_offline_app/data/db/drift_database.dart';
import 'package:benaa_offline_app/features/dashboard/domain/usecases/log_activity.dart';

/// UseCase: حذف مستفيد + تسجيل Activity تلقائياً
///
/// يجمع بين:
/// 1. حذف المستفيد من قاعدة البيانات
/// 2. تسجيل Activity (نشاط) لهذه العملية
class DeleteBeneficiaryWithActivity {
  final AppDatabase database;
  final LogActivity logActivity;

  DeleteBeneficiaryWithActivity({
    required this.database,
    required this.logActivity,
  });

  Future<void> call({
    required int beneficiaryId,
    required String beneficiaryName,
    String? category,
    String? fileNo,
  }) async {
    // 1. تسجيل Activity أولاً (قبل الحذف)
    await logActivity(
      type: 'beneficiary',
      description: 'تم حذف المستفيد',
      beneficiaryId: beneficiaryId.toString(),
      beneficiaryName: beneficiaryName,
      metadata: {
        'action': 'delete',
        if (category != null) 'category': category,
        if (fileNo != null) 'file_no': fileNo,
        'deleted_at': DateTime.now().toIso8601String(),
      },
    );

    // 2. حذف المستفيد
    await database.beneficiariesDao.deleteBeneficiary(beneficiaryId);
  }
}
