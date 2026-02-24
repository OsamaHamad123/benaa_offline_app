import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:benaa_offline_app/features/taxonomies/domain/entities/taxonomy_group.dart';
import 'package:benaa_offline_app/features/taxonomies/presentation/providers/taxonomy_bridge_providers.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/utils/taxonomy_value_resolver.dart';
import '../../../../../core/utils/responsive_utils_v2.dart';
import '../../../../../core/utils/haptic_patterns.dart';
import '../../providers/list/filters_provider.dart';
import '../../providers/list/beneficiaries_list_state.dart';
import '../../providers/list/beneficiaries_list_provider.dart';
import '../../../../../core/design_system/app_animations.dart';

/// 🔍 Filters Bottom Sheet
class FiltersBottomSheet extends ConsumerStatefulWidget {
  const FiltersBottomSheet({super.key});

  @override
  ConsumerState<FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends ConsumerState<FiltersBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(filtersProvider);
    final sectionsAsync = ref.watch(
      bridgeTaxonomiesByGroupOnceProvider(TaxonomyGroup.section),
    );
    final sections = sectionsAsync.maybeWhen(
      data: (value) => value,
      orElse: () => const [],
    );
    final theme = Theme.of(context);
    final rv = ResponsiveUtils.getValues(context);

    final sectionChips = <Widget>[
      _FilterChip(
        label: 'الكل',
        isSelected: filters.categoryId == null,
        onTap: () {
          HapticPatterns.selection();
          ref.read(filtersProvider.notifier).setCategory(null);
          ref.read(beneficiariesListProvider.notifier).refresh();
        },
        rv: rv,
      ),
    ];

    var resolvedSections = 0;
    for (final section in sections) {
      final value = TaxonomyValueResolver.resolveToInt(
        code: section.code,
        id: section.id,
        group: TaxonomyGroup.section,
        source: 'filters_bottom_sheet',
      );
      if (value == null) continue;
      resolvedSections++;

      sectionChips.add(
        _FilterChip(
          label: section.label,
          isSelected: filters.categoryId == value,
          onTap: () {
            HapticPatterns.selection();
            ref.read(filtersProvider.notifier).setCategory(value);
            ref.read(beneficiariesListProvider.notifier).refresh();
          },
          rv: rv,
        ),
      );
    }

    TaxonomyValueResolver.logSummary(
      group: TaxonomyGroup.section,
      source: 'filters_bottom_sheet',
      total: sections.length,
      resolved: resolvedSections,
    );

    return SlideTransitionWidget(
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(rv.isTablet ? 28 : 24),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: rv.isTablet ? 24 : 20,
                vertical: rv.isTablet ? 10 : 8,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: theme.colorScheme.primary,
                    size: rv.isTablet ? 26 : 24,
                  ),
                  SizedBox(width: rv.isTablet ? 14 : 12),
                  Text(
                    'الفلاتر',
                    style: TextStyle(
                      fontSize: rv.isTablet ? 22 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (filters.hasActiveFilters)
                    TextButton(
                      onPressed: () {
                        HapticPatterns.selection();
                        ref.read(filtersProvider.notifier).clearFilters();
                        ref.read(beneficiariesListProvider.notifier).refresh();
                      },
                      child: const Text('مسح الكل'),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      HapticPatterns.selection();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(rv.isTablet ? 24 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Filter
                    _buildSectionTitle('الفئة', rv),
                    SizedBox(height: rv.isTablet ? 14 : 12),
                    Wrap(
                      spacing: rv.isTablet ? 10 : 8,
                      runSpacing: rv.isTablet ? 10 : 8,
                      children: sectionChips,
                    ),
                    if (sectionChips.length == 1) ...[
                      SizedBox(height: rv.isTablet ? 10 : 8),
                      Text(
                        'لا توجد فئات ديناميكية متاحة حالياً',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],

                    SizedBox(height: rv.isTablet ? 28 : 24),

                    // Quick Filters
                    _buildSectionTitle('فلاتر سريعة', rv),
                    SizedBox(height: rv.isTablet ? 14 : 12),
                    _SwitchTile(
                      title: 'معلق المزامنة فقط',
                      value: filters.onlyPendingSync,
                      icon: Icons.cloud_off,
                      onChanged: (value) {
                        HapticPatterns.selection();
                        ref.read(filtersProvider.notifier).togglePendingSync();
                        ref.read(beneficiariesListProvider.notifier).refresh();
                      },
                      rv: rv,
                    ),
                    _SwitchTile(
                      title: 'مع رقم هاتف فقط',
                      value: filters.onlyWithPhone,
                      icon: Icons.phone,
                      onChanged: (value) {
                        HapticPatterns.selection();
                        ref.read(filtersProvider.notifier).toggleWithPhone();
                        ref.read(beneficiariesListProvider.notifier).refresh();
                      },
                      rv: rv,
                    ),
                    _SwitchTile(
                      title: 'مع موقع محدد فقط',
                      value: filters.onlyWithLocation,
                      icon: Icons.location_on,
                      onChanged: (value) {
                        HapticPatterns.selection();
                        ref.read(filtersProvider.notifier).toggleWithLocation();
                        ref.read(beneficiariesListProvider.notifier).refresh();
                      },
                      rv: rv,
                    ),

                    SizedBox(height: rv.isTablet ? 28 : 24),

                    // Sort
                    _buildSectionTitle('الترتيب', rv),
                    SizedBox(height: rv.isTablet ? 14 : 12),
                    Wrap(
                      spacing: rv.isTablet ? 10 : 8,
                      runSpacing: rv.isTablet ? 10 : 8,
                      children: SortBy.values.map((sort) {
                        final isSelected = filters.sortBy == sort;
                        return _FilterChip(
                          label: sort.label,
                          isSelected: isSelected,
                          icon: isSelected ? (filters.sortAscending ? Icons.arrow_upward : Icons.arrow_downward) : null,
                          onTap: () {
                            HapticPatterns.selection();
                            if (isSelected) {
                              ref.read(filtersProvider.notifier).toggleSortDirection();
                            } else {
                              ref.read(filtersProvider.notifier).setSorting(sort, true);
                            }
                            ref.read(beneficiariesListProvider.notifier).refresh();
                          },
                          rv: rv,
                        );
                      }).toList(),
                    ),

                    SizedBox(height: rv.isTablet ? 36 : 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ResponsiveValues rv) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: TextStyle(
        fontSize: rv.isTablet ? 18 : 16,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// Filter Chip
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final ResponsiveValues rv;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.rv,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final chipColor = theme.colorScheme.primary;
    final borderRadius = rv.isTablet ? 24.0 : 20.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: rv.isTablet ? 18 : 16,
          vertical: rv.isTablet ? 12 : 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isSelected ? chipColor : colorScheme.outlineVariant,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: rv.isTablet ? 18 : 16,
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: rv.isTablet ? 8 : 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: rv.isTablet ? 16 : 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Switch Tile
class _SwitchTile extends StatelessWidget {
  final String title;
  final bool value;
  final IconData icon;
  final ValueChanged<bool> onChanged;
  final ResponsiveValues rv;

  const _SwitchTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.onChanged,
    required this.rv,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: rv.isTablet ? 10 : 8),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(rv.isTablet ? 14 : 12),
      ),
      child: SwitchListTile(
        title: Row(
          children: [
            Icon(icon, size: rv.isTablet ? 22 : 20, color: colorScheme.onSurfaceVariant),
            SizedBox(width: rv.isTablet ? 14 : 12),
            Text(title, style: TextStyle(fontSize: rv.isTablet ? 16 : 14)),
          ],
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
