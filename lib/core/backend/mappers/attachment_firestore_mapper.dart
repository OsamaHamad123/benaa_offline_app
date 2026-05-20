import '../../../features/attachments/domain/entities/attachment.dart';
import '../remote_backend.dart';
import 'firestore_mapper_utils.dart';

class AttachmentFirestoreMapper {
  const AttachmentFirestoreMapper._();

  static JsonMap toFirestore(
    Attachment entity, {
    required String userId,
    required String deviceId,
    DateTime? syncedAt,
  }) {
    final payload = <String, dynamic>{
      'id': entity.id,
      'beneficiary_id': entity.beneficiaryId,
      'visit_id': entity.visitId,
      'file_name': entity.fileName,
      'file_path': entity.filePath,
      'file_type': entity.type.name,
      'file_size': entity.fileSize,
      'thumbnail_path': entity.thumbnailPath,
      'document_type': entity.documentType,
      'person_type': entity.personType,
      'person_id': entity.personId,
      'notes': entity.notes,
      'needs_sync': entity.needsSync,
      'server_url': entity.serverUrl,
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

  static Attachment fromFirestore(String attachmentId, JsonMap doc) {
    final createdAt = FirestoreMapperUtils.asDateTime(doc['created_at']) ?? DateTime.now().toUtc();
    final updatedAt = FirestoreMapperUtils.asDateTime(doc['updated_at']) ?? createdAt;

    return Attachment(
      id: attachmentId,
      beneficiaryId: (doc['beneficiary_id'] ?? '').toString(),
      visitId: doc['visit_id']?.toString(),
      fileName: (doc['file_name'] ?? '').toString(),
      filePath: (doc['file_path'] ?? '').toString(),
      type: AttachmentType.fromString((doc['file_type'] ?? 'other').toString()),
      fileSize: (doc['file_size'] as int?) ?? 0,
      createdAt: createdAt,
      updatedAt: updatedAt,
      thumbnailPath: doc['thumbnail_path']?.toString(),
      documentType: doc['document_type']?.toString(),
      personType: doc['person_type']?.toString(),
      personId: doc['person_id']?.toString(),
      notes: doc['notes']?.toString(),
      needsSync: (doc['needs_sync'] as bool?) ?? false,
      serverUrl: doc['server_url']?.toString(),
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
