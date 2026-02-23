import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 📋 Card Info Section - قسم المعلومات
class CardInfoSection extends StatelessWidget {
  final int fileNo;
  final int idNumber;
  final String? amount;
  final String? startDate;
  final String? endDate;
  final String sponsorshipType;
  final String Function(String) typeLabel;
  final bool showLegacyBadge;

  const CardInfoSection({
    required this.fileNo,
    required this.idNumber,
    required this.sponsorshipType,
    required this.typeLabel,
    this.showLegacyBadge = false,
    super.key,
    this.amount,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // الصف الأول: رقم الملف + رقم الهوية
          Row(
            children: [
              Expanded(
                child: _InfoBox(
                  icon: Icons.folder_special_outlined,
                  label: 'رقم الملف',
                  value: '$fileNo',
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _InfoBox(
                  icon: Icons.badge_outlined,
                  label: 'رقم الهوية',
                  value: '$idNumber',
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ],
          ),

          // الصف الثاني: المبلغ + التاريخ (إن وُجد)
          if (amount != null || startDate != null) ...[
            SizedBox(height: 10.h),
            Row(
              children: [
                if (amount != null)
                  Expanded(
                    child: _InfoBox(
                      icon: Icons.payments_outlined,
                      label: 'القيمة',
                      value: amount!,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                if (amount != null && startDate != null) SizedBox(width: 12.w),
                if (startDate != null)
                  Expanded(
                    child: _InfoBox(
                      icon: Icons.calendar_today_outlined,
                      label: 'البداية',
                      value: startDate!,
                      color: Colors.teal,
                    ),
                  ),
              ],
            ),
          ],

          SizedBox(height: 12.h),

          // نوع الكفالة
          _TypeBadge(
            type: sponsorshipType,
            typeLabel: typeLabel,
            showLegacyBadge: showLegacyBadge,
          ),
        ],
      ),
    );
  }
}

/// 📦 Info Box - صندوق معلومة واحدة
class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 🏷️ Type Badge - شارة نوع الكفالة
class _TypeBadge extends StatelessWidget {
  final String type;
  final String Function(String) typeLabel;
  final bool showLegacyBadge;

  const _TypeBadge({
    required this.type,
    required this.typeLabel,
    this.showLegacyBadge = false,
  });

  Color _getTypeColor(String t) {
    return switch (t) {
      'monthly' => Colors.blue,
      'one_time' => Colors.purple,
      'other' => Colors.grey,
      _ => Colors.grey,
    };
  }

  IconData _getTypeIcon(String t) {
    return switch (t) {
      'monthly' => Icons.event_repeat,
      'one_time' => Icons.event_available,
      'other' => Icons.event_note,
      _ => Icons.event,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getTypeColor(type);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getTypeIcon(type), color: color, size: 16.sp),
          SizedBox(width: 6.w),
          Text(
            typeLabel(type),
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (showLegacyBadge) ...[
            SizedBox(width: 6.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                'Legacy',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
