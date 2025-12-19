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
    // Parse name parts
    final firstName = json['data_first_name'] as String? ?? '';
    final fatherName = json['data_father_name'] as String? ?? '';
    final grandFather = json['data_grand_father_name'] as String? ?? '';
    final familyName = json['data_family_name'] as String? ?? '';
    final fullName = '$firstName $fatherName $grandFather $familyName'.trim();

    return BeneficiariesCompanion.insert(
      // Basic required fields
      idNumber: _parseInt(json['data_id_number']) ?? 0,
      phoneNumber: _parseInt(json['data_phone_number']) ?? 0,
      altPhoneNumber: _parseInt(json['data_alt_phone_number']) ?? 0,
      requestStatus: const drift.Value(1), // Default status
      syncState: const drift.Value('synced'),

      // Name parts (fullName is auto-computed from these)
      firstName: drift.Value(firstName.isEmpty ? null : firstName),
      fatherName: drift.Value(fatherName.isEmpty ? null : fatherName),
      grandFatherName: drift.Value(grandFather.isEmpty ? null : grandFather),
      familyName: drift.Value(familyName.isEmpty ? null : familyName),

      // Optional fields
      fileIdNumber: drift.Value(json['file_id_number']?.toString()),
      fullNameNorm: drift.Value(_normalizeArabic(fullName)),
      province: drift.Value(_parseInt(json['data_governorate'])),
      gender: drift.Value(_parseInt(json['data_gender'])),
      relationship: drift.Value(_parseInt(json['data_family_type'])),

      // Metadata
      serverId: drift.Value(
        json['id'] is int
            ? json['id'] as int
            : int.tryParse(json['id']?.toString() ?? ''),
      ),
      lastSyncedAt: drift.Value(DateTime.now()),
      createdAt: drift.Value(
        _parseDateTime(json['created_at']) ?? DateTime.now(),
      ),
      updatedAt: drift.Value(
        _parseDateTime(json['updated_at']) ?? DateTime.now(),
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
      'data_first_name':
          beneficiary.firstName ?? (nameParts.isNotEmpty ? nameParts[0] : ''),
      'data_father_name':
          beneficiary.fatherName ?? (nameParts.length > 1 ? nameParts[1] : ''),
      'data_grand_father_name': beneficiary.grandFatherName ??
          (nameParts.length > 2 ? nameParts[2] : ''),
      'data_family_name':
          beneficiary.familyName ?? (nameParts.length > 3 ? nameParts[3] : ''),

      // Contact
      'data_phone_number': beneficiary.phoneNumber,
      'data_alt_phone_number': beneficiary.altPhoneNumber,

      // Location
      'data_governorate': beneficiary.province,

      // Demographics
      'data_gender': beneficiary.gender,
      'data_family_type':
          beneficiary.relationship, // Using relationship as category
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
