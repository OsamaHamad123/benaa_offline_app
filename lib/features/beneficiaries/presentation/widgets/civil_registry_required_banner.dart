import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Banner shown when civil registry DB is not downloaded.
class CivilRegistryRequiredBanner extends StatelessWidget {
  const CivilRegistryRequiredBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.tertiary.withValues(alpha: 0.55)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: colorScheme.onTertiaryContainer,
            size: 20.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ميزة الملء التلقائي تحتاج تحميل السجل المدني',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onTertiaryContainer,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'حمّل قاعدة السجل المدني لتفعيل البحث والتعبئة التلقائية في إضافة المستفيد.',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: colorScheme.onTertiaryContainer,
                  ),
                ),
                SizedBox(height: 8.h),
                OutlinedButton.icon(
                  onPressed: () => context.push('/database-download'),
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('تحميل السجل المدني'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
