import 'package:json_annotation/json_annotation.dart';

part 'attachment.g.dart';

@JsonSerializable()
class Attachment {
  final String id;
  final String beneficiaryId;
  final String? visitId;
  final String type; // 'image' or 'pdf'
  final String path;
  final String hash;
  final int size;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncState;

  const Attachment({
    required this.id,
    required this.beneficiaryId,
    this.visitId,
    required this.type,
    required this.path,
    required this.hash,
    required this.size,
    required this.createdAt,
    required this.updatedAt,
    this.syncState = 'pending',
  });

  factory Attachment.fromJson(Map<String, dynamic> json) =>
      _$AttachmentFromJson(json);

  Map<String, dynamic> toJson() => _$AttachmentToJson(this);

  Attachment copyWith({
    String? id,
    String? beneficiaryId,
    String? visitId,
    String? type,
    String? path,
    String? hash,
    int? size,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncState,
  }) {
    return Attachment(
      id: id ?? this.id,
      beneficiaryId: beneficiaryId ?? this.beneficiaryId,
      visitId: visitId ?? this.visitId,
      type: type ?? this.type,
      path: path ?? this.path,
      hash: hash ?? this.hash,
      size: size ?? this.size,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
    );
  }

  bool get isImage => type == 'image';
  bool get isPdf => type == 'pdf';
  bool get isSynced => syncState == 'synced';
  bool get isPending => syncState == 'pending';
  bool get hasFailed => syncState == 'failed';

  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
