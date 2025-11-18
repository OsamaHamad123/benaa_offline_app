import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/sync/presentation/providers/sync_providers.dart';

/// 🧪 Test Sync Page - للاختبار المؤقت
///
/// استخدم هذه الصفحة لاختبار المزامنة مع السيرفر
class TestSyncPage extends ConsumerWidget {
  const TestSyncPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncControllerProvider);
    final taxonomyStatsAsync = ref.watch(taxonomyStatisticsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Test Sync 🧪'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sync Status Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _getStatusIcon(syncState.status),
                        const SizedBox(width: 12),
                        Text(
                          _getStatusText(syncState.status),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    if (syncState.message != null) ...[
                      const SizedBox(height: 8),
                      Text(syncState.message!),
                    ],

                    if (syncState.itemsSynced != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '✅ تم مزامنة: ${syncState.itemsSynced} عنصر',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],

                    if (syncState.error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '❌ خطأ: ${syncState.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Test Buttons
            ElevatedButton.icon(
              onPressed: syncState.isSyncing
                  ? null
                  : () async {
                      final controller = ref.read(
                        syncControllerProvider.notifier,
                      );
                      await controller.deltaSync('taxonomies');
                    },
              icon: const Icon(Icons.cloud_download),
              label: const Text('Test: Sync Taxonomies'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: syncState.isSyncing
                  ? null
                  : () async {
                      final controller = ref.read(
                        syncControllerProvider.notifier,
                      );
                      await controller.fullSyncAll();
                    },
              icon: const Icon(Icons.sync),
              label: const Text('Test: Full Sync All'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () async {
                final stats = await ref.read(taxonomyStatisticsProvider.future);
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('📊 Database Statistics'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: stats.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(entry.key),
                                  Chip(label: Text('${entry.value}')),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('إغلاق'),
                        ),
                      ],
                    ),
                  );
                }
              },
              icon: const Icon(Icons.storage),
              label: const Text('Check Local Database'),
            ),

            const SizedBox(height: 24),

            // Statistics Preview
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📊 Local Taxonomy Stats',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      Expanded(
                        child: taxonomyStatsAsync.when(
                          data: (stats) {
                            if (stats.isEmpty) {
                              return const Center(
                                child: Text(
                                  'لا توجد بيانات محلية\nقم بالمزامنة أولاً',
                                ),
                              );
                            }
                            return ListView.builder(
                              itemCount: stats.length,
                              itemBuilder: (context, index) {
                                final entry = stats.entries.elementAt(index);
                                return ListTile(
                                  leading: const Icon(Icons.label),
                                  title: Text(_getGroupLabel(entry.key)),
                                  trailing: Chip(label: Text('${entry.value}')),
                                );
                              },
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (error, _) =>
                              Center(child: Text('خطأ: $error')),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getStatusIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return const Icon(Icons.cloud_off, color: Colors.grey);
      case SyncStatus.syncing:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case SyncStatus.success:
        return const Icon(Icons.check_circle, color: Colors.green);
      case SyncStatus.error:
        return const Icon(Icons.error, color: Colors.red);
    }
  }

  String _getStatusText(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return 'جاهز للمزامنة';
      case SyncStatus.syncing:
        return 'جارٍ المزامنة...';
      case SyncStatus.success:
        return 'تمت المزامنة بنجاح ✅';
      case SyncStatus.error:
        return 'فشلت المزامنة ❌';
    }
  }

  String _getGroupLabel(String group) {
    const labels = {
      'category': 'الفئات',
      'marital_status': 'الحالة الاجتماعية',
      'education_level': 'المستوى التعليمي',
      'health_status': 'الحالة الصحية',
      'gender': 'الجنس',
      'governorate': 'المحافظات',
      'displacement_status': 'حالة النزوح',
      'employment_status': 'حالة العمل',
      'housing_status': 'حالة السكن',
      'housing_type': 'نوع السكن',
    };
    return labels[group] ?? group;
  }
}
