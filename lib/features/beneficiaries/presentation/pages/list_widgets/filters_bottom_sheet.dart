import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final theme = Theme.of(context);
    final rv = ResponsiveUtils.getValues(context);

    return SlideTransitionWidget(
      begin: const Offset(0, 1),
      end: Offset.zero,
      duration: AppDurations.normal,
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
                color: Colors.grey.shade300,
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
                      children: [
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
                        _FilterChip(
                          label: 'يتيم',
                          isSelected: filters.categoryId == 1,
                          onTap: () {
                            HapticPatterns.selection();
                            ref.read(filtersProvider.notifier).setCategory(1);
                            ref.read(beneficiariesListProvider.notifier).refresh();
                          },
                          color: Colors.blue,
                          rv: rv,
                        ),
                        _FilterChip(
                          label: 'أرملة',
                          isSelected: filters.categoryId == 2,
                          onTap: () {
                            HapticPatterns.selection();
                            ref.read(filtersProvider.notifier).setCategory(2);
                            ref.read(beneficiariesListProvider.notifier).refresh();
                          },
                          color: Colors.purple,
                          rv: rv,
                        ),
                        _FilterChip(
                          label: 'فقير',
                          isSelected: filters.categoryId == 3,
                          onTap: () {
                            HapticPatterns.selection();
                            ref.read(filtersProvider.notifier).setCategory(3);
                            ref.read(beneficiariesListProvider.notifier).refresh();
                          },
                          color: Colors.orange,
                          rv: rv,
                        ),
                        _FilterChip(
                          label: 'معاق',
                          isSelected: filters.categoryId == 4,
                          onTap: () {
                            HapticPatterns.selection();
                            ref.read(filtersProvider.notifier).setCategory(4);
                            ref.read(beneficiariesListProvider.notifier).refresh();
                          },
                          color: Colors.red,
                          rv: rv,
                        ),
                      ],
                    ),

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
    return Text(
      title,
      style: TextStyle(
        fontSize: rv.isTablet ? 18 : 16,
        fontWeight: FontWeight.bold,
        color: Colors.grey[700],
      ),
    );
  }
}

/// Filter Chip
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;
  final IconData? icon;
  final ResponsiveValues rv;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.rv,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.primary;
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
          color: isSelected ? chipColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isSelected ? chipColor : Colors.grey.shade300,
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
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              SizedBox(width: rv.isTablet ? 8 : 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: rv.isTablet ? 16 : 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.grey[700],
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
    return Container(
      margin: EdgeInsets.only(bottom: rv.isTablet ? 10 : 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(rv.isTablet ? 14 : 12),
      ),
      child: SwitchListTile(
        title: Row(
          children: [
            Icon(icon, size: rv.isTablet ? 22 : 20, color: Colors.grey[700]),
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
