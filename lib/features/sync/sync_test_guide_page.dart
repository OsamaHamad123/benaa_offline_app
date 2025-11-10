import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client_with_mock.dart';
import '../../core/sync/sync_manager.dart';

/// 📖 دليل تجربة المزامنة
class SyncTestGuidePage extends ConsumerWidget {
  const SyncTestGuidePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('كيفية تجربة المزامنة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Welcome Card
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 48,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'مرحباً بك في نظام المزامنة!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'يمكنك تجربة المزامنة باستخدام سيرفر وهمي محلي',
                    style: TextStyle(color: Colors.blue.shade800),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Steps
          _buildStep(
            context,
            number: '1',
            title: 'تأكد من تفعيل Mock API',
            description:
                'افتح إعدادات المزامنة وتأكد من تفعيل "استخدام Mock API"',
            icon: Icons.toggle_on,
            color: Colors.green,
            action: 'فتح الإعدادات',
            onTap: () {
              Navigator.pop(context);
              // الإعدادات موجودة في AppBar
            },
          ),

          _buildStep(
            context,
            number: '2',
            title: 'أضف بيانات تجريبية',
            description: 'أضف مستفيدين تجريبيين للسيرفر الوهمي',
            icon: Icons.add_circle_outline,
            color: Colors.blue,
            action: 'إضافة بيانات',
            onTap: () => _seedTestData(context, ref),
          ),

          _buildStep(
            context,
            number: '3',
            title: 'أضف مستفيد جديد',
            description: 'اذهب لقائمة المستفيدين وأضف مستفيد جديد',
            icon: Icons.person_add,
            color: Colors.orange,
          ),

          _buildStep(
            context,
            number: '4',
            title: 'ارجع لصفحة المزامنة',
            description: 'اضغط "مزامنة الآن" وشاهد العملية',
            icon: Icons.sync,
            color: Colors.purple,
          ),

          _buildStep(
            context,
            number: '5',
            title: 'شاهد النتائج',
            description: 'بعد المزامنة، تحقق من حصول المستفيد على server_id',
            icon: Icons.check_circle,
            color: Colors.green,
          ),

          const SizedBox(height: 24),

          // Quick Actions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.flash_on, color: theme.primaryColor),
                      const SizedBox(width: 8),
                      Text('إجراءات سريعة', style: theme.textTheme.titleLarge),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _seedTestData(context, ref),
                      icon: const Icon(Icons.science),
                      label: const Text('إضافة بيانات تجريبية'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _testSync(context, ref),
                      icon: const Icon(Icons.sync),
                      label: const Text('تجربة المزامنة الآن'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _clearMockData(context, ref),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('مسح البيانات الوهمية'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Tips
          Card(
            color: Colors.amber.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.amber.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'نصائح مفيدة',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.amber.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTip('يمكنك التحكم في سرعة المزامنة من الإعدادات'),
                  _buildTip('جرّب رفع نسبة الأخطاء لاختبار معالجة الفشل'),
                  _buildTip('فعّل "محاكاة التعارضات" لاختبار حل التعارضات'),
                  _buildTip(
                    'البيانات محفوظة محلياً ولن تُحذف عند إعادة التشغيل',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(
    BuildContext context, {
    required String number,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    String? action,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Number Badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (action != null && onTap != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        action,
                        style: TextStyle(
                          fontSize: 13,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Icon
              Icon(icon, color: color, size: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(color: Colors.amber.shade900, fontSize: 16),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.amber.shade900, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _seedTestData(BuildContext context, WidgetRef ref) async {
    try {
      final apiClient = await ref.read(apiClientWithMockProvider.future);
      await apiClient.seedMockTestData();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ تم إضافة بيانات تجريبية'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✗ خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _testSync(BuildContext context, WidgetRef ref) async {
    try {
      final syncManager = ref.read(syncManagerProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔄 جاري المزامنة...'),
          duration: Duration(seconds: 2),
        ),
      );

      await syncManager.syncAll();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ تمت المزامنة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✗ خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _clearMockData(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد المسح'),
        content: const Text(
          'هل تريد مسح جميع البيانات الوهمية من السيرفر؟\n\n'
          'البيانات المحلية لن تتأثر.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('مسح', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final apiClient = await ref.read(apiClientWithMockProvider.future);
      await apiClient.clearMockServerData();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ تم مسح البيانات الوهمية'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✗ خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
