import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../widgets/modern_sliver_app_bar.dart';
import 'settings_provider.dart';
import '../error_handling/error_handler.dart';

/// 🎯 Enhanced Settings Page - صفحة الإعدادات المحسّنة
class EnhancedSettingsPage extends ConsumerWidget {
  const EnhancedSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            cacheExtent: 500,
            slivers: [
              // Modern App Bar - مكون موحد
              ModernSliverAppBar(
                title: 'الإعدادات',
                icon: Icons.settings_rounded,
                isTablet: isTablet,
                actions: [
                  ModernActionButton(
                    icon: Icons.restore_rounded,
                    tooltip: 'استعادة الإعدادات الافتراضية',
                    onPressed: () => _showResetDialog(context, notifier),
                  ),
                ],
              ),

              // Content
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  vertical: isTablet ? 16.h : 8.h,
                  horizontal: isTablet ? 24.w : 0,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Notifications Section
                    _buildSectionHeader(
                      context,
                      'الإشعارات',
                      Icons.notifications_rounded,
                      Colors.orange,
                    ),
                    _buildSettingsCard(context, [
                      _buildSwitchTile(
                        context,
                        title: 'تفعيل الإشعارات',
                        subtitle: 'عرض إشعارات للأحداث المهمة',
                        value: settings.notificationsEnabled,
                        onChanged: notifier.setNotificationsEnabled,
                        icon: Icons.notifications_active_rounded,
                        color: Colors.orange,
                      ),
                      _buildDivider(),
                      _buildSwitchTile(
                        context,
                        title: 'الصوت',
                        subtitle: 'تشغيل الأصوات مع الإشعارات',
                        value: settings.soundEnabled,
                        onChanged: settings.notificationsEnabled ? notifier.setSoundEnabled : null,
                        icon: Icons.volume_up_rounded,
                        color: Colors.deepOrange,
                      ),
                      _buildDivider(),
                      _buildSwitchTile(
                        context,
                        title: 'الاهتزاز',
                        subtitle: 'اهتزاز الجهاز عند الإجراءات',
                        value: settings.vibrationEnabled,
                        onChanged: settings.notificationsEnabled ? notifier.setVibrationEnabled : null,
                        icon: Icons.vibration_rounded,
                        color: Colors.amber,
                      ),
                    ]),

                    SizedBox(height: 16.h),

                    // Sync Section
                    _buildSectionHeader(
                      context,
                      'المزامنة',
                      Icons.sync_rounded,
                      Colors.blue,
                    ),
                    _buildSettingsCard(context, [
                      _buildSwitchTile(
                        context,
                        title: 'مزامنة تلقائية',
                        subtitle: 'مزامنة البيانات تلقائياً في الخلفية',
                        value: settings.autoSyncEnabled,
                        onChanged: notifier.setAutoSyncEnabled,
                        icon: Icons.cloud_sync_rounded,
                        color: Colors.blue,
                      ),
                      _buildDivider(),
                      _buildSwitchTile(
                        context,
                        title: 'WiFi فقط',
                        subtitle: 'المزامنة عند الاتصال بـ WiFi فقط',
                        value: settings.wifiOnlySync,
                        onChanged: settings.autoSyncEnabled ? notifier.setWifiOnlySync : null,
                        icon: Icons.wifi_rounded,
                        color: Colors.lightBlue,
                      ),
                      _buildDivider(),
                      _buildNavigationTile(
                        context,
                        title: 'فترة المزامنة التلقائية',
                        subtitle: 'كل ${settings.syncIntervalHours} ساعة',
                        icon: Icons.schedule_rounded,
                        color: Colors.indigo,
                        onTap: settings.autoSyncEnabled
                            ? () => _showSyncIntervalDialog(
                                  context,
                                  notifier,
                                  settings,
                                )
                            : null,
                      ),
                    ]),

                    SizedBox(height: 16.h),

                    // Theme Section
                    _buildSectionHeader(
                      context,
                      'المظهر',
                      Icons.palette_rounded,
                      Colors.purple,
                    ),
                    _buildSettingsCard(context, [
                      _buildNavigationTile(
                        context,
                        title: 'وضع المظهر',
                        subtitle: _getThemeModeLabel(settings.themeMode),
                        icon: _getThemeModeIcon(settings.themeMode),
                        color: Colors.purple,
                        onTap: () => _showThemeModeDialog(context, notifier, settings),
                      ),
                      _buildDivider(),
                      _buildColorSchemeTile(
                        context,
                        settings.colorScheme,
                        () => _showColorSchemeDialog(context, notifier, settings),
                      ),
                      _buildDivider(),
                      _buildNavigationTile(
                        context,
                        title: 'حجم الخط',
                        subtitle: '${settings.fontSize.toInt()} نقطة',
                        icon: Icons.text_fields_rounded,
                        color: Colors.deepPurple,
                        onTap: () => _showFontSizeDialog(context, notifier, settings),
                      ),
                      _buildDivider(),
                      _buildSwitchTile(
                        context,
                        title: 'Material Design 3',
                        subtitle: 'استخدام التصميم الحديث',
                        value: settings.useMaterial3,
                        onChanged: notifier.setUseMaterial3,
                        icon: Icons.design_services_rounded,
                        color: Colors.purpleAccent,
                      ),
                    ]),

                    SizedBox(height: 16.h),

                    // Display Section
                    _buildSectionHeader(
                      context,
                      'العرض',
                      Icons.display_settings_rounded,
                      Colors.teal,
                    ),
                    _buildSettingsCard(context, [
                      _buildNavigationTile(
                        context,
                        title: 'عدد العناصر في الصفحة',
                        subtitle: '${settings.itemsPerPage} عنصر',
                        icon: Icons.list_rounded,
                        color: Colors.teal,
                        onTap: () => _showItemsPerPageDialog(
                          context,
                          notifier,
                          settings,
                        ),
                      ),
                      _buildDivider(),
                      _buildNavigationTile(
                        context,
                        title: 'الترتيب الافتراضي',
                        subtitle: _getSortLabel(settings.defaultSort),
                        icon: Icons.sort_rounded,
                        color: Colors.cyan,
                        onTap: () => _showDefaultSortDialog(context, notifier, settings),
                      ),
                      _buildDivider(),
                      _buildSwitchTile(
                        context,
                        title: 'عرض الإحصائيات',
                        subtitle: 'إظهار لوحة الإحصائيات في الصفحة الرئيسية',
                        value: settings.showStatistics,
                        onChanged: notifier.setShowStatistics,
                        icon: Icons.bar_chart_rounded,
                        color: Colors.tealAccent,
                      ),
                    ]),

                    SizedBox(height: 16.h),

                    // Data Section
                    _buildSectionHeader(
                      context,
                      'البيانات',
                      Icons.storage_rounded,
                      Colors.green,
                    ),
                    _buildSettingsCard(context, [
                      _buildSwitchTile(
                        context,
                        title: 'وضع عدم الاتصال',
                        subtitle: 'العمل بدون اتصال بالإنترنت',
                        value: settings.offlineMode,
                        onChanged: notifier.setOfflineMode,
                        icon: Icons.cloud_off_rounded,
                        color: Colors.green,
                      ),
                      _buildDivider(),
                      _buildNavigationTile(
                        context,
                        title: 'مدة التخزين المؤقت',
                        subtitle: '${settings.cacheDurationMinutes} دقيقة',
                        icon: Icons.access_time_rounded,
                        color: Colors.lightGreen,
                        onTap: () => _showCacheDurationDialog(
                          context,
                          notifier,
                          settings,
                        ),
                      ),
                      _buildDivider(),
                      _buildNavigationTile(
                        context,
                        title: 'حجم سجل البحث',
                        subtitle: '${settings.searchHistorySize} عملية بحث',
                        icon: Icons.history_rounded,
                        color: Colors.greenAccent,
                        onTap: () => _showSearchHistorySizeDialog(
                          context,
                          notifier,
                          settings,
                        ),
                      ),
                    ]),

                    SizedBox(height: 16.h),

                    // Advanced Section
                    _buildSectionHeader(
                      context,
                      'متقدم',
                      Icons.developer_mode_rounded,
                      Colors.red,
                    ),
                    _buildSettingsCard(context, [
                      _buildSwitchTile(
                        context,
                        title: 'وضع المطور',
                        subtitle: 'إظهار خيارات المطورين',
                        value: settings.developerMode,
                        onChanged: notifier.setDeveloperMode,
                        icon: Icons.code_rounded,
                        color: Colors.red,
                      ),
                      if (settings.developerMode) ...[
                        _buildDivider(),
                        _buildSwitchTile(
                          context,
                          title: 'تسجيل Debug',
                          subtitle: 'حفظ سجلات التطبيق التفصيلية',
                          value: settings.debugLogging,
                          onChanged: notifier.setDebugLogging,
                          icon: Icons.bug_report_rounded,
                          color: Colors.deepOrange,
                        ),
                        _buildDivider(),
                        _buildSwitchTile(
                          context,
                          title: 'عرض معلومات Debug',
                          subtitle: 'إظهار معلومات التشخيص على الشاشة',
                          value: settings.showDebugInfo,
                          onChanged: notifier.setShowDebugInfo,
                          icon: Icons.info_outline_rounded,
                          color: Colors.amber,
                        ),
                        _buildDivider(),
                        _buildSwitchTile(
                          context,
                          title: 'لوحة الأداء',
                          subtitle: 'عرض معلومات الأداء (FPS, Memory)',
                          value: settings.showPerformanceDashboard,
                          onChanged: notifier.setShowPerformanceDashboard,
                          icon: Icons.speed_rounded,
                          color: Colors.pink,
                        ),
                        _buildDivider(),
                        _buildNavigationTile(
                          context,
                          title: '📊 UX Analytics',
                          subtitle: 'عرض إحصائيات استخدام التحسينات',
                          icon: Icons.analytics_rounded,
                          color: Colors.teal,
                          onTap: () => context.push('/analytics'),
                        ),
                        _buildDivider(),
                        _buildNavigationTile(
                          context,
                          title: '📈 Performance Monitor',
                          subtitle: 'مراقبة الأداء في الوقت الفعلي (FPS, Frame Time)',
                          icon: Icons.monitor_heart_rounded,
                          color: Colors.purple,
                          onTap: () => context.push('/performance-monitor'),
                        ),
                        _buildDivider(),
                        _buildNavigationTile(
                          context,
                          title: '🐛 Sentry Test',
                          subtitle: 'اختبار تقارير الأخطاء والمراقبة',
                          icon: Icons.bug_report_rounded,
                          color: Colors.red,
                          onTap: () => context.push('/sentry-test'),
                        ),
                      ],
                    ]),

                    SizedBox(height: isTablet ? 120.h : 100.h),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // BUILDER METHODS
  // ═══════════════════════════════════════════════════════════════════════════════

  // Optimized divider widget
  static Widget _buildDivider() {
    return Divider(height: 1.h, indent: 72.w, thickness: 0.5);
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, List<Widget> children) {
    return RepaintBoundary(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool)? onChanged,
    required IconData icon,
    required Color color,
  }) {
    final isEnabled = onChanged != null;
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: color.withOpacity(isEnabled ? 0.1 : 0.05),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, color: isEnabled ? color : Colors.grey, size: 24.sp),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: isEnabled ? Colors.black87 : Colors.grey,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12.sp,
          color: isEnabled ? Colors.grey[600] : Colors.grey[400],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildNavigationTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: color.withOpacity(isEnabled ? 0.1 : 0.05),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, color: isEnabled ? color : Colors.grey, size: 24.sp),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: isEnabled ? Colors.black87 : Colors.grey,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12.sp,
          color: isEnabled ? Colors.grey[600] : Colors.grey[400],
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isEnabled ? Colors.grey : Colors.grey[300],
        size: 24.sp,
      ),
      onTap: onTap,
    );
  }

  Widget _buildColorSchemeTile(
    BuildContext context,
    String currentScheme,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          Icons.color_lens_rounded,
          color: Colors.purple,
          size: 24.sp,
        ),
      ),
      title: Text(
        'نظام الألوان',
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        _getColorSchemeLabel(currentScheme),
        style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: _getColorFromScheme(currentScheme),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 2),
              boxShadow: [
                BoxShadow(
                  color: _getColorFromScheme(currentScheme).withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 24.sp),
        ],
      ),
      onTap: onTap,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════════

  IconData _getThemeModeIcon(String mode) {
    switch (mode) {
      case 'light':
        return Icons.wb_sunny_rounded;
      case 'dark':
        return Icons.nights_stay_rounded;
      default:
        return Icons.brightness_auto_rounded;
    }
  }

  String _getThemeModeLabel(String mode) {
    switch (mode) {
      case 'light':
        return 'فاتح';
      case 'dark':
        return 'داكن';
      case 'system':
      default:
        return 'تلقائي (حسب النظام)';
    }
  }

  String _getColorSchemeLabel(String scheme) {
    switch (scheme) {
      case 'blue':
        return 'أزرق';
      case 'green':
        return 'أخضر';
      case 'purple':
        return 'بنفسجي';
      case 'orange':
        return 'برتقالي';
      case 'red':
        return 'أحمر';
      case 'teal':
        return 'أزرق مخضر';
      case 'indigo':
        return 'نيلي';
      case 'pink':
        return 'وردي';
      default:
        return 'أزرق';
    }
  }

  Color _getColorFromScheme(String scheme) {
    switch (scheme) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      case 'teal':
        return Colors.teal;
      case 'indigo':
        return Colors.indigo;
      case 'pink':
        return Colors.pink;
      default:
        return Colors.blue;
    }
  }

  String _getSortLabel(String sort) {
    switch (sort) {
      case 'name_asc':
        return 'الاسم (تصاعدي)';
      case 'name_desc':
        return 'الاسم (تنازلي)';
      case 'date_asc':
        return 'التاريخ (الأقدم أولاً)';
      case 'date_desc':
        return 'التاريخ (الأحدث أولاً)';
      case 'id_asc':
        return 'رقم الملف (تصاعدي)';
      case 'id_desc':
        return 'رقم الملف (تنازلي)';
      default:
        return 'الاسم (تصاعدي)';
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // DIALOG METHODS
  // ═══════════════════════════════════════════════════════════════════════════════

  void _showResetDialog(BuildContext context, SettingsNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isTablet ? 32.w : 24.w,
              vertical: isTablet ? 24.h : 20.h,
            ),
            title: Row(
              children: [
                Icon(
                  Icons.restore_rounded,
                  color: Colors.orange,
                  size: isTablet ? 32.sp : 28.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'استعادة الإعدادات',
                    style: TextStyle(
                      fontSize: isTablet ? 22.sp : 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isTablet ? 500 : 300),
              child: Text(
                'هل تريد استعادة جميع الإعدادات إلى القيم الافتراضية؟',
                style: TextStyle(fontSize: isTablet ? 16.sp : 14.sp),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 16.w : 8.w,
                    vertical: isTablet ? 12.h : 8.h,
                  ),
                  child: Text(
                    'إلغاء',
                    style: TextStyle(fontSize: isTablet ? 16.sp : 14.sp),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await notifier.resetToDefaults();
                  if (context.mounted) {
                    Navigator.pop(context);
                    EnhancedSnackbar.showSuccess(
                      context,
                      message: 'تم استعادة الإعدادات الافتراضية',
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 24.w : 16.w,
                    vertical: isTablet ? 16.h : 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'استعادة',
                  style: TextStyle(fontSize: isTablet ? 16.sp : 14.sp),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showThemeModeDialog(
    BuildContext context,
    SettingsNotifier notifier,
    SettingsState settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.palette_rounded, color: Colors.purple, size: 28.sp),
            SizedBox(width: 12.w),
            const Text('اختر وضع المظهر'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeModeOption(
              context,
              'فاتح',
              'light',
              Icons.wb_sunny_rounded,
              Colors.orange,
              settings.themeMode,
              (value) {
                notifier.setThemeMode(value);
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 8.h),
            _buildThemeModeOption(
              context,
              'داكن',
              'dark',
              Icons.nights_stay_rounded,
              Colors.indigo,
              settings.themeMode,
              (value) {
                notifier.setThemeMode(value);
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 8.h),
            _buildThemeModeOption(
              context,
              'تلقائي (حسب النظام)',
              'system',
              Icons.brightness_auto_rounded,
              Colors.blue,
              settings.themeMode,
              (value) {
                notifier.setThemeMode(value);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeModeOption(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
    String currentValue,
    Function(String) onSelected,
  ) {
    final isSelected = value == currentValue;
    return InkWell(
      onTap: () => onSelected(value),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 24.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : Colors.black87,
                ),
              ),
            ),
            if (isSelected) Icon(Icons.check_circle_rounded, color: color, size: 24.sp),
          ],
        ),
      ),
    );
  }

  void _showColorSchemeDialog(
    BuildContext context,
    SettingsNotifier notifier,
    SettingsState settings,
  ) {
    final schemes = {
      'blue': {'name': 'أزرق', 'color': Colors.blue},
      'green': {'name': 'أخضر', 'color': Colors.green},
      'purple': {'name': 'بنفسجي', 'color': Colors.purple},
      'orange': {'name': 'برتقالي', 'color': Colors.orange},
      'red': {'name': 'أحمر', 'color': Colors.red},
      'teal': {'name': 'أزرق مخضر', 'color': Colors.teal},
      'indigo': {'name': 'نيلي', 'color': Colors.indigo},
      'pink': {'name': 'وردي', 'color': Colors.pink},
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.color_lens_rounded, color: Colors.purple, size: 28.sp),
            SizedBox(width: 12.w),
            const Text('اختر نظام الألوان'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
            ),
            itemCount: schemes.length,
            itemBuilder: (context, index) {
              final entry = schemes.entries.elementAt(index);
              final scheme = entry.key;
              final data = entry.value;
              final isSelected = scheme == settings.colorScheme;

              return InkWell(
                onTap: () {
                  notifier.setColorScheme(scheme);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        data['color'] as Color,
                        (data['color'] as Color).withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
                    boxShadow: [
                      BoxShadow(
                        color: (data['color'] as Color).withOpacity(0.3),
                        blurRadius: isSelected ? 8 : 4,
                        spreadRadius: isSelected ? 2 : 0,
                      ),
                    ],
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 32.sp,
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showFontSizeDialog(
    BuildContext context,
    SettingsNotifier notifier,
    SettingsState settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => _FontSizeDialog(
        notifier: notifier,
        initialFontSize: settings.fontSize,
      ),
    );
  }

  void _showSyncIntervalDialog(
    BuildContext context,
    SettingsNotifier notifier,
    SettingsState settings,
  ) {
    final intervals = [
      {'hours': 1, 'label': 'كل ساعة'},
      {'hours': 6, 'label': 'كل 6 ساعات'},
      {'hours': 12, 'label': 'كل 12 ساعة'},
      {'hours': 24, 'label': 'كل 24 ساعة (يومياً)'},
      {'hours': 48, 'label': 'كل 48 ساعة (يومين)'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.schedule_rounded, color: Colors.indigo, size: 28.sp),
            SizedBox(width: 12.w),
            const Text('فترة المزامنة'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: intervals
              .map(
                (interval) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: _buildIntervalOption(
                    context,
                    interval['label'] as String,
                    interval['hours'] as int,
                    settings.syncIntervalHours,
                    (value) {
                      notifier.setSyncInterval(value);
                      Navigator.pop(context);
                    },
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildIntervalOption(
    BuildContext context,
    String label,
    int hours,
    int currentValue,
    Function(int) onSelected,
  ) {
    final isSelected = hours == currentValue;
    return InkWell(
      onTap: () => onSelected(hours),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? Colors.indigo : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              color: isSelected ? Colors.indigo : Colors.grey,
              size: 24.sp,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.indigo : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: Colors.indigo,
                size: 24.sp,
              ),
          ],
        ),
      ),
    );
  }

  void _showItemsPerPageDialog(
    BuildContext context,
    SettingsNotifier notifier,
    SettingsState settings,
  ) {
    final counts = [10, 20, 30, 50, 100];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.list_rounded, color: Colors.teal, size: 28.sp),
            SizedBox(width: 12.w),
            const Text('عدد العناصر في الصفحة'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: counts
              .map(
                (count) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: _buildItemCountOption(
                    context,
                    count,
                    settings.itemsPerPage,
                    (value) {
                      notifier.setItemsPerPage(value);
                      Navigator.pop(context);
                    },
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildItemCountOption(
    BuildContext context,
    int count,
    int currentValue,
    Function(int) onSelected,
  ) {
    final isSelected = count == currentValue;
    return InkWell(
      onTap: () => onSelected(count),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? Colors.teal : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: isSelected ? Colors.teal.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.teal : Colors.grey,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                '$count عنصر',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.teal : Colors.black87,
                ),
              ),
            ),
            if (isSelected) Icon(Icons.check_circle_rounded, color: Colors.teal, size: 24.sp),
          ],
        ),
      ),
    );
  }

  void _showDefaultSortDialog(
    BuildContext context,
    SettingsNotifier notifier,
    SettingsState settings,
  ) {
    final sorts = {
      'name_asc': {'label': 'الاسم (تصاعدي)', 'icon': Icons.sort_by_alpha},
      'name_desc': {'label': 'الاسم (تنازلي)', 'icon': Icons.sort_by_alpha},
      'date_asc': {'label': 'التاريخ (الأقدم أولاً)', 'icon': Icons.date_range},
      'date_desc': {
        'label': 'التاريخ (الأحدث أولاً)',
        'icon': Icons.date_range,
      },
      'id_asc': {'label': 'رقم الملف (تصاعدي)', 'icon': Icons.numbers},
      'id_desc': {'label': 'رقم الملف (تنازلي)', 'icon': Icons.numbers},
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.sort_rounded, color: Colors.cyan, size: 28.sp),
            SizedBox(width: 12.w),
            const Text('الترتيب الافتراضي'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: sorts.entries
                .map(
                  (entry) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: _buildSortOption(
                      context,
                      entry.value['label'] as String,
                      entry.value['icon'] as IconData,
                      entry.key,
                      settings.defaultSort,
                      (value) {
                        notifier.setDefaultSort(value);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    String label,
    IconData icon,
    String value,
    String currentValue,
    Function(String) onSelected,
  ) {
    final isSelected = value == currentValue;
    return InkWell(
      onTap: () => onSelected(value),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.cyan.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? Colors.cyan : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.cyan : Colors.grey,
              size: 24.sp,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.cyan : Colors.black87,
                ),
              ),
            ),
            if (isSelected) Icon(Icons.check_circle_rounded, color: Colors.cyan, size: 24.sp),
          ],
        ),
      ),
    );
  }

  void _showCacheDurationDialog(
    BuildContext context,
    SettingsNotifier notifier,
    SettingsState settings,
  ) {
    final durations = [
      {'minutes': 15, 'label': '15 دقيقة'},
      {'minutes': 30, 'label': '30 دقيقة'},
      {'minutes': 60, 'label': 'ساعة واحدة'},
      {'minutes': 120, 'label': 'ساعتان'},
      {'minutes': 240, 'label': '4 ساعات'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              color: Colors.lightGreen,
              size: 28.sp,
            ),
            SizedBox(width: 12.w),
            const Text('مدة التخزين المؤقت'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: durations
              .map(
                (duration) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: _buildDurationOption(
                    context,
                    duration['label'] as String,
                    duration['minutes'] as int,
                    settings.cacheDurationMinutes,
                    (value) {
                      notifier.setCacheDuration(value);
                      Navigator.pop(context);
                    },
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildDurationOption(
    BuildContext context,
    String label,
    int minutes,
    int currentValue,
    Function(int) onSelected,
  ) {
    final isSelected = minutes == currentValue;
    return InkWell(
      onTap: () => onSelected(minutes),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.lightGreen.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? Colors.lightGreen : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.schedule_rounded,
              color: isSelected ? Colors.lightGreen : Colors.grey,
              size: 24.sp,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.lightGreen : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: Colors.lightGreen,
                size: 24.sp,
              ),
          ],
        ),
      ),
    );
  }

  void _showSearchHistorySizeDialog(
    BuildContext context,
    SettingsNotifier notifier,
    SettingsState settings,
  ) {
    final sizes = [5, 10, 15, 20, 30];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.history_rounded,
              color: Colors.greenAccent[700],
              size: 28.sp,
            ),
            SizedBox(width: 12.w),
            const Text('حجم سجل البحث'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: sizes
              .map(
                (size) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: _buildHistorySizeOption(
                    context,
                    size,
                    settings.searchHistorySize,
                    (value) {
                      notifier.setSearchHistorySize(value);
                      Navigator.pop(context);
                    },
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildHistorySizeOption(
    BuildContext context,
    int size,
    int currentValue,
    Function(int) onSelected,
  ) {
    final isSelected = size == currentValue;
    final color = Colors.greenAccent[700]!;
    return InkWell(
      onTap: () => onSelected(size),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '$size',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : Colors.grey,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                '$size عملية بحث',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : Colors.black87,
                ),
              ),
            ),
            if (isSelected) Icon(Icons.check_circle_rounded, color: color, size: 24.sp),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FONT SIZE DIALOG - حوار حجم الخط مع Slider ديناميكي
// ═══════════════════════════════════════════════════════════════════════════════

class _FontSizeDialog extends ConsumerStatefulWidget {
  final SettingsNotifier notifier;
  final double initialFontSize;

  const _FontSizeDialog({
    required this.notifier,
    required this.initialFontSize,
  });

  @override
  ConsumerState<_FontSizeDialog> createState() => _FontSizeDialogState();
}

class _FontSizeDialogState extends ConsumerState<_FontSizeDialog> {
  late double _currentFontSize;

  @override
  void initState() {
    super.initState();
    _currentFontSize = widget.initialFontSize;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          contentPadding: EdgeInsets.all(isTablet ? 28.w : 20.w),
          title: Row(
            children: [
              Icon(
                Icons.text_fields_rounded,
                color: Colors.deepPurple,
                size: isTablet ? 32.sp : 28.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'حجم الخط',
                  style: TextStyle(
                    fontSize: isTablet ? 22.sp : 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isTablet ? 500 : 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Preview Container
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isTablet ? 24.w : 16.w),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.deepPurple.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'مثال على النص',
                        style: TextStyle(
                          fontSize: _currentFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Example Text',
                        style: TextStyle(
                          fontSize: _currentFontSize * 0.9,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isTablet ? 32.h : 24.h),

                // Slider Section
                Row(
                  children: [
                    Icon(
                      Icons.text_decrease,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      size: isTablet ? 28.sp : 24.sp,
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: isTablet ? 6 : 4,
                          thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: isTablet ? 14 : 12,
                          ),
                          overlayShape: RoundSliderOverlayShape(
                            overlayRadius: isTablet ? 28 : 24,
                          ),
                          valueIndicatorTextStyle: TextStyle(
                            fontSize: isTablet ? 16.sp : 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Slider(
                          value: _currentFontSize,
                          min: 12,
                          max: 20,
                          divisions: 8,
                          label: _currentFontSize.toInt().toString(),
                          activeColor: Colors.deepPurple,
                          inactiveColor: isDark ? Colors.grey[700] : Colors.grey[300],
                          onChanged: (value) {
                            setState(() {
                              _currentFontSize = value;
                            });
                            widget.notifier.setFontSize(value);
                          },
                        ),
                      ),
                    ),
                    Icon(
                      Icons.text_increase,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      size: isTablet ? 28.sp : 24.sp,
                    ),
                  ],
                ),

                SizedBox(height: isTablet ? 20.h : 16.h),

                // Font Size Label
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 24.w : 16.w,
                    vertical: isTablet ? 12.h : 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: Colors.deepPurple.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.format_size,
                        color: Colors.deepPurple,
                        size: isTablet ? 24.sp : 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '${_currentFontSize.toInt()} نقطة',
                        style: TextStyle(
                          fontSize: isTablet ? 18.sp : 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 16.w : 8.w,
                  vertical: isTablet ? 12.h : 8.h,
                ),
                child: Text(
                  'حسناً',
                  style: TextStyle(fontSize: isTablet ? 16.sp : 14.sp),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
