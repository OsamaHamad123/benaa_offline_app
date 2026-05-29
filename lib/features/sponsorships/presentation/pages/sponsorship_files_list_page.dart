import 'package:flutter/material.dart';

class SponsorshipFilesListPage extends StatelessWidget {
  const SponsorshipFilesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ملفات الكفالات')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('شاشة مبدئية: ملفات الكفالات'),
            SizedBox(height: 8),
            Text('- قائمة الملفات المستلمة من الجمعيات'),
            Text('- إنشاء ملف يدوي'),
            Text('- استيراد المرشحين لاحقاً'),
          ],
        ),
      ),
    );
  }
}
