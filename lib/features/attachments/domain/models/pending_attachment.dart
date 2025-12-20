import 'dart:io';

/// 📎 Pending Attachment Model
///
/// نموذج للمرفقات المعلقة (قبل الحفظ) مع metadata
class PendingAttachment {
  final File file;
  final String? documentType; // نوع الوثيقة
  final String? personType; // نوع الشخص المرتبط
  final String? personId; // ID الشخص (إذا كان فرد من العائلة)
  final String? notes; // ملاحظات

  PendingAttachment({
    required this.file,
    this.documentType,
    this.personType,
    this.personId,
    this.notes,
  });

  /// نسخ مع تعديل
  PendingAttachment copyWith({
    File? file,
    String? documentType,
    String? personType,
    String? personId,
    String? notes,
  }) {
    return PendingAttachment(
      file: file ?? this.file,
      documentType: documentType ?? this.documentType,
      personType: personType ?? this.personType,
      personId: personId ?? this.personId,
      notes: notes ?? this.notes,
    );
  }

  /// تحويل إلى Map لحفظها
  Map<String, dynamic> toMap() {
    return {
      'filePath': file.path,
      'documentType': documentType,
      'personType': personType,
      'personId': personId,
      'notes': notes,
    };
  }

  /// من Map
  factory PendingAttachment.fromMap(Map<String, dynamic> map) {
    return PendingAttachment(
      file: File(map['filePath'] as String),
      documentType: map['documentType'] as String?,
      personType: map['personType'] as String?,
      personId: map['personId'] as String?,
      notes: map['notes'] as String?,
    );
  }
}
