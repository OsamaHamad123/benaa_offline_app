import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../data/db/drift_database.dart';

/// Reusable Beneficiary Info Card Widget
class BeneficiaryInfoCard extends StatelessWidget {
  final Beneficiary beneficiary;
  final bool compact;

  const BeneficiaryInfoCard({
    super.key,
    required this.beneficiary,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(beneficiary.sectionId);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: compact ? 20.r : 24.r,
                  backgroundColor: categoryColor.withOpacity(0.1),
                  child: Text(
                    beneficiary.fullName.substring(0, 1),
                    style: TextStyle(
                      fontSize: compact ? 16.sp : 18.sp,
                      fontWeight: FontWeight.bold,
                      color: categoryColor,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        beneficiary.fullName,
                        style: TextStyle(
                          fontSize: compact ? 14.sp : 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'رقم الملف: ${beneficiary.fileIdNumber ?? "غير محدد"}',
                        style: TextStyle(
                          fontSize: compact ? 11.sp : 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!compact) ...[
              SizedBox(height: 12.h),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 4.w),
                  Text(
                    _getProvinceName(beneficiary.province),
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                  ),
                  if (beneficiary.city != null) ...[
                    Text(
                      ' - ${_getCityName(beneficiary.city)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(int? sectionId) {
    // TODO: Map section IDs to colors based on actual backend codes
    switch (sectionId) {
      case 1: // Example: orphan
        return Colors.blue;
      case 2: // Example: widow
        return Colors.purple;
      case 3: // Example: poor
        return Colors.orange;
      case 4: // Example: disabled
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _getProvinceName(int? province) {
    // TODO: Map province codes to names
    return province?.toString() ?? 'غير محدد';
  }

  String _getCityName(int? city) {
    // TODO: Map city codes to names
    return city?.toString() ?? 'غير محدد';
  }
}
