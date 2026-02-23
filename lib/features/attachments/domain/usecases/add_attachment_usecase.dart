import 'dart:io';
import '../entities/attachment.dart';
import '../repositories/attachment_repository.dart';
import '../../../../core/error_handling/result.dart';

/// Add Attachment Use Case
class AddAttachmentUseCase {
  final AttachmentRepository _repository;

  AddAttachmentUseCase(this._repository);

  Future<Result<Attachment>> execute({
    required String beneficiaryId,
    required File sourceFile, String? visitId,
  }) async {
    return await _repository.addAttachment(
      beneficiaryId: beneficiaryId,
      visitId: visitId,
      sourceFile: sourceFile,
    );
  }
}
