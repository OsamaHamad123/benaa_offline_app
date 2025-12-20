import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/modern_sliver_app_bar.dart';
import 'settings_provider.dart';
import 'widgets/widgets.dart';

/// 🎯 Clean Settings Page - صفحة الإعدادات النظيفة والمنظمة
class CleanSettingsPage extends ConsumerWidget {
  const CleanSettingsPage({super.key});

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
              // App Bar
              ModernSliverAppBar(
                title: 'الإعدادات',
                icon: Icons.settings_rounded,
                isTablet: isTablet,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.restore_rounded),
                    tooltip: 'استعادة الإعدادات الافتراضية',
                    onPressed: () => _handleResetSettings(context, ref, notifier),
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
                    const SettingsSectionHeader(
                      title: 'الإشعارات',
                      icon: Icons.notifications_rounded,
                      color: Colors.orange,
                    ),
                    SettingsSectionCard(
                      children: [
                        SettingsSwitchTile(
                          title: 'تفعيل الإشعارات',
                          subtitle: 'عرض إشعارات للأحداث المهمة',
                          value: settings.notificationsEnabled,
                          onChanged: (value) => _handleToggle(
                            () => notifier.setNotificationsEnabled(value),
                          ),
                          icon: Icons.notifications_active_rounded,
                          color: Colors.orange,
                        ),
                        const SettingsDivider(),
                        SettingsSwitchTile(
                          title: 'الصوت',
                          subtitle: 'تشغيل الأصوات مع الإشعارات',
                          value: settings.soundEnabled,
                          onChanged: settings.notificationsEnabled
                              ? (value) => _handleToggle(
                                    () => notifier.setSoundEnabled(value),
                                  )
                              : null,
                          icon: Icons.volume_up_rounded,
                          color: Colors.deepOrange,
                        ),
                        const SettingsDivider(),
                        SettingsSwitchTile(
                          title: 'الاهتزاز',
                          subtitle: 'اهتزاز الجهاز عند الإجراءات',
                          value: settings.vibrationEnabled,
                          onChanged: settings.notificationsEnabled
                              ? (value) => _handleToggle(
                                    () => notifier.setVibrationEnabled(value),
                                  )
                              : null,
                          icon: Icons.vibration_rounded,
                          color: Colors.amber,
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Sync Section
                    const SettingsSectionHeader(
                      title: 'المزامنة',
                      icon: Icons.sync_rounded,
                      color: Colors.blue,
                    ),
                    SettingsSectionCard(
                      children: [
                        SettingsSwitchTile(
                          title: 'المزامنة التلقائية',
                          subtitle: 'مزامنة البيانات في الخلفية',
                          value: settings.autoSyncEnabled,
                          onChanged: (value) => _handleToggle(
                            () => notifier.setAutoSyncEnabled(value),
                          ),
                          icon: Icons.cloud_sync_rounded,
                          color: Colors.blue,
                        ),
                        const SettingsDivider(),
                        SettingsSwitchTile(
                          title: 'WiFi فقط',
                          subtitle: 'المزامنة عند الاتصال بـ WiFi فقط',
                          value: settings.wifiOnlySync,
                          onChanged: settings.autoSyncEnabled
                              ? (value) => _handleToggle(
                                    () => notifier.setWifiOnlySync(value),
                                  )
                              : null,
                          icon: Icons.wifi_rounded,
                          color: Colors.lightBlue,
                        ),
                        const SettingsDivider(),
                        SettingsNavigationTile(
                          title: 'فترة المزامنة',
                          subtitle: 'كل ${settings.syncIntervalHours} ساعة',
                          icon: Icons.schedule_rounded,
                          color: Colors.indigo,
                          onTap: settings.autoSyncEnabled
                              ? () => _handleSyncIntervalDialog(context, ref, settings, notifier)
                              : () {},
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Theme Section
                    const SettingsSectionHeader(
                      title: 'المظهر',
                      icon: Icons.palette_rounded,
                      color: Colors.purple,
                    ),
                    SettingsSectionCard(
                      children: [
                        SettingsNavigationTile(
                          title: 'وضع المظهر',
                          subtitle: _getThemeModeLabel(settings.themeMode),
                          icon: _getThemeModeIcon(settings.themeMode),
                          color: Colors.purple,
                          onTap: () => _handleThemeModeDialog(context, ref, settings, notifier),
                        ),
                        const SettingsDivider(),
                        SettingsColorSchemeTile(
                          currentScheme: settings.colorScheme,
                          onTap: () => _handleColorSchemeDialog(context, settings, notifier),
                        ),
                        const SettingsDivider(),
                        SettingsNavigationTile(
                          title: 'حجم الخط',
                          subtitle: '${settings.fontSize.toInt()} نقطة',
                          icon: Icons.text_fields_rounded,
                          color: Colors.deepPurple,
                          onTap: () => _handleFontSizeDialog(context, settings, notifier),
                        ),
                        const SettingsDivider(),
                        SettingsSwitchTile(
                          title: 'Material Design 3',
                          subtitle: 'استخدام التصميم الحديث',
                          value: settings.useMaterial3,
                          onChanged: (value) => _handleToggle(
                            () => notifier.setUseMaterial3(value),
                          ),
                          icon: Icons.design_services_rounded,
                          color: Colors.deepPurple,
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Display Section
                    const SettingsSectionHeader(
                      title: 'العرض',
                      icon: Icons.view_list_rounded,
                      color: Colors.green,
                    ),
                    SettingsSectionCard(
                      children: [
                        SettingsNavigationTile(
                          title: 'عدد العناصر في الصفحة',
                          subtitle: '${settings.itemsPerPage} عنصر',
                          icon: Icons.list_rounded,
                          color: Colors.green,
                          onTap: () => _handleItemsPerPageDialog(context, settings, notifier),
                        ),
                        const SettingsDivider(),
                        SettingsSwitchTile(
                          title: 'عرض الإحصائيات',
                          subtitle: 'إظهار لوحة الإحصائيات في الرئيسية',
                          value: settings.showStatistics,
                          onChanged: (value) => _handleToggle(
                            () => notifier.setShowStatistics(value),
                          ),
                          icon: Icons.bar_chart_rounded,
                          color: Colors.teal,
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Data Section
                    const SettingsSectionHeader(
                      title: 'البيانات',
                      icon: Icons.storage_rounded,
                      color: Colors.cyan,
                    ),
                    SettingsSectionCard(
                      children: [
                        SettingsNavigationTile(
                          title: 'مدة الذاكرة المؤقتة',
                          subtitle: '${settings.cacheDurationMinutes} دقيقة',
                          icon: Icons.access_time_rounded,
                          color: Colors.cyan,
                          onTap: () => _handleCacheDurationDialog(context, settings, notifier),
                        ),
                        const SettingsDivider(),
                        SettingsSwitchTile(
                          title: 'وضع عدم الاتصال',
                          subtitle: 'العمل بدون إنترنت',
                          value: settings.offlineMode,
                          onChanged: (value) => _handleToggle(
                            () => notifier.setOfflineMode(value),
                          ),
                          icon: Icons.cloud_off_rounded,
                          color: Colors.lightBlue,
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Security Section
                    const SettingsSectionHeader(
                      title: 'الأمان',
                      icon: Icons.security_rounded,
                      color: Colors.red,
                    ),
                    SettingsSectionCard(
                      children: [
                        SettingsSwitchTile(
                          title: 'المصادقة البيومترية',
                          subtitle: 'البصمة أو التعرف على الوجه',
                          value: settings.biometricAuthEnabled,
                          onChanged: (value) => _handleToggle(
                            () => notifier.setBiometricAuthEnabled(value),
                          ),
                          icon: Icons.fingerprint_rounded,
                          color: Colors.red,
                        ),
                        const SettingsDivider(),
                        SettingsSwitchTile(
                          title: 'كلمة مرور قوية',
                          subtitle: 'يجب أن تحتوي على 8 أحرف على الأقل',
                          value: settings.requireStrongPassword,
                          onChanged: (value) => _handleToggle(
                            () => notifier.setRequireStrongPassword(value),
                          ),
                          icon: Icons.password_rounded,
                          color: Colors.deepOrange,
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Advanced Section
                    const SettingsSectionHeader(
                      title: 'متقدم',
                      icon: Icons.tune_rounded,
                      color: Colors.grey,
                    ),
                    SettingsSectionCard(
                      children: [
                        SettingsSwitchTile(
                          title: 'وضع المطور',
                          subtitle: 'عرض خيارات التطوير',
                          value: settings.developerMode,
                          onChanged: (value) => _handleToggle(
                            () => notifier.setDeveloperMode(value),
                          ),
                          icon: Icons.developer_mode_rounded,
                          color: Colors.grey,
                        ),
                        if (settings.developerMode) ...[
                          const SettingsDivider(),
                          SettingsSwitchTile(
                            title: 'سجل التصحيح',
                            subtitle: 'حفظ سجلات التصحيح',
                            value: settings.debugLogging,
                            onChanged: (value) => _handleToggle(
                              () => notifier.setDebugLogging(value),
                            ),
                            icon: Icons.bug_report_rounded,
                            color: Colors.blueGrey,
                          ),
                          const SettingsDivider(),
                          SettingsSwitchTile(
                            title: 'معلومات التصحيح',
                            subtitle: 'عرض معلومات التصحيح في الواجهة',
                            value: settings.showDebugInfo,
                            onChanged: (value) => _handleToggle(
                              () => notifier.setShowDebugInfo(value),
                            ),
                            icon: Icons.info_rounded,
                            color: Colors.blueGrey,
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: 32.h),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================
  // Helper Methods - طرق مساعدة
  // ============================================

  IconData _getThemeModeIcon(String mode) {
    switch (mode) {
      case 'light':
        return Icons.light_mode_rounded;
      case 'dark':
        return Icons.dark_mode_rounded;
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
      default:
        return 'تلقائي (حسب النظام)';
    }
  }

  // ============================================
  // Action Handlers - معالجات الإجراءات
  // ============================================

  void _handleToggle(Future<void> Function() action) {
    try {
      action();
    } catch (e) {
      debugPrint('❌ Error in toggle: $e');
    }
  }

  Future<void> _handleResetSettings(
    BuildContext context,
    WidgetRef ref,
    SettingsNotifier notifier,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('استعادة الإعدادات'),
        content: const Text(
          'هل تريد استعادة جميع الإعدادات إلى القيم الافتراضية؟',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('استعادة'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await notifier.resetToDefaults();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم استعادة الإعدادات الافتراضية'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل في استعادة الإعدادات: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleThemeModeDialog(
    BuildContext context,
    WidgetRef ref,
    SettingsState settings,
    SettingsNotifier notifier,
  ) async {
    final result = await ThemeModeDialog.show(context, settings.themeMode);

    if (result != null && context.mounted) {
      try {
        await notifier.setThemeMode(result);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل في تغيير المظهر: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleColorSchemeDialog(
    BuildContext context,
    SettingsState settings,
    SettingsNotifier notifier,
  ) async {
    final result = await ColorSchemeDialog.show(context, settings.colorScheme);

    if (result != null && context.mounted) {
      try {
        await notifier.setColorScheme(result);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل في تغيير اللون: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleFontSizeDialog(
    BuildContext context,
    SettingsState settings,
    SettingsNotifier notifier,
  ) async {
    final result = await FontSizeDialog.show(context, settings.fontSize);

    if (result != null && context.mounted) {
      try {
        await notifier.setFontSize(result);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل في تغيير حجم الخط: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleSyncIntervalDialog(
    BuildContext context,
    WidgetRef ref,
    SettingsState settings,
    SettingsNotifier notifier,
  ) async {
    final result = await OptionsDialog.show<int>(
      context: context,
      title: 'فترة المزامنة التلقائية',
      currentValue: settings.syncIntervalHours,
      options: const [
        OptionItem(value: 1, title: 'كل ساعة', icon: Icons.schedule),
        OptionItem(value: 6, title: 'كل 6 ساعات', icon: Icons.schedule),
        OptionItem(value: 12, title: 'كل 12 ساعة', icon: Icons.schedule),
        OptionItem(value: 24, title: 'كل 24 ساعة', icon: Icons.schedule),
      ],
    );

    if (result != null && context.mounted) {
      try {
        await notifier.setSyncIntervalHours(result);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل في تغيير فترة المزامنة: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleItemsPerPageDialog(
    BuildContext context,
    SettingsState settings,
    SettingsNotifier notifier,
  ) async {
    final result = await OptionsDialog.show<int>(
      context: context,
      title: 'عدد العناصر في الصفحة',
      currentValue: settings.itemsPerPage,
      options: const [
        OptionItem(value: 10, title: '10 عناصر', icon: Icons.list),
        OptionItem(value: 20, title: '20 عنصر', icon: Icons.list),
        OptionItem(value: 30, title: '30 عنصر', icon: Icons.list),
        OptionItem(value: 50, title: '50 عنصر', icon: Icons.list),
        OptionItem(value: 100, title: '100 عنصر', icon: Icons.list),
      ],
    );

    if (result != null && context.mounted) {
      try {
        await notifier.setItemsPerPage(result);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل في تغيير عدد العناصر: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleCacheDurationDialog(
    BuildContext context,
    SettingsState settings,
    SettingsNotifier notifier,
  ) async {
    final result = await OptionsDialog.show<int>(
      context: context,
      title: 'مدة الذاكرة المؤقتة',
      currentValue: settings.cacheDurationMinutes,
      options: const [
        OptionItem(value: 15, title: '15 دقيقة', icon: Icons.access_time),
        OptionItem(value: 30, title: '30 دقيقة', icon: Icons.access_time),
        OptionItem(value: 60, title: 'ساعة واحدة', icon: Icons.access_time),
        OptionItem(value: 120, title: 'ساعتان', icon: Icons.access_time),
      ],
    );

    if (result != null && context.mounted) {
      try {
        await notifier.setCacheDurationMinutes(result);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل في تغيير مدة الذاكرة: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}
