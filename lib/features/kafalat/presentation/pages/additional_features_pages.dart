import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 🔄 Sync Settings Page - إعدادات المزامنة
class SyncSettingsPage extends StatelessWidget {
  const SyncSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المزامنة الفورية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {},
            tooltip: 'مزامنة الآن',
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          const _InfoCard(
            icon: Icons.cloud_done,
            title: 'حالة المزامنة',
            subtitle: 'آخر مزامنة: منذ 5 دقائق',
            color: Colors.green,
          ),
          SizedBox(height: 16.h),
          const _SettingTile(
            icon: Icons.sync,
            title: 'المزامنة التلقائية',
            subtitle: 'مزامنة البيانات تلقائياً',
            trailing: Switch(value: true, onChanged: null),
          ),
          const _SettingTile(
            icon: Icons.wifi,
            title: 'المزامنة عبر WiFi فقط',
            subtitle: 'لتوفير استهلاك البيانات',
            trailing: Switch(value: false, onChanged: null),
          ),
          _SettingTile(
            icon: Icons.schedule,
            title: 'فترة المزامنة',
            subtitle: 'كل 15 دقيقة',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

/// 🔐 Permissions Page - الصلاحيات
class PermissionsPage extends StatelessWidget {
  const PermissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الصلاحيات'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          const _RoleCard(
            title: 'المدير العام',
            description: 'صلاحيات كاملة لجميع الميزات',
            color: Colors.red,
            permissions: ['إضافة', 'تعديل', 'حذف', 'عرض'],
          ),
          SizedBox(height: 12.h),
          const _RoleCard(
            title: 'المدير',
            description: 'صلاحيات التعديل والعرض',
            color: Colors.orange,
            permissions: ['تعديل', 'عرض'],
          ),
          SizedBox(height: 12.h),
          const _RoleCard(
            title: 'المشاهد',
            description: 'صلاحيات العرض فقط',
            color: Colors.blue,
            permissions: ['عرض'],
          ),
        ],
      ),
    );
  }
}

/// 📱 Mobile Features Page - ميزات الموبايل
class MobileFeaturesPage extends StatelessWidget {
  const MobileFeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ميزات الموبايل'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _FeatureCard(
            icon: Icons.qr_code_scanner,
            title: 'مسح QR Code',
            subtitle: 'مسح رموز QR للكفالات',
            color: Colors.purple,
            onTap: () {},
          ),
          _FeatureCard(
            icon: Icons.share,
            title: 'مشاركة البيانات',
            subtitle: 'مشاركة الكفالات عبر التطبيقات',
            color: Colors.blue,
            onTap: () {},
          ),
          _FeatureCard(
            icon: Icons.cloud_off,
            title: 'الوضع بدون انترنت',
            subtitle: 'العمل بدون اتصال بالإنترنت',
            color: Colors.green,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

/// 📊 Advanced Dashboard Page - لوحة التحكم المتقدمة
class AdvancedDashboardPage extends StatelessWidget {
  const AdvancedDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم المتقدمة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: const [
          _KPICard(
            title: 'إجمالي الكفالات',
            value: '127',
            trend: '+12%',
            color: Colors.blue,
          ),
          _KPICard(
            title: 'الكفالات النشطة',
            value: '98',
            trend: '+8%',
            color: Colors.green,
          ),
          _KPICard(
            title: 'إجمالي المبالغ',
            value: '125,000',
            trend: '+15%',
            color: Colors.purple,
          ),
        ],
      ),
    );
  }
}

/// ✨ UX Enhancements Page - تحسينات تجربة المستخدم
class UXEnhancementsPage extends StatelessWidget {
  const UXEnhancementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحسينات تجربة المستخدم'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _SettingTile(
            icon: Icons.animation,
            title: 'التأثيرات المتحركة',
            subtitle: 'تفعيل الحركات والانتقالات',
            trailing: Switch(value: true, onChanged: (_) {}),
          ),
          _SettingTile(
            icon: Icons.vibration,
            title: 'الاهتزاز التفاعلي',
            subtitle: 'اهتزاز خفيف عند التفاعل',
            trailing: Switch(value: true, onChanged: (_) {}),
          ),
          _SettingTile(
            icon: Icons.gesture,
            title: 'الإيماءات السريعة',
            subtitle: 'التحكم بالإيماءات',
            trailing: Switch(value: false, onChanged: (_) {}),
          ),
          _SettingTile(
            icon: Icons.speed,
            title: 'سرعة الحركات',
            subtitle: 'سريع',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// Shared Widgets

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style:
                        theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final List<String> permissions;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.color,
    required this.permissions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
          SizedBox(height: 4.h),
          Text(description, style: theme.textTheme.bodySmall),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 6.w,
            children: permissions
                .map((p) => Chip(
                    label: Text(p, style: TextStyle(fontSize: 11.sp)), backgroundColor: color.withValues(alpha: 0.2)))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: color, size: 28.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16.sp, color: color),
          ],
        ),
      ),
    );
  }
}

class _KPICard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final Color color;

  const _KPICard({
    required this.title,
    required this.value,
    required this.trend,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: color)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(trend, style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12.sp)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
