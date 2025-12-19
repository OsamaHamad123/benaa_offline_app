import 'package:benaa_offline_app/features/associations/domain/entities/association.dart';
import 'package:benaa_offline_app/features/associations/presentation/widgets/modern_association_card.dart';
import 'package:flutter/material.dart';

/// 🧪 Visual Test للـ responsive issues
///
/// استخدام:
/// 1. شغل الـ app
/// 2. انتقل لصفحة الـ associations
/// 3. جرب تصغير الشاشة
///
/// هذا الـ file للتوثيق فقط - ليس automated test
void main() {
  runApp(const ResponsiveTestApp());
}

class ResponsiveTestApp extends StatelessWidget {
  const ResponsiveTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Responsive Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ResponsiveTestPage(),
    );
  }
}

class ResponsiveTestPage extends StatefulWidget {
  const ResponsiveTestPage({super.key});

  @override
  State<ResponsiveTestPage> createState() => _ResponsiveTestPageState();
}

class _ResponsiveTestPageState extends State<ResponsiveTestPage> {
  double _cardWidth = 400;

  // Test data - جمعية بمعلومات كاملة
  final testAssociation = Association(
    id: '1',
    name: 'جمعية البناء الخيرية للتنمية المستدامة والرعاية الاجتماعية',
    shortName: 'البناء',
    phone: '07701234567',
    email: 'info@benaa-charity-organization.org',
    bankName: 'المصرف التجاري العراقي',
    accountNumber: '1234567890123456789',
    accountCurrency: 'IQD',
    swiftCode: 'SWIFT123',
    bankPhone: '07801112233',
    isActive: true,
    representativeId: '1',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 Responsive Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfo,
          ),
        ],
      ),
      body: Column(
        children: [
          // Controls
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Card Width: ${_cardWidth.toInt()}px',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: _cardWidth,
                  min: 250,
                  max: 600,
                  divisions: 70,
                  label: _cardWidth.toInt().toString(),
                  onChanged: (value) => setState(() => _cardWidth = value),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(() => _cardWidth = 280),
                      child: const Text('280px\n(ضيق جداً)'),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => _cardWidth = 320),
                      child: const Text('320px\n(iPhone SE)'),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => _cardWidth = 360),
                      child: const Text('360px\n(Standard)'),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => _cardWidth = 400),
                      child: const Text('400px\n(Large)'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Test Cases
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTestCase(
                  'Test 1: بيانات كاملة',
                  testAssociation,
                  'المندوب محمد أحمد',
                ),
                const SizedBox(height: 24),
                _buildTestCase(
                  'Test 2: بدون email',
                  testAssociation.copyWith(email: null),
                  'المندوب أحمد',
                ),
                const SizedBox(height: 24),
                _buildTestCase(
                  'Test 3: بدون مندوب',
                  testAssociation,
                  null,
                ),
                const SizedBox(height: 24),
                _buildTestCase(
                  'Test 4: اسم قصير',
                  testAssociation.copyWith(
                    name: 'جمعية قصيرة',
                    shortName: 'ق',
                  ),
                  'مندوب',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestCase(
    String title,
    Association association,
    String? representative,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: SizedBox(
            width: _cardWidth,
            child: ModernAssociationCard(
              association: association,
              representativeName: representative,
              onTap: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      ],
    );
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📋 كيفية الاستخدام'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1️⃣ استخدم الـ Slider لتغيير عرض البطاقة',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('2️⃣ انقر على الأزرار للأحجام الشائعة'),
              SizedBox(height: 8),
              Text('3️⃣ لاحظ كيف تتكيف البطاقة مع الحجم'),
              SizedBox(height: 16),
              Text(
                '✅ ما يجب ملاحظته:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
              Text('• لا يوجد overflow (قطع في المحتوى)'),
              Text('• البطاقة scrollable إذا كان المحتوى كبير'),
              Text('• الأزرار responsive (عمودي/أفقي)'),
              Text('• معلومات الاتصال والبنك responsive'),
              SizedBox(height: 16),
              Text(
                '❌ المشاكل المحتملة:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              Text('• محتوى يتجاوز حدود البطاقة'),
              Text('• نص مقطوع بدون ellipsis'),
              Text('• أزرار متداخلة أو مخفية'),
              Text('• spacing غير متسق'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('فهمت'),
          ),
        ],
      ),
    );
  }
}

// Extension للمساعدة في الاختبار
extension AssociationCopyWith on Association {
  Association copyWith({
    String? id,
    String? name,
    String? shortName,
    String? phone,
    String? email,
    String? bankName,
    String? accountNumber,
    String? accountCurrency,
    String? swiftCode,
    String? bankPhone,
    bool? isActive,
    String? representativeId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Association(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      phone: phone ?? this.phone,
      email: email,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      accountCurrency: accountCurrency ?? this.accountCurrency,
      swiftCode: swiftCode,
      bankPhone: bankPhone,
      isActive: isActive ?? this.isActive,
      representativeId: representativeId ?? this.representativeId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
