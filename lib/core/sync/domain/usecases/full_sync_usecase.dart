import '../entities/sync_result.dart';
import '../repositories/i_sync_repository.dart';

/// 🎯 Use Case - Full Sync
///
/// حالة الاستخدام: المزامنة الكاملة
/// تستخدم للمرة الأولى أو عند إعادة تعيين البيانات
class FullSyncUseCase {
  final ISyncRepository _repository;

  const FullSyncUseCase(this._repository);

  /// تنفيذ المزامنة الكاملة
  ///
  /// [entityType] نوع البيانات المراد مزامنتها
  ///
  /// Returns: [SyncResult] نتيجة المزامنة
  Future<SyncResult> execute(String entityType) async {
    try {
      return await _repository.fullSync(entityType);
    } catch (e, stackTrace) {
      return SyncFailure(
        error: 'فشلت المزامنة الكاملة: ${e.toString()}',
        stackTrace: stackTrace,
        failedAt: DateTime.now(),
      );
    }
  }

  /// مزامنة كاملة لكل البيانات
  ///
  /// [entityTypes] قائمة أنواع البيانات (افتراضي: كل الأنواع)
  ///
  /// Returns: Map من نوع البيانات إلى نتيجة المزامنة
  Future<Map<String, SyncResult>> executeAll({
    List<String> entityTypes = const [
      'taxonomies', // الأولوية للتصنيفات
      'beneficiaries',
      'visits',
    ],
  }) async {
    final results = <String, SyncResult>{};

    // المزامنة بالترتيب (taxonomies أولاً لأن البقية تعتمد عليها)
    for (final entityType in entityTypes) {
      results[entityType] = await execute(entityType);

      // إذا فشلت taxonomies، نوقف المزامنة
      if (entityType == 'taxonomies' && results[entityType] is SyncFailure) {
        results['error'] = SyncFailure(
          error: 'فشلت مزامنة التصنيفات - تم إيقاف المزامنة الكاملة',
          failedAt: DateTime.now(),
        );
        break;
      }
    }

    return results;
  }
}
