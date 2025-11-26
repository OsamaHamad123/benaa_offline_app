import 'package:benaa_offline_app/data/db/drift_database.dart';
import 'package:benaa_offline_app/features/dashboard/domain/usecases/log_activity.dart';

/// UseCase: حذف مرفق + تسجيل Activity تلقائياً
///
/// يجمع بين:
/// 1. حذف المرفق من قاعدة البيانات
/// 2. تسجيل Activity (نشاط) لهذه العملية
class DeleteAttachmentWithActivity {
  final AppDatabase database;
  final LogActivity logActivity;

  DeleteAttachmentWithActivity({
    required this.database,
    required this.logActivity,
  });

  Future<void> call({
    required Attachment attachment,
    required String beneficiaryName,
  }) async {
    // 1. تسجيل Activity أولاً (قبل الحذف)
    await logActivity(
      type: 'attachment',
      description: 'تم حذف مرفق',
      beneficiaryId: attachment.beneficiaryId.toString(),
      beneficiaryName: beneficiaryName,
      metadata: {
        'action': 'delete',
        'file_name': attachment.fileName,
        'file_type': attachment.type,
        'file_path': attachment.filePath,
        'deleted_at': DateTime.now().toIso8601String(),
      },
    );

    // 2. حذف المرفق
    await database.attachmentsDao.deleteAttachment(attachment.id);
  }
}
