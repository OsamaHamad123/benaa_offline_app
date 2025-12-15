import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../error_handling/error_logger.dart';

/// Debug page for testing Sentry integration
/// Only visible in debug mode
class SentryTestPage extends StatelessWidget {
  const SentryTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return Scaffold(
        appBar: AppBar(title: const Text('غير متاح')),
        body: const Center(
          child: Text('هذه الصفحة متاحة فقط في وضع التطوير'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🐛 اختبار Sentry'),
        backgroundColor: Colors.red.shade700,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'اختبار تقارير الأخطاء',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'استخدم الأزرار أدناه لاختبار إرسال الأخطاء إلى Sentry',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Test 1: Log Error
          _TestButton(
            title: '1️⃣ إرسال خطأ عادي',
            description: 'يرسل خطأ مع context إلى Sentry',
            color: Colors.orange,
            onPressed: () async {
              await ErrorLogger.logError(
                Exception('Test error from Sentry Test Page'),
                StackTrace.current,
                context: {
                  'test_type': 'manual_error',
                  'timestamp': DateTime.now().toIso8601String(),
                  'page': 'SentryTestPage',
                },
                hint: 'Testing basic error logging',
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ تم إرسال الخطأ! تحقق من Sentry Dashboard'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),

          // Test 2: Log Warning
          _TestButton(
            title: '2️⃣ إرسال تحذير',
            description: 'يرسل warning message',
            color: Colors.amber,
            onPressed: () async {
              await ErrorLogger.logWarning(
                'Test warning message',
                context: {
                  'test_type': 'warning',
                  'severity': 'medium',
                },
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('⚠️ تم إرسال التحذير!'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
          ),

          // Test 3: Log Info
          _TestButton(
            title: '3️⃣ إرسال معلومة',
            description: 'يرسل info message',
            color: Colors.blue,
            onPressed: () async {
              await ErrorLogger.logInfo(
                'Test info message',
                context: {
                  'test_type': 'info',
                  'app_version': '1.0.0',
                },
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ℹ️ تم إرسال المعلومة!'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
          ),

          // Test 4: Actual Crash
          _TestButton(
            title: '4️⃣ إنشاء Crash حقيقي',
            description: '⚠️ سيتسبب في توقف التطبيق!',
            color: Colors.red,
            onPressed: () {
              // Show warning dialog first
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('⚠️ تحذير'),
                  content: const Text(
                    'هذا سيتسبب في crash حقيقي وإغلاق التطبيق!\n\n'
                    'متأكد تريد المتابعة؟',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Wait a bit then crash
                        Future.delayed(const Duration(seconds: 1), () {
                          throw Exception('Test crash from Sentry Test Page!');
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('نعم، Crash!'),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 24),
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'كيف تتحقق؟',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. افتح Sentry Dashboard: https://sentry.io\n'
                    '2. اذهب إلى Issues\n'
                    '3. ستشاهد الأخطاء خلال 10-30 ثانية\n'
                    '4. اضغط على أي خطأ للتفاصيل',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TestButton extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final VoidCallback onPressed;

  const _TestButton({
    required this.title,
    required this.description,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.bug_report, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
