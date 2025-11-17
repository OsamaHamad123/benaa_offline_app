import 'dart:io';
import '../entities/attachment.dart';
import '../repositories/attachment_repository.dart';

/// Add Attachment Use Case
class AddAttachmentUseCase {
  final AttachmentRepository _repository;

  AddAttachmentUseCase(this._repository);

  Future<Attachment> execute({
    required String beneficiaryId,
    String? visitId,
    required File sourceFile,
  }) async {
    return await _repository.addAttachment(
      beneficiaryId: beneficiaryId,
      visitId: visitId,
      sourceFile: sourceFile,
    );
  }
}
