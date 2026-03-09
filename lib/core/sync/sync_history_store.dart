import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SyncHistoryEntrySnapshot {
  final DateTime timestamp;
  final bool success;
  final String operation;
  final String source;
  final String? message;
  final int? uploadedCount;
  final int? downloadedCount;
  final int? durationSeconds;
  final String? errorCategory;

  const SyncHistoryEntrySnapshot({
    required this.timestamp,
    required this.success,
    required this.operation,
    required this.source,
    this.message,
    this.uploadedCount,
    this.downloadedCount,
    this.durationSeconds,
    this.errorCategory,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'timestamp': timestamp.toIso8601String(),
        'success': success,
        'message': message,
        'uploadedCount': uploadedCount,
        'downloadedCount': downloadedCount,
        'duration': durationSeconds,
        'operation': operation,
        'source': source,
        'error_category': errorCategory,
      };

  factory SyncHistoryEntrySnapshot.fromJson(Map<String, dynamic> json) {
    return SyncHistoryEntrySnapshot(
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
      success: json['success'] == true,
      operation: json['operation']?.toString() ?? 'unknown',
      source: json['source']?.toString() ?? 'unknown',
      message: json['message']?.toString(),
      uploadedCount: int.tryParse(json['uploadedCount']?.toString() ?? ''),
      downloadedCount: int.tryParse(json['downloadedCount']?.toString() ?? ''),
      durationSeconds: int.tryParse(json['duration']?.toString() ?? ''),
      errorCategory: json['error_category']?.toString(),
    );
  }
}

class SyncHistoryStore {
  static const String _key = 'sync_history';
  static const int _maxEntries = 50;

  static Future<List<SyncHistoryEntrySnapshot>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) {
      return const <SyncHistoryEntrySnapshot>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const <SyncHistoryEntrySnapshot>[];
      }
      return decoded
          .whereType<Map>()
          .map((item) => SyncHistoryEntrySnapshot.fromJson(item.cast<String, dynamic>()))
          .toList(growable: false);
    } catch (_) {
      return const <SyncHistoryEntrySnapshot>[];
    }
  }

  static Future<void> addEntry(SyncHistoryEntrySnapshot entry) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getHistory();
    final next = <SyncHistoryEntrySnapshot>[entry, ...current];
    if (next.length > _maxEntries) {
      next.removeRange(_maxEntries, next.length);
    }

    final encoded = jsonEncode(next.map((e) => e.toJson()).toList(growable: false));
    await prefs.setString(_key, encoded);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
