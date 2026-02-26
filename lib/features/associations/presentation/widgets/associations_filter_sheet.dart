import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_utils_v2.dart';
import '../../../taxonomies/domain/entities/taxonomy_group.dart';
import '../../../taxonomies/presentation/providers/taxonomy_bridge_providers.dart';
import '../providers/associations_provider.dart';

/// 🎯 ورقة الفلاتر - Optimized Performance
///
/// Widget منفصل لعرض الفلاتر:
/// - ✅ StatefulWidget مع ValueNotifiers في initState (Performance)
/// - ✅ SafeArea و SingleChildScrollView لحل مشكلة overflow
/// - ✅ Responsive design للموبايل والتابلت
class AssociationsFilterSheet extends StatefulWidget {
  final bool showOnlyActive;
  final String? selectedRepresentativeId;
  final String? selectedCurrency;
  final String? selectedAssociationTypeCode;
  final Function(bool, String?, String?, String?) onApply;

  const AssociationsFilterSheet({
    required this.showOnlyActive,
    required this.selectedRepresentativeId,
    required this.selectedCurrency,
    required this.selectedAssociationTypeCode,
    required this.onApply,
    super.key,
  });

  @override
  State<AssociationsFilterSheet> createState() => _AssociationsFilterSheetState();
}

class _AssociationsFilterSheetState extends State<AssociationsFilterSheet> {
  late final ValueNotifier<bool> showActiveNotifier;
  late final ValueNotifier<String?> selectedRepNotifier;
  late final ValueNotifier<String?> selectedCurrencyNotifier;
  late final ValueNotifier<String?> selectedAssociationTypeNotifier;

  String? _normalizeNullableFilter(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  List<DropdownMenuItem<String?>> _buildCurrencyItems(WidgetRef ref) {
    final taxonomies = ref
        .watch(
          bridgeTaxonomiesByGroupOnceProvider(TaxonomyGroup.currency),
        )
        .maybeWhen(
          data: (items) => items,
          orElse: () => const [],
        );

    if (taxonomies.isEmpty) {
      return const [
        DropdownMenuItem<String?>(value: null, child: Text('الكل')),
        DropdownMenuItem(value: 'IQD', child: Text('دينار عراقي (IQD)')),
        DropdownMenuItem(value: 'USD', child: Text('دولار أمريكي (USD)')),
        DropdownMenuItem(value: 'EUR', child: Text('يورو (EUR)')),
      ];
    }

    final seen = <String>{};
    final items = <DropdownMenuItem<String?>>[
      const DropdownMenuItem<String?>(value: null, child: Text('الكل')),
    ];

    for (final taxonomy in taxonomies) {
      final code = taxonomy.code.trim().toUpperCase();
      if (code.isEmpty || seen.contains(code)) continue;
      seen.add(code);
      items.add(
        DropdownMenuItem<String?>(
          value: code,
          child: Text('${taxonomy.label} ($code)'),
        ),
      );
    }

    return items;
  }

  List<DropdownMenuItem<String?>> _buildAssociationTypeItems(WidgetRef ref) {
    final taxonomies = ref
        .watch(
          bridgeTaxonomiesByGroupResolvedOnceProvider(TaxonomyGroup.associationType),
        )
        .maybeWhen(
          data: (items) => items,
          orElse: () => const [],
        );

    final items = <DropdownMenuItem<String?>>[
      const DropdownMenuItem<String?>(value: null, child: Text('الكل')),
    ];

    for (final taxonomy in taxonomies) {
      final code = _normalizeNullableFilter(taxonomy.code);
      final label = taxonomy.label.trim();
      if (code == null || label.isEmpty) continue;
      items.add(
        DropdownMenuItem<String?>(
          value: code,
          child: Text(label),
        ),
      );
    }

    return items;
  }

  @override
  void initState() {
    super.initState();
    showActiveNotifier = ValueNotifier<bool>(widget.showOnlyActive);
    selectedRepNotifier = ValueNotifier<String?>(_normalizeNullableFilter(widget.selectedRepresentativeId));
    selectedCurrencyNotifier = ValueNotifier<String?>(_normalizeNullableFilter(widget.selectedCurrency));
    selectedAssociationTypeNotifier =
        ValueNotifier<String?>(_normalizeNullableFilter(widget.selectedAssociationTypeCode));
  }

  @override
  void dispose() {
    showActiveNotifier.dispose();
    selectedRepNotifier.dispose();
    selectedCurrencyNotifier.dispose();
    selectedAssociationTypeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isTablet = ResponsiveUtils.isTablet(context);

    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
          left: ResponsiveUtils.mediumSpace,
          right: ResponsiveUtils.mediumSpace,
          top: ResponsiveUtils.mediumSpace,
          bottom: MediaQuery.of(context).viewInsets.bottom + ResponsiveUtils.mediumSpace,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // عنوان
              _buildHeader(context, isTablet),

              SizedBox(height: ResponsiveUtils.largeSpace),

              // فلتر النشطة فقط
              _buildActiveFilterSwitch(colorScheme),

              SizedBox(height: ResponsiveUtils.mediumSpace),

              // فلتر المندوب
              _buildRepresentativeFilter(),

              SizedBox(height: ResponsiveUtils.mediumSpace),

              // فلتر العملة
              _buildCurrencyFilter(),

              SizedBox(height: ResponsiveUtils.mediumSpace),

              // فلتر نوع الجمعية
              _buildAssociationTypeFilter(),

              SizedBox(height: ResponsiveUtils.largeSpace),

              // أزرار الإجراءات
              _buildClearButton(isTablet),

              SizedBox(height: ResponsiveUtils.mediumSpace),

              _buildApplyButton(colorScheme, isTablet),
            ],
          ),
        ),
      ),
    );
  }

  /// عنوان الورقة
  Widget _buildHeader(BuildContext context, bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(
            Icons.close,
            size: ResponsiveUtils.getIconSize(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        Text(
          'الفلاتر',
          style: TextStyle(
            fontSize: isTablet ? ResponsiveUtils.headingFont : ResponsiveUtils.titleFont,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 48.w),
      ],
    );
  }

  /// فلتر الجمعيات النشطة
  Widget _buildActiveFilterSwitch(ColorScheme colorScheme) {
    return ValueListenableBuilder<bool>(
      valueListenable: showActiveNotifier,
      builder: (context, showActive, _) => SwitchListTile(
        value: showActive,
        onChanged: (value) => showActiveNotifier.value = value,
        title: const Text('عرض الجمعيات النشطة فقط', textAlign: TextAlign.right),
        activeThumbColor: colorScheme.primary,
      ),
    );
  }

  /// فلتر المندوب
  Widget _buildRepresentativeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'تصفية حسب المندوب',
          style: TextStyle(
            fontSize: ResponsiveUtils.bodyFont,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.right,
        ),
        SizedBox(height: ResponsiveUtils.smallSpace),
        Consumer(
          builder: (context, ref, child) {
            final representatives = ref.watch(associationsProvider).representatives;
            final uniqueReps = <String, dynamic>{};
            for (final rep in representatives) {
              final id = _normalizeNullableFilter(rep.id);
              if (id == null) continue;
              uniqueReps.putIfAbsent(id, () => rep);
            }

            return ValueListenableBuilder<String?>(
              valueListenable: selectedRepNotifier,
              builder: (context, selectedRep, _) => DropdownButtonFormField<String?>(
                initialValue: _normalizeNullableFilter(selectedRep),
                decoration: InputDecoration(
                  hintText: 'اختر المندوب',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.mediumSpace,
                    vertical: ResponsiveUtils.smallSpace,
                  ),
                ),
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('الكل')),
                  ...uniqueReps.values.map(
                    (rep) => DropdownMenuItem(
                      value: _normalizeNullableFilter(rep.id),
                      child: Text(rep.name, textAlign: TextAlign.right),
                    ),
                  ),
                ],
                onChanged: (value) => selectedRepNotifier.value = _normalizeNullableFilter(value),
              ),
            );
          },
        ),
      ],
    );
  }

  /// فلتر العملة
  Widget _buildCurrencyFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'تصفية حسب العملة',
          style: TextStyle(
            fontSize: ResponsiveUtils.bodyFont,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.right,
        ),
        SizedBox(height: ResponsiveUtils.smallSpace),
        Consumer(
          builder: (context, ref, _) {
            final currencyItems = _buildCurrencyItems(ref);
            return ValueListenableBuilder<String?>(
              valueListenable: selectedCurrencyNotifier,
              builder: (context, selectedCurrency, _) {
                final normalized = _normalizeNullableFilter(selectedCurrency);
                final hasValue = normalized == null || currencyItems.any((item) => item.value == normalized);
                final safeValue = hasValue ? normalized : null;

                if (safeValue != normalized) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      selectedCurrencyNotifier.value = null;
                    }
                  });
                }

                return DropdownButtonFormField<String?>(
                  initialValue: safeValue,
                  decoration: InputDecoration(
                    hintText: 'اختر العملة',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.mediumSpace,
                      vertical: ResponsiveUtils.smallSpace,
                    ),
                  ),
                  items: currencyItems,
                  onChanged: (value) => selectedCurrencyNotifier.value = _normalizeNullableFilter(value),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAssociationTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'تصفية حسب نوع الجمعية',
          style: TextStyle(
            fontSize: ResponsiveUtils.bodyFont,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.right,
        ),
        SizedBox(height: ResponsiveUtils.smallSpace),
        Consumer(
          builder: (context, ref, _) {
            final typeItems = _buildAssociationTypeItems(ref);
            return ValueListenableBuilder<String?>(
              valueListenable: selectedAssociationTypeNotifier,
              builder: (context, selectedType, _) {
                final normalized = _normalizeNullableFilter(selectedType);
                final hasValue = normalized == null || typeItems.any((item) => item.value == normalized);
                final safeValue = hasValue ? normalized : null;

                if (safeValue != normalized) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      selectedAssociationTypeNotifier.value = null;
                    }
                  });
                }

                return DropdownButtonFormField<String?>(
                  initialValue: safeValue,
                  decoration: InputDecoration(
                    hintText: 'اختر نوع الجمعية',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.mediumSpace,
                      vertical: ResponsiveUtils.smallSpace,
                    ),
                  ),
                  items: typeItems,
                  onChanged: (value) => selectedAssociationTypeNotifier.value = _normalizeNullableFilter(value),
                );
              },
            );
          },
        ),
      ],
    );
  }

  /// زر مسح الفلاتر
  Widget _buildClearButton(bool isTablet) {
    return OutlinedButton.icon(
      onPressed: () {
        HapticFeedback.lightImpact();
        showActiveNotifier.value = true;
        selectedRepNotifier.value = null;
        selectedCurrencyNotifier.value = null;
        selectedAssociationTypeNotifier.value = null;
      },
      icon: Icon(
        Icons.clear_all,
        size: isTablet ? 22.r : 20.r,
      ),
      label: Text(
        'مسح الفلاتر',
        style: TextStyle(
          fontSize: ResponsiveUtils.bodyFont,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 16.h : 14.h,
          horizontal: ResponsiveUtils.mediumSpace,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
        ),
      ),
    );
  }

  /// زر تطبيق الفلاتر
  Widget _buildApplyButton(ColorScheme colorScheme, bool isTablet) {
    return ElevatedButton(
      onPressed: () {
        HapticFeedback.mediumImpact();
        widget.onApply(
          showActiveNotifier.value,
          selectedRepNotifier.value,
          selectedCurrencyNotifier.value,
          selectedAssociationTypeNotifier.value,
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 18.h : 16.h,
          horizontal: ResponsiveUtils.largeSpace,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
        ),
      ),
      child: Text(
        'تطبيق الفلاتر',
        style: TextStyle(
          fontSize: ResponsiveUtils.mediumFont,
          color: Colors.white,
        ),
      ),
    );
  }
}
