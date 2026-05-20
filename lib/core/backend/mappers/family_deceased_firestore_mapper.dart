import '../remote_backend.dart';
import 'firestore_mapper_utils.dart';

class FamilyDeceasedFirestoreMapper {
  const FamilyDeceasedFirestoreMapper._();

  static JsonMap toFirestore(
    JsonMap localDeceased, {
    required String userId,
    required String deviceId,
    DateTime? syncedAt,
  }) {
    final payload = <String, dynamic>{
      ...localDeceased,
      'id': FirestoreMapperUtils.resolveStableId(
        localDeceased,
        preferredKeys: const <String>['serverId', 'server_id', 'id', 'nationalId', 'national_id'],
      ),
    };

    return FirestoreMapperUtils.removeNulls(
      FirestoreMapperUtils.withAuditFields(
        payload,
        userId: userId,
        deviceId: deviceId,
        createdAt: FirestoreMapperUtils.asDateTime(localDeceased['created_at'] ?? localDeceased['createdAt']),
        updatedAt: FirestoreMapperUtils.asDateTime(localDeceased['updated_at'] ?? localDeceased['updatedAt']),
        syncedAt: syncedAt,
      ),
    );
  }

  static JsonMap fromFirestore(JsonMap doc) {
    return <String, dynamic>{
      ...doc,
      'created_at': FirestoreMapperUtils.asDateTime(doc['created_at']),
      'updated_at': FirestoreMapperUtils.asDateTime(doc['updated_at']),
      'synced_at': FirestoreMapperUtils.asDateTime(doc['synced_at']),
      'deleted_at': FirestoreMapperUtils.asDateTime(doc['deleted_at']),
    };
  }
}
