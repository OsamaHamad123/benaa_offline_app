import '../remote_backend.dart';
import 'firestore_mapper_utils.dart';

class DataRequestFirestoreMapper {
  const DataRequestFirestoreMapper._();

  static JsonMap toFirestore(
    JsonMap localRequest, {
    required String userId,
    required String deviceId,
    DateTime? syncedAt,
  }) {
    final payload = <String, dynamic>{
      ...localRequest,
      'id': FirestoreMapperUtils.resolveStableId(
        localRequest,
        preferredKeys: const <String>['serverId', 'server_id', 'id'],
      ),
    };

    return FirestoreMapperUtils.removeNulls(
      FirestoreMapperUtils.withAuditFields(
        payload,
        userId: userId,
        deviceId: deviceId,
        createdAt: FirestoreMapperUtils.asDateTime(localRequest['created_at'] ?? localRequest['createdAt']),
        updatedAt: FirestoreMapperUtils.asDateTime(localRequest['updated_at'] ?? localRequest['updatedAt']),
        syncedAt: syncedAt,
      ),
    );
  }

  static JsonMap fromFirestore(JsonMap doc) {
    return <String, dynamic>{
      ...doc,
      'request_date': FirestoreMapperUtils.asDateTime(doc['request_date']),
      'response_date': FirestoreMapperUtils.asDateTime(doc['response_date']),
      'created_at': FirestoreMapperUtils.asDateTime(doc['created_at']),
      'updated_at': FirestoreMapperUtils.asDateTime(doc['updated_at']),
      'synced_at': FirestoreMapperUtils.asDateTime(doc['synced_at']),
      'deleted_at': FirestoreMapperUtils.asDateTime(doc['deleted_at']),
    };
  }
}
