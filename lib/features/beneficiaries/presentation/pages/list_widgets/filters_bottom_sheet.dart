import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../providers/list/filters_provider.dart';
import '../../providers/list/beneficiaries_list_state.dart';
import '../../providers/list/beneficiaries_list_provider.dart';

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

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: EdgeInsets.symmetric(vertical: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: Row(
              children: [
                Icon(Icons.filter_list, color: theme.colorScheme.primary),
                SizedBox(width: 12.w),
                Text(
                  'الفلاتر',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (filters.hasActiveFilters)
                  TextButton(
                    onPressed: () {
                      ref.read(filtersProvider.notifier).clearFilters();
                      ref.read(beneficiariesListProvider.notifier).refresh();
                    },
                    child: const Text('مسح الكل'),
                  ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Divider(height: 1.h),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Filter
                  _buildSectionTitle('الفئة'),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _FilterChip(
                        label: 'الكل',
                        isSelected: filters.categoryId == null,
                        onTap: () {
                          ref.read(filtersProvider.notifier).setCategory(null);
                          ref
                              .read(beneficiariesListProvider.notifier)
                              .refresh();
                        },
                      ),
                      _FilterChip(
                        label: 'يتيم',
                        isSelected: filters.categoryId == 1,
                        onTap: () {
                          ref.read(filtersProvider.notifier).setCategory(1);
                          ref
                              .read(beneficiariesListProvider.notifier)
                              .refresh();
                        },
                        color: Colors.blue,
                      ),
                      _FilterChip(
                        label: 'أرملة',
                        isSelected: filters.categoryId == 2,
                        onTap: () {
                          ref.read(filtersProvider.notifier).setCategory(2);
                          ref
                              .read(beneficiariesListProvider.notifier)
                              .refresh();
                        },
                        color: Colors.purple,
                      ),
                      _FilterChip(
                        label: 'فقير',
                        isSelected: filters.categoryId == 3,
                        onTap: () {
                          ref.read(filtersProvider.notifier).setCategory(3);
                          ref
                              .read(beneficiariesListProvider.notifier)
                              .refresh();
                        },
                        color: Colors.orange,
                      ),
                      _FilterChip(
                        label: 'معاق',
                        isSelected: filters.categoryId == 4,
                        onTap: () {
                          ref.read(filtersProvider.notifier).setCategory(4);
                          ref
                              .read(beneficiariesListProvider.notifier)
                              .refresh();
                        },
                        color: Colors.red,
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Quick Filters
                  _buildSectionTitle('فلاتر سريعة'),
                  SizedBox(height: 12.h),
                  _SwitchTile(
                    title: 'معلق المزامنة فقط',
                    value: filters.onlyPendingSync,
                    icon: Icons.cloud_off,
                    onChanged: (value) {
                      ref.read(filtersProvider.notifier).togglePendingSync();
                      ref.read(beneficiariesListProvider.notifier).refresh();
                    },
                  ),
                  _SwitchTile(
                    title: 'مع رقم هاتف فقط',
                    value: filters.onlyWithPhone,
                    icon: Icons.phone,
                    onChanged: (value) {
                      ref.read(filtersProvider.notifier).toggleWithPhone();
                      ref.read(beneficiariesListProvider.notifier).refresh();
                    },
                  ),
                  _SwitchTile(
                    title: 'مع موقع محدد فقط',
                    value: filters.onlyWithLocation,
                    icon: Icons.location_on,
                    onChanged: (value) {
                      ref.read(filtersProvider.notifier).toggleWithLocation();
                      ref.read(beneficiariesListProvider.notifier).refresh();
                    },
                  ),

                  SizedBox(height: 24.h),

                  // Sort
                  _buildSectionTitle('الترتيب'),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: SortBy.values.map((sort) {
                      final isSelected = filters.sortBy == sort;
                      return _FilterChip(
                        label: sort.label,
                        isSelected: isSelected,
                        icon: isSelected
                            ? (filters.sortAscending
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward)
                            : null,
                        onTap: () {
                          if (isSelected) {
                            ref
                                .read(filtersProvider.notifier)
                                .toggleSortDirection();
                          } else {
                            ref
                                .read(filtersProvider.notifier)
                                .setSorting(sort, true);
                          }
                          ref
                              .read(beneficiariesListProvider.notifier)
                              .refresh();
                        },
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
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

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? chipColor : Colors.grey.shade300,
            width: 2.w,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16.sp,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              SizedBox(width: 6.w),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
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

  const _SwitchTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: SwitchListTile(
        title: Row(
          children: [
            Icon(icon, size: 20.sp, color: Colors.grey[700]),
            SizedBox(width: 12.w),
            Text(title, style: TextStyle(fontSize: 14.sp)),
          ],
        ),
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
