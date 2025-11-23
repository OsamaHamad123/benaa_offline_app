import 'package:benaa_offline_app/features/search/data/datasources/update_normalization.dart';
import 'package:flutter/material.dart';
import 'package:benaa_offline_app/core/extensions/context_extensions.dart';

/// 🔧 Debug page for updating normalization
///
/// ⚠️ Use this ONCE after updating normalization logic
class UpdateNormalizationPage extends StatefulWidget {
  const UpdateNormalizationPage({super.key});

  @override
  State<UpdateNormalizationPage> createState() =>
      _UpdateNormalizationPageState();
}

class _UpdateNormalizationPageState extends State<UpdateNormalizationPage> {
  bool _isUpdating = false;
  bool _testPassed = false;
  String _statusMessage = '';
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _runTests();
  }

  Future<void> _runTests() async {
    setState(() {
      _statusMessage = 'Running normalization tests...';
    });

    final passed = await UpdateNormalizationUtility.testNormalization();

    setState(() {
      _testPassed = passed;
      _statusMessage = passed
          ? '✅ All tests passed! Ready to update database.'
          : '⚠️ Some tests failed. Check console for details.';
    });
  }

  Future<void> _startUpdate() async {
    // Confirm with user
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ تحديث البيانات'),
        content: const Text(
          'هل أنت متأكد من تحديث جميع السجلات؟\n\n'
          'هذه العملية:\n'
          '• قد تستغرق عدة دقائق\n'
          '• ستعمل على تحديث 5M سجل\n'
          '• يجب تشغيلها مرة واحدة فقط\n\n'
          'لا يمكن التراجع عن هذه العملية.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('تأكيد التحديث'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isUpdating = true;
      _statusMessage = 'Updating normalization...';
      _progress = 0.0;
    });

    try {
      await UpdateNormalizationUtility.updateAllNormalization();

      setState(() {
        _isUpdating = false;
        _progress = 1.0;
        _statusMessage = '✅ Update completed successfully!';
      });

      if (mounted) {
        context.showSuccess('✅ تم تحديث البيانات بنجاح!');
      }
    } catch (e) {
      setState(() {
        _isUpdating = false;
        _statusMessage = '❌ Error: $e';
      });

      if (mounted) {
        context.showError('❌ خطأ: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔧 تحديث Normalization'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange.shade700,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'تحديث لمرة واحدة فقط',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'هذه الصفحة تعمل على تحديث normalization لجميع السجلات '
                      'لإصلاح مشكلة البحث عن الأسماء المنتهية بالهمزة (ولاء، هناء، سناء).',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Test Results
            Card(
              child: ListTile(
                leading: Icon(
                  _testPassed ? Icons.check_circle : Icons.error,
                  color: _testPassed ? Colors.green : Colors.red,
                  size: 32,
                ),
                title: const Text(
                  'Normalization Tests',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _testPassed ? 'All tests passed ✅' : 'Some tests failed ⚠️',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _isUpdating ? null : _runTests,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Status
            if (_statusMessage.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _statusMessage,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Progress
            if (_isUpdating)
              Column(
                children: [
                  const LinearProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(
                    '${(_progress * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),

            const Spacer(),

            // Update Button
            ElevatedButton.icon(
              onPressed: _isUpdating || !_testPassed ? null : _startUpdate,
              icon: _isUpdating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.update),
              label: Text(
                _isUpdating ? 'جاري التحديث...' : 'تحديث البيانات الآن',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                disabledBackgroundColor: Colors.grey,
              ),
            ),

            const SizedBox(height: 8),

            // Warning
            const Text(
              '⚠️ هذه العملية قد تستغرق عدة دقائق',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
