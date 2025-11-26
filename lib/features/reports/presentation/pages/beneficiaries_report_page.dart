import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/db/drift_database.dart';
import '../../../../core/providers/providers.dart';

class BeneficiariesReportPage extends ConsumerWidget {
  const BeneficiariesReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير المستفيدين'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Beneficiary>>(
        future: database.beneficiariesDao.getAllBeneficiaries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          }

          final beneficiaries = snapshot.data ?? [];

          if (beneficiaries.isEmpty) {
            return const Center(child: Text('لا يوجد مستفيدين'));
          }

          return ListView.builder(
            itemCount: beneficiaries.length,
            itemBuilder: (context, index) {
              final b = beneficiaries[index];
              return ListTile(
                title: Text(b.fullName),
                subtitle: Text('الرقم الوطني: ${b.idNumber}'),
                trailing: Text(b.syncState),
              );
            },
          );
        },
      ),
    );
  }
}
