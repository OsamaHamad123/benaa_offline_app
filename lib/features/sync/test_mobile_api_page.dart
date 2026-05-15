import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

/// Test page للتحقق من Mobile Sync API
class TestMobileApiPage extends StatefulWidget {
  const TestMobileApiPage({super.key});

  @override
  State<TestMobileApiPage> createState() => _TestMobileApiPageState();
}

class _TestMobileApiPageState extends State<TestMobileApiPage> {
  final _dio = Dio(
    BaseOptions(
      // DISABLED FOR PUBLIC GITHUB VERSION:
      // Real server URL has been disabled. This test page does not connect to any live server.
      baseUrl: 'https://disabled-api.example.com',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  String _result = 'اضغط على زر لاختبار الـ API';
  bool _loading = false;

  Future<void> _testFetch() async {
    setState(() {
      _loading = true;
      _result = 'جاري الاتصال...';
    });

    try {
      final response = await _dio.get(
        '/api/mobile-sync/fetch',
        queryParameters: {
          'table': 'sy_benaa_application',
          'database': 'u983550065_sy_test',
          'page': 1,
          'per_page': 5,
        },
      );

      setState(() {
        _result = 'نجح! Status: ${response.statusCode}\n\n'
            'Data: ${response.data}';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _result = 'فشل! Error:\n$e';
        _loading = false;
      });
    }
  }

  Future<void> _testDatabaseInfo() async {
    setState(() {
      _loading = true;
      _result = 'جاري الاتصال...';
    });

    try {
      final response = await _dio.get(
        '/api/mobile-sync/database/info',
        queryParameters: {'database': 'u983550065_sy_test'},
      );

      setState(() {
        _result = 'نجح! Status: ${response.statusCode}\n\n'
            'Data: ${response.data}';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _result = 'فشل! Error:\n$e';
        _loading = false;
      });
    }
  }

  Future<void> _testTables() async {
    setState(() {
      _loading = true;
      _result = 'جاري الاتصال...';
    });

    try {
      final response = await _dio.get(
        '/api/mobile-sync/database/tables',
        queryParameters: {'database': 'u983550065_sy_test'},
      );

      setState(() {
        _result = 'نجح! Status: ${response.statusCode}\n\n'
            'Data: ${response.data}';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _result = 'فشل! Error:\n$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Mobile API')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'اختبار Mobile Sync API',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _testFetch,
              child: const Text('Test /fetch endpoint'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _testDatabaseInfo,
              child: const Text('Test /database/info endpoint'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _testTables,
              child: const Text('Test /database/tables endpoint'),
            ),
            const SizedBox(height: 20),
            if (_loading) const Center(child: CircularProgressIndicator()),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _result,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
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
