import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 📸 Quick Actions Floating Button
class QuickActionsButton extends StatelessWidget {
  final VoidCallback? onCamera;
  final VoidCallback? onGallery;
  final VoidCallback? onScan;
  final VoidCallback? onVoiceNote;

  const QuickActionsButton({
    super.key,
    this.onCamera,
    this.onGallery,
    this.onScan,
    this.onVoiceNote,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<String>(
      icon: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(Icons.add_rounded, color: Colors.white, size: 24.sp),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      offset: Offset(-8.w, -8.h),
      itemBuilder: (context) => [
        if (onCamera != null)
          PopupMenuItem<String>(
            value: 'camera',
            child: _buildMenuItem(
              Icons.camera_alt_rounded,
              'التقاط صورة',
              Colors.blue,
            ),
          ),
        if (onGallery != null)
          PopupMenuItem<String>(
            value: 'gallery',
            child: _buildMenuItem(
              Icons.photo_library_rounded,
              'اختيار من المعرض',
              Colors.green,
            ),
          ),
        if (onScan != null)
          PopupMenuItem<String>(
            value: 'scan',
            child: _buildMenuItem(
              Icons.qr_code_scanner_rounded,
              'مسح QR/Barcode',
              Colors.purple,
            ),
          ),
        if (onVoiceNote != null)
          PopupMenuItem<String>(
            value: 'voice',
            child: _buildMenuItem(
              Icons.mic_rounded,
              'تسجيل صوتي',
              Colors.orange,
            ),
          ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'camera':
            onCamera?.call();
            break;
          case 'gallery':
            onGallery?.call();
            break;
          case 'scan':
            onScan?.call();
            break;
          case 'voice':
            onVoiceNote?.call();
            break;
        }
      },
    );
  }

  Widget _buildMenuItem(IconData icon, String label, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20.sp, color: color),
        ),
        SizedBox(width: 12.w),
        Text(label, style: TextStyle(fontSize: 14.sp)),
      ],
    );
  }
}

/// 🌙 Dark Mode Toggle
class DarkModeToggle extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const DarkModeToggle({
    super.key,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return RotationTransition(
            turns: animation,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          key: ValueKey(isDark),
        ),
      ),
      onPressed: () => onChanged(!isDark),
      tooltip: isDark ? 'الوضع الفاتح' : 'الوضع الداكن',
    );
  }
}
