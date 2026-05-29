import 'package:flutter/material.dart';

class BeneficiarySponsorshipsTabStub extends StatelessWidget {
  const BeneficiarySponsorshipsTabStub({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('تبويب الكفالات للمستفيد (مبدئي)'),
            SizedBox(height: 8),
            Text('سيعرض الكفالات الحالية ويسمح بإضافة كفالة جديدة.'),
          ],
        ),
      ),
    );
  }
}
