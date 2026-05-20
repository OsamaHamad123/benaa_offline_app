import '../../../features/dashboard/domain/entities/activity.dart';
import '../remote_backend.dart';
import 'firestore_mapper_utils.dart';

class ActivityFirestoreMapper {
  const ActivityFirestoreMapper._();

  static JsonMap toFirestore(
    Activity entity, {
    required String userId,
    required String deviceId,
    DateTime? syncedAt,
  }) {
    final payload = <String, dynamic>{
      'id': entity.id,
      'type': entity.type,
      'description': entity.description,
      'timestamp': entity.timestamp,
      'beneficiary_id': entity.beneficiaryId,
      'beneficiary_name': entity.beneficiaryName,
      'metadata': entity.metadata,
    };

    return FirestoreMapperUtils.removeNulls(
      FirestoreMapperUtils.withAuditFields(
        payload,
        userId: userId,
        deviceId: deviceId,
        createdAt: entity.timestamp,
        updatedAt: entity.timestamp,
        syncedAt: syncedAt,
      ),
    );
  }

  static Activity fromFirestore(String activityId, JsonMap doc) {
    final timestamp = FirestoreMapperUtils.asDateTime(doc['timestamp']) ??
        FirestoreMapperUtils.asDateTime(doc['created_at']) ??
        DateTime.now().toUtc();

    return Activity(
      id: activityId,
      type: (doc['type'] ?? '').toString(),
      description: (doc['description'] ?? '').toString(),
      timestamp: timestamp,
      beneficiaryId: doc['beneficiary_id']?.toString(),
      beneficiaryName: doc['beneficiary_name']?.toString(),
      metadata: doc['metadata'] is Map<String, dynamic> ? doc['metadata'] as Map<String, dynamic> : null,
    );
  }
}
