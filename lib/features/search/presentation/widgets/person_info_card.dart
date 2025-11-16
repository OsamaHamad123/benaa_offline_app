import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/civil_person.dart';
import 'gender_badge.dart';
import 'location_chip.dart';
import 'person_detail_row.dart';

/// Enhanced Person Info Card - بطاقة معلومات الشخص المحسّنة
///
/// Features:
/// - عرض كل البيانات المتاحة
/// - تصميم عصري مع gradients
/// - Responsive design
/// - Performance optimized
class PersonInfoCard extends StatelessWidget {
  final CivilPerson person;
  final VoidCallback onCopy;
  final VoidCallback onAddAsBeneficiary;
  final bool expanded;

  const PersonInfoCard({
    super.key,
    required this.person,
    required this.onCopy,
    required this.onAddAsBeneficiary,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final rv = ResponsiveUtils.getValues(context);

    return Card(
      elevation: 2,
      shadowColor: Colors.blue.withOpacity(0.2),
      margin: EdgeInsets.only(bottom: rv.spacing),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: Colors.blue.withOpacity(0.1), width: 1.5),
      ),
      child: InkWell(
        onTap: onAddAsBeneficiary,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: rv.padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: 16.h),
              _buildDivider(),
              SizedBox(height: 16.h),
              _buildPersonDetails(context),
              if (expanded) ...[
                SizedBox(height: 16.h),
                _buildAdditionalInfo(context),
              ],
              SizedBox(height: 16.h),
              _buildActions(context, rv),
            ],
          ),
        ),
      ),
    );
  }

  /// Header with name and badges
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                person.fullName,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  GenderBadge(gender: person.gender, compact: true),
                  if (person.city != null || person.governorate != null)
                    LocationChip(
                      city: person.city,
                      governorate: person.governorate,
                    ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: const Icon(Icons.person, color: Colors.blue, size: 32),
        ),
      ],
    );
  }

  /// Divider - simple and fast
  Widget _buildDivider() {
    return Divider(
      height: 1.5.h,
      thickness: 1.5,
      color: Colors.blue.withOpacity(0.2),
    );
  }

  /// Person details section
  Widget _buildPersonDetails(BuildContext context) {
    return Column(
      children: [
        _buildNationalIdRow(context),
        SizedBox(height: 12.h),
        _buildNameBreakdown(),
      ],
    );
  }

  /// National ID row with copy button
  Widget _buildNationalIdRow(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.badge, color: Colors.indigo, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الرقم الوطني',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  person.nationalId,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _copyNationalId(context),
            icon: Icon(Icons.copy, size: 18.sp),
            color: Colors.blue,
            tooltip: 'نسخ الرقم',
            style: IconButton.styleFrom(
              backgroundColor: Colors.blue.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Name breakdown
  Widget _buildNameBreakdown() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSmallDetail(
                Icons.person_outline,
                'الاسم الأول',
                person.firstName,
                Colors.blue,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildSmallDetail(
                Icons.family_restroom,
                'اسم العائلة',
                person.familyName,
                Colors.purple,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _buildSmallDetail(
                Icons.account_circle,
                'اسم الأب',
                person.fatherName,
                Colors.green,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildSmallDetail(
                Icons.supervisor_account,
                'اسم الجد',
                person.grandFatherName,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Small detail widget
  Widget _buildSmallDetail(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14.sp),
              SizedBox(width: 4.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade900,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Additional info (mother name, birth date)
  Widget _buildAdditionalInfo(BuildContext context) {
    final hasMotherName =
        person.motherName != null && person.motherName!.isNotEmpty;
    final hasBirthDate =
        person.birthDate != null && person.birthDate!.isNotEmpty;

    if (!hasMotherName && !hasBirthDate) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'معلومات إضافية',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 12.h),
        if (hasMotherName)
          PersonDetailRow(
            icon: Icons.woman,
            label: 'اسم الأم',
            value: person.motherName!,
            iconColor: Colors.pink,
          ),
        if (hasMotherName && hasBirthDate) SizedBox(height: 8.h),
        if (hasBirthDate)
          PersonDetailRow(
            icon: Icons.cake,
            label: 'تاريخ الميلاد',
            value: person.birthDate!,
            iconColor: Colors.amber,
          ),
      ],
    );
  }

  /// Action buttons
  Widget _buildActions(BuildContext context, ResponsiveValues rv) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _copyToClipboard(context),
            icon: Icon(Icons.copy, size: 18.sp),
            label: Text('نسخ', style: TextStyle(fontSize: rv.fontSize)),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              side: BorderSide(color: Colors.blue, width: 1.5),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: onAddAsBeneficiary,
            icon: Icon(Icons.person_add, size: 18.sp),
            label: Text(
              'إضافة كمستفيد',
              style: TextStyle(fontSize: rv.fontSize),
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Copy national ID only
  void _copyNationalId(BuildContext context) {
    Clipboard.setData(ClipboardData(text: person.nationalId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم نسخ الرقم الوطني ✓'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Copy to clipboard
  void _copyToClipboard(BuildContext context) {
    final text =
        '''
الاسم الكامل: ${person.fullName}
الرقم الوطني: ${person.nationalId}
الجنس: ${person.gender.arabicLabel}
${person.motherName != null ? 'اسم الأم: ${person.motherName}\n' : ''}${person.birthDate != null ? 'تاريخ الميلاد: ${person.birthDate}\n' : ''}${person.city != null ? 'المدينة: ${person.city}\n' : ''}${person.governorate != null ? 'المحافظة: ${person.governorate}\n' : ''}''';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم النسخ إلى الحافظة ✓'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
