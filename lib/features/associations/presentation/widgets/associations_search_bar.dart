import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/responsive_utils_v2.dart';

/// 🔍 شريط البحث للجمعيات
///
/// Widget قابل لإعادة الاستخدام لشريط البحث مع:
/// - ✅ تصميم responsive
/// - ✅ زر مسح مع حالات الفلاتر
/// - ✅ نصوص توضيحية مختلفة للموبايل والتابلت
class AssociationsSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String searchQuery;
  final bool showOnlyActive;
  final String? selectedRepresentativeId;
  final String? selectedCurrency;
  final String? selectedAssociationTypeCode;
  final VoidCallback onClearAll;

  const AssociationsSearchBar({
    required this.controller,
    required this.onChanged,
    required this.searchQuery,
    required this.showOnlyActive,
    required this.onClearAll,
    super.key,
    this.selectedRepresentativeId,
    this.selectedCurrency,
    this.selectedAssociationTypeCode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isTablet = ResponsiveUtils.isTablet(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.mediumSpace),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: ResponsiveUtils.bodyFont),
              decoration: InputDecoration(
                hintText:
                    isTablet ? 'بحث عن جمعية... (الاسم، المندوب، البنك، رقم الحساب)' : 'بحث بالاسم، المندوب، البنك...',
                hintStyle: TextStyle(
                  fontSize: ResponsiveUtils.smallFont,
                  color: isDark ? colorScheme.onSurface.withOpacity(0.6) : Colors.grey.shade600,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: colorScheme.primary,
                  size: ResponsiveUtils.getIconSize(context),
                ),
                filled: true,
                fillColor: isDark ? colorScheme.surfaceContainerHighest : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.mediumSpace,
                  vertical: ResponsiveUtils.smallSpace,
                ),
              ),
            ),
          ),
          if (searchQuery.isNotEmpty ||
              !showOnlyActive ||
              selectedRepresentativeId != null ||
              selectedCurrency != null ||
              selectedAssociationTypeCode != null)
            Padding(
              padding: EdgeInsets.only(right: ResponsiveUtils.smallSpace),
              child: IconButton(
                icon: Icon(
                  Icons.clear,
                  size: ResponsiveUtils.getIconSize(context),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  controller.clear();
                  onClearAll();
                },
                tooltip: 'مسح الكل',
              ),
            ),
        ],
      ),
    );
  }
}
