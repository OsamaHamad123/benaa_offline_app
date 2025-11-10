import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../../data/db/drift_database.dart';

/// Mapper class for converting between Backend JSON and Local Drift Beneficiary
class BeneficiaryMapper {
  /// Convert from Backend JSON to Local Drift Companion
  ///
  /// Backend structure:
  /// - 4 separate name fields (first, father, grand_father, family)
  /// - Integer codes for enums (gender: 1=male, 2=female)
  /// - Province/city as codes
  ///
  /// Local structure:
  /// - Single fullName field
  /// - String labels for enums
  /// - Governorate/district as labels
  static BeneficiariesCompanion fromBackend(Map<String, dynamic> json) {
    // Build full name from 4 parts
    final firstName = json['data_first_name'] ?? '';
    final fatherName = json['data_father_name'] ?? '';
    final grandFatherName = json['data_grand_father_name'] ?? '';
    final familyName = json['data_family_name'] ?? '';
    final fullName = '$firstName $fatherName $grandFatherName $familyName'
        .trim();

    return BeneficiariesCompanion.insert(
      id: const Uuid().v4(), // Generate new local UUID
      // Name fields
      fullName: fullName,
      fullNameNorm: fullName.toLowerCase(),
      fatherName: drift.Value(fatherName.isEmpty ? null : fatherName),
      grandFatherName: drift.Value(
        grandFatherName.isEmpty ? null : grandFatherName,
      ),
      familyName: drift.Value(familyName.isEmpty ? null : familyName),
      motherName: const drift.Value(null), // Not in backend
      // IDs
      nationalId: json['data_id_number'] ?? '',
      fileNo: json['file_id_number'] ?? '',
      serverId: drift.Value(json['id']?.toString()),

      // Contact
      phoneNumber: drift.Value(json['data_phone_number']),
      altPhoneNumber: drift.Value(json['data_alt_phone_number']),

      // Location
      governorate: _mapGovernorateCode(json['data_province']),
      district: drift.Value(_mapCityCode(json['data_city'])),
      address: drift.Value(
        json['data_address_before_displacement'],
      ), // Map old address to address
      currentAddress: drift.Value(json['data_current_address']),
      addressBeforeDisplacement: drift.Value(
        json['data_address_before_displacement'],
      ),

      // Demographics
      gender: _mapGenderFromCode(json['data_gender']),
      birthDate: drift.Value(_parseDate(json['data_birth_date'])),

      // Family
      familySize: drift.Value(json['data_number_of_individuals']),
      numberOfMales: drift.Value(json['data_number_mail']),
      numberOfFemales: drift.Value(json['data_number_female']),
      maritalStatus: drift.Value(
        _mapMaritalStatusCode(json['data_marital_status']),
      ),

      // Classification
      category: _mapCategoryFromRelationship(json['data_relationship']),

      // Education & Health
      educationLevel: drift.Value(
        _mapEducationCode(json['data_academic_qualification']),
      ),
      healthStatus: drift.Value(
        _mapHealthStatusCode(json['data_health_status']),
      ),
      chronicDiseasesCount: drift.Value(
        json['data_number_of_individuals_with_chronic_diseases'],
      ),
      specialNeedsCount: drift.Value(
        json['data_number_of_people_with_special_needs'],
      ),
      hasDisability: drift.Value(
        (json['data_number_of_people_with_special_needs'] ?? 0) > 0,
      ),

      // Status codes
      displacementStatus: drift.Value(json['data_displacement_status']),
      employmentStatus: drift.Value(json['data_employment_status_breadwinner']),
      housingStatus: drift.Value(json['data_housing_status']),
      housingType: drift.Value(json['data_current_housing_type']),
      requestStatus: drift.Value(json['data_request_status']),

      // Notes
      notes: drift.Value(json['data_description_needs'] ?? ''),
      associationName: const drift.Value(null), // Not in backend
      // Timestamps
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updated_at']) ?? DateTime.now(),

      // Sync state
      syncState: const drift.Value('synced'),
      lastSyncedAt: drift.Value(DateTime.now()),
    );
  }

  /// Convert from Local Drift Beneficiary to Backend JSON
  static Map<String, dynamic> toBackend(Beneficiary beneficiary) {
    // Split full name into parts (best effort)
    final nameParts = beneficiary.fullName.split(' ');

    return {
      // ID (only if synced from backend)
      if (beneficiary.serverId != null)
        'id': int.tryParse(beneficiary.serverId!),

      // File IDs
      'file_id_number': beneficiary.fileNo,
      'data_id_number': beneficiary.nationalId,

      // Name parts
      'data_first_name': nameParts.isNotEmpty ? nameParts[0] : '',
      'data_father_name':
          beneficiary.fatherName ?? (nameParts.length > 1 ? nameParts[1] : ''),
      'data_grand_father_name':
          beneficiary.grandFatherName ??
          (nameParts.length > 2 ? nameParts[2] : ''),
      'data_family_name':
          beneficiary.familyName ??
          (nameParts.length > 3 ? nameParts.sublist(3).join(' ') : ''),

      // Contact
      'data_phone_number': beneficiary.phoneNumber ?? '',
      'data_alt_phone_number': beneficiary.altPhoneNumber,

      // Location
      'data_province': _mapGovernorateToCode(beneficiary.governorate),
      'data_city': _mapCityToCode(beneficiary.district),
      'data_current_address': beneficiary.currentAddress,
      'data_address_before_displacement': beneficiary.addressBeforeDisplacement,

      // Demographics
      'data_gender': _mapGenderToCode(beneficiary.gender),
      'data_birth_date': beneficiary.birthDate?.toIso8601String().split('T')[0],

      // Family
      'data_number_of_individuals': beneficiary.familySize,
      'data_number_mail': beneficiary.numberOfMales,
      'data_number_female': beneficiary.numberOfFemales,
      'data_marital_status': _mapMaritalStatusToCode(beneficiary.maritalStatus),

      // Classification
      'data_relationship': _mapCategoryToRelationship(beneficiary.category),

      // Education & Health
      'data_academic_qualification': _mapEducationToCode(
        beneficiary.educationLevel,
      ),
      'data_health_status': _mapHealthStatusToCode(beneficiary.healthStatus),
      'data_number_of_individuals_with_chronic_diseases':
          beneficiary.chronicDiseasesCount,
      'data_number_of_people_with_special_needs': beneficiary.specialNeedsCount,

      // Status codes
      'data_displacement_status': beneficiary.displacementStatus ?? 2,
      'data_employment_status_breadwinner': beneficiary.employmentStatus ?? 1,
      'data_housing_status': beneficiary.housingStatus ?? 1,
      'data_current_housing_type': beneficiary.housingType ?? 4,
      'data_request_status': beneficiary.requestStatus ?? 4,
      'data_section_id': 1, // Default section
      // Notes
      'data_description_needs': beneficiary.notes,

      // Timestamps
      'created_at': beneficiary.createdAt
          .toIso8601String()
          .replaceAll('T', ' ')
          .split('.')[0],
      'updated_at': beneficiary.updatedAt
          .toIso8601String()
          .replaceAll('T', ' ')
          .split('.')[0],

      // Backend metadata
      'data_user_insert_data': 3, // Default user
    };
  }

  // ============================================================================
  // MAPPING FUNCTIONS - Gender
  // ============================================================================

  static String _mapGenderFromCode(dynamic code) {
    if (code == null) return 'male';
    final intCode = code is int ? code : int.tryParse(code.toString());
    return intCode == 2 ? 'female' : 'male';
  }

  static int _mapGenderToCode(String gender) {
    return gender == 'female' ? 2 : 1;
  }

  // ============================================================================
  // MAPPING FUNCTIONS - Category / Relationship
  // ============================================================================

  static String _mapCategoryFromRelationship(dynamic code) {
    if (code == null) return 'other';
    final intCode = code is int ? code : int.tryParse(code.toString());

    // Based on data patterns:
    // 2 = widow (أرملة)
    // 5 = orphan (يتيم)
    // 15 = other/disabled
    switch (intCode) {
      case 2:
        return 'widow';
      case 5:
        return 'orphan';
      default:
        return 'poor'; // Default to poor for others
    }
  }

  static int _mapCategoryToRelationship(String category) {
    switch (category) {
      case 'widow':
        return 2;
      case 'orphan':
        return 5;
      case 'disabled':
        return 15;
      default:
        return 1; // Default relationship code
    }
  }

  // ============================================================================
  // MAPPING FUNCTIONS - Marital Status
  // ============================================================================

  static String? _mapMaritalStatusCode(dynamic code) {
    if (code == null) return null;
    final intCode = code is int ? code : int.tryParse(code.toString());

    switch (intCode) {
      case 1:
        return 'widow'; // أرملة/أرمل
      case 2:
        return 'divorced';
      case 3:
        return 'married';
      case 4:
        return 'single';
      default:
        return 'single';
    }
  }

  static int? _mapMaritalStatusToCode(String? status) {
    if (status == null) return null;

    switch (status) {
      case 'widow':
        return 1;
      case 'divorced':
        return 2;
      case 'married':
        return 3;
      case 'single':
        return 4;
      default:
        return 4;
    }
  }

  // ============================================================================
  // MAPPING FUNCTIONS - Education Level
  // ============================================================================

  static String? _mapEducationCode(dynamic code) {
    if (code == null) return null;
    final intCode = code is int ? code : int.tryParse(code.toString());

    switch (intCode) {
      case 1:
        return 'none';
      case 2:
        return 'elementary';
      case 3:
        return 'middle';
      case 4:
        return 'high_school';
      case 5:
        return 'diploma';
      case 6:
        return 'bachelor';
      case 7:
        return 'master';
      case 8:
        return 'phd';
      case 9:
        return 'vocational';
      case 10:
        return 'religious';
      case 11:
        return 'other';
      default:
        return 'none';
    }
  }

  static int? _mapEducationToCode(String? level) {
    if (level == null) return null;

    switch (level) {
      case 'none':
        return 1;
      case 'elementary':
        return 2;
      case 'middle':
        return 3;
      case 'high_school':
        return 4;
      case 'diploma':
        return 5;
      case 'bachelor':
        return 6;
      case 'master':
        return 7;
      case 'phd':
        return 8;
      case 'vocational':
        return 9;
      case 'religious':
        return 10;
      case 'other':
        return 11;
      default:
        return 1;
    }
  }

  // ============================================================================
  // MAPPING FUNCTIONS - Health Status
  // ============================================================================

  static String? _mapHealthStatusCode(dynamic code) {
    if (code == null) return null;
    final intCode = code is int ? code : int.tryParse(code.toString());

    switch (intCode) {
      case 1:
        return 'good';
      case 2:
        return 'fair';
      case 3:
        return 'poor';
      case 4:
        return 'critical';
      default:
        return 'good';
    }
  }

  static int? _mapHealthStatusToCode(String? status) {
    if (status == null) return null;

    switch (status) {
      case 'good':
        return 1;
      case 'fair':
        return 2;
      case 'poor':
        return 3;
      case 'critical':
        return 4;
      default:
        return 1;
    }
  }

  // ============================================================================
  // MAPPING FUNCTIONS - Governorate (Province)
  // ============================================================================

  static String _mapGovernorateCode(dynamic code) {
    if (code == null) return 'بغداد';
    final strCode = code.toString();

    // Map based on common Iraqi governorate codes
    switch (strCode) {
      case '1':
        return 'بغداد';
      case '2':
        return 'البصرة';
      case '3':
        return 'نينوى';
      case '4':
        return 'الأنبار';
      case '5':
        return 'ديالى';
      case '6':
        return 'كربلاء';
      case '7':
        return 'النجف';
      case '8':
        return 'ذي قار';
      case '9':
        return 'القادسية';
      case '10':
        return 'المثنى';
      default:
        return 'بغداد'; // Default
    }
  }

  static int _mapGovernorateToCode(String governorate) {
    switch (governorate) {
      case 'بغداد':
        return 1;
      case 'البصرة':
        return 2;
      case 'نينوى':
        return 3;
      case 'الأنبار':
        return 4;
      case 'ديالى':
        return 5;
      case 'كربلاء':
        return 6;
      case 'النجف':
        return 7;
      case 'ذي قار':
        return 8;
      case 'القادسية':
        return 9;
      case 'المثنى':
        return 10;
      default:
        return 1;
    }
  }

  // ============================================================================
  // MAPPING FUNCTIONS - City/District
  // ============================================================================

  static String? _mapCityCode(dynamic code) {
    if (code == null || code.toString() == '0') return null;
    // For now, return the code as-is since we don't have the full mapping
    // TODO: Implement full city mapping when backend provides the data
    return 'منطقة $code';
  }

  static int? _mapCityToCode(String? city) {
    if (city == null) return 0;
    // Extract number from "منطقة X" format
    final match = RegExp(r'\d+').firstMatch(city);
    if (match != null) {
      return int.tryParse(match.group(0)!);
    }
    return 0;
  }

  // ============================================================================
  // HELPER FUNCTIONS - Date/Time Parsing
  // ============================================================================

  static DateTime? _parseDate(dynamic dateStr) {
    if (dateStr == null) return null;
    try {
      return DateTime.parse(dateStr.toString());
    } catch (e) {
      return null;
    }
  }

  static DateTime? _parseDateTime(dynamic dateTimeStr) {
    if (dateTimeStr == null) return null;
    try {
      // Handle format "2025-11-09 13:51:47"
      final str = dateTimeStr.toString().replaceAll(' ', 'T');
      return DateTime.parse(str);
    } catch (e) {
      return null;
    }
  }
}
