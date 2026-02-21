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

    final province = _pickIntLoose(
      json,
      const ['data_governorate', 'data_province', 'province', 'governorate'],
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
      firstName: drift.Value(firstName.isEmpty ? null : firstName),
      fatherName: drift.Value(fatherName.isEmpty ? null : fatherName),
      grandFatherName: drift.Value(grandFather.isEmpty ? null : grandFather),
      familyName: drift.Value(familyName.isEmpty ? null : familyName),

      // Optional fields
      fileIdNumber: drift.Value(fileId),
      fullNameNorm: drift.Value(_normalizeArabic(fullName)),
      province: drift.Value(province),
      gender: drift.Value(gender),
      relationship: drift.Value(relationship),

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
    // Split name (best effort)
    final nameParts = beneficiary.fullName.split(' ');

    return {
      // File IDs
      'file_id_number': beneficiary.fileIdNumber,
      'data_id_number': beneficiary.idNumber,

      // Name parts
      'data_first_name': beneficiary.firstName ?? (nameParts.isNotEmpty ? nameParts[0] : ''),
      'data_father_name': beneficiary.fatherName ?? (nameParts.length > 1 ? nameParts[1] : ''),
      'data_grand_father_name': beneficiary.grandFatherName ?? (nameParts.length > 2 ? nameParts[2] : ''),
      'data_family_name': beneficiary.familyName ?? (nameParts.length > 3 ? nameParts[3] : ''),

      // Contact
      'data_phone_number': beneficiary.phoneNumber,
      'data_alt_phone_number': beneficiary.altPhoneNumber,

      // Location
      'data_governorate': beneficiary.province,

      // Demographics
      'data_gender': beneficiary.gender,
      'data_family_type': beneficiary.relationship, // Using relationship as category
      // Metadata (if updating)
      if (beneficiary.serverId != null) 'id': beneficiary.serverId,
    };
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
