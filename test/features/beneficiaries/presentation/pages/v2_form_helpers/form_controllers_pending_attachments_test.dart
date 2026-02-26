import 'dart:io';

import 'package:benaa_offline_app/features/attachments/domain/models/pending_attachment.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_controllers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BeneficiaryFormControllers pending attachments sync', () {
    test('addPendingAttachment keeps legacy file list in sync', () {
      final controllers = BeneficiaryFormControllers();
      addTearDown(controllers.dispose);

      final attachment = PendingAttachment(
        file: File('C:/fake/path/doc.pdf'),
        documentType: 'id_card',
        personType: 'file_owner',
      );

      controllers.addPendingAttachment(attachment);

      expect(controllers.pendingAttachments.length, 1);
      expect(controllers.pendingAttachmentFiles.length, 1);
      expect(controllers.pendingAttachmentFiles.first.path, attachment.file.path);
    });

    test('removePendingAttachment removes matching legacy file entry', () {
      final controllers = BeneficiaryFormControllers();
      addTearDown(controllers.dispose);

      final attachment = PendingAttachment(
        file: File('C:/fake/path/remove_me.pdf'),
        documentType: 'medical_report',
        personType: 'file_owner',
      );

      controllers.addPendingAttachment(attachment);
      controllers.removePendingAttachment(attachment);

      expect(controllers.pendingAttachments, isEmpty);
      expect(controllers.pendingAttachmentFiles, isEmpty);
    });

    test('clearPendingAttachments clears metadata and legacy lists', () {
      final controllers = BeneficiaryFormControllers();
      addTearDown(controllers.dispose);

      controllers.addPendingAttachment(
        PendingAttachment(
          file: File('C:/fake/path/a.pdf'),
          documentType: 'id_card',
          personType: 'file_owner',
        ),
      );
      controllers.addPendingAttachment(
        PendingAttachment(
          file: File('C:/fake/path/b.pdf'),
          documentType: 'birth_certificate',
          personType: 'family_member',
          personId: 'Ahmed',
        ),
      );

      controllers.clearPendingAttachments();

      expect(controllers.pendingAttachments, isEmpty);
      expect(controllers.pendingAttachmentFiles, isEmpty);
      expect(controllers.pendingAttachmentsNotifier.value, isEmpty);
    });
  });
}
