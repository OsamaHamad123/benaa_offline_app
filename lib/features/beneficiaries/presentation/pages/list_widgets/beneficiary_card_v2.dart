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
  final Map<int, String> categoryLabelsById;
  final Map<int, Color> categoryColorsById;
  final Map<int, String> governorateLabelsById;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;
  final bool isSelectionMode;
  final bool isSelected;

  const BeneficiaryCardV2({
    required this.beneficiary,
    this.categoryLabelsById = const <int, String>{},
    this.categoryColorsById = const <int, Color>{},
    this.governorateLabelsById = const <int, String>{},
    super.key,
    this.onTap,
    this.onLongPress,
    this.onDelete,
    this.isSelectionMode = false,
    this.isSelected = false,
  });

  @override
  ConsumerState<BeneficiaryCardV2> createState() => _BeneficiaryCardV2State();
}

class _BeneficiaryCardV2State extends ConsumerState<BeneficiaryCardV2> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keep card alive during scroll

  @override
  Widget build(BuildContext context) {
    super.build(context); // MUST call super for AutomaticKeepAliveClientMixin

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final rv = ResponsiveUtils.getValues(context);
    final categoryColor = BeneficiaryHelpers.getCategoryColor(
      widget.beneficiary.sectionId,
      categoryColorsById: widget.categoryColorsById,
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
            side: widget.isSelected ? BorderSide(color: theme.colorScheme.primary, width: 3) : BorderSide.none,
          ),
          child: InkWell(
            onTap: widget.isSelectionMode
                ? () {
                    HapticPatterns.selection();
                    ref.read(selectionProvider.notifier).toggleItem(widget.beneficiary.id);
                  }
                : (widget.onTap ??
                    () => context.push(
                          '/beneficiaries/${widget.beneficiary.id}',
                        )),
            onLongPress: widget.onLongPress ??
                () {
                  HapticPatterns.selection();
                  ref.read(selectionProvider.notifier).startSelectionWith(widget.beneficiary.id);
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
                  _buildInfoChips(categoryColor, colorScheme, rv),
                  if (BeneficiaryHelpers.isPending(
                    widget.beneficiary.syncState,
                  ))
                    _buildOfflineIndicator(colorScheme, rv),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _categoryLabel() {
    final sectionId = widget.beneficiary.sectionId;
    if (sectionId != null) {
      final dynamicLabel = widget.categoryLabelsById[sectionId];
      if (dynamicLabel != null && dynamicLabel.trim().isNotEmpty) {
        return dynamicLabel;
      }
    }
    return BeneficiaryHelpers.getCategoryLabel(sectionId);
  }

  String? _governorateLabel() {
    final province = widget.beneficiary.province;
    if (province == null) return null;
    final dynamicLabel = widget.governorateLabelsById[province];
    if (dynamicLabel != null && dynamicLabel.trim().isNotEmpty) {
      return dynamicLabel;
    }
    return BeneficiaryHelpers.getProvinceName(
      province,
      governorateLabelsById: widget.governorateLabelsById,
    );
  }

  String? _primaryPhone() {
    final phone = widget.beneficiary.phoneNumber;
    if (phone <= 0) return null;
    final value = phone.toString().trim();
    return value.isEmpty ? null : value;
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
        Expanded(child: _buildNameSection(theme, rv)),

        // Sync Status & Quick Actions
        if (!widget.isSelectionMode) _buildActionsColumn(context, rv),
      ],
    );
  }

  /// Selection Checkbox
  Widget _buildSelectionCheckbox(ThemeData theme, ResponsiveValues rv) {
    final size = rv.isTablet ? 36.0 : 32.0;
    final colorScheme = theme.colorScheme;
    return Container(
      width: size,
      height: size,
      margin: EdgeInsets.only(left: rv.spacing),
      decoration: BoxDecoration(
        color: widget.isSelected ? colorScheme.primary : Colors.transparent,
        border: Border.all(
          color: widget.isSelected ? colorScheme.primary : colorScheme.outline,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: widget.isSelected
          ? Icon(
              Icons.check,
              color: colorScheme.onPrimary,
              size: rv.isTablet ? 22 : 20,
            )
          : null,
    );
  }

  /// Avatar with Gradient + Hero Animation
  Widget _buildAvatar(Color categoryColor, ResponsiveValues rv) {
    return Hero(
      tag: 'beneficiary_avatar_${widget.beneficiary.id}',
      child: CachedAvatar(
        initials: BeneficiaryHelpers.getInitials(widget.beneficiary.fullName),
        color: categoryColor,
        size: rv.isTablet ? 64 : 56,
      ),
    );
  }

  /// Name & File Number
  Widget _buildNameSection(ThemeData theme, ResponsiveValues rv) {
    final colorScheme = theme.colorScheme;
    final rawFileId = widget.beneficiary.fileIdNumber?.trim();
    final hasFileId = rawFileId != null && rawFileId.isNotEmpty;
    final fileLabel = hasFileId
        ? rawFileId
        : ((widget.beneficiary.syncState == 'pending' || widget.beneficiary.syncState == 'modified')
            ? 'بانتظار التخصيص'
            : 'لا يوجد');

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
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.folder_outlined,
              size: rv.isTablet ? 15 : 14,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              fileLabel,
              style: TextStyle(
                fontSize: rv.isTablet ? 14 : 13,
                color: colorScheme.onSurfaceVariant,
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
        const SizedBox(height: 8),
        _QuickActionsButton(
          beneficiary: widget.beneficiary,
          onDelete: widget.onDelete,
        ),
      ],
    );
  }

  /// Info Chips (Category, Location, Age, Phone)
  Widget _buildInfoChips(
    Color categoryColor,
    ColorScheme colorScheme,
    ResponsiveValues rv,
  ) {
    final governorateLabel = _governorateLabel();
    final phone = _primaryPhone();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        InfoChip(
          icon: Icons.category_outlined,
          label: _categoryLabel(),
          color: categoryColor,
          bold: true,
        ),
        if (governorateLabel != null)
          InfoChip(
            icon: Icons.location_on_outlined,
            label: governorateLabel,
            color: colorScheme.primary,
          ),
        if (widget.beneficiary.birthDate != null)
          InfoChip(
            icon: Icons.cake_outlined,
            label: BeneficiaryHelpers.formatAge(
              BeneficiaryHelpers.calculateAge(widget.beneficiary.birthDate),
            ),
            color: colorScheme.tertiary,
          ),
        if (phone != null)
          InfoChip(
            icon: Icons.phone_outlined,
            label: phone,
            color: colorScheme.secondary,
          ),
      ],
    );
  }

  /// Offline Pending Indicator
  Widget _buildOfflineIndicator(ColorScheme colorScheme, ResponsiveValues rv) {
    return Container(
      margin: EdgeInsets.only(top: rv.spacing),
      padding: EdgeInsets.symmetric(horizontal: rv.spacing, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.tertiary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: rv.isTablet ? 18 : 16,
            color: colorScheme.onTertiaryContainer,
          ),
          const SizedBox(width: 6),
          Text(
            'بانتظار المزامنة',
            style: TextStyle(
              fontSize: rv.isTablet ? 12 : 11,
              color: colorScheme.onTertiaryContainer,
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
    final colorScheme = Theme.of(context).colorScheme;
    final hasPhone = beneficiary.phoneNumber > 0;

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, size: rv.isTablet ? 26 : 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) => _handleAction(context, value),
      itemBuilder: (context) => [
        if (hasPhone)
          PopupMenuItem(
            value: 'call',
            child: Row(
              children: [
                Icon(
                  Icons.phone,
                  size: rv.isTablet ? 22 : 20,
                  color: colorScheme.secondary,
                ),
                SizedBox(width: rv.spacing),
                const Text('اتصال'),
              ],
            ),
          ),

        if (hasPhone)
          PopupMenuItem(
            value: 'whatsapp',
            child: Row(
              children: [
                Icon(
                  Icons.chat,
                  size: rv.isTablet ? 22 : 20,
                  color: colorScheme.secondary,
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
                color: colorScheme.error,
              ),
              SizedBox(width: rv.spacing),
              Text(
                'حذف',
                style: TextStyle(color: colorScheme.error),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleAction(BuildContext context, String action) async {
    final phoneStr = beneficiary.phoneNumber > 0 ? beneficiary.phoneNumber.toString() : null;

    switch (action) {
      case 'call':
        if (phoneStr == null) return;
        HapticPatterns.selection();
        await PhoneLauncherService.makeCall(phoneStr);
        break;

      case 'whatsapp':
        if (phoneStr == null) return;
        HapticPatterns.selection();
        await PhoneLauncherService.openWhatsApp(phoneStr);
        break;

      case 'edit':
        HapticPatterns.selection();
        if (context.mounted) {
          context.push('/beneficiaries/${beneficiary.id}/edit');
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
