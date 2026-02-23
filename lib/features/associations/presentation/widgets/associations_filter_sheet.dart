import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_utils_v2.dart';
import '../providers/associations_provider.dart';

/// 🎯 ورقة الفلاتر - Optimized Performance
///
/// Widget منفصل لعرض الفلاتر:
/// - ✅ StatefulWidget مع ValueNotifiers في initState (Performance)
/// - ✅ SafeArea و SingleChildScrollView لحل مشكلة overflow
/// - ✅ Responsive design للموبايل والتابلت
class AssociationsFilterSheet extends StatefulWidget {
  final bool showOnlyActive;
  final String? selectedRepresentativeId;
  final String? selectedCurrency;
  final Function(bool, String?, String?) onApply;

  const AssociationsFilterSheet({
    required this.showOnlyActive, required this.selectedRepresentativeId, required this.selectedCurrency, required this.onApply, super.key,
  });

  @override
  State<AssociationsFilterSheet> createState() =>
      _AssociationsFilterSheetState();
}

class _AssociationsFilterSheetState extends State<AssociationsFilterSheet> {
  late final ValueNotifier<bool> showActiveNotifier;
  late final ValueNotifier<String?> selectedRepNotifier;
  late final ValueNotifier<String?> selectedCurrencyNotifier;

  @override
  void initState() {
    super.initState();
    showActiveNotifier = ValueNotifier<bool>(widget.showOnlyActive);
    selectedRepNotifier =
        ValueNotifier<String?>(widget.selectedRepresentativeId);
    selectedCurrencyNotifier = ValueNotifier<String?>(widget.selectedCurrency);
  }

  @override
  void dispose() {
    showActiveNotifier.dispose();
    selectedRepNotifier.dispose();
    selectedCurrencyNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isTablet = ResponsiveUtils.isTablet(context);

    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
          left: ResponsiveUtils.mediumSpace,
          right: ResponsiveUtils.mediumSpace,
          top: ResponsiveUtils.mediumSpace,
          bottom: MediaQuery.of(context).viewInsets.bottom +
              ResponsiveUtils.mediumSpace,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // عنوان
              _buildHeader(context, isTablet),

              SizedBox(height: ResponsiveUtils.largeSpace),

              // فلتر النشطة فقط
              _buildActiveFilterSwitch(colorScheme),

              SizedBox(height: ResponsiveUtils.mediumSpace),

              // فلتر المندوب
              _buildRepresentativeFilter(),

              SizedBox(height: ResponsiveUtils.mediumSpace),

              // فلتر العملة
              _buildCurrencyFilter(),

              SizedBox(height: ResponsiveUtils.largeSpace),

              // أزرار الإجراءات
              _buildClearButton(isTablet),

              SizedBox(height: ResponsiveUtils.mediumSpace),

              _buildApplyButton(colorScheme, isTablet),
            ],
          ),
        ),
      ),
    );
  }

  /// عنوان الورقة
  Widget _buildHeader(BuildContext context, bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(
            Icons.close,
            size: ResponsiveUtils.getIconSize(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        Text(
          'الفلاتر',
          style: TextStyle(
            fontSize: isTablet
                ? ResponsiveUtils.headingFont
                : ResponsiveUtils.titleFont,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 48.w),
      ],
    );
  }

  /// فلتر الجمعيات النشطة
  Widget _buildActiveFilterSwitch(ColorScheme colorScheme) {
    return ValueListenableBuilder<bool>(
      valueListenable: showActiveNotifier,
      builder: (context, showActive, _) => SwitchListTile(
        value: showActive,
        onChanged: (value) => showActiveNotifier.value = value,
        title:
            const Text('عرض الجمعيات النشطة فقط', textAlign: TextAlign.right),
        activeThumbColor: colorScheme.primary,
      ),
    );
  }

  /// فلتر المندوب
  Widget _buildRepresentativeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'تصفية حسب المندوب',
          style: TextStyle(
            fontSize: ResponsiveUtils.bodyFont,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.right,
        ),
        SizedBox(height: ResponsiveUtils.smallSpace),
        Consumer(
          builder: (context, ref, child) {
            final representatives =
                ref.watch(associationsProvider).representatives;

            return ValueListenableBuilder<String?>(
              valueListenable: selectedRepNotifier,
              builder: (context, selectedRep, _) =>
                  DropdownButtonFormField<String?>(
                initialValue: selectedRep,
                decoration: InputDecoration(
                  hintText: 'اختر المندوب',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(ResponsiveUtils.mediumRadius),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.mediumSpace,
                    vertical: ResponsiveUtils.smallSpace,
                  ),
                ),
                items: [
                  const DropdownMenuItem(child: Text('الكل')),
                  ...representatives.map(
                    (rep) => DropdownMenuItem(
                      value: rep.id,
                      child: Text(rep.name, textAlign: TextAlign.right),
                    ),
                  ),
                ],
                onChanged: (value) => selectedRepNotifier.value = value,
              ),
            );
          },
        ),
      ],
    );
  }

  /// فلتر العملة
  Widget _buildCurrencyFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'تصفية حسب العملة',
          style: TextStyle(
            fontSize: ResponsiveUtils.bodyFont,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.right,
        ),
        SizedBox(height: ResponsiveUtils.smallSpace),
        ValueListenableBuilder<String?>(
          valueListenable: selectedCurrencyNotifier,
          builder: (context, selectedCurrency, _) =>
              DropdownButtonFormField<String?>(
            initialValue: selectedCurrency,
            decoration: InputDecoration(
              hintText: 'اختر العملة',
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(ResponsiveUtils.mediumRadius),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.mediumSpace,
                vertical: ResponsiveUtils.smallSpace,
              ),
            ),
            items: const [
              DropdownMenuItem(child: Text('الكل')),
              DropdownMenuItem(value: 'IQD', child: Text('دينار عراقي (IQD)')),
              DropdownMenuItem(value: 'USD', child: Text('دولار أمريكي (USD)')),
              DropdownMenuItem(value: 'EUR', child: Text('يورو (EUR)')),
            ],
            onChanged: (value) => selectedCurrencyNotifier.value = value,
          ),
        ),
      ],
    );
  }

  /// زر مسح الفلاتر
  Widget _buildClearButton(bool isTablet) {
    return OutlinedButton.icon(
      onPressed: () {
        HapticFeedback.lightImpact();
        showActiveNotifier.value = true;
        selectedRepNotifier.value = null;
        selectedCurrencyNotifier.value = null;
      },
      icon: Icon(
        Icons.clear_all,
        size: isTablet ? 22.r : 20.r,
      ),
      label: Text(
        'مسح الفلاتر',
        style: TextStyle(
          fontSize: ResponsiveUtils.bodyFont,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 16.h : 14.h,
          horizontal: ResponsiveUtils.mediumSpace,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
        ),
      ),
    );
  }

  /// زر تطبيق الفلاتر
  Widget _buildApplyButton(ColorScheme colorScheme, bool isTablet) {
    return ElevatedButton(
      onPressed: () {
        HapticFeedback.mediumImpact();
        widget.onApply(
          showActiveNotifier.value,
          selectedRepNotifier.value,
          selectedCurrencyNotifier.value,
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 18.h : 16.h,
          horizontal: ResponsiveUtils.largeSpace,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
        ),
      ),
      child: Text(
        'تطبيق الفلاتر',
        style: TextStyle(
          fontSize: ResponsiveUtils.mediumFont,
          color: Colors.white,
        ),
      ),
    );
  }
}
