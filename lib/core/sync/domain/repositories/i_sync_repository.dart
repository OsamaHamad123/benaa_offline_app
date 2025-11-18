import '../entities/sync_result.dart';

/// 📋 Repository Interface - Sync Repository
///
/// العقد الذي يحدد عمليات المزامنة المطلوبة
/// يتم تطبيقه في Data Layer
abstract class ISyncRepository {
  /// 🔄 Delta Sync - مزامنة التغييرات فقط
  Future<SyncResult> deltaSync(
    String entityType, {
    DateTime? lastSyncTime,
    ConflictResolution conflictResolution = ConflictResolution.acceptServer,
  });

  /// 📥 Pull Changes - جلب التغييرات من السيرفر
  Future<SyncResult> pullChanges(
    String entityType, {
    DateTime? since,
    int limit = 100,
  });

  /// 📤 Push Changes - رفع التغييرات للسيرفر
  Future<SyncResult> pushChanges(String entityType);

  /// ⚔️ Resolve Conflicts - حل التعارضات
  Future<SyncResult> resolveConflicts(
    List<SyncConflict> conflicts,
    ConflictResolution resolution,
  );

  /// 🔄 Full Sync - مزامنة كاملة
  Future<SyncResult> fullSync(String entityType);

  /// 📊 Get Sync Summary - الحصول على ملخص المزامنة
  Future<SyncSummary?> getSyncSummary(String entityType);

  /// 🕐 Get Last Sync Time - آخر وقت مزامنة
  Future<DateTime?> getLastSyncTime(String entityType);

  /// 🔢 Get Pending Changes Count - عدد التغييرات المعلقة
  Future<int> getPendingChangesCount(String entityType);

  /// 🗑️ Clear Sync Queue - مسح طابور المزامنة
  Future<void> clearSyncQueue([String? entityType]);
}
