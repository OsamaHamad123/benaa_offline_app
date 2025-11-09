class CivilRecord {
  final String nationalId;
  final String fileNo;
  final String fullNameNorm;
  final String fullNameRaw;
  final String governorate;

  const CivilRecord({
    required this.nationalId,
    required this.fileNo,
    required this.fullNameNorm,
    required this.fullNameRaw,
    required this.governorate,
  });

  factory CivilRecord.fromRow(Map<String, dynamic> row) {
    return CivilRecord(
      nationalId: row['national_id'] as String,
      fileNo: row['file_no'] as String,
      fullNameNorm: row['full_name_norm'] as String,
      fullNameRaw: row['full_name_raw'] as String,
      governorate: row['governorate'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'national_id': nationalId,
    'file_no': fileNo,
    'full_name_norm': fullNameNorm,
    'full_name_raw': fullNameRaw,
    'governorate': governorate,
  };

  @override
  String toString() => '$fullNameRaw ($nationalId)';
}

class CivilRegistryManifest {
  final List<CivilRegistryPart> parts;
  final int version;
  final DateTime createdAt;

  const CivilRegistryManifest({
    required this.parts,
    required this.version,
    required this.createdAt,
  });

  factory CivilRegistryManifest.fromJson(Map<String, dynamic> json) {
    return CivilRegistryManifest(
      parts: (json['parts'] as List)
          .map((p) => CivilRegistryPart.fromJson(p as Map<String, dynamic>))
          .toList(),
      version: json['version'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'parts': parts.map((p) => p.toJson()).toList(),
    'version': version,
    'created_at': createdAt.toIso8601String(),
  };

  int get totalSize => parts.fold(0, (sum, part) => sum + part.size);
  int get partCount => parts.length;
}

class CivilRegistryPart {
  final String file;
  final int size;
  final String sha256;

  const CivilRegistryPart({
    required this.file,
    required this.size,
    required this.sha256,
  });

  factory CivilRegistryPart.fromJson(Map<String, dynamic> json) {
    return CivilRegistryPart(
      file: json['file'] as String,
      size: json['size'] as int,
      sha256: json['sha256'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'file': file,
    'size': size,
    'sha256': sha256,
  };
}
