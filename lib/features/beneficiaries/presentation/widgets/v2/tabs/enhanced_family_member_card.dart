import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';

/// 🎨 كارت محسّن لعرض فرد من أفراد العائلة
class EnhancedFamilyMemberCard extends StatelessWidget {
  final Map<String, dynamic> member;
  final bool isDeceased;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final int? index;

  const EnhancedFamilyMemberCard({
    super.key,
    required this.member,
    this.isDeceased = false,
    required this.onEdit,
    required this.onDelete,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final genderIcon = member['gender'] == 1 ? Icons.boy : Icons.girl;
    final genderColor = member['gender'] == 1 ? Colors.blue : Colors.pink;
    final String name =
        '${member['firstName'] ?? ''} ${member['familyName'] ?? ''}';
    final String age = member['age']?.toString() ?? '؟';
    final String? nationalId = member['nationalId']?.toString() ??
        member['orphanNationalId']?.toString();

    return RepaintBoundary(
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [genderColor.withOpacity(0.05), Colors.white],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: genderColor.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: genderColor.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: onEdit,
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  // صورة الفرد أو أيقونة
                  _buildAvatar(genderIcon, genderColor),
                  SizedBox(width: 16.w),

                  // معلومات الفرد
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // الاسم
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6.h),

                        // العمر
                        Row(
                          children: [
                            Icon(
                              Icons.cake,
                              size: 16.sp,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '$age سنة',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[700],
                              ),
                            ),
                            if (isDeceased) ...[
                              SizedBox(width: 12.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.local_hospital,
                                      size: 12.sp,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'متوفى',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),

                        // الرقم الوطني
                        if (nationalId != null && nationalId.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                Icons.credit_card,
                                size: 14.sp,
                                color: Colors.grey[500],
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                nationalId,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey[600],
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // الأزرار
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // زر التعديل
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.edit_rounded,
                            color: Colors.blue,
                            size: 20.sp,
                          ),
                          onPressed: onEdit,
                          tooltip: 'تعديل',
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // زر الحذف
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.delete_rounded,
                            color: Colors.red,
                            size: 20.sp,
                          ),
                          onPressed: onDelete,
                          tooltip: 'حذف',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(IconData icon, Color color) {
    // إذا كانت هناك صورة
    final imagePath = member['imagePath'] as String?;

    if (imagePath != null &&
        imagePath.isNotEmpty &&
        File(imagePath).existsSync()) {
      return Container(
        width: 64.w,
        height: 64.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          image: DecorationImage(
            image: ResizeImage(
              FileImage(File(imagePath)),
              width: (64.w * 2).toInt(), // 2x for better quality on high DPI
              height: (64.w * 2).toInt(),
            ),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // أيقونة افتراضية
    return Container(
      width: 64.w,
      height: 64.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.7)],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 32.sp),
    );
  }
}

/// 🎨 كارت فارغ لإضافة فرد جديد
class AddFamilyMemberCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const AddFamilyMemberCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24.sp),
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
