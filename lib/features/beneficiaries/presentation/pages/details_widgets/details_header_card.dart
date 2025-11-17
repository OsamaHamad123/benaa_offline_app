import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../data/models/beneficiary_model.dart';
import '../../../domain/entities/beneficiary.dart';
import '../../../domain/helpers/beneficiary_domain_helpers.dart';
import '../../../../../core/widgets/cached_avatar.dart';

/// Details Page: Header Card with Avatar and Basic Info
class DetailsHeaderCard extends StatelessWidget {
  final BeneficiaryModel beneficiary;

  const DetailsHeaderCard({super.key, required this.beneficiary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorInfo = BeneficiaryDomainHelpers.getCategoryColorInfo(
      beneficiary.category,
    );
    final categoryColor = Color(colorInfo.primary);
    final lightColor = Color(colorInfo.light);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(color: categoryColor.withAlpha(128), width: 2.w),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: LinearGradient(
            colors: [lightColor, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.all(24.r),
        child: Column(
          children: [
            // Avatar with Hero animation
            Hero(
              tag: 'beneficiary_avatar_${beneficiary.id}',
              child: CachedAvatar(
                imageUrl: null, // TODO: Add photo URL when available
                initials: BeneficiaryDomainHelpers.getInitials(
                  beneficiary.fullName,
                ),
                color: categoryColor,
                size: 80.r,
              ),
            ),
            SizedBox(height: 16.h),

            // Full Name
            Text(
              beneficiary.fullName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),

            // File Number
            if (beneficiary.fileNo != null)
              Text(
                'رقم الملف: ${beneficiary.fileNo}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            SizedBox(height: 12.h),

            // Sync Status Badge
            _SyncStatusBadge(needsSync: beneficiary.needsSync),
            SizedBox(height: 16.h),

            // Category Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: lightColor,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: categoryColor.withAlpha(77)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.category_rounded,
                    color: categoryColor,
                    size: 20.sp,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    BeneficiaryDomainHelpers.getCategoryLabel(
                      beneficiary.category,
                    ),
                    style: TextStyle(
                      color: categoryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ),

            // Quick Stats (Age, Gender)
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (beneficiary.birthDate != null) ...[
                  _QuickStat(
                    icon: Icons.cake_outlined,
                    label: BeneficiaryDomainHelpers.formatAge(beneficiary.age),
                    color: Colors.orange,
                  ),
                  SizedBox(width: 20.w),
                ],
                _QuickStat(
                  icon: beneficiary.gender == Gender.male
                      ? Icons.male
                      : Icons.female,
                  label: BeneficiaryDomainHelpers.getGenderLabel(
                    beneficiary.gender,
                  ),
                  color: beneficiary.gender == Gender.male
                      ? Colors.blue
                      : Colors.pink,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick Stat Widget
class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _QuickStat({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18.sp, color: color),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sync Status Badge
class _SyncStatusBadge extends StatelessWidget {
  final bool needsSync;

  const _SyncStatusBadge({required this.needsSync});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    if (needsSync) {
      color = Colors.orange;
      icon = Icons.sync_rounded;
      label = 'بانتظار المزامنة';
    } else {
      color = Colors.green;
      icon = Icons.check_circle_rounded;
      label = 'تمت المزامنة';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16.sp),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}
