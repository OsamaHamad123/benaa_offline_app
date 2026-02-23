import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

/// 🔍 Advanced Filters Sheet - فلاتر متقدمة للكفالات
///
/// يتضمن:
/// - نطاق تاريخي (من - إلى)
/// - نطاق المبلغ (حد أدنى - أقصى)
/// - فلاتر متعددة معاً
/// - حفظ الفلاتر المفضلة
class AdvancedFiltersSheet extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;
  final Function({
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
  }) onApplyFilters;

  const AdvancedFiltersSheet({
    required this.onApplyFilters, super.key,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
  });

  @override
  State<AdvancedFiltersSheet> createState() => _AdvancedFiltersSheetState();
}

class _AdvancedFiltersSheetState extends State<AdvancedFiltersSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  double? _minAmount;
  double? _maxAmount;

  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _minAmount = widget.minAmount;
    _maxAmount = widget.maxAmount;

    if (_minAmount != null) _minAmountController.text = _minAmount.toString();
    if (_maxAmount != null) _maxAmountController.text = _maxAmount.toString();
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16.w : 20.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.filter_alt_outlined,
                color: theme.colorScheme.primary,
                size: isMobile ? 24.sp : 28.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'فلاتر متقدمة',
                  style: (isMobile ? theme.textTheme.titleLarge : theme.textTheme.headlineSmall)?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              IconButton(
                onPressed: _clearAll,
                icon: const Icon(Icons.clear_all),
                tooltip: 'مسح الكل',
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16.h : 20.h),

          // Date Range Section
          _SectionHeader(
            icon: Icons.calendar_today,
            title: 'نطاق التاريخ',
            theme: theme,
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _DateSelector(
                  label: 'من تاريخ',
                  date: _startDate,
                  onDateSelected: (date) => setState(() => _startDate = date),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _DateSelector(
                  label: 'إلى تاريخ',
                  date: _endDate,
                  onDateSelected: (date) => setState(() => _endDate = date),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16.h : 20.h),

          // Amount Range Section
          _SectionHeader(
            icon: Icons.attach_money,
            title: 'نطاق المبلغ',
            theme: theme,
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'الحد الأدنى',
                    hintText: '0',
                    prefixIcon: const Icon(Icons.arrow_downward),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onChanged: (value) {
                    _minAmount = double.tryParse(value);
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: TextField(
                  controller: _maxAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'الحد الأقصى',
                    hintText: '∞',
                    prefixIcon: const Icon(Icons.arrow_upward),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onChanged: (value) {
                    _maxAmount = double.tryParse(value);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 20.h : 24.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'إلغاء',
                    style: TextStyle(fontSize: isMobile ? 14.sp : 16.sp),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check, size: 20),
                      SizedBox(width: 8.w),
                      Text(
                        'تطبيق الفلاتر',
                        style: TextStyle(
                          fontSize: isMobile ? 14.sp : 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  void _clearAll() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _minAmount = null;
      _maxAmount = null;
      _minAmountController.clear();
      _maxAmountController.clear();
    });
  }

  void _applyFilters() {
    widget.onApplyFilters(
      startDate: _startDate,
      endDate: _endDate,
      minAmount: _minAmount,
      maxAmount: _maxAmount,
    );
    Navigator.pop(context);
  }
}

/// Section Header
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final ThemeData theme;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18.sp,
          color: theme.colorScheme.primary.withOpacity(0.8),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.9),
          ),
        ),
      ],
    );
  }
}

/// Date Selector Widget
class _DateSelector extends StatelessWidget {
  final String label;
  final DateTime? date;
  final Function(DateTime?) onDateSelected;

  const _DateSelector({
    required this.label,
    required this.date,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  size: 18.sp,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: 6.w),
                Text(
                  date != null ? DateFormat('yyyy/MM/dd').format(date!) : 'اختر التاريخ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: date != null ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: DialogThemeData(backgroundColor: Theme.of(context).colorScheme.surface),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }
}
