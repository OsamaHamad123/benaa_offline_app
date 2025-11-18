import '../entities/sync_result.dart';
import '../repositories/i_sync_repository.dart';

/// 🎯 Use Case - Delta Sync
///
/// حالة الاستخدام: المزامنة الذكية (التغييرات فقط)
/// هذا هو النوع الأكثر استخداماً في التطبيق
class DeltaSyncUseCase {
  final ISyncRepository _repository;

  const DeltaSyncUseCase(this._repository);

  /// تنفيذ المزامنة الذكية
  ///
  /// [entityType] نوع البيانات المراد مزامنتها
  /// [conflictResolution] استراتيجية حل التعارضات (افتراضي: السيرفر يفوز)
  ///
  /// Returns: [SyncResult] نتيجة المزامنة
  Future<SyncResult> execute(
    String entityType, {
    ConflictResolution conflictResolution = ConflictResolution.acceptServer,
  }) async {
    try {
      // 1. Get last sync time
      final lastSyncTime = await _repository.getLastSyncTime(entityType);

      // 2. Perform delta sync
      final result = await _repository.deltaSync(
        entityType,
        lastSyncTime: lastSyncTime,
        conflictResolution: conflictResolution,
      );

      return result;
    } catch (e, stackTrace) {
      return SyncFailure(
        error: 'فشلت المزامنة: ${e.toString()}',
        stackTrace: stackTrace,
        failedAt: DateTime.now(),
      );
    }
  }

  /// مزامنة عدة أنواع دفعة واحدة
  ///
  /// [entityTypes] قائمة أنواع البيانات
  ///
  /// Returns: Map من نوع البيانات إلى نتيجة المزامنة
  Future<Map<String, SyncResult>> executeMultiple(
    List<String> entityTypes, {
    ConflictResolution conflictResolution = ConflictResolution.acceptServer,
  }) async {
    final results = <String, SyncResult>{};

    for (final entityType in entityTypes) {
      results[entityType] = await execute(
        entityType,
        conflictResolution: conflictResolution,
      );
    }

    return results;
  }

  /// هل هناك حاجة للمزامنة؟
  ///
  /// [entityType] نوع البيانات
  /// [threshold] الحد الأدنى للوقت بين المزامنات (افتراضي: 5 دقائق)
  Future<bool> shouldSync(
    String entityType, {
    Duration threshold = const Duration(minutes: 5),
  }) async {
    final lastSyncTime = await _repository.getLastSyncTime(entityType);

    // First sync
    if (lastSyncTime == null) return true;

    // Check if enough time has passed
    final timeSinceLastSync = DateTime.now().difference(lastSyncTime);
    return timeSinceLastSync >= threshold;
  }
}
