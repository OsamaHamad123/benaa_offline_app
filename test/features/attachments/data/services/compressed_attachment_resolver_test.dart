import 'package:flutter_test/flutter_test.dart';

import 'package:benaa_offline_app/features/attachments/data/services/compressed_attachment_resolver.dart';
import 'package:benaa_offline_app/features/attachments/domain/entities/attachment.dart';

void main() {
  group('CompressedAttachmentResolver contract parsing', () {
    Attachment makeAttachment({
      required String id,
      required String fileName,
      String? filePath,
      String? serverUrl,
      AttachmentType type = AttachmentType.other,
    }) {
      return Attachment(
        id: id,
        beneficiaryId: '1',
        fileName: fileName,
        filePath: filePath ?? fileName,
        type: type,
        fileSize: 1024,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        serverUrl: serverUrl,
      );
    }

    test('parses zip bang reference (zip+entry)', () {
      final attachment = makeAttachment(
        id: 'a1',
        fileName: 'doc.pdf',
        serverUrl: 'https://example.com/archive.zip!folder/doc.pdf',
      );

      final ref = CompressedAttachmentResolver.parseReference(attachment);

      expect(ref, isNotNull);
      expect(ref!.archiveUrl, 'https://example.com/archive.zip');
      expect(ref.entryPath, 'folder/doc.pdf');
      expect(CompressedAttachmentResolver.isCompressedAttachment(attachment), isTrue);
    });

    test('parses JSON reference payload', () {
      final attachment = makeAttachment(
        id: 'a2',
        fileName: 'x.pdf',
        serverUrl: '{"archive_url":"https://cdn.example.com/a.zip","entry_path":"items/x.pdf"}',
      );

      final ref = CompressedAttachmentResolver.parseReference(attachment);

      expect(ref, isNotNull);
      expect(ref!.archiveUrl, 'https://cdn.example.com/a.zip');
      expect(ref.entryPath, 'items/x.pdf');
    });

    test('direct URL is not treated as compressed reference', () {
      final attachment = makeAttachment(
        id: 'a3',
        fileName: 'image.jpg',
        type: AttachmentType.image,
        serverUrl: 'https://example.com/uploads/image.jpg',
      );

      final ref = CompressedAttachmentResolver.parseReference(attachment);

      expect(ref, isNull);
      expect(CompressedAttachmentResolver.isCompressedAttachment(attachment), isFalse);
    });

    test('zip URL without entry does not produce compressed reference', () {
      final attachment = makeAttachment(
        id: 'a4',
        fileName: 'report.pdf',
        serverUrl: 'https://example.com/archive.zip',
      );

      final ref = CompressedAttachmentResolver.parseReference(attachment);

      expect(ref, isNull);
      expect(CompressedAttachmentResolver.isCompressedAttachment(attachment), isFalse);
    });
  });
}
