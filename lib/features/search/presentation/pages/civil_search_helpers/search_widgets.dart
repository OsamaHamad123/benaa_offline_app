import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/utils/responsive_utils_v2.dart';
import '../../../../../core/utils/haptic_patterns.dart';
import '../../../search.dart' show statisticsProvider;

/// 🎯 App Bar Widgets
///
/// جميع الـ widgets المتعلقة بـ AppBar:
/// - Modern App Bar with statistics
/// - Loading App Bar
/// - Error App Bar
/// - Stat Chip

/// Modern App Bar with statistics and smooth animations
class ModernSearchAppBar extends ConsumerWidget {
  final ResponsiveValues rv;

  const ModernSearchAppBar({
    super.key,
    required this.rv,
  });

  static const _kAppBarGradient = LinearGradient(
    colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statisticsProvider);

    return statsAsync.when(
      data: (stats) => SliverAppBar(
        expandedHeight: rv.isMobile ? 200 : (rv.isTablet ? 220 : 240),
        floating: false,
        pinned: true,
        elevation: 0,
        stretch: true,
        flexibleSpace: FlexibleSpaceBar(
          titlePadding: EdgeInsets.zero,
          centerTitle: false,
          background: Container(
            decoration: const BoxDecoration(gradient: _kAppBarGradient),
            child: Stack(
              children: [
                // Title at top
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: rv.spacing,
                        right: rv.spacing,
                        top: rv.spacing * 0.5,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.people_alt_rounded,
                              size: 24, color: Colors.white),
                          const SizedBox(width: 10),
                          const Text(
                            'السجل المدني',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          // Update Normalization Button
                          IconButton(
                            icon: const Icon(Icons.build_circle_outlined,
                                color: Colors.white70),
                            onPressed: () {
                              // Navigate to update normalization
                            },
                            tooltip: 'تحديث Normalization',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Statistics at bottom
                Positioned(
                  bottom: rv.spacing * 1.2,
                  left: rv.padding.left,
                  right: rv.padding.right,
                  child: RepaintBoundary(
                    child: Wrap(
                      spacing: rv.spacing * 0.6,
                      runSpacing: rv.spacing * 0.4,
                      children: [
                        StatChip(
                          value: '${stats.totalPersons}',
                          label: 'مواطن',
                          icon: Icons.people,
                        ),
                        StatChip(
                          value: '${stats.malesCount}',
                          label: 'ذكور',
                          icon: Icons.male,
                        ),
                        StatChip(
                          value: '${stats.femalesCount}',
                          label: 'إناث',
                          icon: Icons.female,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      loading: () => LoadingAppBar(rv: rv),
      error: (_, __) => ErrorAppBar(rv: rv),
    );
  }
}

/// Loading App Bar
class LoadingAppBar extends StatelessWidget {
  final ResponsiveValues rv;

  const LoadingAppBar({super.key, required this.rv});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: rv.isMobile ? 160 : (rv.isTablet ? 180 : 200),
      floating: false,
      pinned: true,
      backgroundColor: Colors.grey.shade400,
      flexibleSpace: FlexibleSpaceBar(
        title: Text('السجل المدني', style: TextStyle(fontSize: rv.fontSize)),
        centerTitle: true,
      ),
    );
  }
}

/// Error App Bar
class ErrorAppBar extends StatelessWidget {
  final ResponsiveValues rv;

  const ErrorAppBar({super.key, required this.rv});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: rv.isMobile ? 160 : (rv.isTablet ? 180 : 200),
      floating: false,
      pinned: true,
      backgroundColor: Colors.red.shade400,
      flexibleSpace: FlexibleSpaceBar(
        title: Text('السجل المدني', style: TextStyle(fontSize: rv.fontSize)),
        centerTitle: true,
      ),
    );
  }
}

/// Stat Chip - Statistics display chip
class StatChip extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const StatChip({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Filter Buttons Row Widget
class FilterButtonsRow extends StatelessWidget {
  final dynamic filter;
  final double fontSize;
  final VoidCallback onAgeFilterTap;
  final VoidCallback onGovernorateFilterTap;
  final VoidCallback onGenderFilterTap;

  const FilterButtonsRow({
    super.key,
    required this.filter,
    required this.fontSize,
    required this.onAgeFilterTap,
    required this.onGovernorateFilterTap,
    required this.onGenderFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilterButton(
            onPressed: onAgeFilterTap,
            icon: Icons.calendar_today,
            label: filter.hasAgeFilter ? filter.ageRangeText : 'العمر',
            isActive: filter.hasAgeFilter,
            activeColor: Colors.blue,
            fontSize: fontSize,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilterButton(
            onPressed: onGovernorateFilterTap,
            icon: Icons.location_city,
            label: filter.governorate ?? 'المحافظة',
            isActive: filter.governorate != null,
            activeColor: Colors.green,
            fontSize: fontSize,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilterButton(
            onPressed: onGenderFilterTap,
            icon: filter.gender?.code == 1
                ? Icons.male
                : filter.gender?.code == 2
                    ? Icons.female
                    : Icons.people_alt,
            label: filter.gender?.arabicLabel ?? 'الجنس',
            isActive: filter.gender != null,
            activeColor: Colors.purple,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }
}

/// Individual Filter Button
class FilterButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final bool isActive;
  final MaterialColor activeColor;
  final double fontSize;

  const FilterButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        HapticPatterns.light();
        onPressed();
      },
      icon: Icon(
        icon,
        size: 18,
        color: isActive ? activeColor.shade700 : Colors.grey.shade600,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: fontSize * 0.85,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        backgroundColor: isActive ? activeColor.shade50 : Colors.transparent,
        foregroundColor: isActive ? activeColor.shade700 : Colors.grey.shade700,
        side: BorderSide(
          color: isActive ? activeColor.shade300 : Colors.grey.shade300,
          width: isActive ? 2 : 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
