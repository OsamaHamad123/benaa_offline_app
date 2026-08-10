import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_utils_v2.dart';

/// 🔍 شريط الفلاتر السريعة - FilterChips
class AssociationsFiltersBar extends StatelessWidget {
  final String? selectedStatus; // null = الكل، 'active' = نشطة، 'inactive' = معطلة
  final String? selectedBank;
  final List<String> availableBanks;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onBankChanged;

  const AssociationsFiltersBar({
    super.key,
    required this.selectedStatus,
    required this.selectedBank,
    required this.availableBanks,
    required this.onStatusChanged,
    required this.onBankChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.mediumSpace,
        vertical: 8.h,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // فلتر الحالة
            _FilterChip(
              label: 'الكل',
              isSelected: selectedStatus == null,
              icon: Icons.apps,
              onTap: () => onStatusChanged(null),
            ),
            SizedBox(width: 8.w),
            _FilterChip(
              label: 'النشطة',
              isSelected: selectedStatus == 'active',
              icon: Icons.check_circle,
              color: Colors.green,
              onTap: () => onStatusChanged('active'),
            ),
            SizedBox(width: 8.w),
            _FilterChip(
              label: 'المعطلة',
              isSelected: selectedStatus == 'inactive',
              icon: Icons.cancel,
              color: Colors.orange,
              onTap: () => onStatusChanged('inactive'),
            ),

            // Divider
            if (availableBanks.isNotEmpty) ...[
              SizedBox(width: 12.w),
              Container(
                height: 24.h,
                width: 1,
                color: Colors.grey.withOpacity(0.3),
              ),
              SizedBox(width: 12.w),
            ],

            // فلاتر البنوك
            ...availableBanks.take(3).map((bank) {
              return Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: _FilterChip(
                  label: bank,
                  isSelected: selectedBank == bank,
                  icon: Icons.account_balance,
                  color: Colors.blue,
                  onTap: () => onBankChanged(
                    selectedBank == bank ? null : bank,
                  ),
                ),
              );
            }),

            // زر "المزيد" إذا كان هناك بنوك أكثر
            if (availableBanks.length > 3)
              Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: _FilterChip(
                  label: 'المزيد...',
                  isSelected: false,
                  icon: Icons.more_horiz,
                  onTap: () => _showAllBanksDialog(context),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAllBanksDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر البنك'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.clear),
                title: const Text('الكل'),
                trailing: selectedBank == null ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  onBankChanged(null);
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ...availableBanks.map((bank) {
                return ListTile(
                  leading: const Icon(Icons.account_balance),
                  title: Text(bank),
                  trailing: selectedBank == bank ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    onBankChanged(bank);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}

/// Filter Chip واحد
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.icon,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 6.h,
          ),
          decoration: BoxDecoration(
            color: isSelected ? chipColor.withOpacity(0.15) : Colors.grey.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isSelected ? chipColor.withOpacity(0.5) : Colors.grey.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16.sp,
                color: isSelected ? chipColor : Colors.grey.shade600,
              ),
              SizedBox(width: 4.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? chipColor : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
