import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_utils_v2.dart';

/// 🎯 زر الفلاتر مع Badge للحالة النشطة
///
/// Widget لعرض أيقونة الفلتر مع علامة حمراء عند تفعيل أي فلتر
class AssociationsFilterButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool hasActiveFilters;

  const AssociationsFilterButton({
    required this.onPressed, required this.hasActiveFilters, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(
            Icons.filter_list,
            color: Colors.white,
            size: ResponsiveUtils.getIconSize(context),
          ),
          onPressed: onPressed,
          tooltip: 'الفلاتر',
        ),
        if (hasActiveFilters)
          Positioned(
            top: 8.h,
            right: 8.w,
            child: Container(
              width: 8.w,
              height: 8.h,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}
