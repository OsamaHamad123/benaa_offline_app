import 'dart:io';
import '../../domain/entities/attachment.dart';
import '../../domain/repositories/attachment_repository.dart';
import '../datasources/attachment_datasource.dart';
import '../../../../core/error_handling/result.dart';

/// 📎 Attachment Repository Implementation
class AttachmentRepositoryImpl implements AttachmentRepository {
  final AttachmentDataSource _dataSource;

  AttachmentRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<Attachment>>> getBeneficiaryAttachments(
    String beneficiaryId,
  ) async {
    try {
      final attachments =
          await _dataSource.getBeneficiaryAttachments(beneficiaryId);
      return Success(attachments);
    } catch (e, stackTrace) {
      return Failure(DatabaseFailure(
          'Failed to get beneficiary attachments: $e', stackTrace));
    }
  }

  @override
  Future<Result<List<Attachment>>> getVisitAttachments(String visitId) async {
    try {
      // TODO: Implement when visit attachments are needed
      return Failure(UnknownFailure('Visit attachments not yet implemented'));
    } catch (e, stackTrace) {
      return Failure(
          UnknownFailure('Failed to get visit attachments: $e', stackTrace));
    }
  }

  @override
  Future<Result<Attachment>> getAttachmentById(String id) async {
    try {
      final attachment = await _dataSource.getAttachmentById(id);
      if (attachment == null) {
        return Failure(NotFoundFailure('Attachment not found with ID: $id'));
      }
      return Success(attachment);
    } catch (e, stackTrace) {
      return Failure(
          DatabaseFailure('Failed to get attachment: $e', stackTrace));
    }
  }

  @override
  Future<Result<Attachment>> addAttachment({
    required String beneficiaryId,
    String? visitId,
    required File sourceFile,
  }) async {
    try {
      final attachment = await _dataSource.addAttachment(
        beneficiaryId: beneficiaryId,
        visitId: visitId,
        sourceFile: sourceFile,
      );
      return Success(attachment);
    } catch (e, stackTrace) {
      return Failure(FileFailure('Failed to add attachment: $e', stackTrace));
    }
  }

  @override
  Future<Result<bool>> deleteAttachment(String id) async {
    try {
      final result = await _dataSource.deleteAttachment(id);
      return Success(result);
    } catch (e, stackTrace) {
      return Failure(
          DatabaseFailure('Failed to delete attachment: $e', stackTrace));
    }
  }

  @override
  Future<Result<bool>> deleteBeneficiaryAttachments(
      String beneficiaryId) async {
    try {
      final result =
          await _dataSource.deleteBeneficiaryAttachments(beneficiaryId);
      return Success(result);
    } catch (e, stackTrace) {
      return Failure(DatabaseFailure(
          'Failed to delete beneficiary attachments: $e', stackTrace));
    }
  }

  @override
  Future<Result<void>> updateSyncState({
    required String id,
    required bool needsSync,
    String? serverUrl,
  }) async {
    try {
      await _dataSource.updateSyncState(
        id: id,
        needsSync: needsSync,
        serverUrl: serverUrl,
      );
      return Success(null);
    } catch (e, stackTrace) {
      return Failure(
          DatabaseFailure('Failed to update sync state: $e', stackTrace));
    }
  }

  @override
  Future<Result<int>> getAttachmentsCount(String beneficiaryId) async {
    try {
      final count = await _dataSource.getAttachmentsCount(beneficiaryId);
      return Success(count);
    } catch (e, stackTrace) {
      return Failure(
          DatabaseFailure('Failed to get attachments count: $e', stackTrace));
    }
  }
}
