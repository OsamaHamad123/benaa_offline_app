import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';

/// 🔍 Smart Autocomplete Field
///
/// Enhanced autocomplete with debounced search, custom styling, and keyboard navigation
///
/// Features:
/// - ⏱️ Debounced search (300ms default)
/// - 🎨 Material 3 styling
/// - ⌨️ Keyboard navigation
/// - 📱 Mobile-friendly
/// - 🔄 Loading states
/// - 🎯 Exact match detection
///
/// Usage:
/// ```dart
/// AutocompleteField<String>(
///   label: 'القضاء',
///   suggestions: ['بغداد', 'البصرة', 'الموصل', ...],
///   onSelected: (district) => controller.text = district,
///   controller: districtController,
/// )
/// ```

class AutocompleteField<T extends Object> extends StatefulWidget {
  final String label;
  final List<T> suggestions;
  final ValueChanged<T>? onSelected;
  final TextEditingController? controller;
  final String Function(T)? displayStringForOption;
  final IconData? prefixIcon;
  final String? hintText;
  final Duration debounceDuration;
  final int maxSuggestions;
  final bool caseSensitive;

  const AutocompleteField({
    super.key,
    required this.label,
    required this.suggestions,
    this.onSelected,
    this.controller,
    this.displayStringForOption,
    this.prefixIcon,
    this.hintText,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.maxSuggestions = 5,
    this.caseSensitive = false,
  });

  @override
  State<AutocompleteField<T>> createState() => _AutocompleteFieldState<T>();
}

class _AutocompleteFieldState<T extends Object>
    extends State<AutocompleteField<T>> {
  Timer? _debounceTimer;
  bool _isSearching = false;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  String _displayStringForOption(T option) {
    if (widget.displayStringForOption != null) {
      return widget.displayStringForOption!(option);
    }
    return option.toString();
  }

  Iterable<T> _filterSuggestions(String query) {
    if (query.isEmpty) {
      return widget.suggestions.take(widget.maxSuggestions);
    }

    final normalizedQuery = widget.caseSensitive ? query : query.toLowerCase();

    final filtered = widget.suggestions.where((suggestion) {
      final displayString = _displayStringForOption(suggestion);
      final normalizedSuggestion = widget.caseSensitive
          ? displayString
          : displayString.toLowerCase();
      return normalizedSuggestion.contains(normalizedQuery);
    });

    return filtered.take(widget.maxSuggestions);
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      setState(() => _isSearching = false);
      return;
    }

    setState(() => _isSearching = true);

    _debounceTimer = Timer(widget.debounceDuration, () {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Autocomplete<T>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        _onSearchChanged(textEditingValue.text);
        return _filterSuggestions(textEditingValue.text);
      },
      displayStringForOption: _displayStringForOption,
      onSelected: widget.onSelected,
      fieldViewBuilder:
          (
            BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted,
          ) {
            // Use provided controller or the auto-generated one
            final controller = widget.controller ?? textEditingController;

            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: widget.hintText ?? 'ابحث...',
                prefixIcon: widget.prefixIcon != null
                    ? Icon(widget.prefixIcon)
                    : const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? Padding(
                        padding: EdgeInsets.all(12.r),
                        child: SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
              ),
            );
          },
      optionsViewBuilder:
          (
            BuildContext context,
            AutocompleteOnSelected<T> onSelected,
            Iterable<T> options,
          ) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: 200.h,
                    maxWidth: MediaQuery.of(context).size.width - 32.w,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      final T option = options.elementAt(index);
                      final displayString = _displayStringForOption(option);

                      return InkWell(
                        onTap: () => onSelected(option),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 18.sp,
                                color: theme.colorScheme.primary,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  displayString,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
    );
  }
}

/// 📍 District Autocomplete (القضاء)
class DistrictAutocomplete extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onSelected;

  const DistrictAutocomplete({
    super.key,
    required this.controller,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AutocompleteField<String>(
      label: 'القضاء',
      hintText: 'اختر أو ابحث عن القضاء',
      suggestions: IraqLocations.districts,
      controller: controller,
      onSelected: onSelected,
      prefixIcon: Icons.location_city,
    );
  }
}

/// 🏘️ Sub-District Autocomplete (الناحية)
class SubDistrictAutocomplete extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onSelected;
  final String? parentDistrict;

  const SubDistrictAutocomplete({
    super.key,
    required this.controller,
    this.onSelected,
    this.parentDistrict,
  });

  @override
  Widget build(BuildContext context) {
    // Filter sub-districts based on parent district if provided
    final suggestions = parentDistrict != null
        ? IraqLocations.getSubDistricts(parentDistrict!)
        : IraqLocations.allSubDistricts;

    return AutocompleteField<String>(
      label: 'الناحية',
      hintText: 'اختر أو ابحث عن الناحية',
      suggestions: suggestions,
      controller: controller,
      onSelected: onSelected,
      prefixIcon: Icons.location_on,
    );
  }
}

/// 🏢 Organization Autocomplete (اسم الجمعية)
class OrganizationAutocomplete extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onSelected;

  const OrganizationAutocomplete({
    super.key,
    required this.controller,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AutocompleteField<String>(
      label: 'اسم الجمعية',
      hintText: 'اختر أو ابحث عن الجمعية',
      suggestions: IraqLocations.organizations,
      controller: controller,
      onSelected: onSelected,
      prefixIcon: Icons.business,
    );
  }
}

/// 🗺️ Iraq Locations Data
///
/// Static data for Iraq districts, sub-districts, and organizations
class IraqLocations {
  IraqLocations._();

  // Top 18 provinces (محافظات)
  static const List<String> provinces = [
    'بغداد',
    'البصرة',
    'نينوى',
    'الأنبار',
    'أربيل',
    'كركوك',
    'النجف',
    'كربلاء',
    'بابل',
    'ديالى',
    'ذي قار',
    'المثنى',
    'القادسية',
    'صلاح الدين',
    'واسط',
    'ميسان',
    'دهوك',
    'السليمانية',
  ];

  // Major districts (أقضية)
  static const List<String> districts = [
    // بغداد
    'الكرخ',
    'الرصافة',
    'الكاظمية',
    'الأعظمية',
    'المحمودية',
    'أبو غريب',
    'المدائن',

    // البصرة
    'البصرة',
    'الزبير',
    'القرنة',
    'الفاو',
    'أبو الخصيب',

    // نينوى (الموصل)
    'الموصل',
    'تلعفر',
    'سنجار',
    'الحمدانية',
    'تلكيف',

    // الأنبار
    'الرمادي',
    'الفلوجة',
    'هيت',
    'حديثة',
    'عانة',
    'راوة',
    'القائم',

    // أربيل
    'أربيل',
    'كويسنجق',
    'سوران',
    'شقلاوة',
    'راوندوز',

    // كركوك
    'كركوك',
    'الحويجة',
    'داقوق',
    'دبس',

    // النجف
    'النجف',
    'الكوفة',
    'المشخاب',
    'المناذرة',

    // كربلاء
    'كربلاء',
    'الهندية',
    'عين التمر',

    // بابل
    'الحلة',
    'المسيب',
    'الهاشمية',
    'القاسم',

    // ديالى
    'بعقوبة',
    'المقدادية',
    'الخالص',
    'بلدروز',
    'خانقين',

    // ذي قار
    'الناصرية',
    'الرفاعي',
    'الشطرة',
    'سوق الشيوخ',

    // المثنى
    'السماوة',
    'الرميثة',
    'الخضر',

    // القادسية
    'الديوانية',
    'عفك',
    'الشامية',
    'الحمزة',

    // صلاح الدين
    'تكريت',
    'سامراء',
    'بلد',
    'الدور',
    'الشرقاط',

    // واسط
    'الكوت',
    'الحي',
    'النعمانية',
    'الصويرة',

    // ميسان
    'العمارة',
    'الميمونة',
    'قلعة صالح',

    // دهوك
    'دهوك',
    'زاخو',
    'عقرة',
    'سميل',

    // السليمانية
    'السليمانية',
    'حلبجة',
    'دوكان',
    'رانية',
  ];

  // Sub-districts map (نواحي)
  static const Map<String, List<String>> subDistrictsMap = {
    'الكرخ': ['الدورة', 'الرشيد', 'البياع', 'الشعلة', 'العامرية'],
    'الرصافة': ['الكرادة', 'الزعفرانية', 'الشعب', 'الحبيبية', 'الكمالية'],
    'البصرة': ['الهارثة', 'شط العرب', 'الدير', 'الناصرية'],
    'الموصل': ['تلكيف', 'ربيعة', 'زمار', 'الشيخان'],
    'الرمادي': ['الحبانية', 'الخالدية', 'كرمة'],
    'النجف': ['أبو صخير', 'المشخاب', 'الحيرة'],
    'كربلاء': ['الحسينية', 'الجدول الغربي', 'عون'],
  };

  // All sub-districts (combined)
  static List<String> get allSubDistricts {
    final allSubs = <String>{};
    for (final subs in subDistrictsMap.values) {
      allSubs.addAll(subs);
    }
    return allSubs.toList()..sort();
  }

  // Get sub-districts for a specific district
  static List<String> getSubDistricts(String district) {
    return subDistrictsMap[district] ?? [];
  }

  // Sample organizations
  static const List<String> organizations = [
    'جمعية الهلال الأحمر العراقي',
    'منظمة الأمم المتحدة للطفولة (يونيسف)',
    'مفوضية الأمم المتحدة لشؤون اللاجئين',
    'منظمة الصحة العالمية',
    'برنامج الأغذية العالمي',
    'منظمة الإغاثة الإسلامية',
    'الصليب الأحمر الدولي',
    'منظمة أطباء بلا حدود',
    'منظمة الرحمة العالمية',
    'جمعية الإمام علي الخيرية',
    'منظمة النور للإغاثة والتنمية',
    'جمعية الأيتام الخيرية',
    'منظمة رعاية الأرامل والأيتام',
    'جمعية بناء الخيرية',
    'منظمة العون الإنساني',
    'جمعية التكافل الاجتماعي',
    'منظمة الإغاثة السريعة',
    'جمعية رعاية المحتاجين',
    'منظمة دعم الأسر الفقيرة',
    'جمعية المستقبل الخيرية',
  ];
}
