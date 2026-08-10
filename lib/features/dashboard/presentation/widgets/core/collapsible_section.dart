import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../core/utils/haptic_patterns.dart';

/// Collapsible Section Widget - قسم قابل للطي
///
/// استخدام:
/// ```dart
/// CollapsibleSection(
///   title: 'الإحصائيات',
///   icon: Icons.bar_chart,
///   child: StatisticsWidget(),
/// )
/// ```
class CollapsibleSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Color? accentColor;
  final bool initiallyExpanded;

  const CollapsibleSection({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.accentColor,
    this.initiallyExpanded = false,
  });

  @override
  State<CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<CollapsibleSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.accentColor ?? AppColors.primary;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: effectiveColor.withOpacity(_isExpanded ? 0.2 : 0.1),
          width: _isExpanded ? 2 : 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  effectiveColor.withOpacity(0.2),
                  effectiveColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(widget.icon, size: 20.sp, color: effectiveColor),
          ),
          title: Text(
            widget.title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          trailing: AnimatedRotation(
            turns: _isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.expand_more,
              color: effectiveColor,
            ),
          ),
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
            HapticPatterns.selection();
          },
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}
