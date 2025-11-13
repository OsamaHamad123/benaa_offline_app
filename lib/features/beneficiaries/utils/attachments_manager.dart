import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../../../data/db/drift_database.dart';

/// 📎 Attachment Model
class BeneficiaryAttachment {
  final String id;
  final String beneficiaryId;
  final String fileName;
  final String filePath;
  final AttachmentType type;
  final int fileSize;
  final DateTime createdAt;
  String? thumbnailPath;

  BeneficiaryAttachment({
    required this.id,
    required this.beneficiaryId,
    required this.fileName,
    required this.filePath,
    required this.type,
    required this.fileSize,
    required this.createdAt,
    this.thumbnailPath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'beneficiaryId': beneficiaryId,
    'fileName': fileName,
    'filePath': filePath,
    'type': type.name,
    'fileSize': fileSize,
    'createdAt': createdAt.toIso8601String(),
    'thumbnailPath': thumbnailPath,
  };

  factory BeneficiaryAttachment.fromJson(Map<String, dynamic> json) {
    return BeneficiaryAttachment(
      id: json['id'] as String,
      beneficiaryId: json['beneficiaryId'] as String,
      fileName: json['fileName'] as String,
      filePath: json['filePath'] as String,
      type: AttachmentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AttachmentType.other,
      ),
      fileSize: json['fileSize'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      thumbnailPath: json['thumbnailPath'] as String?,
    );
  }

  /// حجم الملف بصيغة قابلة للقراءة
  String get fileSizeReadable {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024)
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// امتداد الملف
  String get extension => path.extension(fileName).toLowerCase();

  /// هل هو صورة؟
  bool get isImage => type == AttachmentType.image;

  /// هل هو PDF؟
  bool get isPdf => type == AttachmentType.pdf;
}

/// أنواع المرفقات
enum AttachmentType { image, pdf, other }

/// 📁 Attachments Manager
class AttachmentsManager {
  static const String _attachmentsFolder = 'beneficiary_attachments';
  static const String _thumbnailsFolder = 'thumbnails';
  static const int _maxImageSize = 1920; // pixels
  static const int _thumbnailSize = 200; // pixels
  static const int _maxFileSize = 10 * 1024 * 1024; // 10 MB

  /// إضافة مرفق جديد
  static Future<BeneficiaryAttachment?> addAttachment({
    required String beneficiaryId,
    required File sourceFile,
  }) async {
    try {
      // التحقق من حجم الملف
      final fileSize = await sourceFile.length();
      if (fileSize > _maxFileSize) {
        throw Exception('حجم الملف يتجاوز الحد الأقصى (10 MB)');
      }

      // تحديد نوع الملف
      final extension = path.extension(sourceFile.path).toLowerCase();
      final type = _getAttachmentType(extension);

      // إنشاء مجلد المرفقات
      final appDir = await getApplicationDocumentsDirectory();
      final attachmentsDir = Directory(
        path.join(appDir.path, _attachmentsFolder, beneficiaryId),
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
      if (type == AttachmentType.image) {
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

      return BeneficiaryAttachment(
        id: '$beneficiaryId-$timestamp',
        beneficiaryId: beneficiaryId,
        fileName: fileName,
        filePath: filePath,
        type: type,
        fileSize: actualFileSize,
        createdAt: DateTime.now(),
        thumbnailPath: thumbnailPath,
      );
    } catch (e) {
      debugPrint('Error adding attachment: $e');
      return null;
    }
  }

  /// حذف مرفق
  static Future<bool> deleteAttachment(BeneficiaryAttachment attachment) async {
    try {
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

      return true;
    } catch (e) {
      debugPrint('Error deleting attachment: $e');
      return false;
    }
  }

  /// ضغط الصورة
  static Future<File?> _compressImage(
    File sourceFile,
    String targetPath,
  ) async {
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
  static Future<String?> _createThumbnail(
    File imageFile,
    String beneficiaryId,
  ) async {
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

  /// تحديد نوع المرفق من الامتداد
  static AttachmentType _getAttachmentType(String extension) {
    const imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
    const pdfExtensions = ['.pdf'];

    if (imageExtensions.contains(extension)) {
      return AttachmentType.image;
    } else if (pdfExtensions.contains(extension)) {
      return AttachmentType.pdf;
    }
    return AttachmentType.other;
  }

  /// الحصول على جميع مرفقات مستفيد
  static Future<List<BeneficiaryAttachment>> getAttachments(
    String beneficiaryId,
  ) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final attachmentsDir = Directory(
        path.join(appDir.path, _attachmentsFolder, beneficiaryId),
      );

      if (!await attachmentsDir.exists()) {
        return [];
      }

      final files = await attachmentsDir.list().toList();
      final attachments = <BeneficiaryAttachment>[];

      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          final extension = path.extension(file.path).toLowerCase();
          final type = _getAttachmentType(extension);

          attachments.add(
            BeneficiaryAttachment(
              id: '$beneficiaryId-${stat.modified.millisecondsSinceEpoch}',
              beneficiaryId: beneficiaryId,
              fileName: path.basename(file.path),
              filePath: file.path,
              type: type,
              fileSize: stat.size,
              createdAt: stat.modified,
            ),
          );
        }
      }

      return attachments;
    } catch (e) {
      debugPrint('Error getting attachments: $e');
      return [];
    }
  }

  /// حذف جميع مرفقات مستفيد
  static Future<bool> deleteAllAttachments(String beneficiaryId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final attachmentsDir = Directory(
        path.join(appDir.path, _attachmentsFolder, beneficiaryId),
      );
      final thumbnailsDir = Directory(
        path.join(appDir.path, _thumbnailsFolder, beneficiaryId),
      );

      if (await attachmentsDir.exists()) {
        await attachmentsDir.delete(recursive: true);
      }

      if (await thumbnailsDir.exists()) {
        await thumbnailsDir.delete(recursive: true);
      }

      return true;
    } catch (e) {
      debugPrint('Error deleting all attachments: $e');
      return false;
    }
  }

  // ============================================================================
  // DATABASE METHODS - دوال قاعدة البيانات
  // ============================================================================

  /// إضافة مرفق مع حفظ في قاعدة البيانات
  static Future<BeneficiaryAttachment?> addAttachmentWithDb({
    required String beneficiaryId,
    required File sourceFile,
    required AppDatabase database,
  }) async {
    final attachment = await addAttachment(
      beneficiaryId: beneficiaryId,
      sourceFile: sourceFile,
    );

    if (attachment != null) {
      // حفظ في قاعدة البيانات
      await database.attachmentsDao.addAttachment(
        AttachmentsCompanion(
          id: drift.Value(const Uuid().v4()),
          beneficiaryId: drift.Value(beneficiaryId),
          fileName: drift.Value(attachment.fileName),
          filePath: drift.Value(attachment.filePath),
          type: drift.Value(attachment.type.name),
          fileSize: drift.Value(attachment.fileSize),
          thumbnailPath: drift.Value(attachment.thumbnailPath),
          createdAt: drift.Value(attachment.createdAt),
          updatedAt: drift.Value(DateTime.now()),
        ),
      );
    }

    return attachment;
  }

  /// حذف مرفق مع حذف من قاعدة البيانات
  static Future<bool> deleteAttachmentWithDb({
    required BeneficiaryAttachment attachment,
    required AppDatabase database,
  }) async {
    final success = await deleteAttachment(attachment);

    if (success) {
      // حذف من قاعدة البيانات
      await database.attachmentsDao.deleteAttachment(attachment.id);
    }

    return success;
  }

  /// جلب مرفقات من قاعدة البيانات
  static Future<List<BeneficiaryAttachment>> getAttachmentsFromDb({
    required String beneficiaryId,
    required AppDatabase database,
  }) async {
    final dbAttachments = await database.attachmentsDao
        .getBeneficiaryAttachments(beneficiaryId);

    return dbAttachments
        .map(
          (a) => BeneficiaryAttachment(
            id: a.id,
            beneficiaryId: a.beneficiaryId,
            fileName: a.fileName,
            filePath: a.filePath,
            type: AttachmentType.values.firstWhere(
              (e) => e.name == a.type,
              orElse: () => AttachmentType.other,
            ),
            fileSize: a.fileSize,
            createdAt: a.createdAt,
            thumbnailPath: a.thumbnailPath,
          ),
        )
        .toList();
  }
}
