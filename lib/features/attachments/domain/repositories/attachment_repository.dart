import 'dart:io';
import '../entities/attachment.dart';
import '../../../../core/error_handling/result.dart';

/// 📎 Attachment Repository Interface - Domain Layer
///
/// Defines the contract for attachment data operations.
abstract class AttachmentRepository {
  /// Get all attachments for a beneficiary
  Future<Result<List<Attachment>>> getBeneficiaryAttachments(
      String beneficiaryId);

  /// Get all attachments for a visit
  Future<Result<List<Attachment>>> getVisitAttachments(String visitId);

  /// Get single attachment by ID
  Future<Result<Attachment>> getAttachmentById(String id);

  /// Add new attachment
  Future<Result<Attachment>> addAttachment({
    required String beneficiaryId,
    required File sourceFile, String? visitId,
  });

  /// Delete attachment
  Future<Result<bool>> deleteAttachment(String id);

  /// Delete all attachments for a beneficiary
  Future<Result<bool>> deleteBeneficiaryAttachments(String beneficiaryId);

  /// Update attachment sync state
  Future<Result<void>> updateSyncState({
    required String id,
    required bool needsSync,
    String? serverUrl,
  });

  /// Get count of attachments for a beneficiary
  Future<Result<int>> getAttachmentsCount(String beneficiaryId);
}
