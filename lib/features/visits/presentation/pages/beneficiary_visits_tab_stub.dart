import 'package:flutter/material.dart';

class BeneficiaryVisitsTabStub extends StatelessWidget {
  const BeneficiaryVisitsTabStub({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('تبويب الزيارات للمستفيد (مبدئي)'),
            SizedBox(height: 8),
            Text('سيعرض السجل، جدولة زيارة، إكمال زيارة، وإنشاء متابعة.'),
          ],
        ),
      ),
    );
  }
}
