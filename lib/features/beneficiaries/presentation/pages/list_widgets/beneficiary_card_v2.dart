import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../data/db/drift_database.dart';
import '../../providers/list/selection_provider.dart';
import '../../../../../../core/widgets/cached_avatar.dart';
import '../../../../../../core/utils/responsive_utils_v2.dart';
import '../../../../../../core/utils/haptic_patterns.dart';

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
/// - ⚡ AutomaticKeepAliveClientMixin for scroll performance
class BeneficiaryCardV2 extends ConsumerStatefulWidget {
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
  ConsumerState<BeneficiaryCardV2> createState() => _BeneficiaryCardV2State();
}

class _BeneficiaryCardV2State extends ConsumerState<BeneficiaryCardV2>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keep card alive during scroll

  @override
  Widget build(BuildContext context) {
    super.build(context); // MUST call super for AutomaticKeepAliveClientMixin

    final theme = Theme.of(context);
    final rv = ResponsiveUtils.getValues(context);
    final categoryColor = BeneficiaryHelpers.getCategoryColor(
      widget.beneficiary.sectionId,
    );

    return Semantics(
      label: 'بطاقة مستفيد: ${widget.beneficiary.fullName}',
      hint: 'انقر للتفاصيل، اضغط مطولاً للتحديد',
      button: true,
      child: RepaintBoundary(
        key: ValueKey('beneficiary_${widget.beneficiary.id}'),
        child: Card(
          elevation: widget.isSelected ? 8 : 2,
          margin: EdgeInsets.only(bottom: rv.spacing),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: widget.isSelected
                ? BorderSide(color: theme.colorScheme.primary, width: 3)
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: widget.isSelectionMode
                ? () {
                    HapticPatterns.selection();
                    ref
                        .read(selectionProvider.notifier)
                        .toggleItem(widget.beneficiary.id);
                  }
                : (widget.onTap ??
                    () => context.push(
                          '/beneficiaries/${widget.beneficiary.id}',
                        )),
            onLongPress: widget.onLongPress ??
                () {
                  HapticPatterns.selection();
                  ref
                      .read(selectionProvider.notifier)
                      .startSelectionWith(widget.beneficiary.id);
                },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: rv.padding,
              constraints: BoxConstraints(minHeight: rv.isTablet ? 160 : 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, ref, theme, categoryColor, rv),
                  SizedBox(height: rv.spacing),
                  _buildInfoChips(categoryColor, rv),
                  if (BeneficiaryHelpers.isPending(
                    widget.beneficiary.syncState,
                  ))
                    _buildOfflineIndicator(rv),
                ],
              ),
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
    ResponsiveValues rv,
  ) {
    return Row(
      children: [
        // Selection Checkbox
        if (widget.isSelectionMode) _buildSelectionCheckbox(theme, rv),

        // Avatar
        _buildAvatar(categoryColor, rv),
        SizedBox(width: rv.spacing),

        // Name & File Number
        Expanded(child: _buildNameSection(rv)),

        // Sync Status & Quick Actions
        if (!widget.isSelectionMode) _buildActionsColumn(context, rv),
      ],
    );
  }

  /// Selection Checkbox
  Widget _buildSelectionCheckbox(ThemeData theme, ResponsiveValues rv) {
    final size = rv.isTablet ? 36.0 : 32.0;
    return Container(
      width: size,
      height: size,
      margin: EdgeInsets.only(left: rv.spacing),
      decoration: BoxDecoration(
        color:
            widget.isSelected ? theme.colorScheme.primary : Colors.transparent,
        border: Border.all(
          color: widget.isSelected ? theme.colorScheme.primary : Colors.grey,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: widget.isSelected
          ? Icon(Icons.check, color: Colors.white, size: rv.isTablet ? 22 : 20)
          : null,
    );
  }

  /// Avatar with Gradient + Hero Animation
  Widget _buildAvatar(Color categoryColor, ResponsiveValues rv) {
    return Hero(
      tag: 'beneficiary_avatar_${widget.beneficiary.id}',
      child: CachedAvatar(
        imageUrl: null, // TODO: Add photo URL when available
        initials: BeneficiaryHelpers.getInitials(widget.beneficiary.fullName),
        color: categoryColor,
        size: rv.isTablet ? 64 : 56,
      ),
    );
  }

  /// Name & File Number
  Widget _buildNameSection(ResponsiveValues rv) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.beneficiary.fullName,
          style: TextStyle(
            fontSize: rv.isTablet ? 18 : 17,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.folder_outlined,
              size: rv.isTablet ? 15 : 14,
              color: Colors.grey,
            ),
            SizedBox(width: 4),
            Text(
              widget.beneficiary.fileIdNumber ?? 'لا يوجد',
              style: TextStyle(
                fontSize: rv.isTablet ? 14 : 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Sync Badge + Quick Actions
  Widget _buildActionsColumn(BuildContext context, ResponsiveValues rv) {
    return Column(
      children: [
        SyncStatusBadge(syncState: widget.beneficiary.syncState),
        SizedBox(height: 8),
        _QuickActionsButton(
          beneficiary: widget.beneficiary,
          onDelete: widget.onDelete,
        ),
      ],
    );
  }

  /// Info Chips (Category, Location, Age, Phone)
  Widget _buildInfoChips(Color categoryColor, ResponsiveValues rv) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Category Chip
        InfoChip(
          icon: Icons.category_outlined,
          label: BeneficiaryHelpers.getCategoryLabel(
            widget.beneficiary.sectionId,
          ),
          color: categoryColor,
          bold: true,
        ),

        // Location Chip
        if (widget.beneficiary.province != null)
          InfoChip(
            icon: Icons.location_on_outlined,
            label: BeneficiaryHelpers.getProvinceName(
              widget.beneficiary.province,
            ),
            color: Colors.blue,
          ),

        // Age Chip (calculated from birthDate)
        if (widget.beneficiary.birthDate != null)
          InfoChip(
            icon: Icons.cake_outlined,
            label: BeneficiaryHelpers.formatAge(
              BeneficiaryHelpers.calculateAge(widget.beneficiary.birthDate),
            ),
            color: Colors.orange,
          ),

        // Phone Chip
        InfoChip(
          icon: Icons.phone_outlined,
          label: widget.beneficiary.phoneNumber.toString(),
          color: Colors.green,
        ),
      ],
    );
  }

  /// Offline Pending Indicator
  Widget _buildOfflineIndicator(ResponsiveValues rv) {
    return Container(
      margin: EdgeInsets.only(top: rv.spacing),
      padding: EdgeInsets.symmetric(horizontal: rv.spacing, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: rv.isTablet ? 18 : 16,
            color: Colors.orange.shade700,
          ),
          SizedBox(width: 6),
          Text(
            'بانتظار المزامنة',
            style: TextStyle(
              fontSize: rv.isTablet ? 12 : 11,
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
    final rv = ResponsiveUtils.getValues(context);
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, size: rv.isTablet ? 26 : 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) => _handleAction(context, value),
      itemBuilder: (context) => [
        // Call Action
        PopupMenuItem(
          value: 'call',
          child: Row(
            children: [
              Icon(
                Icons.phone,
                size: rv.isTablet ? 22 : 20,
                color: Colors.green,
              ),
              SizedBox(width: rv.spacing),
              const Text('اتصال'),
            ],
          ),
        ),

        // WhatsApp Action
        PopupMenuItem(
          value: 'whatsapp',
          child: Row(
            children: [
              Icon(
                Icons.chat,
                size: rv.isTablet ? 22 : 20,
                color: Colors.green[700],
              ),
              SizedBox(width: rv.spacing),
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
              Icon(Icons.edit, size: rv.isTablet ? 22 : 20),
              SizedBox(width: rv.spacing),
              const Text('تعديل'),
            ],
          ),
        ),

        // Delete Action
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete,
                size: rv.isTablet ? 22 : 20,
                color: Colors.red,
              ),
              SizedBox(width: rv.spacing),
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
        HapticPatterns.selection();
        await PhoneLauncherService.makeCall(phoneStr);
        break;

      case 'whatsapp':
        HapticPatterns.selection();
        await PhoneLauncherService.openWhatsApp(phoneStr);
        break;

      case 'edit':
        HapticPatterns.selection();
        if (context.mounted) {
          context.push('/beneficiaries/edit/${beneficiary.id}');
        }
        break;

      case 'delete':
        HapticPatterns.error();
        if (onDelete != null) {
          onDelete!();
        }
        break;
    }
  }
}
