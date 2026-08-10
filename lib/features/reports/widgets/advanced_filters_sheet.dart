import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Advanced Filters Sheet - فلاتر متقدمة للتقارير
class AdvancedFiltersSheet extends StatefulWidget {
  final String? selectedCategory;
  final String? selectedGovernorate;
  final bool? syncedOnly;
  final Function(String?, String?, bool?) onApply;

  const AdvancedFiltersSheet({
    super.key,
    this.selectedCategory,
    this.selectedGovernorate,
    this.syncedOnly,
    required this.onApply,
  });

  @override
  State<AdvancedFiltersSheet> createState() => _AdvancedFiltersSheetState();
}

class _AdvancedFiltersSheetState extends State<AdvancedFiltersSheet> {
  String? _selectedCategory;
  String? _selectedGovernorate;
  bool? _syncedOnly;

  // قائمة الفئات
  final List<String> _categories = [
    'الكل',
    'أيتام',
    'فقراء',
    'ذوي احتياجات خاصة',
    'أسر متعففة',
  ];

  // قائمة المحافظات
  final List<String> _governorates = [
    'الكل',
    'عدن',
    'صنعاء',
    'تعز',
    'حضرموت',
    'إب',
    'الحديدة',
    'ذمار',
    'المحويت',
    'البيضاء',
    'عمران',
    'صعدة',
    'الجوف',
    'مأرب',
    'المهرة',
    'حجة',
    'الضالع',
    'لحج',
    'أبين',
    'شبوة',
    'ريمة',
    'سقطرى',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _selectedGovernorate = widget.selectedGovernorate;
    _syncedOnly = widget.syncedOnly;
  }

  @override
  Widget build(BuildContext context) {
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
            child: Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category ||
                    (_selectedCategory == null && category == 'الكل');
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory =
                          selected && category != 'الكل' ? category : null;
                    });
                  },
                  selectedColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.2),
                  checkmarkColor: Theme.of(context).primaryColor,
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 16.h),

          // فلتر المحافظة
          _buildFilterSection(
            title: 'المحافظة',
            icon: Icons.location_on,
            child: DropdownButtonFormField<String>(
              value: _selectedGovernorate ?? 'الكل',
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 8.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              items: _governorates.map((gov) {
                return DropdownMenuItem(value: gov, child: Text(gov));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGovernorate = value == 'الكل' ? null : value;
                });
              },
            ),
          ),
          SizedBox(height: 16.h),

          // فلتر حالة المزامنة
          _buildFilterSection(
            title: 'حالة المزامنة',
            icon: Icons.sync,
            child: Column(
              children: [
                RadioListTile<bool?>(
                  title: const Text('الكل'),
                  value: null,
                  groupValue: _syncedOnly,
                  onChanged: (value) => setState(() => _syncedOnly = value),
                  contentPadding: EdgeInsets.zero,
                ),
                RadioListTile<bool?>(
                  title: const Text('تمت المزامنة فقط'),
                  value: true,
                  groupValue: _syncedOnly,
                  onChanged: (value) => setState(() => _syncedOnly = value),
                  contentPadding: EdgeInsets.zero,
                ),
                RadioListTile<bool?>(
                  title: const Text('غير متزامن فقط'),
                  value: false,
                  groupValue: _syncedOnly,
                  onChanged: (value) => setState(() => _syncedOnly = value),
                  contentPadding: EdgeInsets.zero,
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
