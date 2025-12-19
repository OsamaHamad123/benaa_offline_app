import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_utils_v2.dart';

/// 🎨 قسم حقول النموذج - Reusable Form Section
class FormSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const FormSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.mediumSpace),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.smallSpace),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(ResponsiveUtils.smallRadius),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
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
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 📝 حقل نصي مع تصميم Material 3
class ModernFormField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String labelText;
  final String? hintText;
  final IconData icon;
  final Color iconColor;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final VoidCallback? onFieldSubmitted;
  final int maxLines;
  final bool enabled;
  final bool required;

  const ModernFormField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.labelText,
    this.hintText,
    required this.icon,
    required this.iconColor,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
    this.maxLines = 1,
    this.enabled = true,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.right,
          textInputAction: textInputAction,
          keyboardType: keyboardType,
          enabled: enabled,
          maxLines: maxLines,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: required ? '$labelText *' : labelText,
            hintText: hintText,
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            prefixIcon: Container(
              margin: EdgeInsets.all(ResponsiveUtils.smallSpace),
              padding: EdgeInsets.all(ResponsiveUtils.xSmallSpace),
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
                size: ResponsiveUtils.getIconSize(context) * 0.8,
              ),
            ),
            suffixIcon: value.text.trim().isNotEmpty && enabled
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: ResponsiveUtils.getIconSize(context) * 0.7,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    onPressed: () {
                      controller.clear();
                      focusNode?.requestFocus();
                    },
                  )
                : null,
            filled: true,
            fillColor: iconColor.withOpacity(0.03),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
              borderSide: BorderSide(
                color: iconColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
              borderSide: BorderSide(
                color: iconColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
              borderSide: BorderSide(
                color: iconColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.mediumSpace,
              vertical: ResponsiveUtils.smallSpace * 1.5,
            ),
          ),
          validator: validator,
          onFieldSubmitted: (_) => onFieldSubmitted?.call(),
        );
      },
    );
  }
}

/// 🔽 قائمة منسدلة مع تصميم Material 3
class ModernDropdown<T> extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final IconData icon;
  final Color iconColor;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final bool required;

  const ModernDropdown({
    super.key,
    required this.labelText,
    this.hintText,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: required ? '$labelText *' : labelText,
        hintText: hintText,
        prefixIcon: Container(
          margin: EdgeInsets.all(ResponsiveUtils.smallSpace),
          padding: EdgeInsets.all(ResponsiveUtils.xSmallSpace),
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
            size: ResponsiveUtils.getIconSize(context) * 0.8,
          ),
        ),
        filled: true,
        fillColor: iconColor.withOpacity(0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
          borderSide: BorderSide(
            color: iconColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
          borderSide: BorderSide(
            color: iconColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
          borderSide: BorderSide(
            color: iconColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 1.5,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.mediumSpace,
          vertical: ResponsiveUtils.smallSpace * 1.5,
        ),
      ),
      dropdownColor: theme.colorScheme.surface,
      style: theme.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w500,
        color: theme.colorScheme.onSurface,
      ),
    );
  }
}

/// ✅ مفتاح تبديل modern
class ModernSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ModernSwitch({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.onChanged,
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
                SizedBox(height: 2.h),
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
            activeColor: iconColor,
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

/// 📏 Responsive Form Grid - تقسيم الحقول على عمودين في التابلت
class ResponsiveFormRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const ResponsiveFormRow({
    super.key,
    required this.children,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveUtils.isMobile(context) || children.length == 1) {
      // موبايل أو حقل واحد: عمود واحد
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children.expand((child) => [child, SizedBox(height: spacing)]).toList()..removeLast(),
      );
    }

    // تابلت+: صفين
    return LayoutBuilder(
      builder: (context, constraints) {
        final colWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children.map((child) => SizedBox(width: colWidth, child: child)).toList(),
        );
      },
    );
  }
}
