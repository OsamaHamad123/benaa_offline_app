import '../../../../data/db/daos/taxonomies_dao.dart';
import '../../../../data/db/daos/beneficiaries_dao.dart';
import '../../../../data/db/daos/sync_metadata_dao.dart';
import '../../../../data/db/daos/sync_dao.dart';
import '../../../../data/db/drift_database.dart';
import '../../../../features/beneficiaries/data/models/beneficiary_data_model.dart';
import '../../../../features/taxonomies/data/models/taxonomy_dto.dart';
import '../../../../features/taxonomies/domain/entities/taxonomy_group.dart';
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
  })  : _taxonomiesDao = taxonomiesDao,
        _beneficiariesDao = beneficiariesDao,
        _syncMetadataDao = syncMetadataDao,
        _syncDao = syncDao;

  Set<String> _entityAliases(String entityType) {
    switch (entityType) {
      case 'beneficiaries':
      case 'beneficiary':
        return {'beneficiary', 'beneficiaries'};
      case 'visits':
      case 'visit':
        return {'visit', 'visits'};
      case 'attachments':
      case 'attachment':
        return {'attachment', 'attachments'};
      default:
        return {entityType};
    }
  }

  String _normalizeGroup(String rawGroup) {
    final normalized = TaxonomyGroup.normalizeValue(rawGroup);
    if (normalized == null || normalized.isEmpty) {
      return rawGroup.trim();
    }
    return normalized;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🏷️ TAXONOMIES - Local Operations
  // ═══════════════════════════════════════════════════════════════════════

  /// حفظ التصنيفات محلياً (Bulk Upsert)
  Future<void> saveTaxonomies(List<TaxonomyDTO> taxonomies) async {
    final companions = taxonomies
        .map(
          (dto) => dto
              .copyWith(
                groupValue: _normalizeGroup(dto.groupValue),
              )
              .toDbCompanion(),
        )
        .toList();
    await _taxonomiesDao.upsertBatch(companions);
  }

  /// حفظ التصنيفات لمجموعة معينة (Replace Strategy)
  Future<void> saveTaxonomiesForGroup(
    String group,
    List<TaxonomyDTO> taxonomies,
  ) async {
    final normalizedGroup = _normalizeGroup(group);
    final companions = taxonomies
        .map(
          (dto) => dto
              .copyWith(
                groupValue: _normalizeGroup(dto.groupValue),
              )
              .toDbCompanion(),
        )
        .toList();
    await _taxonomiesDao.syncReplaceGroup(normalizedGroup, companions);
  }

  /// الحصول على التصنيفات المحلية
  Future<List<TaxonomyDTO>> getLocalTaxonomies(String group) async {
    final entities = await _taxonomiesDao.getByGroup(_normalizeGroup(group));
    return entities
        .map(
          (e) => TaxonomyDTO(
            id: TaxonomyDTO.extractRemoteId(e.id),
            groupValue: _normalizeGroup(e.group),
            code: e.code,
            label: e.label,
            parentId: e.parentId,
            sortOrder: e.sortOrder,
            isActive: e.isActive,
            updatedAt: e.updatedAt,
          ),
        )
        .toList();
  }

  /// آخر تحديث للتصنيفات
  Future<DateTime?> getTaxonomiesLastUpdate(String group) async {
    return await _taxonomiesDao.getLastUpdate(_normalizeGroup(group));
  }

  /// هل نحتاج لمزامنة التصنيفات؟
  Future<bool> needsTaxonomiesSync(
    String group,
    DateTime serverLastUpdate,
  ) async {
    return await _taxonomiesDao.needsSync(_normalizeGroup(group), serverLastUpdate);
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
    return beneficiaries.where((b) => b.updatedAt?.isAfter(since) ?? false).map((b) => b.toJson()).toList();
  }

  /// حفظ مستفيد محلياً
  Future<void> saveBeneficiary(Map<String, dynamic> data) async {
    final model = BeneficiaryDataModel.fromJson(data);
    final companion = model.toDriftCompanion(isNew: false);

    final serverId = model.id;
    if (serverId != null) {
      final existing = await _beneficiariesDao.getBeneficiaryByServerId(serverId);
      if (existing != null) {
        await _beneficiariesDao.updateBeneficiaryCompanion(existing.id, companion);
        return;
      }
    }

    await _beneficiariesDao.insertBeneficiary(companion);
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
    final aliases = _entityAliases(entityType);
    return items.where((item) => aliases.contains(item.entity)).length;
  }

  /// الحصول على التغييرات المعلقة
  Future<List<SyncQueueItem>> getPendingChanges(String entityType) async {
    final allItems = await _syncDao.getSyncQueue(limit: 10000);
    final aliases = _entityAliases(entityType);
    return allItems.where((item) => aliases.contains(item.entity)).toList();
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
  Future<void> removeFromSyncQueue(String queueId) async {
    await _syncDao.removeFromSyncQueue(queueId);
  }

  /// مسح طابور المزامنة
  Future<void> clearSyncQueue([String? entityType]) async {
    final allItems = await _syncDao.getSyncQueue(limit: 100000);

    if (entityType == null || entityType.isEmpty) {
      for (final item in allItems) {
        await _syncDao.removeFromSyncQueue(item.id);
      }
      return;
    }

    final aliases = _entityAliases(entityType);
    for (final item in allItems.where((row) => aliases.contains(row.entity))) {
      await _syncDao.removeFromSyncQueue(item.id);
    }
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
