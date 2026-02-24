import 'package:benaa_offline_app/features/taxonomies/domain/entities/taxonomy_group.dart';
import 'package:benaa_offline_app/features/taxonomies/presentation/providers/taxonomy_bridge_providers.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/utils/taxonomy_value_resolver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'document_card.dart';

/// 📄 Document Type Selector for Family Members
///
/// محدد نوع الوثيقة (شهادة وفاة، إفادة شهيد)
class DocumentTypeSelector extends ConsumerWidget {
  final int? selectedType;
  final ValueChanged<int> onTypeSelected;

  const DocumentTypeSelector({
    required this.selectedType,
    required this.onTypeSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxonomiesAsync = ref.watch(
      bridgeTaxonomiesByGroupOnceProvider(TaxonomyGroup.documentType),
    );
    final options = taxonomiesAsync.maybeWhen(
      data: (value) => value,
      orElse: () => const [],
    );

    final dynamicCards = <Widget>[];
    var resolvedCount = 0;
    for (var index = 0; index < options.length; index++) {
      final taxonomy = options[index];
      final resolvedValue = TaxonomyValueResolver.resolveToInt(
        code: taxonomy.code,
        id: taxonomy.id,
        group: TaxonomyGroup.documentType,
        source: 'document_type_selector_family',
      );
      if (resolvedValue == null) continue;
      resolvedCount++;

      dynamicCards.add(
        Expanded(
          child: DocumentCard(
            label: taxonomy.label,
            icon: Icons.description,
            value: resolvedValue,
            groupValue: selectedType,
            onTap: onTypeSelected,
          ),
        ),
      );

      if (index < options.length - 1) {
        dynamicCards.add(const SizedBox(width: 8.0));
      }
    }

    TaxonomyValueResolver.logSummary(
      group: TaxonomyGroup.documentType,
      source: 'document_type_selector_family',
      total: options.length,
      resolved: resolvedCount,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'نوع الوثيقة',
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8.0),
        if (dynamicCards.isEmpty) const Text('لا توجد أنواع وثائق متاحة حالياً') else Row(children: dynamicCards),
      ],
    );
  }
}
