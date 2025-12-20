import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 🎨 Theme Settings Page - إعدادات الثيمات
class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  int _selectedThemeIndex = 0;

  final _themes = [
    ('الوضع الفاتح', Icons.light_mode, Colors.blue),
    ('الوضع الداكن', Icons.dark_mode, Colors.grey),
    ('أزرق احترافي', Icons.business, Colors.blue),
    ('أخضر طبيعي', Icons.nature, Colors.green),
    ('بنفسجي عصري', Icons.auto_awesome, Colors.purple),
    ('برتقالي دافئ', Icons.wb_sunny, Colors.orange),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الثيمات والمظهر'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Header
          Text(
            'اختر المظهر المفضل',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'يمكنك تغيير مظهر التطبيق حسب تفضيلاتك',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 24.h),

          // Theme Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
            ),
            itemCount: _themes.length,
            itemBuilder: (context, index) {
              final (title, icon, color) = _themes[index];
              final isSelected = _selectedThemeIndex == index;

              return _ThemeCard(
                title: title,
                icon: icon,
                color: color,
                isSelected: isSelected,
                onTap: () => setState(() => _selectedThemeIndex = index),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.2),
              color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: isSelected ? 3 : 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48.sp,
              color: color,
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (isSelected) ...[
              SizedBox(height: 8.h),
              Icon(
                Icons.check_circle,
                color: color,
                size: 20.sp,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
