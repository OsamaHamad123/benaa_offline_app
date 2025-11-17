import '../entities/attachment.dart';
import '../repositories/attachment_repository.dart';

/// Get Beneficiary Attachments Use Case
class GetBeneficiaryAttachmentsUseCase {
  final AttachmentRepository _repository;

  GetBeneficiaryAttachmentsUseCase(this._repository);

  Future<List<Attachment>> execute(String beneficiaryId) async {
    return await _repository.getBeneficiaryAttachments(beneficiaryId);
  }
}
