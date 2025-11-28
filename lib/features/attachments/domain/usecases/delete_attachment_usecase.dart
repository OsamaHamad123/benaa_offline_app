import '../repositories/attachment_repository.dart';
import '../../../../core/error_handling/result.dart';

/// Delete Attachment Use Case
class DeleteAttachmentUseCase {
  final AttachmentRepository _repository;

  DeleteAttachmentUseCase(this._repository);

  Future<Result<bool>> execute(String attachmentId) async {
    return await _repository.deleteAttachment(attachmentId);
  }
}
