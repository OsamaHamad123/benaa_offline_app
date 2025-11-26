import 'package:benaa_offline_app/data/db/drift_database.dart';
import 'package:benaa_offline_app/features/dashboard/domain/usecases/log_activity.dart';

/// UseCase: إضافة مرفق + تسجيل Activity تلقائياً
///
/// يجمع بين:
/// 1. إضافة المرفق إلى قاعدة البيانات
/// 2. تسجيل Activity (نشاط) لهذه العملية
class AddAttachmentWithActivity {
  final AppDatabase database;
  final LogActivity logActivity;

  AddAttachmentWithActivity({
    required this.database,
    required this.logActivity,
  });

  Future<void> call({
    required AttachmentsCompanion attachment,
    required String beneficiaryName,
  }) async {
    // 1. إضافة المرفق
    await database.attachmentsDao.addAttachment(attachment);

    // 2. تسجيل Activity
    await logActivity(
      type: 'attachment',
      description: 'تم إضافة مرفق جديد',
      beneficiaryId: attachment.beneficiaryId.value.toString(),
      beneficiaryName: beneficiaryName,
      metadata: {
        'action': 'add',
        'file_name': attachment.fileName.value,
        'file_type': attachment.type.value,
        'file_path': attachment.filePath.value,
      },
    );
  }
}
