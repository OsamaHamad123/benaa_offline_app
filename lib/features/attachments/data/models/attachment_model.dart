import 'package:drift/drift.dart' as drift;
import '../../domain/entities/attachment.dart' as domain;
import '../../../../data/db/drift_database.dart';

/// 📎 Attachment Model - Data Layer
///
/// Maps between Drift database and domain entity.
class AttachmentModel extends domain.Attachment {
  const AttachmentModel({
    required super.id,
    required super.beneficiaryId,
    required super.fileName,
    required super.filePath,
    required super.type,
    required super.fileSize,
    required super.createdAt,
    required super.updatedAt,
    super.visitId,
    super.thumbnailPath,
    super.needsSync = false,
    super.serverUrl,
    super.lastSyncedAt,
    super.documentType,
    super.personType,
    super.personId,
    super.notes,
  });

  /// Create from Drift database row
  factory AttachmentModel.fromDrift(Attachment data) {
    return AttachmentModel(
      id: data.id,
      beneficiaryId: data.beneficiaryId,
      visitId: data.visitId,
      fileName: data.fileName,
      filePath: data.filePath,
      type: domain.AttachmentType.fromString(data.type),
      fileSize: data.fileSize,
      thumbnailPath: data.thumbnailPath,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      needsSync: data.syncState == 'pending',
      serverUrl: data.serverUrl,
      lastSyncedAt: data.lastSyncedAt,
      documentType: data.documentType,
      personType: data.personType,
      personId: data.personId,
      notes: data.notes,
    );
  }

  /// Convert to Drift companion for insert/update
  AttachmentsCompanion toCompanion() {
    return AttachmentsCompanion(
      id: drift.Value(id),
      beneficiaryId: drift.Value(beneficiaryId),
      visitId: drift.Value(visitId),
      fileName: drift.Value(fileName),
      filePath: drift.Value(filePath),
      type: drift.Value(type.name),
      fileSize: drift.Value(fileSize),
      thumbnailPath: drift.Value(thumbnailPath),
      createdAt: drift.Value(createdAt),
      updatedAt: drift.Value(updatedAt),
      syncState: drift.Value(needsSync ? 'pending' : 'synced'),
      serverUrl: drift.Value(serverUrl),
      lastSyncedAt: drift.Value(lastSyncedAt),
      documentType: drift.Value(documentType),
      personType: drift.Value(personType),
      personId: drift.Value(personId),
      notes: drift.Value(notes),
    );
  }
}
