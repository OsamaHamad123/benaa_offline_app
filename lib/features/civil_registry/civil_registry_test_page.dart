import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

/// صفحة اختبار السجل المدني
class CivilRegistryTestPage extends ConsumerStatefulWidget {
  const CivilRegistryTestPage({super.key});

  @override
  ConsumerState<CivilRegistryTestPage> createState() =>
      _CivilRegistryTestPageState();
}

class _CivilRegistryTestPageState extends ConsumerState<CivilRegistryTestPage> {
  Database? _db;
  bool _isLoading = true;
  String _status = 'جاري التحميل...';
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _sampleData = [];

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    try {
      setState(() {
        _status = 'جاري البحث عن قاعدة البيانات...';
      });

      // الحصول على مسار التطبيق
      final appDir = await getApplicationDocumentsDirectory();
      final dbDir = Directory('${appDir.path}/databases');
      final dbPath = '${dbDir.path}/civil_registry.db';

      // التحقق من وجود القاعدة
      final dbFile = File(dbPath);
      if (!await dbFile.exists()) {
        setState(() {
          _isLoading = false;
          _status =
              'قاعدة بيانات السجل المدني غير موجودة.\n'
              'الرجاء الذهاب إلى صفحة "تنزيل قاعدة بيانات السجل المدني" أولاً.';
        });
        return;
      }

      setState(() {
        _status = 'فتح قاعدة البيانات...';
      });

      // فتح القاعدة
      if (Platform.isWindows || Platform.isLinux) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }

      _db = await openDatabase(dbPath, readOnly: true);

      setState(() {
        _status = 'جمع الإحصائيات...';
      });

      // جمع الإحصائيات
      await _loadStats();

      setState(() {
        _isLoading = false;
        _status = 'جاهز';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = 'خطأ: $e';
      });
    }
  }

  Future<void> _loadStats() async {
    if (_db == null) return;

    final personsCount = await _db!.rawQuery(
      'SELECT COUNT(*) as count FROM persons',
    );
    final relationsCount = await _db!.rawQuery(
      'SELECT COUNT(*) as count FROM relations',
    );
    final maleCount = await _db!.rawQuery(
      'SELECT COUNT(*) as count FROM persons WHERE CI_SEX_CD = 1',
    );
    final femaleCount = await _db!.rawQuery(
      'SELECT COUNT(*) as count FROM persons WHERE CI_SEX_CD = 2',
    );

    final sample = await _db!.rawQuery('SELECT * FROM persons LIMIT 10');

    setState(() {
      _stats = {
        'persons': personsCount[0]['count'],
        'relations': relationsCount[0]['count'],
        'males': maleCount[0]['count'],
        'females': femaleCount[0]['count'],
      };
      _sampleData = sample;
    });
  }

  Future<void> _testSearch(String query) async {
    if (_db == null) return;

    setState(() {
      _isLoading = true;
      _status = 'البحث عن "$query"...';
    });

    final stopwatch = Stopwatch()..start();
    final results = await _db!.rawQuery(
      '''
      SELECT * FROM persons 
      WHERE CI_FIRST_ARB LIKE ? 
         OR CI_FATHER_ARB LIKE ? 
         OR CI_FAMILY_ARB LIKE ?
      LIMIT 50
      ''',
      ['%$query%', '%$query%', '%$query%'],
    );
    stopwatch.stop();

    setState(() {
      _sampleData = results;
      _isLoading = false;
      _status =
          'وجد ${results.length} نتيجة في ${stopwatch.elapsedMilliseconds} ms';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اختبار السجل المدني')),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_status),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // الحالة
                  Card(
                    color: Colors.green[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            _status,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // الإحصائيات
                  if (_stats != null) ...[
                    const Text(
                      '📊 الإحصائيات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildStatRow(
                              '👥 عدد الأشخاص',
                              _stats!['persons'].toString(),
                            ),
                            _buildStatRow(
                              '👨 الذكور',
                              _stats!['males'].toString(),
                            ),
                            _buildStatRow(
                              '👩 الإناث',
                              _stats!['females'].toString(),
                            ),
                            _buildStatRow(
                              '🔗 العلاقات',
                              _stats!['relations'].toString(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // البحث
                  const Text(
                    '🔍 اختبار البحث',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _testSearch('محمد'),
                          child: const Text('بحث: محمد'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _testSearch('أحمد'),
                          child: const Text('بحث: أحمد'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _testSearch('علي'),
                          child: const Text('بحث: علي'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // عينة البيانات
                  const Text(
                    '📋 البيانات',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._sampleData.map(
                    (person) => Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            person['CI_SEX_CD'] == 1
                                ? '👨'
                                : person['CI_SEX_CD'] == 2
                                ? '👩'
                                : '👤',
                          ),
                        ),
                        title: Text(
                          '${person['CI_FIRST_ARB']} ${person['CI_FATHER_ARB']} ${person['CI_FAMILY_ARB']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('الرقم الوطني: ${person['CI_ID_NUM']}'),
                            if (person['MOTHER_NAME1'] != null)
                              Text('الأم: ${person['MOTHER_NAME1']}'),
                            if (person['CI_BIRTH_DT'] != null)
                              Text('الميلاد: ${person['CI_BIRTH_DT']}'),
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

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _db?.close();
    super.dispose();
  }
}
