/// نموذج سجل مدني - متوافق مع قاعدة البيانات الرئيسية
class CivilRecord {
  // Primary Key
  final int id;

  // البيانات الأساسية
  final String nationalId; // CI_ID_NUM
  final String firstName; // CI_FIRST_ARB
  final String fatherName; // CI_FATHER_ARB
  final String grandFatherName; // CI_GRAND_FATHER_ARB
  final String familyName; // CI_FAMILY_ARB

  // معلومات الولادة
  final int? birthCertificateId; // CI_BIRTH_TB_CD
  final int? birthCodeId; // CI_BIRTH_CD
  final DateTime? birthDate; // CI_BIRTH_DT
  final int? sexCode; // CI_SEX_CD (1=ذكر, 2=أنثى)

  // معلومات شخصية
  final int? personalCodeId; // CI_PERSONAL_CD
  final int? deadDate; // CI_DEAD_DT
  final String? motherName; // MOTHER_NAME1

  // معلومات العنوان
  final int? cityId; // CITY
  final String? cityName; // من جدول city
  final String? street; // STREET
  final String? houseNo; // HOUSE_NO

  // العلاقات
  final int? relationId; // CF_ID_NUM
  final int? relativeCodeId; // CF_RELATIVE_CD
  final int? relativeId; // CF_ID_RELATIVE

  // حقول محلية للبحث
  final String fullName; // الاسم الكامل المجمّع
  final String fullNameNormalized; // للبحث
  final String? governorate; // المحافظة
  final String? district; // القضاء

  // حقول المزامنة
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;

  const CivilRecord({
    required this.id,
    required this.nationalId,
    required this.firstName,
    required this.fatherName,
    required this.grandFatherName,
    required this.familyName,
    this.birthCertificateId,
    this.birthCodeId,
    this.birthDate,
    this.sexCode,
    this.personalCodeId,
    this.deadDate,
    this.motherName,
    this.cityId,
    this.cityName,
    this.street,
    this.houseNo,
    this.relationId,
    this.relativeCodeId,
    this.relativeId,
    required this.fullName,
    required this.fullNameNormalized,
    this.governorate,
    this.district,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
  });

  /// البناء من CivilRegistryData (من Drift)
  factory CivilRecord.fromDrift(dynamic driftData) {
    return CivilRecord(
      id: driftData.id,
      nationalId: driftData.nationalId,
      firstName: driftData.firstName,
      fatherName: driftData.fatherName,
      grandFatherName: driftData.grandFatherName,
      familyName: driftData.familyName,
      birthCertificateId: driftData.birthCertificateId,
      birthCodeId: driftData.birthCodeId,
      birthDate: driftData.birthDate,
      sexCode: driftData.sexCode,
      personalCodeId: driftData.personalCodeId,
      deadDate: driftData.deadDate,
      motherName: driftData.motherName,
      cityId: driftData.cityId,
      cityName: driftData.cityName,
      street: driftData.street,
      houseNo: driftData.houseNo,
      relationId: driftData.relationId,
      relativeCodeId: driftData.relativeCodeId,
      relativeId: driftData.relativeId,
      fullName:
          driftData.fullName ??
          _buildFullName(
            driftData.firstName,
            driftData.fatherName,
            driftData.grandFatherName,
            driftData.familyName,
          ),
      fullNameNormalized: driftData.fullNameNormalized ?? '',
      governorate: driftData.governorate,
      district: driftData.district,
      createdAt: driftData.createdAt,
      updatedAt: driftData.updatedAt,
      lastSyncedAt: driftData.lastSyncedAt,
    );
  }

  /// البناء من API Response
  factory CivilRecord.fromJson(Map<String, dynamic> json) {
    final firstName = json['CI_FIRST_ARB'] as String? ?? '';
    final fatherName = json['CI_FATHER_ARB'] as String? ?? '';
    final grandFatherName = json['CI_GRAND_FATHER_ARB'] as String? ?? '';
    final familyName = json['CI_FAMILY_ARB'] as String? ?? '';

    return CivilRecord(
      id: json['id'] as int,
      nationalId: json['CI_ID_NUM']?.toString() ?? '',
      firstName: firstName,
      fatherName: fatherName,
      grandFatherName: grandFatherName,
      familyName: familyName,
      birthCertificateId: json['CI_BIRTH_TB_CD'] as int?,
      birthCodeId: json['CI_BIRTH_CD'] as int?,
      birthDate: json['CI_BIRTH_DT'] != null
          ? DateTime.parse(json['CI_BIRTH_DT'] as String)
          : null,
      sexCode: json['CI_SEX_CD'] as int?,
      personalCodeId: json['CI_PERSONAL_CD'] as int?,
      deadDate: json['CI_DEAD_DT'] as int?,
      motherName: json['MOTHER_NAME1'] as String?,
      cityId: json['CITY'] as int?,
      cityName: json['city_name'] as String?,
      street: json['STREET'] as String?,
      houseNo: json['HOUSE_NO'] as String?,
      relationId: json['CF_ID_NUM'] as int?,
      relativeCodeId: json['CF_RELATIVE_CD'] as int?,
      relativeId: json['CF_ID_RELATIVE'] as int?,
      fullName:
          json['full_name'] as String? ??
          _buildFullName(firstName, fatherName, grandFatherName, familyName),
      fullNameNormalized: json['full_name_normalized'] as String? ?? '',
      governorate: json['governorate'] as String?,
      district: json['district'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      lastSyncedAt: json['last_synced_at'] != null
          ? DateTime.parse(json['last_synced_at'] as String)
          : null,
    );
  }

  /// بناء الاسم الكامل من الأجزاء
  static String _buildFullName(
    String firstName,
    String fatherName,
    String grandFatherName,
    String familyName,
  ) {
    return [
      firstName,
      fatherName,
      grandFatherName,
      familyName,
    ].where((e) => e.isNotEmpty).join(' ');
  }

  /// الجنس كنص
  String get gender {
    if (sexCode == null) return 'غير محدد';
    return sexCode == 1 ? 'ذكر' : 'أنثى';
  }

  /// العمر (إذا كان تاريخ الميلاد متوفر)
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    var age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  /// متوفى؟
  bool get isDeceased => deadDate != null && deadDate! > 0;

  /// العنوان الكامل
  String? get fullAddress {
    final parts = <String>[];
    if (street != null && street!.isNotEmpty) parts.add(street!);
    if (houseNo != null && houseNo!.isNotEmpty) parts.add('منزل $houseNo');
    if (district != null && district!.isNotEmpty) parts.add(district!);
    if (governorate != null && governorate!.isNotEmpty) parts.add(governorate!);
    return parts.isEmpty ? null : parts.join(' - ');
  }

  /// تحويل لـ Map للمستفيد
  Map<String, dynamic> toBeneficiaryData() {
    return {
      'national_id': nationalId,
      'full_name': fullName,
      'first_name': firstName,
      'father_name': fatherName,
      'grand_father_name': grandFatherName,
      'family_name': familyName,
      'mother_name': motherName,
      'birth_date': birthDate?.toIso8601String(),
      'gender': sexCode == 1 ? 'male' : 'female',
      'governorate': governorate,
      'district': district,
      'address': fullAddress,
      'street': street,
      'house_no': houseNo,
    };
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'CI_ID_NUM': nationalId,
    'CI_FIRST_ARB': firstName,
    'CI_FATHER_ARB': fatherName,
    'CI_GRAND_FATHER_ARB': grandFatherName,
    'CI_FAMILY_ARB': familyName,
    'CI_BIRTH_TB_CD': birthCertificateId,
    'CI_BIRTH_CD': birthCodeId,
    'CI_BIRTH_DT': birthDate?.toIso8601String(),
    'CI_SEX_CD': sexCode,
    'CI_PERSONAL_CD': personalCodeId,
    'CI_DEAD_DT': deadDate,
    'MOTHER_NAME1': motherName,
    'CITY': cityId,
    'city_name': cityName,
    'STREET': street,
    'HOUSE_NO': houseNo,
    'CF_ID_NUM': relationId,
    'CF_RELATIVE_CD': relativeCodeId,
    'CF_ID_RELATIVE': relativeId,
    'full_name': fullName,
    'full_name_normalized': fullNameNormalized,
    'governorate': governorate,
    'district': district,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'last_synced_at': lastSyncedAt?.toIso8601String(),
  };

  @override
  String toString() => '$fullName ($nationalId)';
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
