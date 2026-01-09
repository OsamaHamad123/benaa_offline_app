import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../taxonomies/presentation/providers/taxonomy_providers.dart';

/// صفحة التهيئة - تحميل التصنيفات من API أو من البيانات المحلية
class InitializationPage extends ConsumerStatefulWidget {
  const InitializationPage({super.key});

  @override
  ConsumerState<InitializationPage> createState() => _InitializationPageState();
}

class _InitializationPageState extends ConsumerState<InitializationPage> {
  String _statusMessage = 'جاري التحضير...';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      setState(() {
        _statusMessage = 'جاري تحميل التصنيفات...';
      });

      // استخدام نظام التصنيفات الجديد
      final syncNotifier = ref.read(taxonomySyncNotifierProvider.notifier);

      // محاولة المزامنة من API
      try {
        await syncNotifier.sync();
        final syncResult = ref.read(lastSyncResultProvider);
        if (syncResult != null && syncResult.success) {
          setState(() {
            _statusMessage = 'تم تحديث التصنيفات من الخادم (${syncResult.addedCount} جديد)';
          });
        } else {
          setState(() {
            _statusMessage = 'تم تحميل التصنيفات المحلية';
          });
        }
      } catch (e) {
        // في حالة فشل API، نتابع بدون خطأ
        setState(() {
          _statusMessage = 'جاري استخدام التصنيفات المحلية...';
        });
      }

      // الانتظار قليلاً لعرض الرسالة
      await Future.delayed(const Duration(milliseconds: 500));

      // الانتقال إلى الصفحة الرئيسية
      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'حدث خطأ: ${e.toString()}';
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo or App Icon
            Icon(
              Icons.business_center,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 32),

            // App Name
            Text(
              'بناء',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 48),

            // Loading Indicator or Error
            if (!_hasError)
              const CircularProgressIndicator()
            else
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),

            // Status Message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: _hasError ? Colors.red : Colors.grey[700],
                ),
              ),
            ),

            // Retry Button (if error)
            if (_hasError) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _statusMessage = 'جاري إعادة المحاولة...';
                  });
                  _initialize();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  context.go('/dashboard');
                },
                child: const Text('تخطي والمتابعة'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
