import '../remote_backend.dart';
import 'firestore_mapper_utils.dart';

class FamilyMemberFirestoreMapper {
  const FamilyMemberFirestoreMapper._();

  static JsonMap toFirestore(
    JsonMap localMember, {
    required String userId,
    required String deviceId,
    DateTime? syncedAt,
  }) {
    final payload = <String, dynamic>{
      ...localMember,
      'id': FirestoreMapperUtils.resolveStableId(
        localMember,
        preferredKeys: const <String>['serverId', 'server_id', 'id', 'orphanNationalId', 'orphan_national_id'],
      ),
    };

    return FirestoreMapperUtils.removeNulls(
      FirestoreMapperUtils.withAuditFields(
        payload,
        userId: userId,
        deviceId: deviceId,
        createdAt: FirestoreMapperUtils.asDateTime(localMember['created_at'] ?? localMember['createdAt']),
        updatedAt: FirestoreMapperUtils.asDateTime(localMember['updated_at'] ?? localMember['updatedAt']),
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
