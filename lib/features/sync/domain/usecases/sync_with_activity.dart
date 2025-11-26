import 'package:benaa_offline_app/features/dashboard/domain/usecases/log_activity.dart';
import 'package:benaa_offline_app/core/sync/sync_manager.dart';

/// UseCase: مزامنة + تسجيل Activity تلقائياً
///
/// يجمع بين:
/// 1. تنفيذ عملية المزامنة
/// 2. تسجيل Activity (نشاط) للمزامنة
class SyncWithActivity {
  final SyncManager syncManager;
  final LogActivity logActivity;

  SyncWithActivity({required this.syncManager, required this.logActivity});

  /// مزامنة الكل مع تسجيل النشاط
  Future<void> syncAll() async {
    final startTime = DateTime.now();

    try {
      // 1. بدء المزامنة
      await logActivity(
        type: 'sync',
        description: 'بدأت عملية المزامنة',
        metadata: {
          'action': 'sync_start',
          'start_time': startTime.toIso8601String(),
        },
      );

      // 2. تنفيذ المزامنة
      await syncManager.syncAll();

      // 3. تسجيل النجاح
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      await logActivity(
        type: 'sync',
        description: 'تمت المزامنة بنجاح',
        metadata: {
          'action': 'sync_complete',
          'start_time': startTime.toIso8601String(),
          'end_time': endTime.toIso8601String(),
          'duration_seconds': duration.inSeconds,
          'total_items': syncManager.currentStatus.totalItems,
          'completed_items': syncManager.currentStatus.completedItems,
        },
      );
    } catch (e) {
      // 4. تسجيل الفشل
      await logActivity(
        type: 'sync',
        description: 'فشلت عملية المزامنة',
        metadata: {
          'action': 'sync_failed',
          'error': e.toString(),
          'start_time': startTime.toIso8601String(),
          'failed_at': DateTime.now().toIso8601String(),
        },
      );
      rethrow;
    }
  }

  /// مزامنة سحب البيانات من السيرفر
  Future<void> pullFromServer({DateTime? updatedAfter}) async {
    final startTime = DateTime.now();

    try {
      // 1. تسجيل بدء السحب
      await logActivity(
        type: 'sync',
        description: 'بدأت عملية سحب البيانات من السيرفر',
        metadata: {
          'action': 'pull_start',
          'updated_after': updatedAfter?.toIso8601String(),
        },
      );

      // 2. سحب البيانات
      final count = await syncManager.pullBeneficiariesFromServer(
        updatedAfter: updatedAfter,
      );

      // 3. تسجيل النجاح
      await logActivity(
        type: 'sync',
        description: 'تم سحب $count مستفيدين من السيرفر',
        metadata: {
          'action': 'pull_complete',
          'count': count,
          'duration_seconds': DateTime.now().difference(startTime).inSeconds,
        },
      );
    } catch (e) {
      // 4. تسجيل الفشل
      await logActivity(
        type: 'sync',
        description: 'فشلت عملية سحب البيانات',
        metadata: {'action': 'pull_failed', 'error': e.toString()},
      );
      rethrow;
    }
  }
}
