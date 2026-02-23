import 'package:flutter/material.dart';

class AttachmentsPage extends StatelessWidget {
  final String beneficiaryId;

  const AttachmentsPage({required this.beneficiaryId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المرفقات')),
      body: Center(child: Text('مرفقات المستفيد: $beneficiaryId')),
    );
  }
}
