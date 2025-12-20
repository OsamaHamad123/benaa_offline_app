import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/kafalat_providers.dart';
import '../widgets/filters/advanced_filters_sheet.dart';
import '../widgets/cards/professional_sponsorship_card.dart';

/// 🔍 Advanced Filters Page - صفحة الفلاتر المتقدمة
class AdvancedFiltersPage extends ConsumerStatefulWidget {
  const AdvancedFiltersPage({super.key});

  @override
  ConsumerState<AdvancedFiltersPage> createState() => _AdvancedFiltersPageState();
}

class _AdvancedFiltersPageState extends ConsumerState<AdvancedFiltersPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  double? _minAmount;
  double? _maxAmount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sponsorshipsAsync = ref.watch(
      kafalatSponsorshipsProvider((
        associationId: null,
        status: 'all',
        type: 'all',
        query: '',
      )),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('الفلاتر المتقدمة'),
        actions: [
          IconButton(
            onPressed: _openFiltersSheet,
            icon: const Icon(Icons.tune),
            tooltip: 'تعديل الفلاتر',
          ),
        ],
      ),
      body: Column(
        children: [
          // Active Filters Chips
          if (_hasActiveFilters()) _buildActiveFiltersChips(theme),

          // Results
          Expanded(
            child: sponsorshipsAsync.when(
              data: (allSponsorships) {
                final filtered = _filterSponsorships(allSponsorships);

                if (filtered.isEmpty) {
                  return _buildEmptyState(theme);
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return ProfessionalSponsorshipCard(
                      row: filtered[index],
                      onEdit: () {},
                      onDelete: () {},
                      typeLabel: (type) => switch (type) {
                        'monthly' => 'شهرية',
                        'one_time' => 'مرة واحدة',
                        'other' => 'أخرى',
                        _ => type,
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => _buildErrorState(theme),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openFiltersSheet,
        icon: const Icon(Icons.filter_alt),
        label: const Text('تطبيق فلاتر'),
      ),
    );
  }

  bool _hasActiveFilters() {
    return _startDate != null || _endDate != null || _minAmount != null || _maxAmount != null;
  }

  Widget _buildActiveFiltersChips(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: [
          if (_startDate != null)
            _FilterChip(
              label: 'من: ${_formatDate(_startDate!)}',
              onRemove: () => setState(() => _startDate = null),
            ),
          if (_endDate != null)
            _FilterChip(
              label: 'إلى: ${_formatDate(_endDate!)}',
              onRemove: () => setState(() => _endDate = null),
            ),
          if (_minAmount != null)
            _FilterChip(
              label: 'حد أدنى: $_minAmount',
              onRemove: () => setState(() => _minAmount = null),
            ),
          if (_maxAmount != null)
            _FilterChip(
              label: 'حد أقصى: $_maxAmount',
              onRemove: () => setState(() => _maxAmount = null),
            ),
          if (_hasActiveFilters())
            TextButton.icon(
              onPressed: _clearAllFilters,
              icon: const Icon(Icons.clear_all, size: 16),
              label: const Text('مسح الكل'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              ),
            ),
        ],
      ),
    );
  }

  List<dynamic> _filterSponsorships(List<dynamic> all) {
    return all.where((row) {
      final createdAt = row.sponsorship.createdAt;
      final amount = row.sponsorship.amount;

      // Date filter
      if (_startDate != null && (createdAt == null || createdAt.isBefore(_startDate!))) {
        return false;
      }
      if (_endDate != null && (createdAt == null || createdAt.isAfter(_endDate!))) {
        return false;
      }

      // Amount filter
      if (_minAmount != null && (amount == null || amount < _minAmount!)) {
        return false;
      }
      if (_maxAmount != null && (amount == null || amount > _maxAmount!)) {
        return false;
      }

      return true;
    }).toList();
  }

  void _openFiltersSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdvancedFiltersSheet(
        startDate: _startDate,
        endDate: _endDate,
        minAmount: _minAmount,
        maxAmount: _maxAmount,
        onApplyFilters: ({startDate, endDate, minAmount, maxAmount}) {
          setState(() {
            _startDate = startDate;
            _endDate = endDate;
            _minAmount = minAmount;
            _maxAmount = maxAmount;
          });
        },
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _minAmount = null;
      _maxAmount = null;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_alt_off,
            size: 80.sp,
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد نتائج',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'جرب تغيير معايير الفلترة',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60.sp,
            color: theme.colorScheme.error,
          ),
          SizedBox(height: 16.h),
          Text(
            'حدث خطأ في تحميل البيانات',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FilterChip({
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onRemove,
      backgroundColor: theme.colorScheme.primaryContainer,
      labelStyle: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
