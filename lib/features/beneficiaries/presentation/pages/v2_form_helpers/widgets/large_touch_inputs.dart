import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 🎨 Large Touch-Friendly Form Inputs
///
/// Optimized for tablets and field work

class LargeTouchTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool required;
  final int? maxLines;
  final int? maxLength;
  final Widget? suffixIcon;
  final String? errorText;
  final bool readOnly;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;

  const LargeTouchTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.keyboardType,
    this.required = false,
    this.maxLines = 1,
    this.maxLength,
    this.suffixIcon,
    this.errorText,
    this.readOnly = false,
    this.onTap,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (required ? ' *' : ''),
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 10.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          readOnly: readOnly,
          onTap: onTap,
          inputFormatters: inputFormatters,
          style: TextStyle(fontSize: 18.sp),
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            suffixIcon: suffixIcon,
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(width: 2.w),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 2.w),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2.5.w,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.red, width: 2.w),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 18.h,
            ),
          ),
        ),
      ],
    );
  }
}

/// 📝 Large Touch Date Picker
class LargeTouchDatePicker extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool required;

  const LargeTouchDatePicker({
    super.key,
    required this.label,
    this.selectedDate,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (required ? ' *' : ''),
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 10.h),
        InkWell(
          onTap: () async {
            HapticFeedback.selectionClick();
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: firstDate ?? DateTime(1900),
              lastDate: lastDate ?? DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    dialogTheme: DialogThemeData(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              HapticFeedback.mediumImpact();
              onDateSelected(picked);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
            decoration: BoxDecoration(
              border: Border.all(
                color: selectedDate != null
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade300,
                width: 2.w,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 24.sp,
                  color: selectedDate != null
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                        : 'اختر التاريخ',
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: selectedDate != null ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 🎯 Large Radio Buttons Group
class LargeTouchRadioGroup extends StatelessWidget {
  final String label;
  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String> onChanged;
  final bool required;

  const LargeTouchRadioGroup({
    super.key,
    required this.label,
    required this.options,
    this.selectedValue,
    required this.onChanged,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (required ? ' *' : ''),
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 10.h),
        ...options.map((option) {
          final isSelected = option == selectedValue;
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(option);
              },
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.grey.shade300,
                    width: 2.w,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  color: isSelected
                      ? theme.colorScheme.primary.withOpacity(0.05)
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28.w,
                      height: 28.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.grey,
                          width: 2.w,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 14.w,
                                height: 14.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            )
                          : null,
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

/// 🔢 Large Number Stepper
class LargeTouchNumberStepper extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final int step;
  final String? unit;

  const LargeTouchNumberStepper({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            // Decrease button
            Material(
              color: value > min
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12.r),
              child: InkWell(
                onTap: value > min
                    ? () {
                        HapticFeedback.selectionClick();
                        onChanged(value - step);
                      }
                    : null,
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  width: 56.w,
                  height: 56.h,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.remove_rounded,
                    color: value > min ? Colors.white : Colors.grey,
                    size: 28.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            // Value display
            Expanded(
              child: Container(
                height: 56.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 2.w),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '$value${unit ?? ''}',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            // Increase button
            Material(
              color: value < max
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12.r),
              child: InkWell(
                onTap: value < max
                    ? () {
                        HapticFeedback.selectionClick();
                        onChanged(value + step);
                      }
                    : null,
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  width: 56.w,
                  height: 56.h,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.add_rounded,
                    color: value < max ? Colors.white : Colors.grey,
                    size: 28.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
