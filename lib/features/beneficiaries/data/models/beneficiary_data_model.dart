import '../../domain/entities/beneficiary.dart' as entity;
import '../../../../data/db/drift_database.dart' as db;
import 'package:drift/drift.dart' as drift;

/// 📦 Beneficiary Data Model - متطابق مع جدول `data` في قاعدة البيانات الرئيسية
///
/// هذا النموذج يمثل بنية قاعدة البيانات MySQL بالضبط
class BeneficiaryDataModel {
  // Primary Key
  final int? id;

  // File Information
  final String? fileIdNumber; // file_id_number
  final String? originalFileIdFromExcel; // original_file_id_from_excel

  // Classification & Status
  final int? sectionId; // data_section_id
  final int? requestStatus; // data_request_status

  // Personal Information
  final int? idNumber; // data_id_number (الرقم الوطني)
  final String? firstName; // data_first_name
  final String? fatherName; // data_father_name
  final String? grandFatherName; // data_grand_father_name
  final String? familyName; // data_family_name
  final int? relationship; // data_relationship (علاقة القرابة)
  final DateTime? birthDate; // data_birth_date
  final int? gender; // data_gender (1=ذكر، 2=أنثى)

  // Contact Information
  final int? phoneNumber; // data_phone_number
  final int? altPhoneNumber; // data_alt_phone_number

  // Family Information
  final int? numberOfIndividuals; // data_number_of_individuals (حجم العائلة)
  final int? maritalStatus; // data_marital_status
  final int? numberOfMales; // data_number_mail
  final int? numberOfFemales; // data_number_female

  // Education & Employment
  final int? academicQualification; // data_academic_qualification
  final int? employmentStatusBreadwinner; // data_employment_status_breadwinner

  // Displacement & Location
  final int? displacementStatus; // data_displacement_status
  final String? addressBeforeDisplacement; // data_address_before_displacement
  final String? currentAddress; // data_current_address
  final int? city; // data_city (المحافظة)
  final int? province; // data_province (المنطقة)

  // Health & Special Needs
  final int? healthStatus; // data_health_status
  final int?
      numberOfIndividualsWithChronicDiseases; // data_number_of_individuals_with_chronic_diseases
  final int?
      numberOfPeopleWithSpecialNeeds; // data_number_of_people_with_special_needs

  // Housing
  final int? housingStatus; // data_housing_status
  final int? currentHousingType; // data_current_housing_type

  // Needs & Notes
  final String? descriptionNeeds; // data_description_needs

  // System Fields
  final String? userInsertData; // data_user_insert_data
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BeneficiaryDataModel({
    this.id,
    this.fileIdNumber,
    this.originalFileIdFromExcel,
    this.sectionId,
    this.requestStatus,
    this.idNumber,
    this.firstName,
    this.fatherName,
    this.grandFatherName,
    this.familyName,
    this.relationship,
    this.birthDate,
    this.gender,
    this.phoneNumber,
    this.altPhoneNumber,
    this.numberOfIndividuals,
    this.maritalStatus,
    this.numberOfMales,
    this.numberOfFemales,
    this.academicQualification,
    this.employmentStatusBreadwinner,
    this.displacementStatus,
    this.addressBeforeDisplacement,
    this.currentAddress,
    this.city,
    this.province,
    this.healthStatus,
    this.numberOfIndividualsWithChronicDiseases,
    this.numberOfPeopleWithSpecialNeeds,
    this.housingStatus,
    this.currentHousingType,
    this.descriptionNeeds,
    this.userInsertData,
    this.createdAt,
    this.updatedAt,
  });

  /// تحويل من JSON إلى Model
  factory BeneficiaryDataModel.fromJson(Map<String, dynamic> json) {
    return BeneficiaryDataModel(
      id: json['id'] as int?,
      fileIdNumber: json['file_id_number'] as String?,
      originalFileIdFromExcel: json['original_file_id_from_excel'] as String?,
      sectionId: json['data_section_id'] as int?,
      requestStatus: json['data_request_status'] as int?,
      idNumber: json['data_id_number'] as int?,
      firstName: json['data_first_name'] as String?,
      fatherName: json['data_father_name'] as String?,
      grandFatherName: json['data_grand_father_name'] as String?,
      familyName: json['data_family_name'] as String?,
      relationship: json['data_relationship'] as int?,
      birthDate: json['data_birth_date'] != null
          ? DateTime.parse(json['data_birth_date'] as String)
          : null,
      gender: json['data_gender'] as int?,
      phoneNumber: json['data_phone_number'] as int?,
      altPhoneNumber: json['data_alt_phone_number'] as int?,
      numberOfIndividuals: json['data_number_of_individuals'] as int?,
      maritalStatus: json['data_marital_status'] as int?,
      numberOfMales: json['data_number_mail'] as int?,
      numberOfFemales: json['data_number_female'] as int?,
      academicQualification: json['data_academic_qualification'] as int?,
      employmentStatusBreadwinner:
          json['data_employment_status_breadwinner'] as int?,
      displacementStatus: json['data_displacement_status'] as int?,
      addressBeforeDisplacement:
          json['data_address_before_displacement'] as String?,
      currentAddress: json['data_current_address'] as String?,
      city: json['data_city'] as int?,
      province: json['data_province'] as int?,
      healthStatus: json['data_health_status'] as int?,
      numberOfIndividualsWithChronicDiseases:
          json['data_number_of_individuals_with_chronic_diseases'] as int?,
      numberOfPeopleWithSpecialNeeds:
          json['data_number_of_people_with_special_needs'] as int?,
      housingStatus: json['data_housing_status'] as int?,
      currentHousingType: json['data_current_housing_type'] as int?,
      descriptionNeeds: json['data_description_needs'] as String?,
      userInsertData: json['data_user_insert_data'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// تحويل من Model إلى JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'file_id_number': fileIdNumber,
      'original_file_id_from_excel': originalFileIdFromExcel,
      'data_section_id': sectionId,
      'data_request_status': requestStatus ?? 1,
      'data_id_number': idNumber ?? 0,
      'data_first_name': firstName,
      'data_father_name': fatherName,
      'data_grand_father_name': grandFatherName,
      'data_family_name': familyName,
      'data_relationship': relationship,
      'data_birth_date': birthDate?.toIso8601String().split('T')[0],
      'data_gender': gender,
      'data_phone_number': phoneNumber ?? 0,
      'data_alt_phone_number': altPhoneNumber ?? 0,
      'data_number_of_individuals': numberOfIndividuals,
      'data_marital_status': maritalStatus,
      'data_academic_qualification': academicQualification,
      'data_displacement_status': displacementStatus,
      'data_address_before_displacement': addressBeforeDisplacement,
      'data_current_address': currentAddress,
      'data_city': city,
      'data_province': province,
      'data_health_status': healthStatus,
      'data_description_needs': descriptionNeeds,
      'data_number_mail': numberOfMales,
      'data_number_female': numberOfFemales,
      'data_number_of_individuals_with_chronic_diseases':
          numberOfIndividualsWithChronicDiseases,
      'data_number_of_people_with_special_needs':
          numberOfPeopleWithSpecialNeeds,
      'data_employment_status_breadwinner': employmentStatusBreadwinner,
      'data_housing_status': housingStatus,
      'data_current_housing_type': currentHousingType,
      'data_user_insert_data': userInsertData,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// تحويل من Beneficiary Entity إلى Data Model
  factory BeneficiaryDataModel.fromEntity(entity.Beneficiary beneficiary) {
    return BeneficiaryDataModel(
      id: int.tryParse(beneficiary.id),
      fileIdNumber: beneficiary.fileNo,
      sectionId: beneficiary.category.code,
      requestStatus: beneficiary.requestStatus?.code ?? 1,
      idNumber: int.tryParse(beneficiary.nationalId),
      firstName:
          beneficiary.fatherName, // نستخدم fatherName كـ first name مؤقتاً
      fatherName: beneficiary.fatherName,
      grandFatherName: beneficiary.grandFatherName,
      familyName: beneficiary.familyName,
      birthDate: beneficiary.birthDate,
      gender: beneficiary.gender == entity.Gender.male ? 1 : 2,
      phoneNumber: int.tryParse(
        beneficiary.phoneNumber?.replaceAll(RegExp(r'\D'), '') ?? '0',
      ),
      altPhoneNumber: int.tryParse(
        beneficiary.altPhoneNumber?.replaceAll(RegExp(r'\D'), '') ?? '0',
      ),
      numberOfIndividuals: beneficiary.familySize,
      maritalStatus: _maritalStatusToCode(beneficiary.maritalStatus),
      numberOfMales: beneficiary.numberOfMales,
      numberOfFemales: beneficiary.numberOfFemales,
      academicQualification: _educationLevelToCode(beneficiary.educationLevel),
      employmentStatusBreadwinner: beneficiary.employmentStatus?.code,
      displacementStatus: beneficiary.displacementStatus?.code,
      addressBeforeDisplacement: beneficiary.addressBeforeDisplacement,
      currentAddress: beneficiary.currentAddress,
      city: _parseLocationCode(beneficiary.governorate),
      province: _parseLocationCode(beneficiary.district),
      healthStatus: _healthStatusToCode(beneficiary.healthStatus),
      numberOfIndividualsWithChronicDiseases: beneficiary.chronicDiseasesCount,
      numberOfPeopleWithSpecialNeeds: beneficiary.specialNeedsCount,
      housingStatus: beneficiary.housingStatus?.code,
      currentHousingType: beneficiary.housingType?.code,
      descriptionNeeds: beneficiary.notes,
      createdAt: beneficiary.createdAt,
      updatedAt: beneficiary.updatedAt,
    );
  }

  /// تحويل من Data Model إلى Beneficiary Entity
  entity.Beneficiary toEntity() {
    return entity.Beneficiary(
      id: id?.toString() ?? '0',
      fullName: _buildFullName(),
      nationalId: idNumber?.toString() ?? '0',
      gender: gender == 1 ? entity.Gender.male : entity.Gender.female,
      category: entity.BeneficiaryCategory.fromCode(sectionId ?? 1),
      birthDate: birthDate,
      fatherName: fatherName,
      grandFatherName: grandFatherName,
      familyName: familyName,
      phoneNumber: phoneNumber?.toString(),
      altPhoneNumber: altPhoneNumber != 0 ? altPhoneNumber?.toString() : null,
      governorate: city?.toString(),
      district: province?.toString(),
      address: null, // لا يوجد حقل مباشر في DB
      currentAddress: currentAddress,
      addressBeforeDisplacement: addressBeforeDisplacement,
      fileNo: fileIdNumber,
      maritalStatus: _codeToMaritalStatus(maritalStatus),
      educationLevel: _codeToEducationLevel(academicQualification),
      healthStatus: _codeToHealthStatus(healthStatus),
      hasDisability: (numberOfPeopleWithSpecialNeeds ?? 0) > 0,
      familySize: numberOfIndividuals,
      numberOfMales: numberOfMales,
      numberOfFemales: numberOfFemales,
      chronicDiseasesCount: numberOfIndividualsWithChronicDiseases,
      specialNeedsCount: numberOfPeopleWithSpecialNeeds,
      displacementStatus: entity.DisplacementStatus.fromCode(
        displacementStatus,
      ),
      employmentStatus: entity.EmploymentStatus.fromCode(
        employmentStatusBreadwinner,
      ),
      housingStatus: entity.HousingStatus.fromCode(housingStatus),
      housingType: entity.HousingType.fromCode(currentHousingType),
      requestStatus: entity.RequestStatus.fromCode(requestStatus),
      notes: descriptionNeeds,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  String _buildFullName() {
    final parts = [
      firstName,
      fatherName,
      grandFatherName,
      familyName,
    ].where((part) => part != null && part.isNotEmpty).toList();
    return parts.join(' ');
  }

  // Helper methods for code conversion
  static int? _maritalStatusToCode(entity.MaritalStatus? status) {
    if (status == null) return null;
    switch (status) {
      case entity.MaritalStatus.single:
        return 1;
      case entity.MaritalStatus.married:
        return 2;
      case entity.MaritalStatus.divorced:
        return 3;
      case entity.MaritalStatus.widowed:
        return 4;
    }
  }

  static entity.MaritalStatus? _codeToMaritalStatus(int? code) {
    if (code == null) return null;
    switch (code) {
      case 1:
        return entity.MaritalStatus.single;
      case 2:
        return entity.MaritalStatus.married;
      case 3:
        return entity.MaritalStatus.divorced;
      case 4:
        return entity.MaritalStatus.widowed;
      default:
        return null;
    }
  }

  static int? _educationLevelToCode(entity.EducationLevel? level) {
    if (level == null) return null;
    // حسب البيانات: 5 يبدو أنه المستوى الأكثر شيوعاً
    switch (level) {
      case entity.EducationLevel.none:
      case entity.EducationLevel.illiterate:
        return 1;
      case entity.EducationLevel.primary:
        return 2;
      case entity.EducationLevel.intermediate:
        return 3;
      case entity.EducationLevel.secondary:
        return 4;
      case entity.EducationLevel.diploma:
      case entity.EducationLevel.bachelor:
        return 5;
      case entity.EducationLevel.master:
      case entity.EducationLevel.phd:
        return 6;
    }
  }

  static entity.EducationLevel? _codeToEducationLevel(int? code) {
    if (code == null) return null;
    switch (code) {
      case 1:
        return entity.EducationLevel.none;
      case 2:
        return entity.EducationLevel.primary;
      case 3:
        return entity.EducationLevel.intermediate;
      case 4:
        return entity.EducationLevel.secondary;
      case 5:
        return entity.EducationLevel.bachelor;
      case 6:
        return entity.EducationLevel.master;
      default:
        return null;
    }
  }

  static int? _healthStatusToCode(entity.HealthStatus? status) {
    if (status == null) return 1;
    switch (status) {
      case entity.HealthStatus.good:
        return 1;
      case entity.HealthStatus.fair:
        return 2;
      case entity.HealthStatus.chronicDisease:
        return 3;
      case entity.HealthStatus.disability:
        return 4;
      case entity.HealthStatus.poor:
        return 5;
    }
  }

  static entity.HealthStatus _codeToHealthStatus(int? code) {
    switch (code) {
      case 2:
        return entity.HealthStatus.fair;
      case 3:
        return entity.HealthStatus.chronicDisease;
      case 4:
        return entity.HealthStatus.disability;
      case 5:
        return entity.HealthStatus.poor;
      default:
        return entity.HealthStatus.good;
    }
  }

  static int? _parseLocationCode(String? location) {
    if (location == null || location.isEmpty) return null;
    return int.tryParse(location);
  }

  // ========================================================================
  // Drift Database Conversions
  // ========================================================================

  /// إنشاء DataModel من Drift Database Row
  factory BeneficiaryDataModel.fromDrift(db.Beneficiary drift) {
    return BeneficiaryDataModel(
      id: drift.serverId,
      fileIdNumber: drift.fileIdNumber,
      originalFileIdFromExcel: drift.originalFileIdFromExcel,
      sectionId: drift.sectionId,
      requestStatus: drift.requestStatus,
      idNumber: drift.idNumber,
      firstName: drift.firstName,
      fatherName: drift.fatherName,
      grandFatherName: drift.grandFatherName,
      familyName: drift.familyName,
      relationship: drift.relationship,
      birthDate: drift.birthDate,
      gender: drift.gender,
      phoneNumber: drift.phoneNumber,
      altPhoneNumber: drift.altPhoneNumber,
      numberOfIndividuals: drift.numberOfIndividuals,
      maritalStatus: drift.maritalStatus,
      numberOfMales: drift.numberOfMales,
      numberOfFemales: drift.numberOfFemales,
      academicQualification: drift.academicQualification,
      employmentStatusBreadwinner: drift.employmentStatusBreadwinner,
      displacementStatus: drift.displacementStatus,
      addressBeforeDisplacement: drift.addressBeforeDisplacement,
      currentAddress: drift.currentAddress,
      city: drift.city,
      province: drift.province,
      healthStatus: drift.healthStatus,
      numberOfIndividualsWithChronicDiseases:
          drift.numberOfIndividualsWithChronicDiseases,
      numberOfPeopleWithSpecialNeeds: drift.numberOfPeopleWithSpecialNeeds,
      housingStatus: drift.housingStatus,
      currentHousingType: drift.currentHousingType,
      descriptionNeeds: drift.descriptionNeeds,
      userInsertData: drift.userInsertData,
      createdAt: drift.createdAt,
      updatedAt: drift.updatedAt,
    );
  }

  /// تحويل DataModel إلى Drift Companion (للحفظ في قاعدة البيانات المحلية)
  db.BeneficiariesCompanion toDriftCompanion({bool isNew = true}) {
    return db.BeneficiariesCompanion.insert(
      idNumber: idNumber ?? 0,
      phoneNumber: phoneNumber ?? 0,
      altPhoneNumber: altPhoneNumber ?? 0,
      fileIdNumber: drift.Value(fileIdNumber),
      originalFileIdFromExcel: drift.Value(originalFileIdFromExcel),
      sectionId: drift.Value(sectionId),
      requestStatus: drift.Value(requestStatus ?? 1),
      firstName: drift.Value(firstName),
      fatherName: drift.Value(fatherName),
      grandFatherName: drift.Value(grandFatherName),
      familyName: drift.Value(familyName),
      relationship: drift.Value(relationship),
      birthDate: drift.Value(birthDate),
      gender: drift.Value(gender),
      numberOfIndividuals: drift.Value(numberOfIndividuals),
      maritalStatus: drift.Value(maritalStatus),
      numberOfMales: drift.Value(numberOfMales),
      numberOfFemales: drift.Value(numberOfFemales),
      academicQualification: drift.Value(academicQualification),
      employmentStatusBreadwinner: drift.Value(employmentStatusBreadwinner),
      displacementStatus: drift.Value(displacementStatus),
      addressBeforeDisplacement: drift.Value(addressBeforeDisplacement),
      currentAddress: drift.Value(currentAddress),
      city: drift.Value(city),
      province: drift.Value(province),
      healthStatus: drift.Value(healthStatus),
      numberOfIndividualsWithChronicDiseases: drift.Value(
        numberOfIndividualsWithChronicDiseases,
      ),
      numberOfPeopleWithSpecialNeeds: drift.Value(
        numberOfPeopleWithSpecialNeeds,
      ),
      housingStatus: drift.Value(housingStatus),
      currentHousingType: drift.Value(currentHousingType),
      descriptionNeeds: drift.Value(descriptionNeeds),
      userInsertData: drift.Value(userInsertData),
      createdAt: drift.Value(createdAt),
      updatedAt: drift.Value(updatedAt),
      serverId: drift.Value(id),
      syncState:
          isNew ? const drift.Value('pending') : const drift.Value('synced'),
      lastSyncedAt: drift.Value(isNew ? null : DateTime.now()),
    );
  }
}
