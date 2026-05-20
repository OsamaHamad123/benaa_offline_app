import '../remote_backend.dart';
import 'firestore_mapper_utils.dart';

class SponsorshipFirestoreMapper {
  const SponsorshipFirestoreMapper._();

  static JsonMap toFirestore(
    JsonMap localSponsorship, {
    required String userId,
    required String deviceId,
    DateTime? syncedAt,
  }) {
    final payload = <String, dynamic>{
      ...localSponsorship,
      'id': FirestoreMapperUtils.resolveStableId(
        localSponsorship,
        preferredKeys: const <String>['serverId', 'server_id', 'fileNo', 'file_no', 'id'],
      ),
    };

    return FirestoreMapperUtils.removeNulls(
      FirestoreMapperUtils.withAuditFields(
        payload,
        userId: userId,
        deviceId: deviceId,
        createdAt: FirestoreMapperUtils.asDateTime(localSponsorship['created_at'] ?? localSponsorship['createdAt']),
        updatedAt: FirestoreMapperUtils.asDateTime(localSponsorship['updated_at'] ?? localSponsorship['updatedAt']),
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
