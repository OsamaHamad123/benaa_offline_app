import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/civil_registry_person.dart';

/// 👤 Civil Registry Preview Card
///
/// Shows a preview of data from civil registry before autofill.
class CivilRegistryPreviewCard extends StatelessWidget {
  final CivilRegistryPerson person;
  final VoidCallback? onDismiss;

  const CivilRegistryPreviewCard({
    super.key,
    required this.person,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'بيانات من السجل المدني: ${person.fullName}, الرقم الوطني ${person.nationalId}',
      hint: 'عرض البيانات المستوردة من السجل المدني',
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(color: Colors.green.shade200, width: 2),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.verified_rounded,
                      color: Colors.green, size: 24.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'بيانات من السجل المدني',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                      ),
                    ),
                  ),
                  if (onDismiss != null)
                    IconButton(
                      onPressed: onDismiss,
                      icon: const Icon(Icons.close),
                      iconSize: 20.sp,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),

              Divider(height: 16.h, thickness: 1),

              // Full Name
              _buildInfoRow(
                icon: Icons.person_rounded,
                label: 'الاسم الكامل',
                value: person.fullName,
              ),

              // National ID
              _buildInfoRow(
                icon: Icons.credit_card_rounded,
                label: 'الرقم الوطني',
                value: person.nationalId,
              ),

              // Birth Date
              if (person.birthDate != null)
                _buildInfoRow(
                  icon: Icons.cake_rounded,
                  label: 'تاريخ الميلاد',
                  value: _formatDate(person.birthDate!),
                  extra: person.age != null ? '(${person.age} سنة)' : null,
                ),

              // Gender
              if (person.gender != null)
                _buildInfoRow(
                  icon: Icons.wc_rounded,
                  label: 'الجنس',
                  value: person.gender!,
                ),

              // Address
              if (person.address != null)
                _buildInfoRow(
                  icon: Icons.location_on_rounded,
                  label: 'العنوان',
                  value: person.address!,
                ),

              // Status indicator
              if (person.status != null && person.status != 'active')
                Container(
                  margin: EdgeInsets.only(top: 8.h),
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_rounded,
                        size: 16.sp,
                        color: Colors.orange.shade900,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'حالة السجل: ${person.status}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    String? extra,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: Colors.grey.shade600),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (extra != null)
                      Text(
                        extra,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
