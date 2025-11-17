import '../repositories/attachment_repository.dart';

/// Delete Attachment Use Case
class DeleteAttachmentUseCase {
  final AttachmentRepository _repository;

  DeleteAttachmentUseCase(this._repository);

  Future<bool> execute(String attachmentId) async {
    return await _repository.deleteAttachment(attachmentId);
  }
}
