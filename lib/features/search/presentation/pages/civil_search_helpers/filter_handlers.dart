import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/search_provider.dart';
import '../../widgets/age_filter_bottom_sheet.dart';
import '../../widgets/governorate_filter_bottom_sheet.dart';
import '../../widgets/gender_filter_bottom_sheet.dart';

/// 🎯 Filter Handlers
///
/// يحتوي على معالجات الفلاتر:
/// - Age filter
/// - Governorate filter
/// - Gender filter
/// - Clear filters
class FilterHandlers {
  FilterHandlers._();

  /// Show age filter bottom sheet
  static void showAgeFilter(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.read(searchProvider).filter;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AgeFilterBottomSheet(
        initialMinAge: currentFilter.minAge,
        initialMaxAge: currentFilter.maxAge,
        onApply: (minAge, maxAge) {
          ref.read(searchProvider.notifier).setAgeRange(minAge, maxAge);
          if (ref.read(searchProvider).query.isNotEmpty) {
            ref.read(searchProvider.notifier).search(reset: true);
          }
        },
      ),
    );
  }

  /// Show governorate filter bottom sheet
  static Future<void> showGovernorateFilter(
    BuildContext context,
    WidgetRef ref,
    List<String> availableGovernorates,
  ) async {
    final currentFilter = ref.read(searchProvider).filter;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GovernorateFilterBottomSheet(
        currentGovernorate: currentFilter.governorate,
        availableGovernorates: availableGovernorates,
        onApply: (governorate) {
          ref.read(searchProvider.notifier).setGovernorate(governorate);
          if (ref.read(searchProvider).query.isNotEmpty) {
            ref.read(searchProvider.notifier).search(reset: true);
          }
        },
      ),
    );
  }

  /// Show gender filter bottom sheet
  static void showGenderFilter(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.read(searchProvider).filter;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GenderFilterBottomSheet(
        currentGender: currentFilter.gender?.arabicLabel,
        onApply: (genderText) {
          ref.read(searchProvider.notifier).setGender(genderText);
          if (ref.read(searchProvider).query.isNotEmpty) {
            ref.read(searchProvider.notifier).search(reset: true);
          }
        },
      ),
    );
  }

  /// Clear all filters
  static void clearFilters(WidgetRef ref) {
    ref.read(searchProvider.notifier).clearFilters();
  }
}
