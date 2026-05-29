import 'package:flutter/material.dart';

class SponsorshipCandidateReviewPage extends StatelessWidget {
  const SponsorshipCandidateReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مراجعة مرشحي الكفالة')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('شاشة مبدئية: مراجعة مرشحي الكفالة'),
            SizedBox(height: 8),
            Text('- مطابقة مستفيد موجود'),
            Text('- إنشاء مستفيد جديد مع رقم Cedar'),
            Text('- إنشاء سجل كفالة مرتبط'),
          ],
        ),
      ),
    );
  }
}
