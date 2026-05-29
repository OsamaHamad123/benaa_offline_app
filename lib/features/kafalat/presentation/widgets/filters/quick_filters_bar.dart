import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../taxonomies/domain/entities/taxonomy.dart' as taxonomy_domain;
import '../../../../taxonomies/domain/entities/taxonomy_group.dart';
import '../../../../taxonomies/presentation/providers/taxonomy_bridge_providers.dart';

/// 🎯 Quick Filters Bar - شريط الفلاتر السريعة
class QuickFiltersBar extends ConsumerWidget {
  final String selectedStatus;
  final String selectedType;
  final String? selectedAssociationId;
  final List<({String id, String name})> associations;
  final Function(String) onStatusChanged;
  final Function(String) onTypeChanged;
  final Function(String?) onAssociationChanged;
  final VoidCallback? onClearFilters;

  const QuickFiltersBar({
    required this.selectedStatus,
    required this.selectedType,
    required this.selectedAssociationId,
    required this.associations,
    required this.onStatusChanged,
    required this.onTypeChanged,
    required this.onAssociationChanged,
    super.key,
    this.onClearFilters,
  });

  bool get _hasActiveFilters => selectedStatus != 'all' || selectedType != 'all' || selectedAssociationId != null;

  String _resolveTaxonomyLabel(
    String code,
    List<taxonomy_domain.Taxonomy> taxonomyItems,
    Map<String, String> fallbackLabels,
  ) {
    for (final taxonomy in taxonomyItems) {
      if (taxonomy.code == code) return taxonomy.label;
    }
    return fallbackLabels[code] ?? code;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statusTaxonomies = ref
        .watch(
          bridgeTaxonomiesByGroupOnceProvider(TaxonomyGroup.beneficiaryStatus),
        )
        .maybeWhen(
          data: (items) => items,
          orElse: () => const <taxonomy_domain.Taxonomy>[],
        );
    final sponsorshipTypeTaxonomies = ref
        .watch(
          bridgeTaxonomiesByGroupOnceProvider(TaxonomyGroup.sponsorshipType),
        )
        .maybeWhen(
          data: (items) => items,
          orElse: () => const <taxonomy_domain.Taxonomy>[],
        );

    final activeStatusLabel = _resolveTaxonomyLabel(
      'active',
      statusTaxonomies,
      const {'active': 'نشطة', 'paused': 'موقوفة', 'ended': 'منتهية'},
    );
    final pausedStatusLabel = _resolveTaxonomyLabel(
      'paused',
      statusTaxonomies,
      const {'active': 'نشطة', 'paused': 'موقوفة', 'ended': 'منتهية'},
    );
    final endedStatusLabel = _resolveTaxonomyLabel(
      'ended',
      statusTaxonomies,
      const {'active': 'نشطة', 'paused': 'موقوفة', 'ended': 'منتهية'},
    );
    final monthlyTypeLabel = _resolveTaxonomyLabel(
      'monthly',
      sponsorshipTypeTaxonomies,
      const {'monthly': 'شهرية', 'one_time': 'مرة واحدة', 'other': 'أخرى'},
    );
    final oneTimeTypeLabel = _resolveTaxonomyLabel(
      'one_time',
      sponsorshipTypeTaxonomies,
      const {'monthly': 'شهرية', 'one_time': 'مرة واحدة', 'other': 'أخرى'},
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withOpacity(0.5),
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
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _buildChip(
                context,
                label: 'الكل',
                isSelected: selectedStatus == 'all',
                onTap: () => onStatusChanged('all'),
                icon: Icons.apps,
              ),
              _buildChip(
                context,
                label: activeStatusLabel,
                isSelected: selectedStatus == 'active',
                onTap: () => onStatusChanged('active'),
                icon: Icons.check_circle,
              ),
              _buildChip(
                context,
                label: pausedStatusLabel,
                isSelected: selectedStatus == 'paused',
                onTap: () => onStatusChanged('paused'),
                icon: Icons.pause_circle,
              ),
              _buildChip(
                context,
                label: endedStatusLabel,
                isSelected: selectedStatus == 'ended',
                onTap: () => onStatusChanged('ended'),
                icon: Icons.cancel,
              ),
              _buildChip(
                context,
                label: 'كل الأنواع',
                isSelected: selectedType == 'all',
                onTap: () => onTypeChanged('all'),
                icon: Icons.category,
              ),
              _buildChip(
                context,
                label: monthlyTypeLabel,
                isSelected: selectedType == 'monthly',
                onTap: () => onTypeChanged('monthly'),
                icon: Icons.calendar_month,
              ),
              _buildChip(
                context,
                label: oneTimeTypeLabel,
                isSelected: selectedType == 'one_time',
                onTap: () => onTypeChanged('one_time'),
                icon: Icons.bolt,
              ),
            ],
          ),
          if (associations.isNotEmpty) ...[
            SizedBox(height: 10.h),
            DropdownButtonFormField<String?>(
              isExpanded: true,
              initialValue: selectedAssociationId,
              decoration: const InputDecoration(
                labelText: 'الجمعية',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('كل الجمعيات', overflow: TextOverflow.ellipsis),
                ),
                ...associations.map(
                  (assoc) => DropdownMenuItem<String?>(
                    value: assoc.id,
                    child: Text(assoc.name, overflow: TextOverflow.ellipsis, maxLines: 1),
                  ),
                ),
              ],
              onChanged: onAssociationChanged,
            ),
          ],
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
