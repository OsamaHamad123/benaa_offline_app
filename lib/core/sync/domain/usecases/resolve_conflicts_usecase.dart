import '../entities/sync_result.dart';
import '../repositories/i_sync_repository.dart';

/// 🎯 Use Case - Resolve Conflicts
///
/// حالة الاستخدام: حل التعارضات بين النسخة المحلية والسيرفر
class ResolveConflictsUseCase {
  final ISyncRepository _repository;

  const ResolveConflictsUseCase(this._repository);

  /// حل التعارضات باستخدام استراتيجية محددة
  ///
  /// [conflicts] قائمة التعارضات
  /// [resolution] طريقة الحل
  ///
  /// Returns: [SyncResult] نتيجة الحل
  Future<SyncResult> execute(
    List<SyncConflict> conflicts,
    ConflictResolution resolution,
  ) async {
    try {
      if (conflicts.isEmpty) {
        return SyncSuccess(
          itemsSynced: 0,
          syncedAt: DateTime.now(),
          message: 'لا توجد تعارضات',
        );
      }

      return await _repository.resolveConflicts(conflicts, resolution);
    } catch (e, stackTrace) {
      return SyncFailure(
        error: 'فشل حل التعارضات: ${e.toString()}',
        stackTrace: stackTrace,
        failedAt: DateTime.now(),
      );
    }
  }

  /// حل تعارض واحد
  ///
  /// [conflict] التعارض المراد حله
  /// [resolution] طريقة الحل
  Future<SyncResult> resolveSingle(
    SyncConflict conflict,
    ConflictResolution resolution,
  ) async {
    return execute([conflict], resolution);
  }

  /// الحصول على استراتيجية الحل الموصى بها
  ///
  /// [conflict] التعارض
  ///
  /// Returns: الاستراتيجية الموصى بها بناءً على نوع التعارض
  ConflictResolution getRecommendedResolution(SyncConflict conflict) {
    switch (conflict.reason) {
      case ConflictReason.editEditConflict:
        // إذا السيرفر أحدث، اقبل السيرفر
        return conflict.isServerNewer
            ? ConflictResolution.acceptServer
            : ConflictResolution.keepLocal;

      case ConflictReason.editDeleteConflict:
        // إذا تم حذف العنصر من السيرفر، احذفه محلياً
        return ConflictResolution.acceptServer;

      case ConflictReason.deleteEditConflict:
        // إذا تم حذفه محلياً لكن معدل في السيرفر، احتفظ بالسيرفر
        return ConflictResolution.acceptServer;

      case ConflictReason.versionMismatch:
        // اسأل المستخدم في حالة اختلاف الإصدار
        return ConflictResolution.askUser;

      case ConflictReason.unknown:
        // في الحالات غير المعروفة، السيرفر يفوز (أكثر أماناً)
        return ConflictResolution.acceptServer;
    }
  }

  /// تصنيف التعارضات حسب النوع
  ///
  /// [conflicts] قائمة التعارضات
  ///
  /// Returns: Map من نوع التعارض إلى قائمة التعارضات
  Map<ConflictReason, List<SyncConflict>> categorizeConflicts(
    List<SyncConflict> conflicts,
  ) {
    final categorized = <ConflictReason, List<SyncConflict>>{};

    for (final conflict in conflicts) {
      categorized.putIfAbsent(conflict.reason, () => []).add(conflict);
    }

    return categorized;
  }

  /// حل جميع التعارضات تلقائياً
  ///
  /// [conflicts] قائمة التعارضات
  ///
  /// Returns: نتائج الحل لكل تعارض
  Future<Map<String, SyncResult>> resolveAllAutomatically(
    List<SyncConflict> conflicts,
  ) async {
    final results = <String, SyncResult>{};
    final categorized = categorizeConflicts(conflicts);

    for (final entry in categorized.entries) {
      final reason = entry.key;
      final conflictsList = entry.value;

      // اختر الاستراتيجية المناسبة لكل نوع
      ConflictResolution resolution;
      switch (reason) {
        case ConflictReason.editEditConflict:
          resolution = ConflictResolution.acceptServer; // Last-Write-Wins
          break;
        case ConflictReason.editDeleteConflict:
        case ConflictReason.deleteEditConflict:
          resolution = ConflictResolution.acceptServer;
          break;
        case ConflictReason.versionMismatch:
        case ConflictReason.unknown:
          resolution = ConflictResolution.skip; // نتخطى غير المعروف
          break;
      }

      results[reason.code] = await execute(conflictsList, resolution);
    }

    return results;
  }
}
