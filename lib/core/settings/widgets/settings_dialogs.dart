import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 🌙 Theme Mode Dialog
/// حوار اختيار وضع المظهر

class ThemeModeDialog {
  static Future<String?> show(
    BuildContext context,
    String currentMode,
  ) async {
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('وضع المظهر'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemeModeOption(
              mode: 'light',
              currentMode: currentMode,
              icon: Icons.light_mode_rounded,
              title: 'فاتح',
              description: 'مظهر فاتح مريح للعين',
            ),
            SizedBox(height: 12.h),
            _ThemeModeOption(
              mode: 'dark',
              currentMode: currentMode,
              icon: Icons.dark_mode_rounded,
              title: 'داكن',
              description: 'مظهر داكن يحافظ على البطارية',
            ),
            SizedBox(height: 12.h),
            _ThemeModeOption(
              mode: 'system',
              currentMode: currentMode,
              icon: Icons.brightness_auto_rounded,
              title: 'تلقائي',
              description: 'يتبع إعدادات النظام',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }
}

class _ThemeModeOption extends StatelessWidget {
  final String mode;
  final String currentMode;
  final IconData icon;
  final String title;
  final String description;

  const _ThemeModeOption({
    required this.mode,
    required this.currentMode,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = mode == currentMode;

    return InkWell(
      onTap: () => Navigator.pop(context, mode),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 28.sp,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? theme.colorScheme.primary : null,
                    ),
                  ),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}

/// 🎨 Color Scheme Dialog
/// حوار اختيار نظام الألوان

class ColorSchemeDialog {
  static const Map<String, Map<String, dynamic>> _colors = {
    'blue': {'name': 'أزرق', 'color': Colors.blue},
    'green': {'name': 'أخضر', 'color': Colors.green},
    'purple': {'name': 'بنفسجي', 'color': Colors.purple},
    'orange': {'name': 'برتقالي', 'color': Colors.orange},
    'red': {'name': 'أحمر', 'color': Colors.red},
    'teal': {'name': 'تركواز', 'color': Colors.teal},
  };

  static Future<String?> show(
    BuildContext context,
    String currentScheme,
  ) async {
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('لون التطبيق'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.9,
            ),
            itemCount: _colors.length,
            itemBuilder: (context, index) {
              final entry = _colors.entries.elementAt(index);
              final isSelected = currentScheme == entry.key;

              return _ColorOption(
                name: entry.value['name'] as String,
                color: entry.value['color'] as Color,
                isSelected: isSelected,
                onTap: () => Navigator.pop(context, entry.key),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  final String name;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorOption({
    required this.name,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16.r),
          border: isSelected ? Border.all(color: Colors.white, width: 4) : null,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 32.sp,
              ),
            SizedBox(height: 8.h),
            Text(
              name,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 📝 Font Size Dialog
/// حوار اختيار حجم الخط

class FontSizeDialog {
  static Future<double?> show(
    BuildContext context,
    double currentSize,
  ) async {
    double fontSize = currentSize;

    return await showDialog<double>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('حجم الخط'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'معاينة النص',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Text(
                    '${fontSize.toInt()}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'نقطة',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('12', style: TextStyle(fontSize: 12.sp)),
                  Text('20', style: TextStyle(fontSize: 12.sp)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, fontSize),
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}

/// ⏱️ Generic Options Dialog
/// حوار عام لاختيار من قائمة خيارات

class OptionsDialog<T> {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<OptionItem<T>> options,
    required T currentValue,
  }) async {
    return await showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) {
            final isSelected = option.value == currentValue;
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: InkWell(
                onTap: () => Navigator.pop(context, option.value),
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (option.icon != null) ...[
                        Icon(
                          option.icon,
                          color: isSelected ? Theme.of(context).colorScheme.primary : null,
                        ),
                        SizedBox(width: 12.w),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Theme.of(context).colorScheme.primary : null,
                                  ),
                            ),
                            if (option.subtitle != null)
                              Text(
                                option.subtitle!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                              ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }
}

class OptionItem<T> {
  final T value;
  final String title;
  final String? subtitle;
  final IconData? icon;

  const OptionItem({
    required this.value,
    required this.title,
    this.subtitle,
    this.icon,
  });
}
