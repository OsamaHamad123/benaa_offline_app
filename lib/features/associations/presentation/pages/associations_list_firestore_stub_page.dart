import 'package:flutter/material.dart';

class AssociationsListFirestoreStubPage extends StatelessWidget {
  const AssociationsListFirestoreStubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الجمعيات - Firestore')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('شاشة مبدئية: قائمة الجمعيات'),
            SizedBox(height: 8),
            Text('المتاح حالياً:'),
            Text('- عرض الجمعيات من local cache'),
            Text('- إضافة/تعديل جمعية'),
            Text('- عرض جهات الاتصال'),
          ],
        ),
      ),
    );
  }
}
