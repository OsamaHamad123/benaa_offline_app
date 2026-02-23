import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/dashboard_settings_provider.dart';
import '../utils/dashboard_colors.dart';
import '../utils/dashboard_text_styles.dart';
import '../utils/dashboard_spacing.dart';

/// Dashboard Settings Page - تخصيص إعدادات الداشبورد
class DashboardSettingsPage extends ConsumerWidget {
  const DashboardSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(dashboardSettingsProvider);
    final notifier = ref.read(dashboardSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات الداشبورد'),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await notifier.resetToDefaults();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إعادة تعيين الإعدادات الافتراضية')),
                );
              }
            },
            icon: const Icon(Icons.restore, color: Colors.white),
            label: const Text('إعادة تعيين', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(DashboardSpacing.paddingMedium),
        children: [
          // Section Visibility
          _buildSectionCard(
            title: 'إظهار/إخفاء الأقسام',
            icon: Icons.visibility,
            children: [
              _buildSwitchTile(
                title: 'الإجراءات السريعة',
                value: settings.showQuickActions,
                onChanged: (value) => notifier.toggleSection('quickActions', value),
              ),
              _buildSwitchTile(
                title: 'الإحصائيات',
                value: settings.showStatistics,
                onChanged: (value) => notifier.toggleSection('statistics', value),
              ),
              _buildSwitchTile(
                title: 'الرسوم البيانية',
                value: settings.showCharts,
                onChanged: (value) => notifier.toggleSection('charts', value),
              ),
              _buildSwitchTile(
                title: 'التوزيع الجغرافي',
                value: settings.showGeographicDistribution,
                onChanged: (value) => notifier.toggleSection('geographicDistribution', value),
              ),
              _buildSwitchTile(
                title: 'الأداء اليومي',
                value: settings.showDailyPerformance,
                onChanged: (value) => notifier.toggleSection('dailyPerformance', value),
              ),
              _buildSwitchTile(
                title: 'الأنشطة الأخيرة',
                value: settings.showRecentActivities,
                onChanged: (value) => notifier.toggleSection('recentActivities', value),
              ),
            ],
          ),

          SizedBox(height: DashboardSpacing.medium),

          // Color Theme
          _buildSectionCard(
            title: 'نظام الألوان',
            icon: Icons.palette,
            children: [
              _buildColorThemeSelector(
                currentTheme: settings.colorTheme,
                onChanged: notifier.changeColorTheme,
              ),
            ],
          ),

          SizedBox(height: DashboardSpacing.medium),

          // Display Preferences
          _buildSectionCard(
            title: 'تفضيلات العرض',
            icon: Icons.tune,
            children: [
              _buildSwitchTile(
                title: 'إظهار لافتة الترحيب',
                value: settings.showWelcomeBanner,
                onChanged: notifier.toggleWelcomeBanner,
              ),
              _buildSwitchTile(
                title: 'إظهار شرائح التصفية',
                value: settings.showFilterChips,
                onChanged: notifier.toggleFilterChips,
              ),
              _buildSwitchTile(
                title: 'تفعيل الاهتزاز اللمسي',
                value: settings.enableHapticFeedback,
                onChanged: notifier.toggleHapticFeedback,
              ),
              _buildSwitchTile(
                title: 'تفعيل الحركات',
                value: settings.enableAnimations,
                onChanged: notifier.toggleAnimations,
              ),
            ],
          ),

          SizedBox(height: DashboardSpacing.medium),

          // Auto Refresh
          _buildSectionCard(
            title: 'التحديث التلقائي',
            icon: Icons.refresh,
            children: [
              _buildAutoRefreshSelector(
                currentSeconds: settings.autoRefreshSeconds,
                onChanged: notifier.updateAutoRefresh,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DashboardSpacing.radiusLarge),
      ),
      child: Padding(
        padding: EdgeInsets.all(DashboardSpacing.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: DashboardColors.totalBeneficiaries),
                SizedBox(width: DashboardSpacing.small),
                Text(title, style: DashboardTextStyles.cardTitle),
              ],
            ),
            SizedBox(height: DashboardSpacing.small),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: DashboardTextStyles.cardSubtitle),
      value: value,
      onChanged: onChanged,
      activeThumbColor: DashboardColors.success,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildColorThemeSelector({
    required String currentTheme,
    required ValueChanged<String> onChanged,
  }) {
    final themes = {
      'default': {'name': 'افتراضي', 'color': DashboardColors.totalBeneficiaries},
      'blue': {'name': 'أزرق', 'color': Colors.blue},
      'green': {'name': 'أخضر', 'color': Colors.green},
      'purple': {'name': 'بنفسجي', 'color': Colors.purple},
    };

    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: themes.entries.map((entry) {
        final isSelected = currentTheme == entry.key;
        return InkWell(
          onTap: () => onChanged(entry.key),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: DashboardSpacing.paddingMedium,
              vertical: DashboardSpacing.paddingSmall,
            ),
            decoration: BoxDecoration(
              color: entry.value['color'] as Color,
              borderRadius: BorderRadius.circular(DashboardSpacing.radiusMedium),
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
            ),
            child: Text(
              entry.value['name'] as String,
              style: DashboardTextStyles.cardSubtitle.copyWith(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAutoRefreshSelector({
    required int currentSeconds,
    required ValueChanged<int> onChanged,
  }) {
    final options = {
      0: 'معطل',
      60: 'كل دقيقة',
      300: 'كل 5 دقائق',
      600: 'كل 10 دقائق',
      1800: 'كل 30 دقيقة',
    };

    return DropdownButtonFormField<int>(
      initialValue: currentSeconds,
      decoration: InputDecoration(
        labelText: 'فترة التحديث التلقائي',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DashboardSpacing.radiusMedium),
        ),
      ),
      items: options.entries.map((entry) {
        return DropdownMenuItem(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
