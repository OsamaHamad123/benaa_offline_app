import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:benaa_offline_app/features/taxonomies/domain/entities/taxonomy_group.dart';
import 'package:benaa_offline_app/features/taxonomies/presentation/providers/taxonomy_bridge_providers.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/utils/taxonomy_value_resolver.dart';
import 'selectable_chip.dart';

/// 💀 Death Cause Selector
///
/// محدد سبب الوفاة (طبيعية، مرض، حادث، مغدور، أخرى)
class DeathCauseSelector extends ConsumerWidget {
  final int? selectedCause;
  final ValueChanged<int> onCauseSelected;

  const DeathCauseSelector({
    required this.selectedCause,
    required this.onCauseSelected,
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
      bridgeTaxonomiesByGroupOnceProvider(TaxonomyGroup.deathReason),
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
        group: TaxonomyGroup.deathReason,
        source: 'death_cause_selector',
      );
      if (resolvedValue == null) continue;
      resolvedCount++;

      chips.add(
        SelectableChip(
          label: taxonomy.label,
          value: resolvedValue,
          groupValue: selectedCause,
          onTap: onCauseSelected,
          color: palette[index % palette.length],
        ),
      );
    }

    TaxonomyValueResolver.logSummary(
      group: TaxonomyGroup.deathReason,
      source: 'death_cause_selector',
      total: options.length,
      resolved: resolvedCount,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'سبب الوفاة',
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8.0),
        if (chips.isEmpty)
          const Text('لا توجد أسباب وفاة متاحة حالياً')
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
