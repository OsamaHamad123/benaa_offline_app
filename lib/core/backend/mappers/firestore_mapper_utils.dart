import '../remote_backend.dart';

class FirestoreMapperUtils {
  const FirestoreMapperUtils._();

  static String resolveStableId(
    JsonMap source, {
    List<String> preferredKeys = const <String>['id', 'server_id', 'serverId', 'uuid', 'remote_id', 'remoteId'],
  }) {
    for (final key in preferredKeys) {
      final value = source[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    throw ArgumentError('Unable to resolve stable id from payload.');
  }

  static JsonMap withAuditFields(
    JsonMap payload, {
    required String userId,
    required String deviceId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) {
    final now = DateTime.now().toUtc();
    return <String, dynamic>{
      ...payload,
      'user_id': userId,
      'device_id': deviceId,
      'created_at': createdAt ?? payload['created_at'] ?? now,
      'updated_at': updatedAt ?? payload['updated_at'] ?? now,
      'synced_at': syncedAt ?? payload['synced_at'] ?? now,
      'deleted_at': payload['deleted_at'],
    };
  }

  static JsonMap markSoftDeleted(
    JsonMap payload, {
    required String userId,
    required String deviceId,
    DateTime? deletedAt,
  }) {
    final now = deletedAt ?? DateTime.now().toUtc();
    return withAuditFields(
      <String, dynamic>{
        ...payload,
        'deleted_at': now,
      },
      userId: userId,
      deviceId: deviceId,
      updatedAt: now,
      syncedAt: now,
    );
  }

  static DateTime? asDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value.toUtc();

    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value)?.toUtc();
    }

    if (value is int) {
      if (value > 1000000000000) {
        return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
      }
      return DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true);
    }

    try {
      final dynamic dynamicValue = value;
      final date = dynamicValue.toDate();
      if (date is DateTime) {
        return date.toUtc();
      }
    } catch (_) {
      // Ignore unsupported date value.
    }

    return null;
  }

  static JsonMap removeNulls(JsonMap source) {
    final output = <String, dynamic>{};
    source.forEach((key, value) {
      if (value != null) {
        output[key] = value;
      }
    });
    return output;
  }
}
