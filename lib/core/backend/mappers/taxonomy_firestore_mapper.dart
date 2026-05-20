import '../../../features/taxonomies/domain/entities/taxonomy.dart';
import '../../../features/taxonomies/domain/entities/taxonomy_group.dart';
import '../remote_backend.dart';
import 'firestore_mapper_utils.dart';

class TaxonomyFirestoreMapper {
  const TaxonomyFirestoreMapper._();

  static JsonMap toFirestore(
    Taxonomy entity, {
    required String userId,
    required String deviceId,
    DateTime? syncedAt,
  }) {
    final payload = <String, dynamic>{
      'id': entity.id,
      'group': entity.group.value,
      'code': entity.code,
      'label': entity.label,
      'label_en': entity.labelEn,
      'parent_id': entity.parentId,
      'sort_order': entity.sortOrder,
      'is_active': entity.isActive,
      'description': entity.description,
      'color': entity.color,
      'icon': entity.icon,
      'metadata': entity.metadata,
      'deleted_at': entity.deletedAt,
    };

    return FirestoreMapperUtils.removeNulls(
      FirestoreMapperUtils.withAuditFields(
        payload,
        userId: userId,
        deviceId: deviceId,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
        syncedAt: syncedAt,
      ),
    );
  }

  static Taxonomy fromFirestore(String taxonomyId, JsonMap doc) {
    final createdAt = FirestoreMapperUtils.asDateTime(doc['created_at']) ?? DateTime.now().toUtc();
    final updatedAt = FirestoreMapperUtils.asDateTime(doc['updated_at']) ?? createdAt;
    final groupRaw = doc['group']?.toString();

    return Taxonomy(
      id: taxonomyId,
      group: TaxonomyGroup.fromString(groupRaw) ?? TaxonomyGroup.category,
      code: (doc['code'] ?? '').toString(),
      label: (doc['label'] ?? '').toString(),
      labelEn: doc['label_en']?.toString(),
      parentId: doc['parent_id']?.toString(),
      sortOrder: (doc['sort_order'] as int?) ?? 0,
      isActive: (doc['is_active'] as bool?) ?? true,
      description: doc['description']?.toString(),
      color: doc['color']?.toString(),
      icon: doc['icon']?.toString(),
      metadata: doc['metadata'] is Map<String, dynamic> ? doc['metadata'] as Map<String, dynamic> : null,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: FirestoreMapperUtils.asDateTime(doc['deleted_at']),
    );
  }
}
