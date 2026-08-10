import 'package:flutter/material.dart';
import '../../data/db/drift_database.dart';

/// 🔀 Conflict Resolution Strategies
enum ConflictStrategy {
  serverWins, // السيرفر يكسب دائماً
  localWins, // المحلي يكسب دائماً
  newerWins, // الأحدث يكسب
  askUser, // اسأل المستخدم
}

/// Conflict Resolution Result
class ConflictResolution<T> {
  final T resolvedData;
  final ConflictStrategy strategyUsed;
  final bool userInterventionRequired;

  ConflictResolution({
    required this.resolvedData,
    required this.strategyUsed,
    this.userInterventionRequired = false,
  });
}

/// 🔀 Conflict Resolver - Smart Conflict Resolution
class ConflictResolver {
  final ConflictStrategy defaultStrategy;

  ConflictResolver({this.defaultStrategy = ConflictStrategy.newerWins});

  /// Resolve Beneficiary Conflict
  Future<ConflictResolution<Beneficiary>> resolveBeneficiary({
    required Beneficiary localVersion,
    required Map<String, dynamic> serverVersion,
    ConflictStrategy? strategy,
  }) async {
    final resolveStrategy = strategy ?? defaultStrategy;

    switch (resolveStrategy) {
      case ConflictStrategy.serverWins:
        return ConflictResolution(
          resolvedData: _beneficiaryFromJson(serverVersion),
          strategyUsed: ConflictStrategy.serverWins,
        );

      case ConflictStrategy.localWins:
        return ConflictResolution(
          resolvedData: localVersion,
          strategyUsed: ConflictStrategy.localWins,
        );

      case ConflictStrategy.newerWins:
        final serverUpdatedAt = DateTime.parse(
          serverVersion['updated_at'] as String,
        );
        final localUpdated = localVersion.updatedAt ?? DateTime(2000);
        final isServerNewer = serverUpdatedAt.isAfter(localUpdated);

        return ConflictResolution(
          resolvedData: isServerNewer
              ? _beneficiaryFromJson(serverVersion)
              : localVersion,
          strategyUsed: ConflictStrategy.newerWins,
        );

      case ConflictStrategy.askUser:
        return ConflictResolution(
          resolvedData: localVersion, // Temporary - requires UI
          strategyUsed: ConflictStrategy.askUser,
          userInterventionRequired: true,
        );
    }
  }

  /// Show Conflict Dialog to User
  Future<Beneficiary?> showConflictDialog({
    required BuildContext context,
    required Beneficiary localVersion,
    required Beneficiary serverVersion,
  }) async {
    return showDialog<Beneficiary>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 12),
            Text('تعارض في البيانات'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'تم تعديل هذا السجل على الجهاز والسيرفر. اختر النسخة التي تريد الاحتفاظ بها:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              _buildVersionCard(
                title: 'النسخة المحلية',
                data: localVersion,
                icon: Icons.smartphone,
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildVersionCard(
                title: 'نسخة السيرفر',
                data: serverVersion,
                icon: Icons.cloud,
                color: Colors.green,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(localVersion),
            child: const Text('المحلية'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(serverVersion),
            child: const Text('السيرفر'),
          ),
          ElevatedButton(
            onPressed: () {
              final localTime = localVersion.updatedAt ?? DateTime(2000);
              final serverTime = serverVersion.updatedAt ?? DateTime(2000);
              Navigator.of(context).pop(
                localTime.isAfter(serverTime) ? localVersion : serverVersion,
              );
            },
            child: const Text('الأحدث'),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionCard({
    required String title,
    required Beneficiary data,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('الاسم: ${data.fullName}'),
          Text('المعرف: ${data.id}'),
          Text(
            'آخر تعديل: ${_formatDate(data.updatedAt ?? DateTime.now())}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Helper to convert JSON to Beneficiary
  Beneficiary _beneficiaryFromJson(Map<String, dynamic> json) {
    // TODO: Implement proper JSON to Beneficiary conversion
    // This is a placeholder - adjust based on your actual model
    throw UnimplementedError('Implement JSON to Beneficiary conversion');
  }

  /// Merge Strategy - Intelligent field-level merge
  Beneficiary mergeIntelligent({
    required Beneficiary localVersion,
    required Beneficiary serverVersion,
  }) {
    // Take newer version for each field
    final localTime = localVersion.updatedAt ?? DateTime(2000);
    final serverTime = serverVersion.updatedAt ?? DateTime(2000);

    return localVersion.copyWith(
      fullName: localTime.isAfter(serverTime)
          ? localVersion.fullName
          : serverVersion.fullName,
      // Add more fields as needed...
    );
  }
}
