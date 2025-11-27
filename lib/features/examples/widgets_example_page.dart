import 'package:flutter/material.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/utils/helpers.dart';

/// 📖 صفحة توضيحية لاستخدام الـ Widgets والـ Extensions الجديدة
/// يمكن حذف هذا الملف - هو فقط للتوضيح

class WidgetsExamplePage extends StatelessWidget {
  const WidgetsExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('أمثلة على الـ Widgets الجديدة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ========== SectionCard Example ==========
          SectionCard(
            title: 'المعلومات الأساسية',
            icon: Icons.person,
            child: Column(
              children: [
                InfoRow(
                  label: 'الاسم',
                  value: 'محمد أحمد علي',
                  icon: Icons.person,
                ),
                InfoRow(
                  label: 'الرقم الوطني',
                  value: '12345678901',
                  icon: Icons.badge,
                ),
                InfoRow(
                  label: 'رقم الهاتف',
                  value: '0912345678',
                  icon: Icons.phone,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ========== Status Badges Example ==========
          SectionCard(
            title: 'حالات مختلفة',
            icon: Icons.info,
            color: Colors.blue,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusBadge(
                  label: 'متصل',
                  color: Colors.green,
                  isGlowing: true,
                ),
                StatusBadge(
                  label: 'قيد المعالجة',
                  color: Colors.orange,
                  icon: Icons.sync,
                ),
                StatusBadge(
                  label: 'مكتمل',
                  color: Colors.blue,
                  icon: Icons.check_circle,
                ),
                StatusBadge(label: 'خطأ', color: Colors.red, icon: Icons.error),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ========== Stat Cards Example ==========
          const Text(
            'إحصائيات',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: context.isSmallScreen ? 2 : 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              StatCard(
                label: 'إجمالي المستفيدين',
                value: '1,234',
                icon: Icons.people,
                color: Colors.blue,
                onTap: () => context.showSnackBar('تم الضغط على المستفيدين'),
              ),
              StatCard(
                label: 'تمت المزامنة',
                value: '856',
                icon: Icons.sync,
                color: Colors.green,
                onTap: () {},
              ),
              StatCard(
                label: 'قيد الانتظار',
                value: '378',
                icon: Icons.pending,
                color: Colors.orange,
                onTap: () {},
              ),
              StatCard(
                label: 'أخطاء',
                value: '12',
                icon: Icons.error,
                color: Colors.red,
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ========== Action Buttons Example ==========
          const Text(
            'إجراءات سريعة',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ActionButtonCard(
            title: 'إضافة مستفيد',
            subtitle: 'إضافة مستفيد جديد للنظام',
            icon: Icons.person_add,
            color: Colors.blue,
            onTap: () => context.showSnackBar('فتح صفحة الإضافة'),
          ),

          const SizedBox(height: 8),

          ActionButtonCard(
            title: 'البحث في السجل المدني',
            subtitle: 'البحث عن شخص في قاعدة البيانات',
            icon: Icons.search,
            color: Colors.green,
            onTap: () {},
          ),

          const SizedBox(height: 8),

          ActionButtonCard(
            title: 'التقارير',
            subtitle: 'عرض التقارير والإحصائيات',
            icon: Icons.bar_chart,
            color: Colors.orange,
            onTap: () {},
          ),

          const SizedBox(height: 16),

          // ========== Extensions Examples ==========
          SectionCard(
            title: 'أمثلة على Extensions',
            icon: Icons.code,
            color: Colors.purple,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildExtensionDemo(
                  'تنسيق الأرقام',
                  '1234567'.formatWithCommas(),
                  '1,234,567',
                ),
                _buildExtensionDemo(
                  'حجم الملفات',
                  '1572864'.formatBytes(),
                  '1.50 MB',
                ),
                _buildExtensionDemo(
                  'التاريخ بالعربي',
                  DateTime.now().formatArabic(),
                  'مثال: ١١ نوفمبر ٢٠٢٥',
                ),
                _buildExtensionDemo(
                  'الوقت بالعربي',
                  DateTime.now().formatTimeArabic(),
                  'مثال: ٣:٣٠ مساءً',
                ),
                _buildExtensionDemo(
                  'منذ متى',
                  DateTime.now().subtract(const Duration(hours: 3)).timeAgo(),
                  'منذ ٣ ساعات',
                ),
                _buildExtensionDemo(
                  'اختصار النص',
                  'هذا نص طويل جداً'.truncate(10),
                  'هذا نص طو...',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ========== Buttons Example ==========
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () async {
                    final confirmed = await showConfirmationDialog(
                      context: context,
                      title: 'تأكيد',
                      message: 'هل أنت متأكد من هذا الإجراء؟',
                    );

                    if (confirmed) {
                      if (context.mounted) {
                        showSuccessSnackBar(context, 'تم التأكيد بنجاح!');
                      }
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('حوار عادي'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () async {
                    final confirmed = await showConfirmationDialog(
                      context: context,
                      title: 'تحذير',
                      message: 'هذا إجراء خطير! هل تريد المتابعة؟',
                      isDangerous: true,
                      confirmText: 'حذف',
                    );

                    if (confirmed) {
                      if (context.mounted) {
                        showErrorSnackBar(context, 'تم الحذف');
                      }
                    }
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('حوار خطر'),
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ========== Color Examples ==========
          SectionCard(
            title: 'أمثلة على الألوان',
            icon: Icons.palette,
            color: Colors.pink,
            child: Column(
              children: [
                _buildColorDemo('اللون الأصلي', Colors.blue),
                _buildColorDemo('مفتّح 20%', Colors.blue.lighten(0.2)),
                _buildColorDemo('مغمّق 20%', Colors.blue.darken(0.2)),
                _buildColorDemo('شفاف 50%', Colors.blue.withOpacity(0.5)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ========== Responsive Example ==========
          SectionCard(
            title: 'معلومات الشاشة',
            icon: Icons.phone_android,
            color: Colors.teal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoRow(
                  label: 'العرض',
                  value: '${context.screenWidth.toStringAsFixed(0)} px',
                ),
                InfoRow(
                  label: 'الارتفاع',
                  value: '${context.screenHeight.toStringAsFixed(0)} px',
                ),
                InfoRow(
                  label: 'النوع',
                  value: context.isSmallScreen
                      ? 'شاشة صغيرة'
                      : context.isMediumScreen
                          ? 'شاشة متوسطة'
                          : 'شاشة كبيرة',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtensionDemo(String label, String result, String example) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'النتيجة: $result',
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
          ),
          if (example.isNotEmpty)
            Text(
              example,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildColorDemo(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

// ========== Extensions Examples ==========
extension on String {
  String formatWithCommas() {
    final parts = split('.');
    final beforeDecimal = parts[0];
    final regExp = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return beforeDecimal.replaceAllMapped(regExp, (Match m) => '${m[1]},');
  }

  String formatBytes() {
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var value = double.parse(this);
    var suffixIndex = 0;

    while (value >= 1024 && suffixIndex < suffixes.length - 1) {
      value /= 1024;
      suffixIndex++;
    }

    return '${value.toStringAsFixed(2)} ${suffixes[suffixIndex]}';
  }
}
