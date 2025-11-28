import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/haptic_patterns.dart';

/// Filter Chip Group - Multiple selection chips
class FilterChipGroup extends StatefulWidget {
  final List<FilterChipData> filters;
  final Function(List<String>)? onSelectionChanged;
  final bool multiSelect;
  final String? selectedFilter;

  const FilterChipGroup({
    super.key,
    required this.filters,
    this.onSelectionChanged,
    this.multiSelect = false,
    this.selectedFilter,
  });

  @override
  State<FilterChipGroup> createState() => _FilterChipGroupState();
}

class _FilterChipGroupState extends State<FilterChipGroup> {
  final Set<String> _selectedFilters = {};

  @override
  void initState() {
    super.initState();
    if (widget.selectedFilter != null) {
      _selectedFilters.add(widget.selectedFilter!);
    }
  }

  void _onFilterTapped(String filter) {
    HapticPatterns.selection();
    setState(() {
      if (widget.multiSelect) {
        if (_selectedFilters.contains(filter)) {
          _selectedFilters.remove(filter);
        } else {
          _selectedFilters.add(filter);
        }
      } else {
        _selectedFilters.clear();
        _selectedFilters.add(filter);
      }
    });

    if (widget.onSelectionChanged != null) {
      widget.onSelectionChanged!(_selectedFilters.toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: widget.filters.map((filter) {
          final isSelected = _selectedFilters.contains(filter.value);
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: _FilterChipWidget(
              label: filter.label,
              icon: filter.icon,
              count: filter.count,
              isSelected: isSelected,
              color: filter.color,
              onTap: () => _onFilterTapped(filter.value),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Single Filter Chip Widget
class _FilterChipWidget extends StatelessWidget {
  final String label;
  final IconData? icon;
  final int? count;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChipWidget({
    required this.label,
    this.icon,
    this.count,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? Colors.blue;
    final backgroundColor = isSelected ? chipColor : chipColor.withOpacity(0.1);
    final textColor = isSelected ? Colors.white : chipColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isSelected ? chipColor : chipColor.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16.sp, color: textColor),
                SizedBox(width: 6.w),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: textColor,
                ),
              ),
              if (count != null) ...[
                SizedBox(width: 6.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withOpacity(0.3) : chipColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Filter Chip Data Model
class FilterChipData {
  final String label;
  final String value;
  final IconData? icon;
  final int? count;
  final Color? color;

  const FilterChipData({
    required this.label,
    required this.value,
    this.icon,
    this.count,
    this.color,
  });
}
