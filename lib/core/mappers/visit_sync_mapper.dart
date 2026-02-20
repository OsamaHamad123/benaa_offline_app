import 'package:drift/drift.dart' as drift;
import '../../data/db/drift_database.dart';

/// 📦 Visit Sync Mapper
///
/// Converts between local Visit entities and API JSON
class VisitSyncMapper {
  /// Backend → Local (Drift)
  static VisitsCompanion fromBackend(Map<String, dynamic> json) {
    return VisitsCompanion.insert(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      beneficiaryId: json['beneficiary_id']?.toString() ?? '',
      visitDate: _parseDateTime(json['visit_date']) ?? DateTime.now(),
      staffName: json['staff_name'] ?? 'Unknown',
      notes: drift.Value(json['notes'] ?? ''),
      isSubmitted: drift.Value(json['is_submitted'] ?? true),
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updated_at']) ?? DateTime.now(),
      syncState: const drift.Value('synced'),
      serverId: drift.Value(json['id']?.toString()),
      lastSyncedAt: drift.Value(DateTime.now()),
    );
  }

  /// Local → Backend (JSON)
  static Map<String, dynamic> toBackend(Visit visit) {
    return {
      'local_id': visit.id,
      'beneficiary_id': visit.beneficiaryId,
      'visit_date': visit.visitDate.toIso8601String(),
      'staff_name': visit.staffName,
      'notes': visit.notes,
      'is_submitted': visit.isSubmitted,
      'created_at': visit.createdAt.toIso8601String(),
      'updated_at': visit.updatedAt.toIso8601String(),
      if (visit.serverId != null) 'id': visit.serverId,
    };
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
