import '../../../../data/db/daos/taxonomies_dao.dart';
import '../../../../data/db/daos/beneficiaries_dao.dart';
import '../../../../data/db/daos/sync_metadata_dao.dart';
import '../../../../data/db/daos/sync_dao.dart';
import '../../../../data/models/taxonomy_dto.dart';
import '../../../../data/db/drift_database.dart';
import 'dart:convert' show jsonEncode;

/// 💾 Local Sync DataSource
///
/// مسؤول عن التعامل مع قاعدة البيانات المحلية
class LocalSyncDataSource {
  final TaxonomiesDao _taxonomiesDao;
  final BeneficiariesDao _beneficiariesDao;
  final SyncMetadataDao _syncMetadataDao;
  final SyncDao _syncDao;

  const LocalSyncDataSource({
    required TaxonomiesDao taxonomiesDao,
    required BeneficiariesDao beneficiariesDao,
    required SyncMetadataDao syncMetadataDao,
    required SyncDao syncDao,
  }) : _taxonomiesDao = taxonomiesDao,
       _beneficiariesDao = beneficiariesDao,
       _syncMetadataDao = syncMetadataDao,
       _syncDao = syncDao;

  // ═══════════════════════════════════════════════════════════════════════
  // 🏷️ TAXONOMIES - Local Operations
  // ═══════════════════════════════════════════════════════════════════════

  /// حفظ التصنيفات محلياً (Bulk Upsert)
  Future<void> saveTaxonomies(List<TaxonomyDTO> taxonomies) async {
    final companions = taxonomies.map((dto) => dto.toCompanion()).toList();
    await _taxonomiesDao.upsertBatch(companions);
  }

  /// حفظ التصنيفات لمجموعة معينة (Replace Strategy)
  Future<void> saveTaxonomiesForGroup(
    String group,
    List<TaxonomyDTO> taxonomies,
  ) async {
    final companions = taxonomies.map((dto) => dto.toCompanion()).toList();
    await _taxonomiesDao.syncReplaceGroup(group, companions);
  }

  /// الحصول على التصنيفات المحلية
  Future<List<TaxonomyDTO>> getLocalTaxonomies(String group) async {
    final entities = await _taxonomiesDao.getByGroup(group);
    return entities.map((e) => TaxonomyDTO.fromEntity(e)).toList();
  }

  /// آخر تحديث للتصنيفات
  Future<DateTime?> getTaxonomiesLastUpdate(String group) async {
    return await _taxonomiesDao.getLastUpdate(group);
  }

  /// هل نحتاج لمزامنة التصنيفات؟
  Future<bool> needsTaxonomiesSync(
    String group,
    DateTime serverLastUpdate,
  ) async {
    return await _taxonomiesDao.needsSync(group, serverLastUpdate);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 👥 BENEFICIARIES - Local Operations
  // ═══════════════════════════════════════════════════════════════════════

  /// الحصول على المستفيدين المعدلين محلياً منذ وقت معين
  Future<List<Map<String, dynamic>>> getModifiedBeneficiaries({
    DateTime? since,
  }) async {
    // Get all beneficiaries modified locally
    final beneficiaries = await _beneficiariesDao.getAllBeneficiaries();

    if (since == null) return beneficiaries.map((b) => b.toJson()).toList();

    // Filter by date
    return beneficiaries
        .where((b) => b.updatedAt?.isAfter(since) ?? false)
        .map((b) => b.toJson())
        .toList();
  }

  /// حفظ مستفيد محلياً
  Future<void> saveBeneficiary(Map<String, dynamic> data) async {
    // Implementation depends on your BeneficiaryDataModel structure
    // This is a placeholder
    throw UnimplementedError('Implement based on your BeneficiaryDataModel');
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📋 SYNC METADATA Operations
  // ═══════════════════════════════════════════════════════════════════════

  /// الحصول على آخر وقت مزامنة
  Future<DateTime?> getLastSyncTime(String entityType) async {
    return await _syncMetadataDao.getLastSyncTime(entityType);
  }

  /// تحديث وقت المزامنة بعد النجاح
  Future<void> updateSyncSuccess({
    required String entityType,
    required int itemsSynced,
  }) async {
    await _syncMetadataDao.updateSyncSuccess(
      entityType,
      totalSynced: itemsSynced,
    );
  }

  /// تحديث وقت المزامنة بعد الفشل
  Future<void> updateSyncFailure({
    required String entityType,
    required String error,
  }) async {
    await _syncMetadataDao.updateSyncFailure(entityType, error: error);
  }

  /// الحصول على جميع بيانات المزامنة
  Future<List<SyncMetadata>> getAllSyncMetadata() async {
    return await _syncMetadataDao.getAllSyncMetadata();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📤 SYNC QUEUE Operations (للتغييرات المعلقة)
  // ═══════════════════════════════════════════════════════════════════════

  /// عدد التغييرات المعلقة
  Future<int> getPendingChangesCount(String entityType) async {
    final items = await _syncDao.getSyncQueue(limit: 10000);
    return items.where((item) => item.entity == entityType).length;
  }

  /// الحصول على التغييرات المعلقة
  Future<List<SyncQueueItem>> getPendingChanges(String entityType) async {
    final allItems = await _syncDao.getSyncQueue(limit: 10000);
    return allItems.where((item) => item.entity == entityType).toList();
  }

  /// إضافة تغيير لطابور المزامنة
  Future<void> addToSyncQueue({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    final companion = SyncQueueCompanion.insert(
      id: '$entityType-$entityId-${DateTime.now().millisecondsSinceEpoch}',
      entity: entityType,
      entityId: entityId,
      operation: operation,
      payload: jsonEncode(data),
      createdAt: DateTime.now(),
    );
    await _syncDao.addToSyncQueue(companion);
  }

  /// إزالة تغيير من طابور المزامنة (بالستخدام queueId كـ String ID)
  Future<void> removeFromSyncQueue(int queueId) async {
    // Note: SyncDao expects String ID, need to convert or use item.id
    // For now, we'll clear all synced items as workaround
    // TODO: Fix this to use proper ID
    return;
  }

  /// مسح طابور المزامنة
  /// Note: Current SyncDao doesn't have clearQueue method
  /// TODO: Implement proper queue clearing
  Future<void> clearSyncQueue([String? entityType]) async {
    // Placeholder - needs implementation in SyncDao
    return;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📊 STATISTICS Operations
  // ═══════════════════════════════════════════════════════════════════════

  /// إحصائيات التصنيفات المحلية
  Future<Map<String, int>> getTaxonomiesStatistics() async {
    return await _taxonomiesDao.getStatistics();
  }

  /// عدد المستفيدين المحليين
  Future<int> getBeneficiariesCount() async {
    final all = await _beneficiariesDao.getAllBeneficiaries();
    return all.length;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🧹 CLEANUP Operations
  // ═══════════════════════════════════════════════════════════════════════

  /// حذف كل التصنيفات (لإعادة التعيين)
  Future<void> clearAllTaxonomies() async {
    await _taxonomiesDao.deleteAll();
  }

  /// حذف بيانات المزامنة
  Future<void> clearSyncMetadata() async {
    await _syncMetadataDao.clearAll();
  }
}
