import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/db/drift_database.dart';
import 'core/providers/providers.dart';

/// Temporary widget to check database beneficiaries
class TempDatabaseCheck extends ConsumerWidget {
  const TempDatabaseCheck({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Database Check')),
      body: FutureBuilder<List<Beneficiary>>(
        future: database.beneficiariesDao.getAllBeneficiaries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}\n\n${snapshot.stackTrace}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final beneficiaries = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Beneficiaries: ${beneficiaries.length}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (beneficiaries.isEmpty)
                  const Text(
                    '⚠️ NO BENEFICIARIES IN DATABASE',
                    style: TextStyle(fontSize: 18, color: Colors.orange),
                  )
                else ...[
                  const Text(
                    'Sample Data (First 5):',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...beneficiaries
                      .take(5)
                      .map(
                        (b) => Card(
                          child: ListTile(
                            title: Text(b.fullName),
                            subtitle: Text(
                              'ID: ${b.idNumber}\nSync: ${b.syncState}\nCreated: ${b.createdAt}',
                            ),
                          ),
                        ),
                      ),
                  const SizedBox(height: 16),
                  Text(
                    'Sync States Distribution:',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ...beneficiaries
                      .fold<Map<String, int>>({}, (map, b) {
                        map[b.syncState] = (map[b.syncState] ?? 0) + 1;
                        return map;
                      })
                      .entries
                      .map((e) => Text('  ${e.key}: ${e.value}')),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
