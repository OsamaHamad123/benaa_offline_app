import 'package:drift/drift.dart';
import 'dart:convert' show jsonEncode;
import '../drift_database.dart';
import '../tables/attachments_table.dart';

part 'attachments_dao.g.dart';

/// Attachments Data Access Object
/// يحتوي على جميع عمليات CRUD والاستعلامات الخاصة بالمرفقات
@DriftAccessor(tables: [Attachments])
class AttachmentsDao extends DatabaseAccessor<AppDatabase> with _$AttachmentsDaoMixin {
  AttachmentsDao(super.db);

  // ============================================================================
  // CRUD OPERATIONS
  // ============================================================================

  /// Get all attachments for a beneficiary
  Future<List<Attachment>> getBeneficiaryAttachments(
    String beneficiaryId,
  ) async {
    return await (select(attachments)
          ..where((a) => a.beneficiaryId.equals(beneficiaryId))
          ..orderBy([(a) => OrderingTerm.desc(a.createdAt)]))
        .get();
  }

  /// Add attachment
  Future<void> addAttachment(AttachmentsCompanion attachment) async {
    await into(attachments).insert(attachment);
  }

  /// Delete attachment
  Future<void> deleteAttachment(String id, {bool trackSyncDelete = true}) async {
    if (trackSyncDelete) {
      final existing = await getAttachment(id);
      if (existing != null) {
        await db.syncDao.addTombstone(
          entityType: 'attachments',
          entityId: existing.id,
          payload: jsonEncode({
            'attachment_id': existing.id,
            'beneficiary_id': existing.beneficiaryId,
            'server_url': existing.serverUrl,
          }),
        );
      }
    }

    await (delete(attachments)..where((a) => a.id.equals(id))).go();
  }

  /// Delete all attachments for a beneficiary
  Future<void> deleteBeneficiaryAttachments(
    String beneficiaryId, {
    bool trackSyncDelete = true,
  }) async {
    if (trackSyncDelete) {
      final existingRows = await getBeneficiaryAttachments(beneficiaryId);
      for (final existing in existingRows) {
        await db.syncDao.addTombstone(
          entityType: 'attachments',
          entityId: existing.id,
          payload: jsonEncode({
            'attachment_id': existing.id,
            'beneficiary_id': existing.beneficiaryId,
            'server_url': existing.serverUrl,
          }),
        );
      }
    }

    await (delete(attachments)..where((a) => a.beneficiaryId.equals(beneficiaryId))).go();
  }

  /// Get attachment by ID
  Future<Attachment?> getAttachment(String id) async {
    return await (select(
      attachments,
    )..where((a) => a.id.equals(id)))
        .getSingleOrNull();
  }

  /// Update attachment sync state
  Future<void> updateAttachmentSyncState(
    String id,
    String syncState, {
    String? serverUrl,
  }) async {
    await (update(attachments)..where((a) => a.id.equals(id))).write(
      AttachmentsCompanion(
        syncState: Value(syncState),
        serverUrl: Value(serverUrl),
        lastSyncedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Get all attachments that need sync
  Future<List<Attachment>> getPendingAttachments() async {
    return await (select(attachments)..where((a) => a.syncState.equals('pending'))).get();
  }
}
