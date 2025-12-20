import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 🎯 حلول بديلة لـ FAB (Quick Actions)
///
/// المشكلة الحالية:
/// - FAB يتعارض مع BottomNavigationBar
/// - يخفي محتوى مهم
/// - غير مناسب للتابلت
///
/// الحلول المقترحة:
/// 1. قائمة منسدلة في AppBar (الأفضل للتابلت)
/// 2. Bottom Sheet من BottomBar
/// 3. Speed Dial FAB
/// 4. Context Menu على الحقول

/// ✅ الحل 1: قائمة Quick Actions في AppBar
class QuickActionsMenu extends StatelessWidget {
  final VoidCallback onCopyFromBeneficiary;
  final VoidCallback onClearAllFields;
  final VoidCallback onPasteData;
  final VoidCallback onFillDemoData;
  final bool enabled;

  const QuickActionsMenu({
    super.key,
    required this.onCopyFromBeneficiary,
    required this.onClearAllFields,
    required this.onPasteData,
    required this.onFillDemoData,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<String>(
      icon: Icon(
        Icons.flash_on_outlined,
        color: enabled ? null : theme.disabledColor,
      ),
      tooltip: 'إجراءات سريعة',
      enabled: enabled,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      offset: Offset(0, 50.h),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'copy',
          child: _MenuItem(
            icon: Icons.copy,
            title: 'نسخ من مستفيد',
            subtitle: 'انسخ البيانات من مستفيد آخر',
          ),
        ),
        PopupMenuItem(
          value: 'paste',
          child: _MenuItem(
            icon: Icons.paste,
            title: 'لصق البيانات',
            subtitle: 'لصق من الحافظة',
          ),
        ),
        PopupMenuItem(
          value: 'demo',
          child: _MenuItem(
            icon: Icons.science_outlined,
            title: 'بيانات تجريبية',
            subtitle: 'ملء النموذج للاختبار',
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'clear',
          child: _MenuItem(
            icon: Icons.clear_all,
            title: 'مسح كل الحقول',
            subtitle: 'حذف جميع البيانات',
            isDestructive: true,
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'copy':
            onCopyFromBeneficiary();
            break;
          case 'paste':
            onPasteData();
            break;
          case 'demo':
            onFillDemoData();
            break;
          case 'clear':
            onClearAllFields();
            break;
        }
      },
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDestructive ? theme.colorScheme.error : null;

    return Row(
      children: [
        Icon(icon, color: color, size: 24.sp),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 2.h),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// ✅ الحل 2: Bottom Sheet للـ Quick Actions
class QuickActionsBottomSheet extends StatelessWidget {
  final VoidCallback onCopyFromBeneficiary;
  final VoidCallback onClearAllFields;
  final VoidCallback onPasteData;
  final VoidCallback onFillDemoData;

  const QuickActionsBottomSheet({
    super.key,
    required this.onCopyFromBeneficiary,
    required this.onClearAllFields,
    required this.onPasteData,
    required this.onFillDemoData,
  });

  static void show(
    BuildContext context, {
    required VoidCallback onCopyFromBeneficiary,
    required VoidCallback onClearAllFields,
    required VoidCallback onPasteData,
    required VoidCallback onFillDemoData,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickActionsBottomSheet(
        onCopyFromBeneficiary: onCopyFromBeneficiary,
        onClearAllFields: onClearAllFields,
        onPasteData: onPasteData,
        onFillDemoData: onFillDemoData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            SizedBox(height: 20.h),

            // Title
            Text(
              'إجراءات سريعة',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 24.h),

            // Actions
            _ActionTile(
              icon: Icons.copy,
              title: 'نسخ من مستفيد',
              subtitle: 'انسخ البيانات من مستفيد آخر',
              onTap: () {
                Navigator.pop(context);
                onCopyFromBeneficiary();
              },
            ),

            _ActionTile(
              icon: Icons.paste,
              title: 'لصق البيانات',
              subtitle: 'لصق من الحافظة',
              onTap: () {
                Navigator.pop(context);
                onPasteData();
              },
            ),

            _ActionTile(
              icon: Icons.science_outlined,
              title: 'بيانات تجريبية',
              subtitle: 'ملء النموذج للاختبار',
              onTap: () {
                Navigator.pop(context);
                onFillDemoData();
              },
            ),

            Divider(height: 32.h),

            _ActionTile(
              icon: Icons.clear_all,
              title: 'مسح كل الحقول',
              subtitle: 'حذف جميع البيانات',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                onClearAllFields();
              },
            ),

            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        isDestructive ? theme.colorScheme.error : theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.dividerColor),
          ],
        ),
      ),
    );
  }
}

/// ✅ الحل 3: Speed Dial FAB (اختياري)
class QuickActionsSpeedDial extends StatefulWidget {
  final VoidCallback onCopyFromBeneficiary;
  final VoidCallback onClearAllFields;
  final VoidCallback onPasteData;
  final VoidCallback onFillDemoData;
  final bool enabled;

  const QuickActionsSpeedDial({
    super.key,
    required this.onCopyFromBeneficiary,
    required this.onClearAllFields,
    required this.onPasteData,
    required this.onFillDemoData,
    this.enabled = true,
  });

  @override
  State<QuickActionsSpeedDial> createState() => _QuickActionsSpeedDialState();
}

class _QuickActionsSpeedDialState extends State<QuickActionsSpeedDial>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_isOpen) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() => _isOpen = !_isOpen);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Backdrop
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggle,
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          ),

        // Actions
        ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _SpeedDialAction(
                icon: Icons.copy,
                label: 'نسخ',
                onTap: () {
                  _toggle();
                  widget.onCopyFromBeneficiary();
                },
              ),
              SizedBox(height: 12.h),
              _SpeedDialAction(
                icon: Icons.paste,
                label: 'لصق',
                onTap: () {
                  _toggle();
                  widget.onPasteData();
                },
              ),
              SizedBox(height: 12.h),
              _SpeedDialAction(
                icon: Icons.science_outlined,
                label: 'تجريبي',
                onTap: () {
                  _toggle();
                  widget.onFillDemoData();
                },
              ),
              SizedBox(height: 12.h),
              _SpeedDialAction(
                icon: Icons.clear_all,
                label: 'مسح',
                backgroundColor: theme.colorScheme.error,
                onTap: () {
                  _toggle();
                  widget.onClearAllFields();
                },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),

        // Main FAB
        FloatingActionButton(
          onPressed: widget.enabled ? _toggle : null,
          child: AnimatedRotation(
            turns: _isOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 250),
            child: Icon(_isOpen ? Icons.close : Icons.flash_on),
          ),
        ),
      ],
    );
  }
}

class _SpeedDialAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;

  const _SpeedDialAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
        ),
        SizedBox(width: 12.w),
        FloatingActionButton.small(
          onPressed: onTap,
          backgroundColor: backgroundColor,
          child: Icon(icon),
        ),
      ],
    );
  }
}
