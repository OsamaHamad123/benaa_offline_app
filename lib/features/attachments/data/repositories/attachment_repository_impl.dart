import 'dart:io';
import '../../domain/entities/attachment.dart';
import '../../domain/repositories/attachment_repository.dart';
import '../datasources/attachment_datasource.dart';

/// 📎 Attachment Repository Implementation
class AttachmentRepositoryImpl implements AttachmentRepository {
  final AttachmentDataSource _dataSource;

  AttachmentRepositoryImpl(this._dataSource);

  @override
  Future<List<Attachment>> getBeneficiaryAttachments(
    String beneficiaryId,
  ) async {
    return await _dataSource.getBeneficiaryAttachments(beneficiaryId);
  }

  @override
  Future<List<Attachment>> getVisitAttachments(String visitId) async {
    // TODO: Implement when visit attachments are needed
    throw UnimplementedError('Visit attachments not yet implemented');
  }

  @override
  Future<Attachment?> getAttachmentById(String id) async {
    return await _dataSource.getAttachmentById(id);
  }

  @override
  Future<Attachment> addAttachment({
    required String beneficiaryId,
    String? visitId,
    required File sourceFile,
  }) async {
    return await _dataSource.addAttachment(
      beneficiaryId: beneficiaryId,
      visitId: visitId,
      sourceFile: sourceFile,
    );
  }

  @override
  Future<bool> deleteAttachment(String id) async {
    return await _dataSource.deleteAttachment(id);
  }

  @override
  Future<bool> deleteBeneficiaryAttachments(String beneficiaryId) async {
    return await _dataSource.deleteBeneficiaryAttachments(beneficiaryId);
  }

  @override
  Future<void> updateSyncState({
    required String id,
    required bool needsSync,
    String? serverUrl,
  }) async {
    await _dataSource.updateSyncState(
      id: id,
      needsSync: needsSync,
      serverUrl: serverUrl,
    );
  }

  @override
  Future<int> getAttachmentsCount(String beneficiaryId) async {
    return await _dataSource.getAttachmentsCount(beneficiaryId);
  }
}
