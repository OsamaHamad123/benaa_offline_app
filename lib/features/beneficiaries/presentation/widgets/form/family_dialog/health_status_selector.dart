import 'package:benaa_offline_app/features/taxonomies/domain/entities/taxonomy_group.dart';
import 'package:benaa_offline_app/features/taxonomies/presentation/providers/taxonomy_bridge_providers.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/utils/taxonomy_value_resolver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'selectable_chip.dart';

/// 🏥 Health Status Selector
///
/// محدد الحالة الصحية (سليم، مريض، مزمن، معاق)
class HealthStatusSelector extends ConsumerWidget {
  final int? selectedStatus;
  final ValueChanged<int> onStatusSelected;

  const HealthStatusSelector({
    required this.selectedStatus,
    required this.onStatusSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final palette = <Color>[
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      colorScheme.error,
    ];

    final taxonomiesAsync = ref.watch(
      bridgeTaxonomiesByGroupOnceProvider(TaxonomyGroup.healthStatus),
    );
    final options = taxonomiesAsync.maybeWhen(
      data: (value) => value,
      orElse: () => const [],
    );

    final chips = <Widget>[];
    var resolvedCount = 0;
    for (var index = 0; index < options.length; index++) {
      final taxonomy = options[index];
      final resolvedValue = TaxonomyValueResolver.resolveToInt(
        code: taxonomy.code,
        id: taxonomy.id,
        group: TaxonomyGroup.healthStatus,
        source: 'health_status_selector',
      );
      if (resolvedValue == null) continue;
      resolvedCount++;

      chips.add(
        SelectableChip(
          label: taxonomy.label,
          value: resolvedValue,
          groupValue: selectedStatus,
          onTap: onStatusSelected,
          color: palette[index % palette.length],
        ),
      );
    }

    TaxonomyValueResolver.logSummary(
      group: TaxonomyGroup.healthStatus,
      source: 'health_status_selector',
      total: options.length,
      resolved: resolvedCount,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الحالة الصحية',
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8.0),
        if (chips.isEmpty)
          const Text('لا توجد حالات صحية متاحة حالياً')
        else
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            children: chips,
          ),
      ],
    );
  }
}
