import 'package:drift/drift.dart' as drift;
import '../../data/db/drift_database.dart';

/// ========================================================================
/// 📦 Beneficiary Mapper - تحويل بين التطبيق والسيرفر
/// ========================================================================
/// تحويل بين نموذج البيانات المحلي (Drift) ونموذج السيرفر (JSON)
/// ========================================================================

class BeneficiaryMapper {
  /// Backend → Local (Drift Companion)
  static BeneficiariesCompanion fromBackend(Map<String, dynamic> json) {
    final nestedData = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : null;

    // Parse name parts
    final firstName = _pickString(
          json,
          const ['data_first_name', 'first_name', 'name_first'],
          nested: nestedData,
        ) ??
        '';
    final fatherName = _pickString(
          json,
          const ['data_father_name', 'father_name', 'name_father'],
          nested: nestedData,
        ) ??
        '';
    final grandFather = _pickString(
          json,
          const ['data_grand_father_name', 'grand_father_name', 'name_grand_father'],
          nested: nestedData,
        ) ??
        '';
    final familyName = _pickString(
          json,
          const ['data_family_name', 'last_name', 'family_name', 'name_family'],
          nested: nestedData,
        ) ??
        '';

    final idNumber = _pickIntLoose(
          json,
          const ['data_id_number', 'national_id', 'id_number', 'data_national_id'],
          nested: nestedData,
        ) ??
        0;
    final phoneNumber = _pickIntLoose(
          json,
          const ['data_phone_number', 'phone_number', 'phone', 'mobile'],
          nested: nestedData,
        ) ??
        0;
    final altPhoneNumber = _pickIntLoose(
          json,
          const ['data_alt_phone_number', 'alt_phone_number', 'alt_phone'],
          nested: nestedData,
        ) ??
        0;

    final fileId = _pickString(
      json,
      const ['file_id_number', 'data_file_id_number', 'data_file_no', 'file_no', 'data_file_id'],
      nested: nestedData,
    );

    final originalFileIdFromExcel = _pickString(
      json,
      const ['original_file_id_from_excel'],
      nested: nestedData,
    );

    final sectionId = _pickIntLoose(
      json,
      const ['data_section_id', 'section_id'],
      nested: nestedData,
    );

    final province = _pickIntLoose(
      json,
      const ['data_governorate', 'data_province', 'province', 'governorate'],
      nested: nestedData,
    );
    final city = _pickIntLoose(
      json,
      const ['data_city', 'city'],
      nested: nestedData,
    );
    final gender = _pickIntLoose(
      json,
      const ['data_gender', 'gender'],
      nested: nestedData,
    );
    final relationship = _pickIntLoose(
      json,
      const ['data_family_type', 'data_relationship', 'relationship'],
      nested: nestedData,
    );
    final requestStatus = _pickIntLoose(
          json,
          const ['data_request_status', 'request_status'],
          nested: nestedData,
        ) ??
        1;

    final birthDate = _parseDateTime(
      _pickString(
        json,
        const ['data_birth_date', 'birth_date', 'date_of_birth'],
        nested: nestedData,
      ),
    );

    final numberOfIndividuals = _pickIntLoose(
      json,
      const ['data_number_of_individuals', 'number_of_individuals'],
      nested: nestedData,
    );
    final maritalStatus = _pickIntLoose(
      json,
      const ['data_marital_status', 'marital_status'],
      nested: nestedData,
    );
    final numberOfMales = _pickIntLoose(
      json,
      const ['data_number_mail', 'data_number_male', 'number_of_males'],
      nested: nestedData,
    );
    final numberOfFemales = _pickIntLoose(
      json,
      const ['data_number_female', 'number_of_females'],
      nested: nestedData,
    );

    final academicQualification = _pickIntLoose(
      json,
      const ['data_academic_qualification', 'academic_qualification'],
      nested: nestedData,
    );
    final employmentStatusBreadwinner = _pickIntLoose(
      json,
      const ['data_employment_status_breadwinner', 'employment_status_breadwinner'],
      nested: nestedData,
    );

    final displacementStatus = _pickIntLoose(
      json,
      const ['data_displacement_status', 'displacement_status'],
      nested: nestedData,
    );
    final addressBeforeDisplacement = _pickString(
      json,
      const ['data_address_before_displacement', 'address_before_displacement'],
      nested: nestedData,
    );
    final currentAddress = _pickString(
      json,
      const ['data_current_address', 'current_address', 'address'],
      nested: nestedData,
    );

    final healthStatus = _pickIntLoose(
      json,
      const ['data_health_status', 'health_status'],
      nested: nestedData,
    );
    final numberOfIndividualsWithChronicDiseases = _pickIntLoose(
      json,
      const [
        'data_number_of_individuals_with_chronic_diseases',
        'number_of_individuals_with_chronic_diseases',
      ],
      nested: nestedData,
    );
    final numberOfPeopleWithSpecialNeeds = _pickIntLoose(
      json,
      const ['data_number_of_people_with_special_needs', 'number_of_people_with_special_needs'],
      nested: nestedData,
    );

    final housingStatus = _pickIntLoose(
      json,
      const ['data_housing_status', 'housing_status'],
      nested: nestedData,
    );
    final currentHousingType = _pickIntLoose(
      json,
      const ['data_current_housing_type', 'current_housing_type'],
      nested: nestedData,
    );

    final assistanceTypeCode = _pickString(
      json,
      const ['assistance_type_code', 'assistance_type', 'data_assistance_type'],
      nested: nestedData,
    );
    final disabilityTypeCode = _pickString(
      json,
      const ['disability_type_code', 'disability_type', 'data_disability_type'],
      nested: nestedData,
    );
    final incomeSourceCode = _pickString(
      json,
      const ['income_source_code', 'income_source', 'data_income_source'],
      nested: nestedData,
    );
    final guaranteeTypeCode = _pickString(
      json,
      const ['guarantee_type_code', 'guarantee_type', 'data_guarantee_type'],
      nested: nestedData,
    );

    final descriptionNeeds = _pickString(
      json,
      const ['data_description_needs', 'description_needs', 'notes'],
      nested: nestedData,
    );
    final userInsertData = _pickString(
      json,
      const ['data_user_insert_data', 'user_insert_data'],
      nested: nestedData,
    );

    final serverId = _pickIntLoose(
      json,
      const ['id', 'server_id', 'data_id'],
      nested: nestedData,
    );

    final fullName = '$firstName $fatherName $grandFather $familyName'.trim();

    return BeneficiariesCompanion.insert(
      // Basic required fields
      idNumber: idNumber,
      phoneNumber: phoneNumber,
      altPhoneNumber: altPhoneNumber,
      requestStatus: drift.Value(requestStatus),
      syncState: const drift.Value('synced'),

      // Name parts (fullName is auto-computed from these)
      // Important: keep empty string instead of null to avoid NOT NULL failure
      // on generated full_name column when server omits one of the name parts.
      firstName: drift.Value(firstName),
      fatherName: drift.Value(fatherName),
      grandFatherName: drift.Value(grandFather),
      familyName: drift.Value(familyName),

      // Optional fields
      fileIdNumber: drift.Value(fileId),
      originalFileIdFromExcel: drift.Value(originalFileIdFromExcel),
      sectionId: drift.Value(sectionId),
      fullNameNorm: drift.Value(_normalizeArabic(fullName)),
      province: drift.Value(province),
      city: drift.Value(city),
      gender: drift.Value(gender),
      relationship: drift.Value(relationship),
      birthDate: drift.Value(birthDate),
      numberOfIndividuals: drift.Value(numberOfIndividuals),
      maritalStatus: drift.Value(maritalStatus),
      numberOfMales: drift.Value(numberOfMales),
      numberOfFemales: drift.Value(numberOfFemales),
      academicQualification: drift.Value(academicQualification),
      employmentStatusBreadwinner: drift.Value(employmentStatusBreadwinner),
      displacementStatus: drift.Value(displacementStatus),
      addressBeforeDisplacement: drift.Value(addressBeforeDisplacement),
      currentAddress: drift.Value(currentAddress),
      healthStatus: drift.Value(healthStatus),
      numberOfIndividualsWithChronicDiseases: drift.Value(numberOfIndividualsWithChronicDiseases),
      numberOfPeopleWithSpecialNeeds: drift.Value(numberOfPeopleWithSpecialNeeds),
      housingStatus: drift.Value(housingStatus),
      currentHousingType: drift.Value(currentHousingType),
      assistanceTypeCode: drift.Value(assistanceTypeCode),
      disabilityTypeCode: drift.Value(disabilityTypeCode),
      incomeSourceCode: drift.Value(incomeSourceCode),
      guaranteeTypeCode: drift.Value(guaranteeTypeCode),
      descriptionNeeds: drift.Value(descriptionNeeds),
      userInsertData: drift.Value(userInsertData),

      // Metadata
      serverId: drift.Value(serverId),
      lastSyncedAt: drift.Value(DateTime.now()),
      createdAt: drift.Value(
        _parseDateTime(
              _pickString(json, const ['created_at'], nested: nestedData),
            ) ??
            DateTime.now(),
      ),
      updatedAt: drift.Value(
        _parseDateTime(
              _pickString(json, const ['updated_at'], nested: nestedData),
            ) ??
            DateTime.now(),
      ),
    );
  }

  /// Local → Backend (JSON)
  static Map<String, dynamic> toBackend(Beneficiary beneficiary) {
    return {
      if (beneficiary.serverId != null) 'id': beneficiary.serverId,

      // File information
      'file_id_number': beneficiary.fileIdNumber,
      'original_file_id_from_excel': beneficiary.originalFileIdFromExcel,

      // Classification & status
      'data_section_id': beneficiary.sectionId,
      'data_request_status': beneficiary.requestStatus,

      // Personal information
      'data_id_number': beneficiary.idNumber,
      'data_first_name': beneficiary.firstName,
      'data_father_name': beneficiary.fatherName,
      'data_grand_father_name': beneficiary.grandFatherName,
      'data_family_name': beneficiary.familyName,
      'data_relationship': beneficiary.relationship,
      'data_birth_date': _toDateOnly(beneficiary.birthDate),
      'data_gender': beneficiary.gender,

      // Contact information
      'data_phone_number': beneficiary.phoneNumber,
      'data_alt_phone_number': beneficiary.altPhoneNumber,

      // Family information
      'data_number_of_individuals': beneficiary.numberOfIndividuals,
      'data_marital_status': beneficiary.maritalStatus,
      'data_number_mail': beneficiary.numberOfMales,
      'data_number_female': beneficiary.numberOfFemales,

      // Education & employment
      'data_academic_qualification': beneficiary.academicQualification,
      'data_employment_status_breadwinner': beneficiary.employmentStatusBreadwinner,

      // Displacement & location
      'data_displacement_status': beneficiary.displacementStatus,
      'data_address_before_displacement': beneficiary.addressBeforeDisplacement,
      'data_current_address': beneficiary.currentAddress,
      'data_city': beneficiary.city,
      'data_province': beneficiary.province,

      // Health & special needs
      'data_health_status': beneficiary.healthStatus,
      'data_number_of_individuals_with_chronic_diseases': beneficiary.numberOfIndividualsWithChronicDiseases,
      'data_number_of_people_with_special_needs': beneficiary.numberOfPeopleWithSpecialNeeds,

      // Housing
      'data_housing_status': beneficiary.housingStatus,
      'data_current_housing_type': beneficiary.currentHousingType,

      // Extended taxonomy fields
      'assistance_type_code': beneficiary.assistanceTypeCode,
      'disability_type_code': beneficiary.disabilityTypeCode,
      'income_source_code': beneficiary.incomeSourceCode,
      'guarantee_type_code': beneficiary.guaranteeTypeCode,

      // Notes/system fields
      'data_description_needs': beneficiary.descriptionNeeds,
      'data_user_insert_data': beneficiary.userInsertData,

      // Timestamps
      'created_at': beneficiary.createdAt?.toIso8601String(),
      'updated_at': beneficiary.updatedAt?.toIso8601String(),
    };
  }

  static String? _toDateOnly(DateTime? value) {
    if (value == null) return null;
    return value.toIso8601String().split('T').first;
  }

  // ========================================================================
  // HELPER METHODS
  // ========================================================================

  static String _normalizeArabic(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      try {
        return int.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static int? _parseIntLoose(dynamic value) {
    final direct = _parseInt(value);
    if (direct != null) return direct;

    final raw = value?.toString();
    if (raw == null || raw.isEmpty) return null;
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

  static String? _pickString(
    Map<String, dynamic> source,
    List<String> keys, {
    Map<String, dynamic>? nested,
  }) {
    for (final key in keys) {
      final value = source[key] ?? nested?[key];
      if (value == null) continue;
      final raw = value.toString().trim();
      if (raw.isNotEmpty) return raw;
    }
    return null;
  }

  static int? _pickIntLoose(
    Map<String, dynamic> source,
    List<String> keys, {
    Map<String, dynamic>? nested,
  }) {
    for (final key in keys) {
      final value = source[key] ?? nested?[key];
      final parsed = _parseIntLoose(value);
      if (parsed != null) return parsed;
    }
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
