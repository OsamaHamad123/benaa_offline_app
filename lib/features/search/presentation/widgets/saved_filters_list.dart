import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../providers/search_filter_provider.dart';

/// 💾 Saved Filters List Widget
///
/// قائمة الفلاتر المحفوظة

class SavedFiltersList extends ConsumerWidget {
  final Function(String)? onFilterSelected;

  const SavedFiltersList({
    super.key,
    this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(searchFilterProvider);
    final savedFilters = filterState.savedFilters;

    if (savedFilters.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: savedFilters.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final filter = savedFilters[index];
        final dateFormat = DateFormat('dd/MM/yyyy', 'ar');

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: InkWell(
            onTap: () {
              ref
                  .read(searchFilterProvider.notifier)
                  .applySavedFilter(filter.id);
              onFilterSelected?.call(filter.id);
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.filter_alt,
                        color: Theme.of(context).primaryColor,
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          filter.name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20.sp,
                        ),
                        onPressed: () => _showDeleteDialog(
                          context,
                          ref,
                          filter.id,
                          filter.name,
                        ),
                        tooltip: 'حذف',
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'تاريخ الإنشاء: ${dateFormat.format(filter.createdAt)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  if (filter.lastUsedAt != null) ...[
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'آخر استخدام: ${dateFormat.format(filter.lastUsedAt!)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 8.h),
                  _buildFilterSummary(context, filter.filter),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_list_off,
            size: 64.sp,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد فلاتر محفوظة',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'قم بإنشاء فلتر جديد وحفظه للوصول السريع',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSummary(BuildContext context, filter) {
    final activeCriteria = <String>[];

    if (filter.name != null) activeCriteria.add('الاسم');
    if (filter.nationalId != null) activeCriteria.add('رقم الهوية');
    if (filter.city != null) activeCriteria.add('المدينة');
    if (filter.minAge != null || filter.maxAge != null) {
      activeCriteria.add('العمر');
    }
    if (filter.gender != null) activeCriteria.add('الجنس');
    if (filter.maritalStatus != null) activeCriteria.add('الحالة الاجتماعية');
    if (filter.hasSponsorship != null) activeCriteria.add('الكفالة');

    if (activeCriteria.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 6.w,
      runSpacing: 6.h,
      children: activeCriteria
          .map((criterion) => Chip(
                label: Text(
                  criterion,
                  style: TextStyle(fontSize: 11.sp),
                ),
                backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.1),
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ))
          .toList(),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    String id,
    String name,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الفلتر'),
        content: Text(
          'هل أنت متأكد من حذف الفلتر "$name"؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(searchFilterProvider.notifier).deleteSavedFilter(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف الفلتر')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
