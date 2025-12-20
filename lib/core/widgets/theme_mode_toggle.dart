import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/theme_mode_provider.dart';
import '../theme/theme_mode_settings.dart';

/// 🌙 Theme Mode Toggle Widget
///
/// ويدجت لتبديل وضع السمة (فاتح/داكن/تلقائي)
class ThemeModeToggle extends ConsumerWidget {
  final bool showAutoSwitch;
  final bool compact;

  const ThemeModeToggle({
    super.key,
    this.showAutoSwitch = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themeModeNotifier = ref.read(themeModeProvider.notifier);
    final autoSwitch = themeModeNotifier.autoSwitch;

    if (compact) {
      return _buildCompactToggle(
          context, themeMode, themeModeNotifier, autoSwitch);
    }

    return _buildFullToggle(context, themeMode, themeModeNotifier, autoSwitch);
  }

  /// نسخة مدمجة (أيقونة فقط)
  Widget _buildCompactToggle(
    BuildContext context,
    ThemeMode themeMode,
    ThemeModeNotifier notifier,
    bool autoSwitch,
  ) {
    return IconButton(
      icon: Icon(
        autoSwitch
            ? Icons.brightness_auto_rounded
            : ThemeModeSettings.getThemeModeIcon(themeMode),
      ),
      tooltip: autoSwitch
          ? 'تلقائي (${ThemeModeSettings.getThemeModeLabel(themeMode)})'
          : ThemeModeSettings.getThemeModeLabel(themeMode),
      onPressed: () =>
          _showThemeModeDialog(context, themeMode, notifier, autoSwitch),
    );
  }

  /// نسخة كاملة (مع نص)
  Widget _buildFullToggle(
    BuildContext context,
    ThemeMode themeMode,
    ThemeModeNotifier notifier,
    bool autoSwitch,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(
          autoSwitch
              ? Icons.brightness_auto_rounded
              : ThemeModeSettings.getThemeModeIcon(themeMode),
          size: 28.sp,
        ),
        title: const Text('وضع السمة'),
        subtitle: Text(
          autoSwitch
              ? 'تلقائي (${ThemeModeSettings.getThemeModeLabel(themeMode)})'
              : ThemeModeSettings.getThemeModeLabel(themeMode),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: () =>
            _showThemeModeDialog(context, themeMode, notifier, autoSwitch),
      ),
    );
  }

  /// نافذة اختيار وضع السمة
  void _showThemeModeDialog(
    BuildContext context,
    ThemeMode currentMode,
    ThemeModeNotifier notifier,
    bool autoSwitch,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.palette_rounded, size: 28.sp),
            SizedBox(width: 12.w),
            const Text('اختيار وضع السمة'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // خيارات الوضع
            _buildThemeModeOption(
              context: context,
              mode: ThemeMode.light,
              currentMode: currentMode,
              autoSwitch: autoSwitch,
              onTap: () {
                notifier.setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 8.h),
            _buildThemeModeOption(
              context: context,
              mode: ThemeMode.dark,
              currentMode: currentMode,
              autoSwitch: autoSwitch,
              onTap: () {
                notifier.setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 8.h),
            _buildThemeModeOption(
              context: context,
              mode: ThemeMode.system,
              currentMode: currentMode,
              autoSwitch: autoSwitch,
              onTap: () {
                notifier.setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),

            if (showAutoSwitch) ...[
              Divider(height: 24.h),

              // خيار التبديل التلقائي
              SwitchListTile(
                title: const Text('تبديل تلقائي حسب الوقت'),
                subtitle: const Text('فاتح نهاراً (6ص-6م)\nداكن ليلاً (6م-6ص)'),
                value: autoSwitch,
                onChanged: (value) {
                  notifier.setAutoSwitch(value);
                  Navigator.pop(context);
                },
                secondary: Icon(Icons.schedule_rounded, size: 24.sp),
              ),
            ],
          ],
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

  /// خيار وضع السمة
  Widget _buildThemeModeOption({
    required BuildContext context,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required bool autoSwitch,
    required VoidCallback onTap,
  }) {
    final isSelected = !autoSwitch && mode == currentMode;
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12.r),
          color: isSelected
              ? theme.colorScheme.primaryContainer.withOpacity(0.3)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              ThemeModeSettings.getThemeModeIcon(mode),
              size: 24.sp,
              color: isSelected ? theme.colorScheme.primary : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                ThemeModeSettings.getThemeModeLabel(mode),
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? theme.colorScheme.primary : null,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                size: 20.sp,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
