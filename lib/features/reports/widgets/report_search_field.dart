import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Search Field Widget for Reports
class ReportSearchField extends StatelessWidget {
  final String? hint;
  final Function(String) onSearch;
  final VoidCallback? onClear;
  final TextEditingController? controller;

  const ReportSearchField({
    required this.onSearch, super.key,
    this.hint,
    this.onClear,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final textController = controller ?? TextEditingController();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: TextField(
        controller: textController,
        decoration: InputDecoration(
          hintText: hint ?? 'ابحث...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: textController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    textController.clear();
                    onSearch('');
                    if (onClear != null) onClear!();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
        ),
        onChanged: onSearch,
      ),
    );
  }
}
