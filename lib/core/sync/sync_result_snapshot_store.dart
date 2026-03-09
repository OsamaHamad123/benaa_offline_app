import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'mobile_sync_service.dart';

class SyncResultSnapshot {
  final DateTime timestamp;
  final String operation;
  final String source;
  final bool success;
  final int recordsSynced;
  final int recordsFailed;
  final String? error;
  final Map<String, int> payloadCounters;
  final Map<String, int> writeCounters;
  final String? errorCategory;
  final String? errorContext;

  const SyncResultSnapshot({
    required this.timestamp,
    required this.operation,
    this.source = 'unknown',
    required this.success,
    required this.recordsSynced,
    required this.recordsFailed,
    this.error,
    this.payloadCounters = const <String, int>{},
    this.writeCounters = const <String, int>{},
    this.errorCategory,
    this.errorContext,
  });

  factory SyncResultSnapshot.fromMobileResult({
    required String operation,
    String source = 'unknown',
    required MobileSyncResult result,
    DateTime? timestamp,
  }) {
    return SyncResultSnapshot(
      timestamp: timestamp ?? DateTime.now(),
      operation: operation,
      source: source,
      success: result.success,
      recordsSynced: result.recordsSynced,
      recordsFailed: result.recordsFailed,
      error: result.error,
      payloadCounters: Map<String, int>.from(result.payloadCounters),
      writeCounters: Map<String, int>.from(result.writeCounters),
      errorCategory: result.errorCategory,
      errorContext: result.errorContext,
    );
  }

  MobileSyncResult toMobileSyncResult() {
    return MobileSyncResult(
      success: success,
      recordsSynced: recordsSynced,
      recordsFailed: recordsFailed,
      error: error,
      payloadCounters: payloadCounters,
      writeCounters: writeCounters,
      errorCategory: errorCategory,
      errorContext: errorContext,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'timestamp': timestamp.toIso8601String(),
        'operation': operation,
        'source': source,
        'success': success,
        'records_synced': recordsSynced,
        'records_failed': recordsFailed,
        'error': error,
        'payload_counters': payloadCounters,
        'write_counters': writeCounters,
        'error_category': errorCategory,
        'error_context': errorContext,
      };

  factory SyncResultSnapshot.fromJson(Map<String, dynamic> json) {
    final payloadRaw = json['payload_counters'];
    final writesRaw = json['write_counters'];

    Map<String, int> parseCounters(dynamic value) {
      if (value is! Map) return const <String, int>{};
      final out = <String, int>{};
      for (final entry in value.entries) {
        final parsed = int.tryParse(entry.value?.toString() ?? '');
        if (parsed != null) {
          out[entry.key.toString()] = parsed;
        }
      }
      return out;
    }

    return SyncResultSnapshot(
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
      operation: json['operation']?.toString() ?? 'unknown',
      source: json['source']?.toString() ?? 'unknown',
      success: json['success'] == true,
      recordsSynced: int.tryParse(json['records_synced']?.toString() ?? '') ?? 0,
      recordsFailed: int.tryParse(json['records_failed']?.toString() ?? '') ?? 0,
      error: json['error']?.toString(),
      payloadCounters: parseCounters(payloadRaw),
      writeCounters: parseCounters(writesRaw),
      errorCategory: json['error_category']?.toString(),
      errorContext: json['error_context']?.toString(),
    );
  }
}

class SyncResultSnapshotStore {
  static const String _lastResultKey = 'sync_last_result_snapshot_v1';

  static Future<void> save(SyncResultSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastResultKey, jsonEncode(snapshot.toJson()));
  }

  static Future<SyncResultSnapshot?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastResultKey);
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return SyncResultSnapshot.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }
}
