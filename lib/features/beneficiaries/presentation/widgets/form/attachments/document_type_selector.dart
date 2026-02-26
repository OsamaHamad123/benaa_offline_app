import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../taxonomies/domain/entities/taxonomy.dart';
import '../../../../../taxonomies/domain/entities/taxonomy_group.dart';
import '../../../../../taxonomies/presentation/providers/taxonomy_bridge_providers.dart';
import '../../../../../../core/sync/presentation/providers/sync_providers.dart' as sync_providers;

/// 🎨 Document Type Selector Widget
///
/// Dropdown منظم لاختيار نوع الوثيقة من التصنيفات الديناميكية
class DocumentTypeSelector extends ConsumerWidget {
  final String? selectedType;
  final ValueChanged<String?> onChanged;
  final String? label;
  final bool isRequired;

  const DocumentTypeSelector({
    required this.onChanged,
    super.key,
    this.selectedType,
    this.label,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final documentTypesAsync = ref.watch(
      bridgeTaxonomiesByGroupOnceProvider(TaxonomyGroup.documentType),
    );
    final options = documentTypesAsync.maybeWhen<List<Taxonomy>>(
      data: (value) => value,
      orElse: () => const <Taxonomy>[],
    );
    final isLoading = documentTypesAsync.isLoading && !documentTypesAsync.hasValue;
    final hasError = documentTypesAsync.hasError;
    final hasSelectedTypeInOptions = selectedType != null && options.any((type) => type.code == selectedType);
    final effectiveSelectedType = hasSelectedTypeInOptions ? selectedType : null;

    Future<void> retryLoad() async {
      ref.invalidate(bridgeTaxonomiesByGroupOnceProvider(TaxonomyGroup.documentType));
    }

    Future<void> syncAndReload() async {
      await ref.read(sync_providers.syncControllerProvider.notifier).deltaSync('taxonomies');
      await retryLoad();
    }

    if (isLoading) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: label ?? 'نوع الوثيقة ${isRequired ? '*' : ''}',
          prefixIcon: const Icon(Icons.description_rounded),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('جاري تحميل أنواع الوثائق...'),
            SizedBox(height: 8.h),
            const LinearProgressIndicator(),
          ],
        ),
      );
    }

    final dropdown = DropdownButtonFormField<String>(
      initialValue: effectiveSelectedType,
      decoration: InputDecoration(
        labelText: label ?? 'نوع الوثيقة ${isRequired ? '*' : ''}',
        prefixIcon: const Icon(Icons.description_rounded),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      items: options.map((type) {
        return DropdownMenuItem(
          value: type.code,
          child: Row(
            children: [
              Icon(Icons.description_rounded, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  type.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: options.isEmpty ? null : onChanged,
      disabledHint: const Text('لا توجد أنواع وثائق متاحة حالياً'),
      validator: isRequired ? (value) => value == null ? 'يرجى اختيار نوع الوثيقة' : null : null,
    );

    if (options.isNotEmpty) return dropdown;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        dropdown,
        SizedBox(height: 8.h),
        Text(
          hasError ? 'تعذر تحميل هذا التصنيف حالياً' : 'لا توجد بيانات لهذا التصنيف',
          style: theme.textTheme.bodySmall,
        ),
        SizedBox(height: 6.h),
        Wrap(
          spacing: 8.w,
          children: [
            OutlinedButton.icon(
              onPressed: retryLoad,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
            FilledButton.tonalIcon(
              onPressed: syncAndReload,
              icon: const Icon(Icons.sync),
              label: const Text('مزامنة التصنيفات'),
            ),
          ],
        ),
      ],
    );
  }
}

/// 👤 Person Type Selector (صاحب الملف / أفراد الأسرة / المتوفين)
class PersonTypeSelector extends StatelessWidget {
  final String? selectedPerson;
  final ValueChanged<String?> onChanged;
  final List<String> availablePersons;
  final String? label;

  const PersonTypeSelector({
    required this.onChanged,
    required this.availablePersons,
    super.key,
    this.selectedPerson,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalizedPersons = <String>[];
    final seenPersons = <String>{};

    for (final person in availablePersons) {
      final normalized = person.trim().replaceAll(RegExp(r'\s+'), ' ');
      if (normalized.isEmpty) continue;
      if (normalized == 'file_owner' || normalized == 'divider_family') continue;
      if (seenPersons.add(normalized)) {
        normalizedPersons.add(normalized);
      }
    }

    final validPersonValues = <String>{
      'file_owner',
      ...normalizedPersons,
    };
    final selectedPersonValue = validPersonValues.contains(selectedPerson) ? selectedPerson : null;

    return DropdownButtonFormField<String>(
      initialValue: selectedPersonValue,
      decoration: InputDecoration(
        labelText: label ?? 'اختر الشخص *',
        prefixIcon: const Icon(Icons.person_pin_rounded),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      items: [
        const DropdownMenuItem(
          value: 'file_owner',
          child: Row(
            children: [
              Icon(Icons.account_circle_rounded),
              SizedBox(width: 8),
              Text('صاحب الملف'),
            ],
          ),
        ),
        if (normalizedPersons.isNotEmpty)
          const DropdownMenuItem(
            value: 'divider_family',
            enabled: false,
            child: Divider(),
          ),
        ...normalizedPersons.map((person) {
          return DropdownMenuItem(
            value: person,
            child: Row(
              children: [
                const Icon(Icons.family_restroom_rounded),
                SizedBox(width: 8.w),
                Expanded(child: Text(person)),
              ],
            ),
          );
        }),
      ],
      onChanged: onChanged,
    );
  }
}
