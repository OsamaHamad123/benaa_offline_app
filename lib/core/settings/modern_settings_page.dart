import 'package:benaa_offline_app/core/theme/theme_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/modern_sliver_app_bar.dart';
import 'settings_provider.dart';
import '../notifications/notifications.dart';

/// 🎯 Modern Settings Page
/// صفحة الإعدادات الحديثة المحسّنة

class ModernSettingsPage extends ConsumerStatefulWidget {
  const ModernSettingsPage({super.key});

  @override
  ConsumerState<ModernSettingsPage> createState() => _ModernSettingsPageState();
}

class _ModernSettingsPageState extends ConsumerState<ModernSettingsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          ModernSliverAppBar(
            title: 'الإعدادات',
            icon: Icons.settings_rounded,
            actions: [
              ModernActionButton(
                icon: Icons.restore,
                tooltip: 'استعادة الإعدادات الافتراضية',
                onPressed: () => _showResetDialog(context, notifier),
              ),
            ],
          ),

          // Tabs
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: theme.colorScheme.primary,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                tabs: const [
                  Tab(icon: Icon(Icons.palette), text: 'المظهر'),
                  Tab(icon: Icon(Icons.notifications), text: 'الإشعارات'),
                  Tab(icon: Icon(Icons.sync), text: 'المزامنة'),
                  Tab(icon: Icon(Icons.security), text: 'الأمان'),
                  Tab(icon: Icon(Icons.tune), text: 'متقدم'),
                ],
              ),
            ),
          ),

          // Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAppearanceTab(settings, notifier),
                _buildNotificationsTab(settings, notifier),
                _buildSyncTab(settings, notifier),
                _buildSecurityTab(settings, notifier),
                _buildAdvancedTab(settings, notifier),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🎨 تبويب المظهر
  Widget _buildAppearanceTab(SettingsState settings, SettingsNotifier notifier) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        _buildSectionCard(
          title: 'الوضع',
          icon: Icons.brightness_6,
          children: [
            _buildThemeModeTile(settings, notifier),
            const Divider(height: 1),
            _buildColorSchemeTile(settings, notifier),
          ],
        ),
        SizedBox(height: 16.h),
        _buildSectionCard(
          title: 'النص',
          icon: Icons.text_fields,
          children: [
            _buildFontSizeTile(settings, notifier),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('Material Design 3'),
              subtitle: const Text('استخدام التصميم الحديث'),
              value: settings.useMaterial3,
              onChanged: notifier.setUseMaterial3,
              secondary: const Icon(Icons.design_services),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _buildSectionCard(
          title: 'العرض',
          icon: Icons.view_list,
          children: [
            _buildItemsPerPageTile(settings, notifier),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('عرض الإحصائيات'),
              subtitle: const Text('إظهار لوحة الإحصائيات في الرئيسية'),
              value: settings.showStatistics,
              onChanged: notifier.setShowStatistics,
              secondary: const Icon(Icons.bar_chart),
            ),
          ],
        ),
      ],
    );
  }

  // 🔔 تبويب الإشعارات
  Widget _buildNotificationsTab(SettingsState settings, SettingsNotifier notifier) {
    final notificationsState = ref.watch(notificationsStateProvider);

    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        // حالة الإشعارات
        Card(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Icon(
                  notificationsState.isInitialized ? Icons.check_circle : Icons.error,
                  color: notificationsState.isInitialized ? Colors.green : Colors.red,
                  size: 32.sp,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'حالة الإشعارات',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        notificationsState.isInitialized ? 'مفعّلة' : 'غير مفعّلة',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                if (!notificationsState.hasPermissions)
                  ElevatedButton(
                    onPressed: () async {
                      await ref.read(notificationsStateProvider.notifier).requestPermissions();
                    },
                    child: const Text('تفعيل'),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16.h),

        _buildSectionCard(
          title: 'الإعدادات العامة',
          icon: Icons.settings,
          children: [
            SwitchListTile(
              title: const Text('تفعيل الإشعارات'),
              subtitle: const Text('إظهار إشعارات للأحداث المهمة'),
              value: settings.notificationsEnabled,
              onChanged: notifier.setNotificationsEnabled,
              secondary: const Icon(Icons.notifications_active),
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('الصوت'),
              subtitle: const Text('تشغيل الأصوات مع الإشعارات'),
              value: settings.soundEnabled,
              onChanged: settings.notificationsEnabled ? notifier.setSoundEnabled : null,
              secondary: const Icon(Icons.volume_up),
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('الاهتزاز'),
              subtitle: const Text('اهتزاز الجهاز عند الإجراءات'),
              value: settings.vibrationEnabled,
              onChanged: settings.notificationsEnabled ? notifier.setVibrationEnabled : null,
              secondary: const Icon(Icons.vibration),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // إشعارات مجدولة
        Card(
          child: ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('الإشعارات المجدولة'),
            subtitle: Text('${notificationsState.scheduledCount} إشعار'),
            trailing: IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: notificationsState.scheduledCount > 0 ? () => _cancelAllNotifications() : null,
              tooltip: 'إلغاء الكل',
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // اختبار الإشعارات
        Card(
          child: ListTile(
            leading: const Icon(Icons.notifications_active, color: Colors.blue),
            title: const Text('اختبار الإشعارات'),
            subtitle: const Text('إرسال إشعار تجريبي'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _testNotification(),
          ),
        ),
      ],
    );
  }

  // 🔄 تبويب المزامنة
  Widget _buildSyncTab(SettingsState settings, SettingsNotifier notifier) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        _buildSectionCard(
          title: 'المزامنة التلقائية',
          icon: Icons.sync,
          children: [
            SwitchListTile(
              title: const Text('تفعيل المزامنة التلقائية'),
              subtitle: const Text('مزامنة البيانات في الخلفية'),
              value: settings.autoSyncEnabled,
              onChanged: notifier.setAutoSyncEnabled,
              secondary: const Icon(Icons.cloud_sync),
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('WiFi فقط'),
              subtitle: const Text('المزامنة عند الاتصال بـ WiFi فقط'),
              value: settings.wifiOnlySync,
              onChanged: settings.autoSyncEnabled ? notifier.setWifiOnlySync : null,
              secondary: const Icon(Icons.wifi),
            ),
            const Divider(height: 1),
            _buildSyncIntervalTile(settings, notifier),
          ],
        ),
        SizedBox(height: 16.h),
        _buildSectionCard(
          title: 'النسخ الاحتياطي',
          icon: Icons.backup,
          children: [
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('نسخ احتياطي الآن'),
              subtitle: const Text('حفظ نسخة من البيانات'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _performBackup(),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('استعادة من نسخة احتياطية'),
              subtitle: const Text('استرجاع البيانات المحفوظة'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _restoreBackup(),
            ),
          ],
        ),
      ],
    );
  }

  // 🔒 تبويب الأمان
  Widget _buildSecurityTab(SettingsState settings, SettingsNotifier notifier) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        _buildSectionCard(
          title: 'المصادقة',
          icon: Icons.fingerprint,
          children: [
            SwitchListTile(
              title: const Text('المصادقة البيومترية'),
              subtitle: const Text('البصمة أو التعرف على الوجه'),
              value: settings.biometricAuthEnabled,
              onChanged: notifier.setBiometricAuthEnabled,
              secondary: const Icon(Icons.fingerprint),
            ),
            const Divider(height: 1),
            _buildSessionTimeoutTile(settings, notifier),
          ],
        ),
        SizedBox(height: 16.h),
        _buildSectionCard(
          title: 'كلمة المرور',
          icon: Icons.password,
          children: [
            SwitchListTile(
              title: const Text('كلمة مرور قوية'),
              subtitle: const Text('يجب أن تحتوي على 8 أحرف على الأقل'),
              value: settings.requireStrongPassword,
              onChanged: notifier.setRequireStrongPassword,
              secondary: const Icon(Icons.security),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.lock_reset),
              title: const Text('تغيير كلمة المرور'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _changePassword(),
            ),
          ],
        ),
      ],
    );
  }

  // ⚙️ تبويب متقدم
  Widget _buildAdvancedTab(SettingsState settings, SettingsNotifier notifier) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        _buildSectionCard(
          title: 'البيانات',
          icon: Icons.storage,
          children: [
            SwitchListTile(
              title: const Text('وضع عدم الاتصال'),
              subtitle: const Text('العمل بدون إنترنت'),
              value: settings.offlineMode,
              onChanged: notifier.setOfflineMode,
              secondary: const Icon(Icons.cloud_off),
            ),
            const Divider(height: 1),
            _buildCacheDurationTile(settings, notifier),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.delete_sweep, color: Colors.red),
              title: const Text('مسح الذاكرة المؤقتة'),
              subtitle: const Text('حذف البيانات المخزنة مؤقتاً'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _clearCache(),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _buildSectionCard(
          title: 'المطور',
          icon: Icons.code,
          children: [
            SwitchListTile(
              title: const Text('وضع المطور'),
              subtitle: const Text('عرض خيارات التطوير'),
              value: settings.developerMode,
              onChanged: notifier.setDeveloperMode,
              secondary: const Icon(Icons.developer_mode),
            ),
            if (settings.developerMode) ...[
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('سجل التصحيح'),
                subtitle: const Text('حفظ سجلات التصحيح'),
                value: settings.debugLogging,
                onChanged: notifier.setDebugLogging,
                secondary: const Icon(Icons.bug_report),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('معلومات التصحيح'),
                subtitle: const Text('عرض معلومات التصحيح في الواجهة'),
                value: settings.showDebugInfo,
                onChanged: notifier.setShowDebugInfo,
                secondary: const Icon(Icons.info),
              ),
            ],
          ],
        ),
        SizedBox(height: 16.h),
        _buildSectionCard(
          title: 'عن التطبيق',
          icon: Icons.info,
          children: [
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('الإصدار'),
              subtitle: Text('1.0.0'),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('سياسة الخصوصية'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showPrivacyPolicy(),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('شروط الاستخدام'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showTermsOfService(),
            ),
          ],
        ),
      ],
    );
  }

  // Helper Widgets
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildThemeModeTile(SettingsState settings, SettingsNotifier notifier) {
    return ListTile(
      leading: Icon(_getThemeModeIcon(settings.themeMode)),
      title: const Text('وضع المظهر'),
      subtitle: Text(_getThemeModeLabel(settings.themeMode)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showThemeModeDialog(settings, notifier),
    );
  }

  Widget _buildColorSchemeTile(SettingsState settings, SettingsNotifier notifier) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getColorFromScheme(settings.colorScheme),
        radius: 16,
      ),
      title: const Text('لون التطبيق'),
      subtitle: Text(_getColorSchemeLabel(settings.colorScheme)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showColorSchemeDialog(settings, notifier),
    );
  }

  Widget _buildFontSizeTile(SettingsState settings, SettingsNotifier notifier) {
    return ListTile(
      leading: const Icon(Icons.text_fields),
      title: const Text('حجم الخط'),
      subtitle: Text('${settings.fontSize.toInt()} نقطة'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showFontSizeDialog(settings, notifier),
    );
  }

  Widget _buildItemsPerPageTile(SettingsState settings, SettingsNotifier notifier) {
    return ListTile(
      leading: const Icon(Icons.list),
      title: const Text('عدد العناصر في الصفحة'),
      subtitle: Text('${settings.itemsPerPage} عنصر'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showItemsPerPageDialog(settings, notifier),
    );
  }

  Widget _buildSyncIntervalTile(SettingsState settings, SettingsNotifier notifier) {
    return ListTile(
      leading: const Icon(Icons.schedule),
      title: const Text('فترة المزامنة'),
      subtitle: Text('كل ${settings.syncIntervalHours} ساعة'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      enabled: settings.autoSyncEnabled,
      onTap: settings.autoSyncEnabled ? () => _showSyncIntervalDialog(settings, notifier) : null,
    );
  }

  Widget _buildSessionTimeoutTile(SettingsState settings, SettingsNotifier notifier) {
    return ListTile(
      leading: const Icon(Icons.timer),
      title: const Text('مهلة الجلسة'),
      subtitle: Text('${settings.sessionTimeoutMinutes} دقيقة'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showSessionTimeoutDialog(settings, notifier),
    );
  }

  Widget _buildCacheDurationTile(SettingsState settings, SettingsNotifier notifier) {
    return ListTile(
      leading: const Icon(Icons.access_time),
      title: const Text('مدة الذاكرة المؤقتة'),
      subtitle: Text('${settings.cacheDurationMinutes} دقيقة'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showCacheDurationDialog(settings, notifier),
    );
  }

  // Dialog Methods
  Future<void> _showThemeModeDialog(SettingsState settings, SettingsNotifier notifier) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('وضع المظهر'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('فاتح'),
              value: 'light',
              groupValue: settings.themeMode,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<String>(
              title: const Text('داكن'),
              value: 'dark',
              groupValue: settings.themeMode,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<String>(
              title: const Text('تلقائي (حسب النظام)'),
              value: 'system',
              groupValue: settings.themeMode,
              onChanged: (value) => Navigator.pop(context, value),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      await notifier.setThemeMode(result);
      // تحديث ThemeModeProvider
      ref.read(themeModeProvider.notifier).setThemeMode(_convertThemeMode(result));
    }
  }

  Future<void> _showColorSchemeDialog(SettingsState settings, SettingsNotifier notifier) async {
    final colors = {
      'blue': {'name': 'أزرق', 'color': Colors.blue},
      'green': {'name': 'أخضر', 'color': Colors.green},
      'purple': {'name': 'بنفسجي', 'color': Colors.purple},
      'orange': {'name': 'برتقالي', 'color': Colors.orange},
      'red': {'name': 'أحمر', 'color': Colors.red},
      'teal': {'name': 'تركواز', 'color': Colors.teal},
    };

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('لون التطبيق'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final entry = colors.entries.elementAt(index);
              final isSelected = settings.colorScheme == entry.key;

              return InkWell(
                onTap: () => Navigator.pop(context, entry.key),
                child: Container(
                  decoration: BoxDecoration(
                    color: entry.value['color'] as Color,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isSelected) const Icon(Icons.check, color: Colors.white),
                        const SizedBox(height: 4),
                        Text(
                          entry.value['name'] as String,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    if (result != null) {
      await notifier.setColorScheme(result);
    }
  }

  Future<void> _showFontSizeDialog(SettingsState settings, SettingsNotifier notifier) async {
    double fontSize = settings.fontSize;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('حجم الخط'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'معاينة النص',
                style: TextStyle(fontSize: fontSize),
              ),
              const SizedBox(height: 16),
              Slider(
                value: fontSize,
                min: 12,
                max: 20,
                divisions: 8,
                label: fontSize.toInt().toString(),
                onChanged: (value) {
                  setState(() => fontSize = value);
                },
              ),
              Text('${fontSize.toInt()} نقطة'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                notifier.setFontSize(fontSize);
                Navigator.pop(context);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showItemsPerPageDialog(SettingsState settings, SettingsNotifier notifier) async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('عدد العناصر في الصفحة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [10, 20, 30, 50, 100].map((count) {
            return RadioListTile<int>(
              title: Text('$count عنصر'),
              value: count,
              groupValue: settings.itemsPerPage,
              onChanged: (value) => Navigator.pop(context, value),
            );
          }).toList(),
        ),
      ),
    );

    if (result != null) {
      await notifier.setItemsPerPage(result);
    }
  }

  Future<void> _showSyncIntervalDialog(SettingsState settings, SettingsNotifier notifier) async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('فترة المزامنة التلقائية'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<int>(
              title: const Text('كل ساعة'),
              value: 1,
              groupValue: settings.syncIntervalHours,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<int>(
              title: const Text('كل 6 ساعات'),
              value: 6,
              groupValue: settings.syncIntervalHours,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<int>(
              title: const Text('كل 12 ساعة'),
              value: 12,
              groupValue: settings.syncIntervalHours,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<int>(
              title: const Text('كل 24 ساعة'),
              value: 24,
              groupValue: settings.syncIntervalHours,
              onChanged: (value) => Navigator.pop(context, value),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      await notifier.setSyncIntervalHours(result);
    }
  }

  Future<void> _showSessionTimeoutDialog(SettingsState settings, SettingsNotifier notifier) async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مهلة الجلسة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [5, 15, 30, 60].map((minutes) {
            return RadioListTile<int>(
              title: Text('$minutes دقيقة'),
              value: minutes,
              groupValue: settings.sessionTimeoutMinutes,
              onChanged: (value) => Navigator.pop(context, value),
            );
          }).toList(),
        ),
      ),
    );

    if (result != null) {
      await notifier.setSessionTimeoutMinutes(result);
    }
  }

  Future<void> _showCacheDurationDialog(SettingsState settings, SettingsNotifier notifier) async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مدة الذاكرة المؤقتة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [15, 30, 60, 120].map((minutes) {
            return RadioListTile<int>(
              title: Text('$minutes دقيقة'),
              value: minutes,
              groupValue: settings.cacheDurationMinutes,
              onChanged: (value) => Navigator.pop(context, value),
            );
          }).toList(),
        ),
      ),
    );

    if (result != null) {
      await notifier.setCacheDurationMinutes(result);
    }
  }

  Future<void> _showResetDialog(BuildContext context, SettingsNotifier notifier) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('استعادة الإعدادات'),
        content: const Text('هل تريد استعادة جميع الإعدادات إلى القيم الافتراضية؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('استعادة'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await notifier.resetToDefaults();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم استعادة الإعدادات الافتراضية')),
        );
      }
    }
  }

  // Action Methods
  Future<void> _testNotification() async {
    await NotificationsService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: 'إشعار تجريبي',
      body: 'هذا إشعار تجريبي من تطبيق بناء',
    );
  }

  Future<void> _cancelAllNotifications() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الإشعارات'),
        content: const Text('هل تريد إلغاء جميع الإشعارات المجدولة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('نعم'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(notificationsStateProvider.notifier).cancelAllNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إلغاء جميع الإشعارات')),
        );
      }
    }
  }

  Future<void> _performBackup() async {
    // TODO: Implement backup
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري إنشاء نسخة احتياطية...')),
    );
  }

  Future<void> _restoreBackup() async {
    // TODO: Implement restore
  }

  Future<void> _changePassword() async {
    // TODO: Implement password change
  }

  Future<void> _clearCache() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح الذاكرة المؤقتة'),
        content: const Text('هل تريد حذف جميع البيانات المخزنة مؤقتاً؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('مسح'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // TODO: Clear cache
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم مسح الذاكرة المؤقتة')),
      );
    }
  }

  Future<void> _showPrivacyPolicy() async {
    // TODO: Show privacy policy
  }

  Future<void> _showTermsOfService() async {
    // TODO: Show terms
  }

  // Helper Methods
  IconData _getThemeModeIcon(String mode) {
    switch (mode) {
      case 'light':
        return Icons.light_mode;
      case 'dark':
        return Icons.dark_mode;
      default:
        return Icons.brightness_auto;
    }
  }

  String _getThemeModeLabel(String mode) {
    switch (mode) {
      case 'light':
        return 'فاتح';
      case 'dark':
        return 'داكن';
      default:
        return 'تلقائي';
    }
  }

  String _getColorSchemeLabel(String scheme) {
    const labels = {
      'blue': 'أزرق',
      'green': 'أخضر',
      'purple': 'بنفسجي',
      'orange': 'برتقالي',
      'red': 'أحمر',
      'teal': 'تركواز',
    };
    return labels[scheme] ?? 'أزرق';
  }

  Color _getColorFromScheme(String scheme) {
    switch (scheme) {
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
      default:
        return Colors.blue;
    }
  }

  ThemeMode _convertThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

// TabBar Delegate
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return false;
  }
}
