/// 👤 Beneficiary Entity - Domain Layer
///
/// Core business model for a beneficiary in the system.
/// Independent of database or framework.
class Beneficiary {
  final String id;
  final String fullName;
  final String nationalId;
  final Gender gender;
  final BeneficiaryCategory category;
  final DateTime? birthDate;

  // Family Info
  final String? motherName;
  final String? fatherName;
  final String? grandFatherName;
  final String? familyName;

  // Contact Info
  final String? phoneNumber;
  final String? altPhoneNumber;
  final String? governorate;
  final String? district;
  final String? address;
  final String? currentAddress;
  final String? addressBeforeDisplacement;

  // Additional Info
  final String? fileNo;
  final String? associationName;
  final MaritalStatus? maritalStatus;
  final EducationLevel? educationLevel;
  final HealthStatus healthStatus;
  final bool hasDisability;

  // Family Details
  final int? familySize;
  final int? numberOfMales;
  final int? numberOfFemales;
  final int? chronicDiseasesCount;
  final int? specialNeedsCount;

  // Status Fields
  final DisplacementStatus? displacementStatus;
  final EmploymentStatus? employmentStatus;
  final HousingStatus? housingStatus;
  final HousingType? housingType;
  final RequestStatus? requestStatus;

  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool needsSync;

  const Beneficiary({
    required this.id,
    required this.fullName,
    required this.nationalId,
    required this.gender,
    required this.category,
    this.birthDate,
    this.motherName,
    this.fatherName,
    this.grandFatherName,
    this.familyName,
    this.phoneNumber,
    this.altPhoneNumber,
    this.governorate,
    this.district,
    this.address,
    this.currentAddress,
    this.addressBeforeDisplacement,
    this.fileNo,
    this.associationName,
    this.maritalStatus,
    this.educationLevel,
    this.healthStatus = HealthStatus.good,
    this.hasDisability = false,
    this.familySize,
    this.numberOfMales,
    this.numberOfFemales,
    this.chronicDiseasesCount,
    this.specialNeedsCount,
    this.displacementStatus,
    this.employmentStatus,
    this.housingStatus,
    this.housingType,
    this.requestStatus,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.needsSync = false,
  });

  /// Calculate age from birth date
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  /// Check if beneficiary is a child (<18 years)
  bool get isChild {
    final ageValue = age;
    return ageValue != null && ageValue < 18;
  }

  /// Check if beneficiary is elderly (>60 years)
  bool get isElderly {
    final ageValue = age;
    return ageValue != null && ageValue > 60;
  }

  /// Get display name (prioritize full name, fallback to parts)
  String get displayName {
    if (fullName.isNotEmpty) return fullName;
    final parts = [
      firstName,
      fatherName,
      familyName,
    ].where((p) => p != null && p.isNotEmpty);
    return parts.join(' ').trim();
  }

  String? get firstName => fullName.split(' ').firstOrNull;

  /// Check if data is complete enough for submission
  bool get isComplete {
    return fullName.isNotEmpty &&
        nationalId.isNotEmpty &&
        phoneNumber != null &&
        phoneNumber!.isNotEmpty;
  }

  /// Calculate completion percentage
  double get completionPercentage {
    int filled = 0;
    int total = 15; // Total important fields

    if (fullName.isNotEmpty) filled++;
    if (nationalId.isNotEmpty) filled++;
    if (phoneNumber != null && phoneNumber!.isNotEmpty) filled++;
    if (birthDate != null) filled++;
    if (gender != Gender.unknown) filled++;
    if (category != BeneficiaryCategory.other) filled++;
    if (motherName != null && motherName!.isNotEmpty) filled++;
    if (governorate != null && governorate!.isNotEmpty) filled++;
    if (district != null && district!.isNotEmpty) filled++;
    if (address != null && address!.isNotEmpty) filled++;
    if (maritalStatus != null) filled++;
    if (educationLevel != null) filled++;
    if (familySize != null) filled++;
    if (employmentStatus != null) filled++;
    if (housingStatus != null) filled++;

    return (filled / total) * 100;
  }

  Beneficiary copyWith({
    String? id,
    String? fullName,
    String? nationalId,
    Gender? gender,
    BeneficiaryCategory? category,
    DateTime? birthDate,
    String? motherName,
    String? fatherName,
    String? grandFatherName,
    String? familyName,
    String? phoneNumber,
    String? altPhoneNumber,
    String? governorate,
    String? district,
    String? address,
    String? currentAddress,
    String? addressBeforeDisplacement,
    String? fileNo,
    String? associationName,
    MaritalStatus? maritalStatus,
    EducationLevel? educationLevel,
    HealthStatus? healthStatus,
    bool? hasDisability,
    int? familySize,
    int? numberOfMales,
    int? numberOfFemales,
    int? chronicDiseasesCount,
    int? specialNeedsCount,
    DisplacementStatus? displacementStatus,
    EmploymentStatus? employmentStatus,
    HousingStatus? housingStatus,
    HousingType? housingType,
    RequestStatus? requestStatus,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? needsSync,
  }) {
    return Beneficiary(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      nationalId: nationalId ?? this.nationalId,
      gender: gender ?? this.gender,
      category: category ?? this.category,
      birthDate: birthDate ?? this.birthDate,
      motherName: motherName ?? this.motherName,
      fatherName: fatherName ?? this.fatherName,
      grandFatherName: grandFatherName ?? this.grandFatherName,
      familyName: familyName ?? this.familyName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      altPhoneNumber: altPhoneNumber ?? this.altPhoneNumber,
      governorate: governorate ?? this.governorate,
      district: district ?? this.district,
      address: address ?? this.address,
      currentAddress: currentAddress ?? this.currentAddress,
      addressBeforeDisplacement:
          addressBeforeDisplacement ?? this.addressBeforeDisplacement,
      fileNo: fileNo ?? this.fileNo,
      associationName: associationName ?? this.associationName,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      educationLevel: educationLevel ?? this.educationLevel,
      healthStatus: healthStatus ?? this.healthStatus,
      hasDisability: hasDisability ?? this.hasDisability,
      familySize: familySize ?? this.familySize,
      numberOfMales: numberOfMales ?? this.numberOfMales,
      numberOfFemales: numberOfFemales ?? this.numberOfFemales,
      chronicDiseasesCount: chronicDiseasesCount ?? this.chronicDiseasesCount,
      specialNeedsCount: specialNeedsCount ?? this.specialNeedsCount,
      displacementStatus: displacementStatus ?? this.displacementStatus,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      housingStatus: housingStatus ?? this.housingStatus,
      housingType: housingType ?? this.housingType,
      requestStatus: requestStatus ?? this.requestStatus,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      needsSync: needsSync ?? this.needsSync,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Beneficiary && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Beneficiary(id: $id, name: $fullName, nationalId: $nationalId)';
}

/// 🚻 Gender
enum Gender {
  male('ذكر', 'male'),
  female('أنثى', 'female'),
  unknown('غير محدد', 'unknown');

  final String arabicLabel;
  final String englishValue;
  const Gender(this.arabicLabel, this.englishValue);

  static Gender fromString(String value) {
    return Gender.values.firstWhere(
      (g) => g.englishValue == value || g.arabicLabel == value,
      orElse: () => Gender.unknown,
    );
  }
}

/// 📋 Beneficiary Category
enum BeneficiaryCategory {
  orphan('يتيم', 'orphan'),
  poor('فقير', 'poor'),
  displaced('نازح', 'displaced'),
  disabled('ذوي احتياجات خاصة', 'disabled'),
  elderly('مسن', 'elderly'),
  widow('أرملة', 'widow'),
  divorced('مطلقة', 'divorced'),
  prisoner('أسير', 'prisoner'),
  injured('جريح', 'injured'),
  martyr('شهيد', 'martyr'),
  other('أخرى', 'other');

  final String arabicLabel;
  final String englishValue;
  const BeneficiaryCategory(this.arabicLabel, this.englishValue);

  static BeneficiaryCategory fromString(String value) {
    return BeneficiaryCategory.values.firstWhere(
      (c) => c.englishValue == value || c.arabicLabel == value,
      orElse: () => BeneficiaryCategory.other,
    );
  }
}

/// 💍 Marital Status
enum MaritalStatus {
  single('أعزب/عزباء'),
  married('متزوج/متزوجة'),
  divorced('مطلق/مطلقة'),
  widowed('أرمل/أرملة');

  final String arabicLabel;
  const MaritalStatus(this.arabicLabel);
}

/// 🎓 Education Level
enum EducationLevel {
  none('أمي'),
  primary('ابتدائي'),
  intermediate('إعدادي'),
  secondary('ثانوي'),
  diploma('دبلوم'),
  bachelor('بكالوريوس'),
  master('ماجستير'),
  illiterate('غير متعلم'),
  phd('دكتوراه');

  final String arabicLabel;
  const EducationLevel(this.arabicLabel);
}

/// 🏥 Health Status
enum HealthStatus {
  good('جيد'),
  fair('متوسط'),
  chronicDisease('مزمن'),
  disability('معاق'),
  poor('سيء');

  final String arabicLabel;
  const HealthStatus(this.arabicLabel);

  static HealthStatus fromString(String value) {
    return HealthStatus.values.firstWhere(
      (h) => h.arabicLabel == value || h.name == value,
      orElse: () => HealthStatus.good,
    );
  }
}

/// 🏘️ Displacement Status
enum DisplacementStatus {
  notDisplaced(0, 'غير نازح'),
  displaced(1, 'نازح'),
  refugee(2, 'لاجئ'),
  returned(3, 'عائد'),
  returnee(4, 'عائد');

  final int code;
  final String arabicLabel;
  const DisplacementStatus(this.code, this.arabicLabel);

  static DisplacementStatus? fromCode(int? code) {
    if (code == null) return null;
    return DisplacementStatus.values.firstWhere(
      (d) => d.code == code,
      orElse: () => DisplacementStatus.notDisplaced,
    );
  }
}

/// 💼 Employment Status
enum EmploymentStatus {
  employed(1, 'موظف'),
  unemployed(2, 'عاطل عن العمل'),
  student(3, 'طالب'),
  retired(4, 'متقاعد'),
  disabled(5, 'معاق'),
  selfEmployed(6, 'عمل حر');

  final int code;
  final String arabicLabel;
  const EmploymentStatus(this.code, this.arabicLabel);

  static EmploymentStatus? fromCode(int? code) {
    if (code == null) return null;
    return EmploymentStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => EmploymentStatus.unemployed,
    );
  }
}

/// 🏠 Housing Status
enum HousingStatus {
  owned(1, 'ملك'),
  rented(2, 'إيجار'),
  shared(3, 'مشترك'),
  homeless(4, 'مشرد'),
  withFamily(5, 'مع العائلة'),
  sharedOwned(6, 'مشترك ملك'),
  temporary(7, 'مؤقت');

  final int code;
  final String arabicLabel;
  const HousingStatus(this.code, this.arabicLabel);

  static HousingStatus? fromCode(int? code) {
    if (code == null) return null;
    return HousingStatus.values.firstWhere(
      (h) => h.code == code,
      orElse: () => HousingStatus.rented,
    );
  }
}

/// 🏘️ Housing Type
enum HousingType {
  house(1, 'منزل'),
  apartment(2, 'شقة'),
  room(3, 'غرفة'),
  tent(4, 'خيمة'),
  caravan(5, 'قافلة'),
  shelter(6, 'مأوى'),
  other(7, 'أخرى');

  final int code;
  final String arabicLabel;
  const HousingType(this.code, this.arabicLabel);

  static HousingType? fromCode(int? code) {
    if (code == null) return null;
    return HousingType.values.firstWhere(
      (h) => h.code == code,
      orElse: () => HousingType.house,
    );
  }
}

/// 📝 Request Status
enum RequestStatus {
  pending(1, 'قيد المراجعة'),
  approved(2, 'مقبول'),
  rejected(3, 'مرفوض'),
  completed(4, 'مكتمل');

  final int code;
  final String arabicLabel;
  const RequestStatus(this.code, this.arabicLabel);

  static RequestStatus? fromCode(int? code) {
    if (code == null) return null;
    return RequestStatus.values.firstWhere(
      (r) => r.code == code,
      orElse: () => RequestStatus.pending,
    );
  }
}
