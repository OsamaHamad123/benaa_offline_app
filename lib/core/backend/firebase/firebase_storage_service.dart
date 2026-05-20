import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  FirebaseStorageService({FirebaseStorage? storage}) : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;
  static const int _maxUploadBytes = 10 * 1024 * 1024; // 10 MB
  static const Set<String> _allowedContentTypes = <String>{
    'application/pdf',
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/webp',
  };

  Future<String?> uploadAttachment(
    String beneficiaryId,
    String localPath,
    String fileName,
    String contentType,
  ) async {
    final file = File(localPath);
    if (!await file.exists()) {
      throw ArgumentError('Attachment file does not exist at path: $localPath');
    }

    final normalizedContentType = contentType.trim().toLowerCase();
    if (!_allowedContentTypes.contains(normalizedContentType)) {
      throw ArgumentError('Unsupported attachment content type: $contentType');
    }

    final fileSize = await file.length();
    if (fileSize > _maxUploadBytes) {
      throw ArgumentError('Attachment exceeds max upload size (${_maxUploadBytes ~/ (1024 * 1024)} MB).');
    }

    final ref = _storage.ref().child('beneficiaries/$beneficiaryId/attachments/$fileName');

    try {
      final metadata = SettableMetadata(contentType: normalizedContentType);
      await ref.putFile(file, metadata);
      return ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw Exception('Firebase Storage upload failed (${e.code}): ${e.message ?? 'unknown error'}');
    } catch (e) {
      throw Exception('Attachment upload failed: $e');
    }
  }
}
