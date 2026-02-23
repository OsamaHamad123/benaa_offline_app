/// 🔍 Advanced Search Filter Entity
///
/// يمثل الفلاتر المتقدمة للبحث
library;

class AdvancedSearchFilter {
  final String? name;
  final String? nationalId;
  final String? phoneNumber;
  final String? city;
  final String? district;
  final int? minAge;
  final int? maxAge;
  final String? gender;
  final String? maritalStatus;
  final String? healthStatus;
  final int? minFamilySize;
  final int? maxFamilySize;
  final DateTime? registrationStartDate;
  final DateTime? registrationEndDate;
  final bool? hasSponsorship;
  final List<String>? documentTypes;

  const AdvancedSearchFilter({
    this.name,
    this.nationalId,
    this.phoneNumber,
    this.city,
    this.district,
    this.minAge,
    this.maxAge,
    this.gender,
    this.maritalStatus,
    this.healthStatus,
    this.minFamilySize,
    this.maxFamilySize,
    this.registrationStartDate,
    this.registrationEndDate,
    this.hasSponsorship,
    this.documentTypes,
  });

  AdvancedSearchFilter copyWith({
    String? name,
    String? nationalId,
    String? phoneNumber,
    String? city,
    String? district,
    int? minAge,
    int? maxAge,
    String? gender,
    String? maritalStatus,
    String? healthStatus,
    int? minFamilySize,
    int? maxFamilySize,
    DateTime? registrationStartDate,
    DateTime? registrationEndDate,
    bool? hasSponsorship,
    List<String>? documentTypes,
  }) {
    return AdvancedSearchFilter(
      name: name ?? this.name,
      nationalId: nationalId ?? this.nationalId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      city: city ?? this.city,
      district: district ?? this.district,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      healthStatus: healthStatus ?? this.healthStatus,
      minFamilySize: minFamilySize ?? this.minFamilySize,
      maxFamilySize: maxFamilySize ?? this.maxFamilySize,
      registrationStartDate:
          registrationStartDate ?? this.registrationStartDate,
      registrationEndDate: registrationEndDate ?? this.registrationEndDate,
      hasSponsorship: hasSponsorship ?? this.hasSponsorship,
      documentTypes: documentTypes ?? this.documentTypes,
    );
  }

  /// هل الفلتر فارغ؟
  bool get isEmpty =>
      name == null &&
      nationalId == null &&
      phoneNumber == null &&
      city == null &&
      district == null &&
      minAge == null &&
      maxAge == null &&
      gender == null &&
      maritalStatus == null &&
      healthStatus == null &&
      minFamilySize == null &&
      maxFamilySize == null &&
      registrationStartDate == null &&
      registrationEndDate == null &&
      hasSponsorship == null &&
      (documentTypes == null || documentTypes!.isEmpty);

  /// مسح جميع الفلاتر
  factory AdvancedSearchFilter.empty() => const AdvancedSearchFilter();

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nationalId': nationalId,
      'phoneNumber': phoneNumber,
      'city': city,
      'district': district,
      'minAge': minAge,
      'maxAge': maxAge,
      'gender': gender,
      'maritalStatus': maritalStatus,
      'healthStatus': healthStatus,
      'minFamilySize': minFamilySize,
      'maxFamilySize': maxFamilySize,
      'registrationStartDate': registrationStartDate?.toIso8601String(),
      'registrationEndDate': registrationEndDate?.toIso8601String(),
      'hasSponsorship': hasSponsorship,
      'documentTypes': documentTypes,
    };
  }

  factory AdvancedSearchFilter.fromJson(Map<String, dynamic> json) {
    return AdvancedSearchFilter(
      name: json['name'] as String?,
      nationalId: json['nationalId'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      city: json['city'] as String?,
      district: json['district'] as String?,
      minAge: json['minAge'] as int?,
      maxAge: json['maxAge'] as int?,
      gender: json['gender'] as String?,
      maritalStatus: json['maritalStatus'] as String?,
      healthStatus: json['healthStatus'] as String?,
      minFamilySize: json['minFamilySize'] as int?,
      maxFamilySize: json['maxFamilySize'] as int?,
      registrationStartDate: json['registrationStartDate'] != null
          ? DateTime.parse(json['registrationStartDate'] as String)
          : null,
      registrationEndDate: json['registrationEndDate'] != null
          ? DateTime.parse(json['registrationEndDate'] as String)
          : null,
      hasSponsorship: json['hasSponsorship'] as bool?,
      documentTypes: (json['documentTypes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }
}
