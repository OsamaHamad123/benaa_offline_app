import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/mappers/beneficiary_mapper.dart';
import '../../core/providers/providers.dart';

/// صفحة استيراد بيانات التجربة من backend_schema.json
class ImportTestDataPage extends ConsumerStatefulWidget {
  const ImportTestDataPage({super.key});

  @override
  ConsumerState<ImportTestDataPage> createState() => _ImportTestDataPageState();
}

class _ImportTestDataPageState extends ConsumerState<ImportTestDataPage> {
  String _statusMessage = '';
  bool _isLoading = false;
  int _totalRecords = 0;
  int _importedRecords = 0;
  int _errorRecords = 0;

  Future<void> _importBackendData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'جاري قراءة الملف...';
      _totalRecords = 0;
      _importedRecords = 0;
      _errorRecords = 0;
    });

    try {
      // قراءة ملف backend_schema.json
      final jsonString = await rootBundle.loadString(
        'docs/backend_schema.json',
      );
      final jsonData = jsonDecode(jsonString);

      // استخراج جدول data
      final database = jsonData['database'] as Map<String, dynamic>;
      final dataTable = database['data'] as Map<String, dynamic>;
      final rows = dataTable['data'] as List;

      setState(() {
        _totalRecords = rows.length;
        _statusMessage = 'تم العثور على $_totalRecords سجل. جاري الاستيراد...';
      });

      final db = ref.read(databaseProvider);

      // استيراد كل سجل
      for (int i = 0; i < rows.length; i++) {
        try {
          final row = rows[i] as Map<String, dynamic>;

          // تحويل البيانات باستخدام Mapper
          final beneficiaryCompanion = BeneficiaryMapper.fromBackend(row);

          // حفظ في قاعدة البيانات
          await db.beneficiariesDao.insertBeneficiary(beneficiaryCompanion);

          setState(() {
            _importedRecords = i + 1;
            _statusMessage =
                'تم استيراد $_importedRecords من $_totalRecords...';
          });
        } catch (e) {
          setState(() {
            _errorRecords++;
          });
          debugPrint('خطأ في استيراد السجل ${i + 1}: $e');
        }
      }

      setState(() {
        _isLoading = false;
        _statusMessage =
            'اكتمل الاستيراد!\n✅ نجح: $_importedRecords\n❌ فشل: $_errorRecords';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'خطأ: $e ❌';
      });
    }
  }

  Future<void> _clearAllData() async {
    // تأكيد الحذف
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف جميع المستفيدين؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'جاري حذف البيانات...';
    });

    try {
      final db = ref.read(databaseProvider);
      final beneficiaries = await db.beneficiariesDao.getAllBeneficiaries();

      for (final beneficiary in beneficiaries) {
        await db.beneficiariesDao.deleteBeneficiary(beneficiary.id);
      }

      setState(() {
        _isLoading = false;
        _statusMessage = 'تم حذف ${beneficiaries.length} مستفيد ✅';
        _importedRecords = 0;
        _totalRecords = 0;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'خطأ: $e ❌';
      });
    }
  }

  Future<void> _checkCurrentData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'جاري فحص البيانات...';
    });

    try {
      final db = ref.read(databaseProvider);
      final count = await db.beneficiariesDao.countBeneficiaries();
      final beneficiaries = await db.beneficiariesDao.getAllBeneficiaries();

      if (beneficiaries.isNotEmpty) {
        final sample = beneficiaries.first;
        setState(() {
          _isLoading = false;
          _statusMessage =
              '''
إجمالي المستفيدين: $count

مثال على أول مستفيد:
- الاسم: ${sample.fullName}
- الرقم الوطني: ${sample.nationalId}
- الجنس: ${sample.gender}
- المحافظة: ${sample.governorate}
- الفئة: ${sample.category}
${sample.serverId != null ? '- Server ID: ${sample.serverId}' : ''}
          ''';
        });
      } else {
        setState(() {
          _isLoading = false;
          _statusMessage = 'لا يوجد مستفيدين في قاعدة البيانات';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'خطأ: $e ❌';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('استيراد بيانات التجربة')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'معلومات',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'هذه الصفحة تستورد البيانات من backend_schema.json مباشرة لاختبار نظام التحويل (Mapper) بدون الحاجة لـ API.',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Progress Card
            if (_isLoading || _totalRecords > 0)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'التقدم',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      if (_totalRecords > 0) ...[
                        LinearProgressIndicator(
                          value: _totalRecords > 0
                              ? _importedRecords / _totalRecords
                              : 0,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_importedRecords / $_totalRecords',
                          textAlign: TextAlign.center,
                        ),
                      ],
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator()),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Import Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _importBackendData,
              icon: const Icon(Icons.cloud_download),
              label: const Text('استيراد من backend_schema.json'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 12),

            // Check Data Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _checkCurrentData,
              icon: const Icon(Icons.assessment),
              label: const Text('فحص البيانات الحالية'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 12),

            // Clear Button
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _clearAllData,
              icon: const Icon(Icons.delete_forever),
              label: const Text('حذف جميع البيانات'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                foregroundColor: Colors.red,
              ),
            ),

            const SizedBox(height: 24),

            // Status Message
            if (_statusMessage.isNotEmpty)
              Expanded(
                child: Card(
                  color: _statusMessage.contains('✅')
                      ? Colors.green.shade50
                      : _statusMessage.contains('❌')
                      ? Colors.red.shade50
                      : Colors.blue.shade50,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _statusMessage,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
