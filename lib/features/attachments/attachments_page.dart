import 'package:flutter/material.dart';

class AttachmentsPage extends StatelessWidget {
  final String beneficiaryId;

  const AttachmentsPage({super.key, required this.beneficiaryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المرفقات')),
      body: Center(child: Text('مرفقات المستفيد: $beneficiaryId')),
    );
  }
}
