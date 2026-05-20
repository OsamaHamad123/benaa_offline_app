import '../../../features/visits/domain/entities/visit_entity.dart';
import '../remote_backend.dart';
import 'firestore_mapper_utils.dart';

class VisitFirestoreMapper {
  const VisitFirestoreMapper._();

  static JsonMap toFirestore(
    VisitEntity entity, {
    required String userId,
    required String deviceId,
    DateTime? syncedAt,
  }) {
    final payload = <String, dynamic>{
      'id': entity.id,
      'beneficiary_id': entity.beneficiaryId,
      'visit_date': entity.visitDate,
      'staff_name': entity.staffName,
      'notes': entity.notes,
      'is_submitted': entity.isSubmitted,
      'sync_state': entity.syncState,
      'server_id': entity.serverId,
      'last_synced_at': entity.lastSyncedAt,
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

  static VisitEntity fromFirestore(String visitId, JsonMap doc) {
    final createdAt = FirestoreMapperUtils.asDateTime(doc['created_at']) ?? DateTime.now().toUtc();
    final updatedAt = FirestoreMapperUtils.asDateTime(doc['updated_at']) ?? createdAt;

    return VisitEntity(
      id: visitId,
      beneficiaryId: (doc['beneficiary_id'] ?? '').toString(),
      visitDate: FirestoreMapperUtils.asDateTime(doc['visit_date']) ?? createdAt,
      staffName: (doc['staff_name'] ?? '').toString(),
      notes: (doc['notes'] ?? '').toString(),
      isSubmitted: (doc['is_submitted'] as bool?) ?? false,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncState: (doc['sync_state'] ?? 'synced').toString(),
      serverId: doc['server_id']?.toString(),
      lastSyncedAt: FirestoreMapperUtils.asDateTime(doc['last_synced_at']),
    );
  }

  static JsonMap markDeleted(
    JsonMap localPayload, {
    required String userId,
    required String deviceId,
  }) {
    return FirestoreMapperUtils.markSoftDeleted(
      localPayload,
      userId: userId,
      deviceId: deviceId,
    );
  }
}
