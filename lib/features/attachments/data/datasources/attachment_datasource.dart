import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../../../../data/db/drift_database.dart';
import '../../../../core/utils/beneficiary_identity_resolver.dart';
import '../models/attachment_model.dart';
import '../../domain/entities/attachment.dart' as domain;

/// 📎 Attachment Data Source
///
/// Handles file operations and database access for attachments.
class AttachmentDataSource {
  final AppDatabase _database;
  static const String _attachmentsFolder = 'beneficiary_attachments';
  static const String _thumbnailsFolder = 'thumbnails';
  static const int _maxImageSize = 1920;
  static const int _thumbnailSize = 200;
  static const int _maxFileSize = 10 * 1024 * 1024; // 10 MB

  AttachmentDataSource(this._database);

  /// Get all attachments for a beneficiary
  Future<List<AttachmentModel>> getBeneficiaryAttachments(
    String beneficiaryId,
  ) async {
    final resolvedBeneficiaryId = await _resolveBeneficiaryIdForQuery(beneficiaryId);
    debugPrint('📎 [DataSource] Getting attachments for: $beneficiaryId (resolved: $resolvedBeneficiaryId)');
    final results = await _database.attachmentsDao.getBeneficiaryAttachments(
      resolvedBeneficiaryId,
    );
    debugPrint('📎 [DataSource] Found ${results.length} attachments in DB');
    final models = results.map((e) => AttachmentModel.fromDrift(e)).toList();
    debugPrint('📎 [DataSource] Converted to ${models.length} models');
    return models;
  }

  /// Get single attachment by ID
  Future<AttachmentModel?> getAttachmentById(String id) async {
    final result = await _database.attachmentsDao.getAttachment(id);
    return result != null ? AttachmentModel.fromDrift(result) : null;
  }

  /// Add new attachment
  Future<AttachmentModel> addAttachment({
    required String beneficiaryId,
    String? visitId,
    required File sourceFile,
  }) async {
    final resolvedBeneficiaryId = await _resolveBeneficiaryIdForQuery(beneficiaryId);

    // التحقق من حجم الملف
    final fileSize = await sourceFile.length();
    if (fileSize > _maxFileSize) {
      throw Exception('حجم الملف يتجاوز الحد الأقصى (10 MB)');
    }

    // تحديد نوع الملف
    final extension = path.extension(sourceFile.path).toLowerCase();
    final type = domain.AttachmentType.fromExtension(extension);

    // إنشاء مجلد المرفقات
    final appDir = await getApplicationDocumentsDirectory();
    final attachmentsDir = Directory(
      path.join(appDir.path, _attachmentsFolder, resolvedBeneficiaryId),
    );
    if (!await attachmentsDir.exists()) {
      await attachmentsDir.create(recursive: true);
    }

    // اسم الملف الجديد
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '$timestamp$extension';
    final filePath = path.join(attachmentsDir.path, fileName);

    File finalFile;
    String? thumbnailPath;

    // معالجة الصور
    if (type == domain.AttachmentType.image) {
      // ضغط الصورة
      final compressedFile = await _compressImage(sourceFile, filePath);
      finalFile = compressedFile ?? await sourceFile.copy(filePath);

      // إنشاء thumbnail
      thumbnailPath = await _createThumbnail(finalFile, beneficiaryId);
    } else {
      // نسخ الملف مباشرة
      finalFile = await sourceFile.copy(filePath);
    }

    final actualFileSize = await finalFile.length();
    final now = DateTime.now();
    final id = const Uuid().v4();

    // حفظ في قاعدة البيانات
    await _database.attachmentsDao.addAttachment(
      AttachmentsCompanion(
        id: drift.Value(id),
        beneficiaryId: drift.Value(resolvedBeneficiaryId),
        visitId: drift.Value(visitId),
        fileName: drift.Value(fileName),
        filePath: drift.Value(filePath),
        type: drift.Value(type.name),
        fileSize: drift.Value(actualFileSize),
        thumbnailPath: drift.Value(thumbnailPath),
        createdAt: drift.Value(now),
        updatedAt: drift.Value(now),
        syncState: const drift.Value('pending'),
      ),
    );

    return AttachmentModel(
      id: id,
      beneficiaryId: resolvedBeneficiaryId,
      visitId: visitId,
      fileName: fileName,
      filePath: filePath,
      type: type,
      fileSize: actualFileSize,
      thumbnailPath: thumbnailPath,
      createdAt: now,
      updatedAt: now,
      needsSync: true,
    );
  }

  /// Delete attachment
  Future<bool> deleteAttachment(String id) async {
    try {
      // Get attachment info first
      final attachment = await getAttachmentById(id);
      if (attachment == null) return false;

      // Delete physical file
      final file = File(attachment.filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Delete thumbnail if exists
      if (attachment.thumbnailPath != null) {
        final thumbnail = File(attachment.thumbnailPath!);
        if (await thumbnail.exists()) {
          await thumbnail.delete();
        }
      }

      // Delete from database
      await _database.attachmentsDao.deleteAttachment(id);

      return true;
    } catch (e) {
      debugPrint('Error deleting attachment: $e');
      return false;
    }
  }

  /// Delete all attachments for a beneficiary
  Future<bool> deleteBeneficiaryAttachments(String beneficiaryId) async {
    try {
      final resolvedBeneficiaryId = await _resolveBeneficiaryIdForQuery(beneficiaryId);

      // Get all attachments first
      final attachments = await getBeneficiaryAttachments(resolvedBeneficiaryId);

      // Delete all physical files
      for (final attachment in attachments) {
        final file = File(attachment.filePath);
        if (await file.exists()) {
          await file.delete();
        }

        if (attachment.thumbnailPath != null) {
          final thumbnail = File(attachment.thumbnailPath!);
          if (await thumbnail.exists()) {
            await thumbnail.delete();
          }
        }
      }

      // Delete from database
      await _database.attachmentsDao.deleteBeneficiaryAttachments(
        resolvedBeneficiaryId,
      );

      // Delete directories
      final appDir = await getApplicationDocumentsDirectory();
      final attachmentsDir = Directory(
        path.join(appDir.path, _attachmentsFolder, resolvedBeneficiaryId),
      );
      final thumbnailsDir = Directory(
        path.join(appDir.path, _thumbnailsFolder, resolvedBeneficiaryId),
      );

      if (await attachmentsDir.exists()) {
        await attachmentsDir.delete(recursive: true);
      }

      if (await thumbnailsDir.exists()) {
        await thumbnailsDir.delete(recursive: true);
      }

      return true;
    } catch (e) {
      debugPrint('Error deleting beneficiary attachments: $e');
      return false;
    }
  }

  /// Update attachment sync state
  Future<void> updateSyncState({
    required String id,
    required bool needsSync,
    String? serverUrl,
  }) async {
    await _database.attachmentsDao.updateAttachmentSyncState(
      id,
      needsSync ? 'pending' : 'synced',
      serverUrl: serverUrl,
    );
  }

  /// Get count of attachments
  Future<int> getAttachmentsCount(String beneficiaryId) async {
    final attachments = await getBeneficiaryAttachments(beneficiaryId);
    return attachments.length;
  }

  Future<String> _resolveBeneficiaryIdForQuery(String beneficiaryId) async {
    final resolved = await BeneficiaryIdentityResolver.resolveLocalBeneficiaryIdAsString(
      database: _database,
      beneficiaryId: beneficiaryId,
    );
    return resolved ?? beneficiaryId;
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  /// ضغط الصورة
  Future<File?> _compressImage(File sourceFile, String targetPath) async {
    try {
      final result = await FlutterImageCompress.compressAndGetFile(
        sourceFile.absolute.path,
        targetPath,
        quality: 85,
        minWidth: _maxImageSize,
        minHeight: _maxImageSize,
      );

      return result != null ? File(result.path) : null;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }

  /// إنشاء thumbnail للصورة
  Future<String?> _createThumbnail(File imageFile, String beneficiaryId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final thumbnailsDir = Directory(
        path.join(appDir.path, _thumbnailsFolder, beneficiaryId),
      );
      if (!await thumbnailsDir.exists()) {
        await thumbnailsDir.create(recursive: true);
      }

      final fileName = path.basename(imageFile.path);
      final thumbnailPath = path.join(thumbnailsDir.path, 'thumb_$fileName');

      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        thumbnailPath,
        quality: 70,
        minWidth: _thumbnailSize,
        minHeight: _thumbnailSize,
      );

      return result?.path;
    } catch (e) {
      debugPrint('Error creating thumbnail: $e');
      return null;
    }
  }
}
