import '../remote_backend.dart';
import 'firestore_mapper_utils.dart';

class UserFirestoreMapper {
  const UserFirestoreMapper._();

  static JsonMap toFirestore({
    required String uid,
    required JsonMap data,
    required String userId,
    required String deviceId,
  }) {
    final payload = <String, dynamic>{
      'id': uid,
      ...data,
    };

    return FirestoreMapperUtils.removeNulls(
      FirestoreMapperUtils.withAuditFields(
        payload,
        userId: userId,
        deviceId: deviceId,
      ),
    );
  }

  static JsonMap fromFirestore(String uid, JsonMap doc) {
    return <String, dynamic>{
      'id': uid,
      ...doc,
      'created_at': FirestoreMapperUtils.asDateTime(doc['created_at']),
      'updated_at': FirestoreMapperUtils.asDateTime(doc['updated_at']),
      'synced_at': FirestoreMapperUtils.asDateTime(doc['synced_at']),
      'deleted_at': FirestoreMapperUtils.asDateTime(doc['deleted_at']),
    };
  }
}
