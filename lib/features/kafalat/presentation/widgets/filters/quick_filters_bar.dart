import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 🎯 Quick Filters Bar - شريط الفلاتر السريعة
class QuickFiltersBar extends StatelessWidget {
  final String selectedStatus;
  final String selectedType;
  final String? selectedAssociationId;
  final List<({String id, String name})> associations;
  final Function(String) onStatusChanged;
  final Function(String) onTypeChanged;
  final Function(String?) onAssociationChanged;
  final VoidCallback? onClearFilters;

  const QuickFiltersBar({
    super.key,
    required this.selectedStatus,
    required this.selectedType,
    required this.selectedAssociationId,
    required this.associations,
    required this.onStatusChanged,
    required this.onTypeChanged,
    required this.onAssociationChanged,
    this.onClearFilters,
  });

  bool get _hasActiveFilters => selectedStatus != 'all' || selectedType != 'all' || selectedAssociationId != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list_rounded,
                size: 20.sp,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                'فلترة سريعة',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (_hasActiveFilters)
                TextButton.icon(
                  onPressed: onClearFilters,
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('مسح الكل'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),

          // Filters Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Status Filters
                _buildChip(
                  context,
                  label: 'الكل',
                  isSelected: selectedStatus == 'all',
                  onTap: () => onStatusChanged('all'),
                  icon: Icons.apps,
                ),
                SizedBox(width: 8.w),
                _buildChip(
                  context,
                  label: 'نشطة',
                  isSelected: selectedStatus == 'active',
                  onTap: () => onStatusChanged('active'),
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                SizedBox(width: 8.w),
                _buildChip(
                  context,
                  label: 'موقوفة',
                  isSelected: selectedStatus == 'paused',
                  onTap: () => onStatusChanged('paused'),
                  icon: Icons.pause_circle,
                  color: Colors.orange,
                ),
                SizedBox(width: 8.w),
                _buildChip(
                  context,
                  label: 'منتهية',
                  isSelected: selectedStatus == 'ended',
                  onTap: () => onStatusChanged('ended'),
                  icon: Icons.cancel,
                  color: theme.colorScheme.error,
                ),

                // Divider
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.w),
                  width: 1,
                  height: 32.h,
                  color: theme.colorScheme.outlineVariant,
                ),

                // Type Filters
                _buildChip(
                  context,
                  label: 'كل الأنواع',
                  isSelected: selectedType == 'all',
                  onTap: () => onTypeChanged('all'),
                  icon: Icons.category,
                ),
                SizedBox(width: 8.w),
                _buildChip(
                  context,
                  label: 'شهرية',
                  isSelected: selectedType == 'monthly',
                  onTap: () => onTypeChanged('monthly'),
                  icon: Icons.calendar_month,
                  color: Colors.blue,
                ),
                SizedBox(width: 8.w),
                _buildChip(
                  context,
                  label: 'مرة واحدة',
                  isSelected: selectedType == 'one_time',
                  onTap: () => onTypeChanged('one_time'),
                  icon: Icons.bolt,
                  color: Colors.purple,
                ),

                // Association Filters (if available)
                if (associations.isNotEmpty) ...[
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 8.w),
                    width: 1,
                    height: 32.h,
                    color: theme.colorScheme.outlineVariant,
                  ),
                  _buildChip(
                    context,
                    label: 'كل الجمعيات',
                    isSelected: selectedAssociationId == null,
                    onTap: () => onAssociationChanged(null),
                    icon: Icons.business,
                  ),
                  ...associations.take(3).map(
                        (assoc) => Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: _buildChip(
                            context,
                            label: assoc.name,
                            isSelected: selectedAssociationId == assoc.id,
                            onTap: () => onAssociationChanged(assoc.id),
                            icon: Icons.account_balance,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color:
                isSelected ? chipColor.withOpacity(0.15) : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isSelected ? chipColor.withOpacity(0.5) : theme.colorScheme.outline.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16.sp,
                  color: isSelected ? chipColor : theme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 6.w),
              ],
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? chipColor : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
