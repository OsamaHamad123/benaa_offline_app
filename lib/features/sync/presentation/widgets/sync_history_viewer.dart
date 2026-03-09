import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/sync/sync_history_store.dart';

/// 📜 Sync History Entry - سجل عملية مزامنة
class SyncHistoryEntry {
  final DateTime timestamp;
  final bool success;
  final String operation;
  final String source;
  final String? errorCategory;
  final String? message;
  final int? uploadedCount;
  final int? downloadedCount;
  final Duration? duration;

  SyncHistoryEntry({
    required this.timestamp,
    required this.success,
    this.operation = 'unknown',
    this.source = 'unknown',
    this.errorCategory,
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
      duration: json['duration'] != null ? Duration(seconds: json['duration']) : null,
    );
  }
}

/// 📚 Sync History Manager - مدير سجل المزامنة
class SyncHistoryManager {
  static Future<List<SyncHistoryEntry>> getHistory() async {
    final snapshots = await SyncHistoryStore.getHistory();
    return snapshots
        .map(
          (entry) => SyncHistoryEntry(
            timestamp: entry.timestamp,
            success: entry.success,
            operation: entry.operation,
            source: entry.source,
            errorCategory: entry.errorCategory,
            message: entry.message,
            uploadedCount: entry.uploadedCount,
            downloadedCount: entry.downloadedCount,
            duration: entry.durationSeconds == null ? null : Duration(seconds: entry.durationSeconds!),
          ),
        )
        .toList(growable: false);
  }

  static Future<void> addEntry(SyncHistoryEntry entry) async {
    await SyncHistoryStore.addEntry(
      SyncHistoryEntrySnapshot(
        timestamp: entry.timestamp,
        success: entry.success,
        operation: entry.operation,
        source: entry.source,
        message: entry.message,
        uploadedCount: entry.uploadedCount,
        downloadedCount: entry.downloadedCount,
        durationSeconds: entry.duration?.inSeconds,
        errorCategory: entry.errorCategory,
      ),
    );
  }

  static Future<void> clearHistory() async {
    await SyncHistoryStore.clear();
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
    final averageDuration =
        durations.isEmpty ? 0 : durations.fold(0, (sum, e) => sum + e.duration!.inSeconds) ~/ durations.length;

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

final syncStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return SyncHistoryManager.getStatistics();
});

/// 📊 Sync History Viewer - عارض سجل المزامنة
class SyncHistoryViewer extends ConsumerStatefulWidget {
  const SyncHistoryViewer({super.key});

  @override
  ConsumerState<SyncHistoryViewer> createState() => _SyncHistoryViewerState();
}

class _SyncHistoryViewerState extends ConsumerState<SyncHistoryViewer> {
  _SyncHistoryFilter _selectedFilter = _SyncHistoryFilter.all;

  @override
  Widget build(BuildContext context) {
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

          _buildFilterBar(),

          // History List
          Expanded(
            child: historyAsync.when(
              data: (history) {
                final filtered = _applyFilter(history);

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'لا يوجد سجل مطابق للتصفية',
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
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final entry = filtered[index];
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

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip(_SyncHistoryFilter.all, 'الكل'),
          const SizedBox(width: 8),
          _buildFilterChip(_SyncHistoryFilter.up, 'رفع'),
          const SizedBox(width: 8),
          _buildFilterChip(_SyncHistoryFilter.down, 'تنزيل'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(_SyncHistoryFilter filter, String label) {
    return ChoiceChip(
      selected: _selectedFilter == filter,
      label: Text(label),
      onSelected: (_) {
        setState(() {
          _selectedFilter = filter;
        });
      },
    );
  }

  List<SyncHistoryEntry> _applyFilter(List<SyncHistoryEntry> history) {
    switch (_selectedFilter) {
      case _SyncHistoryFilter.up:
        return history.where((entry) => entry.operation.toLowerCase() == 'sync_up').toList(growable: false);
      case _SyncHistoryFilter.down:
        return history.where((entry) => entry.operation.toLowerCase() == 'sync_down').toList(growable: false);
      case _SyncHistoryFilter.all:
        return history;
    }
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
    final time = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    final operationLabel = _operationLabel(entry.operation);
    final sourceLabel = _sourceLabel(entry.source);

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
          entry.success ? 'مزامنة ناجحة ($operationLabel)' : 'فشل المزامنة ($operationLabel)',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('$date - $time'),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildMetaTag(sourceLabel),
                if (entry.errorCategory != null && entry.errorCategory!.trim().isNotEmpty) ...[
                  const SizedBox(width: 6),
                  _buildMetaTag('سبب: ${entry.errorCategory}'),
                ],
              ],
            ),
            if (entry.message != null) ...[
              const SizedBox(height: 4),
              Text(entry.message!, style: const TextStyle(fontSize: 12)),
            ],
            if (entry.uploadedCount != null || entry.downloadedCount != null) ...[
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

  Widget _buildMetaTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11),
      ),
    );
  }

  String _operationLabel(String operation) {
    switch (operation.trim().toLowerCase()) {
      case 'sync_down':
        return 'تنزيل';
      case 'sync_up':
        return 'رفع';
      default:
        return 'غير محدد';
    }
  }

  String _sourceLabel(String source) {
    switch (source.trim().toLowerCase()) {
      case 'foreground':
        return 'من الواجهة';
      case 'background':
        return 'من الخلفية';
      default:
        return 'مصدر غير محدد';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes} دقيقة ${duration.inSeconds % 60} ثانية';
    }
    return '${duration.inSeconds} ثانية';
  }
}

enum _SyncHistoryFilter {
  all,
  up,
  down,
}
