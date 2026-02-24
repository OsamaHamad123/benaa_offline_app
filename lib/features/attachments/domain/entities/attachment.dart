/// 📎 Attachment Entity - Domain Layer
///
/// Core business model for file attachments.
class Attachment {
  final String id;
  final String beneficiaryId;
  final String? visitId;
  final String fileName;
  final String filePath;
  final AttachmentType type;
  final int fileSize;
  final String? thumbnailPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool needsSync;
  final String? serverUrl;
  final DateTime? lastSyncedAt;
  final String? documentType;
  final String? personType;
  final String? personId;
  final String? notes;

  const Attachment({
    required this.id,
    required this.beneficiaryId,
    required this.fileName,
    required this.filePath,
    required this.type,
    required this.fileSize,
    required this.createdAt,
    required this.updatedAt,
    this.visitId,
    this.thumbnailPath,
    this.needsSync = false,
    this.serverUrl,
    this.lastSyncedAt,
    this.documentType,
    this.personType,
    this.personId,
    this.notes,
  });

  /// حجم الملف بصيغة قابلة للقراءة
  String get fileSizeReadable {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// امتداد الملف
  String get extension {
    final parts = fileName.split('.');
    return parts.length > 1 ? '.${parts.last.toLowerCase()}' : '';
  }

  /// هل هو صورة؟
  bool get isImage => type == AttachmentType.image;

  /// هل هو PDF؟
  bool get isPdf => type == AttachmentType.pdf;

  /// هل تم المزامنة؟
  bool get isSynced => !needsSync && serverUrl != null;

  /// معرف المرفق على السيرفر (مشتق من المعرف المحلي الموحّد)
  String? get serverAttachmentId {
    const prefix = 'srv_att_';
    if (id.startsWith(prefix) && id.length > prefix.length) {
      final candidate = id.substring(prefix.length);
      if (candidate.isNotEmpty && RegExp(r'^\d+$').hasMatch(candidate)) {
        return candidate;
      }
    }
    return null;
  }

  /// رابط التحميل من السيرفر (حالياً مطابق serverUrl)
  String? get downloadUrl => serverUrl;
}

/// أنواع المرفقات
enum AttachmentType {
  image,
  pdf,
  other;

  String get arabicLabel {
    switch (this) {
      case AttachmentType.image:
        return 'صورة';
      case AttachmentType.pdf:
        return 'PDF';
      case AttachmentType.other:
        return 'ملف آخر';
    }
  }

  static AttachmentType fromString(String value) {
    return AttachmentType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AttachmentType.other,
    );
  }

  static AttachmentType fromExtension(String extension) {
    const imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
    const pdfExtensions = ['.pdf'];

    final ext = extension.toLowerCase();
    if (imageExtensions.contains(ext)) {
      return AttachmentType.image;
    } else if (pdfExtensions.contains(ext)) {
      return AttachmentType.pdf;
    }
    return AttachmentType.other;
  }
}
