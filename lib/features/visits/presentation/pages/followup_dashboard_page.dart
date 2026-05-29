import 'package:flutter/material.dart';

class FollowupDashboardPage extends StatelessWidget {
  const FollowupDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('لوحة المتابعات')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('شاشة مبدئية: لوحة المتابعات'),
            SizedBox(height: 8),
            Text('- المتابعات المفتوحة'),
            Text('- مستحقة اليوم'),
            Text('- متأخرة'),
          ],
        ),
      ),
    );
  }
}
