import '../../../../data/db/daos/sync_metadata_dao.dart';
import '../../../../data/db/daos/taxonomies_dao.dart';
import '../../../../data/db/drift_database.dart' show TaxonomiesCompanion;
import 'package:drift/drift.dart' as drift;
import '../../domain/entities/taxonomy.dart';
import '../../domain/entities/taxonomy_group.dart';
import '../models/taxonomy_dto.dart';
import 'taxonomy_local_datasource.dart';

class TaxonomyLocalDriftDataSource implements TaxonomyLocalDataSource {
  final TaxonomiesDao _taxonomiesDao;
  final SyncMetadataDao _syncMetadataDao;

  static const String _syncEntity = 'taxonomies';

  TaxonomyLocalDriftDataSource(this._taxonomiesDao, this._syncMetadataDao);

  @override
  Future<void> clearAll() async {
    await _taxonomiesDao.deleteAll();
  }

  @override
  Future<void> clearGroup(TaxonomyGroup group) async {
    await _taxonomiesDao.deleteByGroup(group.value);
  }

  @override
  Future<void> deleteTaxonomy(String id) async {
    final item = await _taxonomiesDao.getById(id) ?? await _taxonomiesDao.getByRemoteId(id);
    if (item == null) {
      return;
    }
    await _taxonomiesDao.setActiveStatus(item.id, false);
  }

  @override
  Future<bool> exists(String id) async {
    final item = await _taxonomiesDao.getById(id) ?? await _taxonomiesDao.getByRemoteId(id);
    return item != null;
  }

  @override
  Future<List<Taxonomy>> getAllTaxonomies() async {
    final items = await _taxonomiesDao.getAllTaxonomies();
    final out = <Taxonomy>[];
    for (final item in items) {
      final mapped = _fromDbEntityOrNull(item);
      if (mapped != null) {
        out.add(mapped);
      }
    }
    return out;
  }

  @override
  Future<List<Taxonomy>> getChildTaxonomies(String parentId) async {
    final items = await _taxonomiesDao.getChildren(parentId);
    final out = <Taxonomy>[];
    for (final item in items) {
      final mapped = _fromDbEntityOrNull(item);
      if (mapped != null) {
        out.add(mapped);
      }
    }
    return out;
  }

  @override
  Future<DateTime?> getLastSyncTime() {
    return _syncMetadataDao.getLastSyncTime(_syncEntity);
  }

  @override
  Future<Taxonomy?> getTaxonomyByCode(TaxonomyGroup group, String code) async {
    final item = await _taxonomiesDao.getByCode(group.value, code);
    if (item == null) return null;
    return _fromDbEntityOrNull(item);
  }

  @override
  Future<Taxonomy?> getTaxonomyById(String id) async {
    final item = await _taxonomiesDao.getById(id) ?? await _taxonomiesDao.getByRemoteId(id);
    if (item == null) return null;
    return _fromDbEntityOrNull(item);
  }

  @override
  Future<List<Taxonomy>> getTaxonomiesByGroup(TaxonomyGroup group) async {
    final items = await _taxonomiesDao.getByGroup(group.value);
    final out = <Taxonomy>[];
    for (final item in items) {
      final mapped = _fromDbEntityOrNull(item);
      if (mapped != null) {
        out.add(mapped);
      }
    }
    return out;
  }

  @override
  Future<TaxonomyStatistics> getStatistics() async {
    final allItems = await _taxonomiesDao.getAllTaxonomies();
    final activeItems = allItems.where((item) => item.isActive).toList();
    final inactiveItems = allItems.where((item) => !item.isActive).toList();

    final counts = <TaxonomyGroup, int>{};
    final deletedCounts = <TaxonomyGroup, int>{};

    for (final group in TaxonomyGroup.values) {
      counts[group] = activeItems.where((item) => TaxonomyGroup.normalizeValue(item.group) == group.value).length;
      deletedCounts[group] =
          inactiveItems.where((item) => TaxonomyGroup.normalizeValue(item.group) == group.value).length;
    }

    return TaxonomyStatistics(
      totalCount: allItems.length,
      activeCount: activeItems.length,
      inactiveCount: inactiveItems.length,
      countByGroup: counts,
      deletedCountByGroup: deletedCounts,
      lastSyncTime: await getLastSyncTime(),
    );
  }

  @override
  Future<bool> isCodeUnique(TaxonomyGroup group, String code, {String? excludeId}) async {
    final item = await _taxonomiesDao.getByCode(group.value, code);
    if (item == null) return true;
    if (excludeId != null) {
      final excludedRemote = TaxonomyDTO.extractRemoteId(excludeId);
      final itemRemote = TaxonomyDTO.extractRemoteId(item.id);
      if (item.id == excludeId || itemRemote == excludedRemote) {
        return true;
      }
    }
    return false;
  }

  @override
  Future<void> permanentlyDeleteTaxonomy(String id) async {
    final item = await _taxonomiesDao.getById(id) ?? await _taxonomiesDao.getByRemoteId(id);
    if (item == null) {
      return;
    }
    await _taxonomiesDao.deleteTaxonomy(item.id);
  }

  @override
  Future<void> restoreTaxonomy(String id) async {
    final item = await _taxonomiesDao.getById(id) ?? await _taxonomiesDao.getByRemoteId(id);
    if (item == null) {
      return;
    }
    await _taxonomiesDao.setActiveStatus(item.id, true);
  }

  @override
  Future<void> saveTaxonomies(List<Taxonomy> taxonomies) async {
    final companions = taxonomies.map((taxonomy) => TaxonomyDTO.fromEntity(taxonomy).toDbCompanion()).toList();
    await _taxonomiesDao.upsertBatch(companions);
  }

  /// حفظ تصنيفات قادمة من السيرفر مع احترام الحذف المحلي.
  ///
  /// لا يُعيد إحياء التصنيف الذي حذفه المستخدم محلياً حتى لو السيرفر
  /// أرسله كـ isActive=true.
  Future<void> saveTaxonomiesFromSync(List<Taxonomy> taxonomies) async {
    final companions = taxonomies.map((t) => TaxonomyDTO.fromEntity(t).toDbCompanion()).toList();
    await _taxonomiesDao.syncSafeUpsertBatch(companions);
  }

  @override
  Future<void> saveTaxonomy(Taxonomy taxonomy) async {
    await _taxonomiesDao.upsertTaxonomy(TaxonomyDTO.fromEntity(taxonomy).toDbCompanion());
  }

  @override
  Future<List<Taxonomy>> searchTaxonomies(String query) async {
    final items = await _taxonomiesDao.search(query);
    final out = <Taxonomy>[];
    for (final item in items) {
      final mapped = _fromDbEntityOrNull(item);
      if (mapped != null) {
        out.add(mapped);
      }
    }
    return out;
  }

  @override
  Future<void> updateLastSyncTime(DateTime time) async {
    await _syncMetadataDao.updateSyncSuccess(
      _syncEntity,
      totalSynced: 0,
      syncTime: time,
    );
  }

  Future<void> upsertCompanions(List<TaxonomiesCompanion> companions) async {
    await _taxonomiesDao.upsertBatch(companions);
  }

  /// نسخة آمنة من upsertCompanions تحترم الحذف المحلي.
  /// تستخدم أثناء المزامنة من السيرفر فقط.
  Future<void> upsertCompanionsFromSync(List<TaxonomiesCompanion> companions) async {
    await _taxonomiesDao.syncSafeUpsertBatch(companions);
  }

  /// جلب IDs التصنيفات المحذوفة محلياً
  Future<Set<String>> getLocallyDeletedIds() async {
    return _taxonomiesDao.getLocallyDeletedIds();
  }

  Future<int> purgeUnsupportedGroups() async {
    final groups = await _taxonomiesDao.getAllGroups();
    var deleted = 0;
    for (final group in groups) {
      if (TaxonomyGroup.isValidGroup(group)) {
        continue;
      }
      deleted += await _taxonomiesDao.deleteByGroup(group);
    }
    return deleted;
  }

  /// يصلح قيَم group القديمة/غير الموحّدة ويعيد بناء الـ id المحلي بصيغة canonical.
  ///
  /// يعالج البيانات الموجودة مسبقًا في الأجهزة قبل اعتماد التطبيع الموحّد.
  Future<int> repairCanonicalStorage() async {
    final allItems = await _taxonomiesDao.getAllTaxonomies();
    if (allItems.isEmpty) {
      return 0;
    }

    final upsertsById = <String, TaxonomiesCompanion>{};
    final staleIds = <String>{};
    var changedRows = 0;

    for (final item in allItems) {
      final normalizedGroup = TaxonomyGroup.normalizeValue(item.group);
      if (normalizedGroup == null || normalizedGroup.isEmpty) {
        continue;
      }

      final remoteId = TaxonomyDTO.extractRemoteId(item.id);
      final canonicalId = TaxonomyDTO.buildLocalId(
        groupValue: normalizedGroup,
        rawId: remoteId,
        code: item.code,
      );

      final groupChanged = item.group != normalizedGroup;
      final idChanged = item.id != canonicalId;
      if (!groupChanged && !idChanged) {
        continue;
      }

      changedRows += 1;
      if (idChanged) {
        staleIds.add(item.id);
      }

      final candidate = TaxonomiesCompanion.insert(
        id: canonicalId,
        group: normalizedGroup,
        code: item.code,
        label: item.label,
        updatedAt: item.updatedAt,
        parentId: drift.Value(item.parentId),
        sortOrder: drift.Value(item.sortOrder),
        isActive: drift.Value(item.isActive),
      );

      final existing = upsertsById[canonicalId];
      if (existing == null) {
        upsertsById[canonicalId] = candidate;
        continue;
      }

      final existingUpdatedAt = existing.updatedAt.present ? existing.updatedAt.value : item.updatedAt;
      final candidateUpdatedAt = candidate.updatedAt.present ? candidate.updatedAt.value : item.updatedAt;
      if (candidateUpdatedAt.isAfter(existingUpdatedAt)) {
        upsertsById[canonicalId] = candidate;
      }
    }

    if (upsertsById.isEmpty) {
      return 0;
    }

    await _taxonomiesDao.upsertBatch(upsertsById.values.toList(growable: false));

    for (final staleId in staleIds) {
      await _taxonomiesDao.deleteTaxonomy(staleId);
    }

    return changedRows;
  }

  Taxonomy? _fromDbEntityOrNull(dynamic entity) {
    final normalizedGroupValue = TaxonomyGroup.normalizeValue(entity.group);
    final resolvedGroup = TaxonomyGroup.fromString(normalizedGroupValue);
    if (resolvedGroup == null) {
      return null;
    }
    final remoteId = TaxonomyDTO.extractRemoteId(entity.id);

    return Taxonomy(
      id: remoteId,
      group: resolvedGroup,
      code: entity.code,
      label: entity.label,
      parentId: entity.parentId,
      sortOrder: entity.sortOrder,
      isActive: entity.isActive,
      metadata: const {},
      createdAt: entity.updatedAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.isActive ? null : entity.updatedAt,
    );
  }
}
