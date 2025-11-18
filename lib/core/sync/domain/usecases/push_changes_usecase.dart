import '../entities/sync_result.dart';
import '../repositories/i_sync_repository.dart';

/// 🎯 Use Case - Push Changes
///
/// حالة الاستخدام: رفع التغييرات المحلية للسيرفر
class PushChangesUseCase {
  final ISyncRepository _repository;

  const PushChangesUseCase(this._repository);

  /// رفع التغييرات المعلقة
  ///
  /// [entityType] نوع البيانات
  ///
  /// Returns: [SyncResult] نتيجة الرفع
  Future<SyncResult> execute(String entityType) async {
    try {
      // Check if there are pending changes
      final pendingCount = await _repository.getPendingChangesCount(entityType);

      if (pendingCount == 0) {
        return SyncSuccess(
          itemsSynced: 0,
          syncedAt: DateTime.now(),
          message: 'لا توجد تغييرات معلقة',
        );
      }

      // Push changes
      return await _repository.pushChanges(entityType);
    } catch (e, stackTrace) {
      return SyncFailure(
        error: 'فشل رفع التغييرات: ${e.toString()}',
        stackTrace: stackTrace,
        failedAt: DateTime.now(),
      );
    }
  }

  /// رفع جميع التغييرات المعلقة
  ///
  /// Returns: Map من نوع البيانات إلى نتيجة الرفع
  Future<Map<String, SyncResult>> executeAll() async {
    final entityTypes = ['beneficiaries', 'visits', 'attachments'];
    final results = <String, SyncResult>{};

    for (final entityType in entityTypes) {
      results[entityType] = await execute(entityType);
    }

    return results;
  }

  /// الحصول على عدد التغييرات المعلقة
  ///
  /// [entityType] نوع البيانات (null = الكل)
  Future<int> getPendingCount([String? entityType]) async {
    if (entityType != null) {
      return await _repository.getPendingChangesCount(entityType);
    }

    // Get total pending for all types
    int total = 0;
    for (final type in ['beneficiaries', 'visits', 'attachments']) {
      total += await _repository.getPendingChangesCount(type);
    }
    return total;
  }
}
