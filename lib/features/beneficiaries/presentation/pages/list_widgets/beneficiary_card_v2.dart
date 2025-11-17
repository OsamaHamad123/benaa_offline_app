import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../data/db/drift_database.dart';
import '../../providers/list/selection_provider.dart';
import '../../../../../../core/widgets/cached_avatar.dart';

// Helpers & Services
import 'helpers/beneficiary_helpers.dart';
import 'services/phone_launcher_service.dart';

// Widgets
import 'widgets/info_chip.dart';
import 'widgets/sync_status_badge.dart';

/// 📇 Beneficiary Card V2 - بطاقة محسّنة للتابلت/الموبايل
///
/// Clean Architecture:
/// - Uses BeneficiaryHelpers for data formatting
/// - Uses PhoneLauncherService for external actions
/// - Uses reusable widgets (InfoChip, SyncStatusBadge)
class BeneficiaryCardV2 extends ConsumerWidget {
  final Beneficiary beneficiary;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;
  final bool isSelectionMode;
  final bool isSelected;

  const BeneficiaryCardV2({
    super.key,
    required this.beneficiary,
    this.onTap,
    this.onLongPress,
    this.onDelete,
    this.isSelectionMode = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoryColor = BeneficiaryHelpers.getCategoryColor(
      beneficiary.sectionId,
    );

    return RepaintBoundary(
      key: ValueKey('beneficiary_${beneficiary.id}'),
      child: Card(
        elevation: isSelected ? 8 : 2,
        margin: EdgeInsets.only(bottom: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: isSelected
              ? BorderSide(color: theme.colorScheme.primary, width: 3.w)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: isSelectionMode
              ? () => ref
                    .read(selectionProvider.notifier)
                    .toggleItem(beneficiary.id)
              : (onTap ??
                    () => context.push('/beneficiaries/${beneficiary.id}')),
          onLongPress:
              onLongPress ??
              () => ref
                  .read(selectionProvider.notifier)
                  .startSelectionWith(beneficiary.id),
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.all(16.r),
            constraints: BoxConstraints(minHeight: 140.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, ref, theme, categoryColor),
                SizedBox(height: 16.h),
                _buildInfoChips(categoryColor),
                if (BeneficiaryHelpers.isPending(beneficiary.syncState))
                  _buildOfflineIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Header: Checkbox + Avatar + Name + Actions
  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    Color categoryColor,
  ) {
    return Row(
      children: [
        // Selection Checkbox
        if (isSelectionMode) _buildSelectionCheckbox(theme),

        // Avatar
        _buildAvatar(categoryColor),
        SizedBox(width: 12.w),

        // Name & File Number
        Expanded(child: _buildNameSection()),

        // Sync Status & Quick Actions
        if (!isSelectionMode) _buildActionsColumn(context),
      ],
    );
  }

  /// Selection Checkbox
  Widget _buildSelectionCheckbox(ThemeData theme) {
    return Container(
      width: 32.w,
      height: 32.h,
      margin: EdgeInsets.only(left: 12.w),
      decoration: BoxDecoration(
        color: isSelected ? theme.colorScheme.primary : Colors.transparent,
        border: Border.all(
          color: isSelected ? theme.colorScheme.primary : Colors.grey,
          width: 2.w,
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: isSelected
          ? Icon(Icons.check, color: Colors.white, size: 20.sp)
          : null,
    );
  }

  /// Avatar with Gradient
  Widget _buildAvatar(Color categoryColor) {
    return CachedAvatar(
      imageUrl: null, // TODO: Add photo URL when available
      initials: BeneficiaryHelpers.getInitials(beneficiary.fullName),
      color: categoryColor,
      size: 56,
    );
  }

  /// Name & File Number
  Widget _buildNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          beneficiary.fullName,
          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Icon(Icons.folder_outlined, size: 14.sp, color: Colors.grey),
            SizedBox(width: 4.w),
            Text(
              beneficiary.fileIdNumber ?? 'لا يوجد',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  /// Sync Badge + Quick Actions
  Widget _buildActionsColumn(BuildContext context) {
    return Column(
      children: [
        SyncStatusBadge(syncState: beneficiary.syncState),
        SizedBox(height: 8.h),
        _QuickActionsButton(beneficiary: beneficiary, onDelete: onDelete),
      ],
    );
  }

  /// Info Chips (Category, Location, Age, Phone)
  Widget _buildInfoChips(Color categoryColor) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        // Category Chip
        InfoChip(
          icon: Icons.category_outlined,
          label: BeneficiaryHelpers.getCategoryLabel(beneficiary.sectionId),
          color: categoryColor,
          bold: true,
        ),

        // Location Chip
        if (beneficiary.province != null)
          InfoChip(
            icon: Icons.location_on_outlined,
            label: BeneficiaryHelpers.getProvinceName(beneficiary.province),
            color: Colors.blue,
          ),

        // Age Chip (calculated from birthDate)
        if (beneficiary.birthDate != null)
          InfoChip(
            icon: Icons.cake_outlined,
            label: BeneficiaryHelpers.formatAge(
              BeneficiaryHelpers.calculateAge(beneficiary.birthDate),
            ),
            color: Colors.orange,
          ),

        // Phone Chip
        InfoChip(
          icon: Icons.phone_outlined,
          label: beneficiary.phoneNumber.toString(),
          color: Colors.green,
        ),
      ],
    );
  }

  /// Offline Pending Indicator
  Widget _buildOfflineIndicator() {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 16.sp,
            color: Colors.orange.shade700,
          ),
          SizedBox(width: 6.w),
          Text(
            'بانتظار المزامنة',
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.orange.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 🎯 Quick Actions Button - PopupMenu للإجراءات السريعة
class _QuickActionsButton extends StatelessWidget {
  final Beneficiary beneficiary;
  final VoidCallback? onDelete;

  const _QuickActionsButton({required this.beneficiary, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, size: 24.sp),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      onSelected: (value) => _handleAction(context, value),
      itemBuilder: (context) => [
        // Call Action
        PopupMenuItem(
          value: 'call',
          child: Row(
            children: [
              Icon(Icons.phone, size: 20.sp, color: Colors.green),
              SizedBox(width: 12.w),
              const Text('اتصال'),
            ],
          ),
        ),

        // WhatsApp Action
        PopupMenuItem(
          value: 'whatsapp',
          child: Row(
            children: [
              Icon(Icons.chat, size: 20.sp, color: Colors.green[700]),
              SizedBox(width: 12.w),
              const Text('واتساب'),
            ],
          ),
        ),

        const PopupMenuDivider(),

        // Edit Action
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20.sp),
              SizedBox(width: 12.w),
              const Text('تعديل'),
            ],
          ),
        ),

        // Delete Action
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 20.sp, color: Colors.red),
              SizedBox(width: 12.w),
              Text('حذف', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleAction(BuildContext context, String action) async {
    final phoneStr = beneficiary.phoneNumber.toString();

    switch (action) {
      case 'call':
        await PhoneLauncherService.makeCall(phoneStr);
        break;

      case 'whatsapp':
        await PhoneLauncherService.openWhatsApp(phoneStr);
        break;

      case 'edit':
        if (context.mounted) {
          context.push('/beneficiaries/edit/${beneficiary.id}');
        }
        break;

      case 'delete':
        if (onDelete != null) {
          onDelete!();
        }
        break;
    }
  }
}
