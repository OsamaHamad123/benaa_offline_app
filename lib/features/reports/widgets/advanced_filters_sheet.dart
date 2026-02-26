import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../taxonomies/domain/entities/taxonomy_group.dart';
import '../../taxonomies/presentation/providers/taxonomy_bridge_providers.dart';

/// Advanced Filters Sheet - فلاتر متقدمة للتقارير
class AdvancedFiltersSheet extends ConsumerStatefulWidget {
  final String? selectedCategory;
  final String? selectedGovernorate;
  final bool? syncedOnly;
  final Function(String?, String?, bool?) onApply;

  const AdvancedFiltersSheet({
    required this.onApply,
    super.key,
    this.selectedCategory,
    this.selectedGovernorate,
    this.syncedOnly,
  });

  @override
  ConsumerState<AdvancedFiltersSheet> createState() => _AdvancedFiltersSheetState();
}

class _AdvancedFiltersSheetState extends ConsumerState<AdvancedFiltersSheet> {
  String? _selectedCategory;
  String? _selectedGovernorate;
  bool? _syncedOnly;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _selectedGovernorate = widget.selectedGovernorate;
    _syncedOnly = widget.syncedOnly;
  }

  @override
  Widget build(BuildContext context) {
    final governoratesAsync = ref.watch(bridgeGovernoratesProvider);
    final categoriesAsync = ref.watch(
      bridgeTaxonomiesByGroupResolvedOnceProvider(TaxonomyGroup.category),
    );

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.all(20.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Title
          Row(
            children: [
              Icon(
                Icons.filter_list,
                color: Theme.of(context).primaryColor,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'فلاتر متقدمة',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // فلتر الفئة
          _buildFilterSection(
            title: 'الفئة',
            icon: Icons.category,
            child: categoriesAsync.when(
              data: (categories) {
                final options = [
                  const DropdownMenuItem<String>(child: Text('الكل')),
                  ...categories.where((item) => item.code.trim().isNotEmpty && item.label.trim().isNotEmpty).map(
                        (item) => DropdownMenuItem<String>(
                          value: item.code,
                          child: Text(item.label),
                        ),
                      ),
                ];

                final hasSelected = _selectedCategory != null && options.any((item) => item.value == _selectedCategory);

                return DropdownButtonFormField<String>(
                  initialValue: hasSelected ? _selectedCategory : null,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  items: options,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                );
              },
              loading: () => DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                items: const [
                  DropdownMenuItem<String>(
                    child: Text('جاري تحميل الفئات...'),
                  ),
                ],
                onChanged: null,
              ),
              error: (_, __) => DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                items: [
                  const DropdownMenuItem<String>(child: Text('الكل')),
                  if (_selectedCategory != null)
                    DropdownMenuItem<String>(value: _selectedCategory, child: Text(_selectedCategory!)),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // فلتر المنطقة
          _buildFilterSection(
            title: 'المنطقة',
            icon: Icons.location_on,
            child: governoratesAsync.when(
              data: (governorates) {
                final options = [
                  'الكل',
                  ...governorates.map((item) => item.label),
                ];
                final hasSelected = _selectedGovernorate != null && options.contains(_selectedGovernorate);
                final currentValue = hasSelected ? _selectedGovernorate : 'الكل';

                return DropdownButtonFormField<String>(
                  initialValue: currentValue,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  items: options.map((region) {
                    return DropdownMenuItem(value: region, child: Text(region));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGovernorate = value == 'الكل' ? null : value;
                    });
                  },
                );
              },
              loading: () => DropdownButtonFormField<String>(
                initialValue: 'الكل',
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'الكل',
                    child: Text('جاري تحميل المناطق...'),
                  ),
                ],
                onChanged: null,
              ),
              error: (_, __) => DropdownButtonFormField<String>(
                initialValue: _selectedGovernorate ?? 'الكل',
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                items: [
                  const DropdownMenuItem(value: 'الكل', child: Text('الكل')),
                  if (_selectedGovernorate != null)
                    DropdownMenuItem(value: _selectedGovernorate, child: Text(_selectedGovernorate!)),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGovernorate = value == 'الكل' ? null : value;
                  });
                },
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // فلتر حالة المزامنة
          _buildFilterSection(
            title: 'حالة المزامنة',
            icon: Icons.sync,
            child: Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                ChoiceChip(
                  label: const Text('الكل'),
                  selected: _syncedOnly == null,
                  onSelected: (_) => setState(() => _syncedOnly = null),
                ),
                ChoiceChip(
                  label: const Text('تمت المزامنة فقط'),
                  selected: _syncedOnly == true,
                  onSelected: (_) => setState(() => _syncedOnly = true),
                ),
                ChoiceChip(
                  label: const Text('غير متزامن فقط'),
                  selected: _syncedOnly == false,
                  onSelected: (_) => setState(() => _syncedOnly = false),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // أزرار الإجراءات
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = null;
                      _selectedGovernorate = null;
                      _syncedOnly = null;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: const Text('إعادة تعيين'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(
                      _selectedCategory,
                      _selectedGovernorate,
                      _syncedOnly,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: const Text('تطبيق الفلاتر'),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18.sp, color: Colors.grey[700]),
            SizedBox(width: 6.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        child,
      ],
    );
  }
}
