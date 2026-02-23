import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils_v2.dart';

/// ✅ مفتاح تبديل modern
class ModernSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ModernSwitch({
    required this.title, required this.subtitle, required this.icon, required this.iconColor, required this.value, required this.onChanged, super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.mediumSpace),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            iconColor.withOpacity(0.08),
            iconColor.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
        border: Border.all(
          color: iconColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.smallSpace),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [iconColor, iconColor.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(ResponsiveUtils.smallRadius),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: ResponsiveUtils.getIconSize(context),
            ),
          ),
          SizedBox(width: ResponsiveUtils.smallSpace),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.xSmallSpace / 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: ResponsiveUtils.smallSpace),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: iconColor,
            thumbIcon: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Icon(
                  Icons.check,
                  color: Colors.white,
                  size: ResponsiveUtils.getIconSize(context) * 0.6,
                );
              }
              return null;
            }),
          ),
        ],
      ),
    );
  }
}
