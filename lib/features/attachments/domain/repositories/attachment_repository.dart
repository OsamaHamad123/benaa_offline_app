import 'dart:io';
import '../entities/attachment.dart';

/// 📎 Attachment Repository Interface - Domain Layer
///
/// Defines the contract for attachment data operations.
abstract class AttachmentRepository {
  /// Get all attachments for a beneficiary
  Future<List<Attachment>> getBeneficiaryAttachments(String beneficiaryId);

  /// Get all attachments for a visit
  Future<List<Attachment>> getVisitAttachments(String visitId);

  /// Get single attachment by ID
  Future<Attachment?> getAttachmentById(String id);

  /// Add new attachment
  Future<Attachment> addAttachment({
    required String beneficiaryId,
    String? visitId,
    required File sourceFile,
  });

  /// Delete attachment
  Future<bool> deleteAttachment(String id);

  /// Delete all attachments for a beneficiary
  Future<bool> deleteBeneficiaryAttachments(String beneficiaryId);

  /// Update attachment sync state
  Future<void> updateSyncState({
    required String id,
    required bool needsSync,
    String? serverUrl,
  });

  /// Get count of attachments for a beneficiary
  Future<int> getAttachmentsCount(String beneficiaryId);
}
