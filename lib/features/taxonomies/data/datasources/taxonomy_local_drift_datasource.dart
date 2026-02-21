import '../../../../data/db/daos/sync_metadata_dao.dart';
import '../../../../data/db/daos/taxonomies_dao.dart';
import '../../../../data/db/drift_database.dart' show TaxonomiesCompanion;
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
    await _taxonomiesDao.setActiveStatus(id, false);
  }

  @override
  Future<bool> exists(String id) async {
    final item = await _taxonomiesDao.getById(id);
    return item != null;
  }

  @override
  Future<List<Taxonomy>> getAllTaxonomies() async {
    final items = await _taxonomiesDao.getAllTaxonomies();
    return items.map(_fromDbEntity).toList();
  }

  @override
  Future<List<Taxonomy>> getChildTaxonomies(String parentId) async {
    final items = await _taxonomiesDao.getChildren(parentId);
    return items.map(_fromDbEntity).toList();
  }

  @override
  Future<DateTime?> getLastSyncTime() {
    return _syncMetadataDao.getLastSyncTime(_syncEntity);
  }

  @override
  Future<Taxonomy?> getTaxonomyByCode(TaxonomyGroup group, String code) async {
    final item = await _taxonomiesDao.getByCode(group.value, code);
    if (item == null) return null;
    return _fromDbEntity(item);
  }

  @override
  Future<Taxonomy?> getTaxonomyById(String id) async {
    final item = await _taxonomiesDao.getById(id);
    if (item == null) return null;
    return _fromDbEntity(item);
  }

  @override
  Future<List<Taxonomy>> getTaxonomiesByGroup(TaxonomyGroup group) async {
    final items = await _taxonomiesDao.getByGroup(group.value);
    return items.map(_fromDbEntity).toList();
  }

  @override
  Future<TaxonomyStatistics> getStatistics() async {
    final allItems = await _taxonomiesDao.getAllTaxonomies();
    final activeItems = allItems.where((item) => item.isActive).toList();
    final inactiveItems = allItems.where((item) => !item.isActive).toList();
    final counts = <TaxonomyGroup, int>{};
    for (final group in TaxonomyGroup.values) {
      counts[group] = activeItems.where((item) => TaxonomyGroup.normalizeValue(item.group) == group.value).length;
    }

    return TaxonomyStatistics(
      totalCount: allItems.length,
      activeCount: activeItems.length,
      inactiveCount: inactiveItems.length,
      countByGroup: counts,
      lastSyncTime: await getLastSyncTime(),
    );
  }

  @override
  Future<bool> isCodeUnique(TaxonomyGroup group, String code, {String? excludeId}) async {
    final item = await _taxonomiesDao.getByCode(group.value, code);
    if (item == null) return true;
    if (excludeId != null && item.id == excludeId) return true;
    return false;
  }

  @override
  Future<void> permanentlyDeleteTaxonomy(String id) async {
    await _taxonomiesDao.deleteTaxonomy(id);
  }

  @override
  Future<void> restoreTaxonomy(String id) async {
    await _taxonomiesDao.setActiveStatus(id, true);
  }

  @override
  Future<void> saveTaxonomies(List<Taxonomy> taxonomies) async {
    final companions = taxonomies.map((taxonomy) => TaxonomyDTO.fromEntity(taxonomy).toDbCompanion()).toList();
    await _taxonomiesDao.upsertBatch(companions);
  }

  @override
  Future<void> saveTaxonomy(Taxonomy taxonomy) async {
    await _taxonomiesDao.upsertTaxonomy(TaxonomyDTO.fromEntity(taxonomy).toDbCompanion());
  }

  @override
  Future<List<Taxonomy>> searchTaxonomies(String query) async {
    final items = await _taxonomiesDao.search(query);
    return items.map(_fromDbEntity).toList();
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

  Taxonomy _fromDbEntity(dynamic entity) {
    final normalizedGroupValue = TaxonomyGroup.normalizeValue(entity.group);
    final resolvedGroup = TaxonomyGroup.fromString(normalizedGroupValue) ?? TaxonomyGroup.category;

    return Taxonomy(
      id: entity.id,
      group: resolvedGroup,
      code: entity.code,
      label: entity.label,
      labelEn: null,
      parentId: entity.parentId,
      sortOrder: entity.sortOrder,
      isActive: entity.isActive,
      description: null,
      color: null,
      icon: null,
      metadata: const {},
      createdAt: entity.updatedAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.isActive ? null : entity.updatedAt,
    );
  }
}
