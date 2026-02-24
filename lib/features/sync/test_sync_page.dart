import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/sync/mobile_sync_service.dart';
import 'presentation/providers/mobile_sync_operations_providers.dart';

final testMobileSyncStatusProvider = StreamProvider<MobileSyncStatus>((ref) {
  final service = ref.watch(mobileSyncServiceProvider);
  return service.statusStream;
});

/// صفحة تجربة المزامنة مع Backend
class TestSyncPage extends ConsumerStatefulWidget {
  const TestSyncPage({super.key});

  @override
  ConsumerState<TestSyncPage> createState() => _TestSyncPageState();
}

class _TestSyncPageState extends ConsumerState<TestSyncPage> {
  String _statusMessage = '';
  bool _isLoading = false;

  Future<void> _testPullSync() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'جاري جلب البيانات من السيرفر...';
    });

    try {
      final syncDown = ref.read(mobileSyncDownUseCaseProvider);
      final result = await syncDown();

      setState(() {
        _isLoading = false;
        _statusMessage = 'تم جلب ${result.recordsSynced} سجل بنجاح ✅';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'خطأ: $e ❌';
      });
    }
  }

  Future<void> _testPushSync() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'جاري رفع البيانات للسيرفر...';
    });

    try {
      final syncUp = ref.read(mobileSyncUpUseCaseProvider);
      final result = await syncUp();

      setState(() {
        _isLoading = false;
        _statusMessage = 'تم رفع ${result.recordsSynced} سجل بنجاح ✅';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'خطأ: $e ❌';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final syncStatus = ref.watch(testMobileSyncStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('اختبار المزامنة')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sync Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'حالة المزامنة',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    syncStatus.when(
                      data: (status) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusRow(
                            'الحالة',
                            status.isSyncing ? 'جاري المزامنة...' : 'جاهز',
                            status.isSyncing ? Colors.orange : Colors.green,
                          ),
                          if (status.isSyncing) ...[
                            const SizedBox(height: 8),
                            _buildStatusRow(
                              'التقدم',
                              '${(status.progress * 100).toStringAsFixed(0)}%',
                              Colors.blue,
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(value: status.progress),
                          ],
                          if (status.currentOperation.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _buildStatusRow(
                              'العنصر الحالي',
                              status.currentOperation,
                              Colors.purple,
                            ),
                          ],
                          if (status.lastError != null) ...[
                            const SizedBox(height: 8),
                            _buildStatusRow(
                              'آخر خطأ',
                              status.lastError!,
                              Colors.red,
                            ),
                          ],
                        ],
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, _) => Text(
                        'خطأ: $error',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Pull Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testPullSync,
              icon: const Icon(Icons.download),
              label: const Text('سحب البيانات من السيرفر (Pull)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 16),

            // Push Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testPushSync,
              icon: const Icon(Icons.upload),
              label: const Text('رفع البيانات للسيرفر (Push)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 24),

            // Status Message
            if (_statusMessage.isNotEmpty)
              Card(
                color: _statusMessage.contains('✅')
                    ? Colors.green.shade50
                    : _statusMessage.contains('❌')
                        ? Colors.red.shade50
                        : Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _statusMessage,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color),
          ),
          child: Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
