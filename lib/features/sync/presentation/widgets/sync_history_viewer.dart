import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// 📜 Sync History Entry - سجل عملية مزامنة
class SyncHistoryEntry {
  final DateTime timestamp;
  final bool success;
  final String? message;
  final int? uploadedCount;
  final int? downloadedCount;
  final Duration? duration;

  SyncHistoryEntry({
    required this.timestamp,
    required this.success,
    this.message,
    this.uploadedCount,
    this.downloadedCount,
    this.duration,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'success': success,
        'message': message,
        'uploadedCount': uploadedCount,
        'downloadedCount': downloadedCount,
        'duration': duration?.inSeconds,
      };

  factory SyncHistoryEntry.fromJson(Map<String, dynamic> json) {
    return SyncHistoryEntry(
      timestamp: DateTime.parse(json['timestamp']),
      success: json['success'],
      message: json['message'],
      uploadedCount: json['uploadedCount'],
      downloadedCount: json['downloadedCount'],
      duration:
          json['duration'] != null ? Duration(seconds: json['duration']) : null,
    );
  }
}

/// 📚 Sync History Manager - مدير سجل المزامنة
class SyncHistoryManager {
  static const String _key = 'sync_history';
  static const int _maxEntries = 50;

  static Future<List<SyncHistoryEntry>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((e) => SyncHistoryEntry.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> addEntry(SyncHistoryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();

    history.insert(0, entry);

    // Keep only the last N entries
    if (history.length > _maxEntries) {
      history.removeRange(_maxEntries, history.length);
    }

    final jsonString = json.encode(history.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<Map<String, dynamic>> getStatistics() async {
    final history = await getHistory();
    if (history.isEmpty) {
      return {
        'totalSyncs': 0,
        'successfulSyncs': 0,
        'failedSyncs': 0,
        'successRate': 0.0,
        'totalUploaded': 0,
        'totalDownloaded': 0,
        'averageDuration': 0,
      };
    }

    final successful = history.where((e) => e.success).length;
    final failed = history.length - successful;
    final totalUploaded = history.fold(
      0,
      (sum, e) => sum + (e.uploadedCount ?? 0),
    );
    final totalDownloaded = history.fold(
      0,
      (sum, e) => sum + (e.downloadedCount ?? 0),
    );
    final durations = history.where((e) => e.duration != null).toList();
    final averageDuration = durations.isEmpty
        ? 0
        : durations.fold(0, (sum, e) => sum + e.duration!.inSeconds) ~/
            durations.length;

    return {
      'totalSyncs': history.length,
      'successfulSyncs': successful,
      'failedSyncs': failed,
      'successRate': (successful / history.length * 100),
      'totalUploaded': totalUploaded,
      'totalDownloaded': totalDownloaded,
      'averageDuration': averageDuration,
    };
  }
}

/// Provider للسجل
final syncHistoryProvider = FutureProvider<List<SyncHistoryEntry>>((ref) async {
  return SyncHistoryManager.getHistory();
});

final syncStatisticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  return SyncHistoryManager.getStatistics();
});

/// 📊 Sync History Viewer - عارض سجل المزامنة
class SyncHistoryViewer extends ConsumerWidget {
  const SyncHistoryViewer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(syncHistoryProvider);
    final statsAsync = ref.watch(syncStatisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل المزامنة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'مسح السجل',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('مسح السجل'),
                  content: const Text('هل تريد مسح سجل المزامنة بالكامل؟'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('إلغاء'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('مسح'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await SyncHistoryManager.clearHistory();
                ref.invalidate(syncHistoryProvider);
                ref.invalidate(syncStatisticsProvider);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Card
          statsAsync.when(
            data: (stats) => _buildStatisticsCard(stats),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // History List
          Expanded(
            child: historyAsync.when(
              data: (history) {
                if (history.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'لا يوجد سجل مزامنة',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: history.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final entry = history[index];
                    return _buildHistoryCard(entry);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('حدث خطأ: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(Map<String, dynamic> stats) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الإحصائيات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'إجمالي العمليات',
                    '${stats['totalSyncs']}',
                    Icons.sync,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'نجح',
                    '${stats['successfulSyncs']}',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'فشل',
                    '${stats['failedSyncs']}',
                    Icons.error,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'معدل النجاح',
                    '${stats['successRate'].toStringAsFixed(1)}%',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'رفع',
                    '${stats['totalUploaded']}',
                    Icons.cloud_upload,
                    Colors.purple,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'تنزيل',
                    '${stats['totalDownloaded']}',
                    Icons.cloud_download,
                    Colors.teal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHistoryCard(SyncHistoryEntry entry) {
    final dateTime = entry.timestamp;
    final date =
        '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: entry.success ? Colors.green : Colors.red,
          child: Icon(
            entry.success ? Icons.check : Icons.close,
            color: Colors.white,
          ),
        ),
        title: Text(
          entry.success ? 'مزامنة ناجحة' : 'فشل المزامنة',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('$date - $time'),
            if (entry.message != null) ...[
              const SizedBox(height: 4),
              Text(entry.message!, style: const TextStyle(fontSize: 12)),
            ],
            if (entry.uploadedCount != null ||
                entry.downloadedCount != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  if (entry.uploadedCount != null) ...[
                    Icon(Icons.cloud_upload, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.uploadedCount}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (entry.downloadedCount != null) ...[
                    Icon(
                      Icons.cloud_download,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.downloadedCount}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ],
              ),
            ],
            if (entry.duration != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.timer, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDuration(entry.duration!),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes} دقيقة ${duration.inSeconds % 60} ثانية';
    }
    return '${duration.inSeconds} ثانية';
  }
}
