import 'package:cloud_firestore/cloud_firestore.dart';

import '../remote_backend.dart';

class FirebaseFirestoreService {
  FirebaseFirestoreService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> configureOfflinePersistence() async {
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  Future<void> upsertBeneficiary(JsonMap data) async {
    final beneficiaryId = _resolveEntityId(data);

    await _firestore.collection('beneficiaries').doc(beneficiaryId).set(
          _normalizePayload(data, enforcedId: beneficiaryId),
          SetOptions(merge: true),
        );
  }

  Future<void> upsertVisit(String beneficiaryId, JsonMap data) async {
    final visitId = _resolveEntityId(data);

    await _firestore.collection('beneficiaries').doc(beneficiaryId).collection('visits').doc(visitId).set(
          _normalizePayload(
            data,
            enforcedId: visitId,
            additionalFields: <String, dynamic>{'beneficiaryId': beneficiaryId},
          ),
          SetOptions(merge: true),
        );
  }

  Future<void> upsertAttachmentMetadata(String beneficiaryId, JsonMap data) async {
    final attachmentId = _resolveEntityId(data);

    await _firestore.collection('beneficiaries').doc(beneficiaryId).collection('attachments').doc(attachmentId).set(
          _normalizePayload(
            data,
            enforcedId: attachmentId,
            additionalFields: <String, dynamic>{'beneficiaryId': beneficiaryId},
          ),
          SetOptions(merge: true),
        );
  }

  Future<List<JsonMap>> pullUpdatedBeneficiaries({DateTime? since}) async {
    Query<Map<String, dynamic>> query = _firestore.collection('beneficiaries');

    if (since != null) {
      query = query.where('updatedAt', isGreaterThan: Timestamp.fromDate(since));
    }

    final snapshots = await query.get();
    return snapshots.docs
        .map(
          (doc) => <String, dynamic>{
            'id': doc.id,
            ..._denormalizePayload(doc.data()),
          },
        )
        .toList();
  }

  String _resolveEntityId(JsonMap data) {
    final raw = data['id'] ?? data['remoteId'] ?? data['uuid'] ?? data['uid'];
    if (raw == null) {
      throw ArgumentError('Entity id is required in payload.');
    }
    return raw.toString();
  }

  JsonMap _normalizePayload(
    JsonMap data, {
    required String enforcedId,
    JsonMap additionalFields = const <String, dynamic>{},
  }) {
    final updatedAtValue = data['updated_at'] ?? data['updatedAt'] ?? FieldValue.serverTimestamp();

    final merged = <String, dynamic>{
      ...data,
      ...additionalFields,
      'id': enforcedId,
      'updated_at': updatedAtValue,
      'updatedAt': updatedAtValue,
    };

    return _convertToFirestoreTypes(merged);
  }

  JsonMap _denormalizePayload(JsonMap data) {
    return data.map((key, value) => MapEntry(key, _fromFirestoreType(value)));
  }

  JsonMap _convertToFirestoreTypes(JsonMap payload) {
    return payload.map((key, value) => MapEntry(key, _toFirestoreType(value)));
  }

  dynamic _toFirestoreType(dynamic value) {
    if (value is DateTime) {
      return Timestamp.fromDate(value);
    }
    if (value is Map<String, dynamic>) {
      return value.map((key, inner) => MapEntry(key, _toFirestoreType(inner)));
    }
    if (value is List) {
      return value.map(_toFirestoreType).toList();
    }
    return value;
  }

  dynamic _fromFirestoreType(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is Map<String, dynamic>) {
      return value.map((key, inner) => MapEntry(key, _fromFirestoreType(inner)));
    }
    if (value is List) {
      return value.map(_fromFirestoreType).toList();
    }
    return value;
  }
}
