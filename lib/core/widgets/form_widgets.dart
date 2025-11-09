import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 🎨 Form Widgets - نظام موحد لجميع widgets النماذج
///
/// يحتوي على:
/// - CustomTextField: حقول إدخال موحدة
/// - CustomDropdown: قوائم منسدلة موحدة
/// - StatCard: بطاقات إحصائية
/// - InfoCard: بطاقات معلومات
/// - EmptyStateCard: حالة فارغة
/// - AlertCard: تنبيهات

// ==================== Constants ====================
const _kBorderRadius = BorderRadius.all(Radius.circular(12));
const _kOutlineBorder = OutlineInputBorder(borderRadius: _kBorderRadius);

// ==================== CustomTextField ====================

/// حقل إدخال موحد مع تصميم Material 3
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? hint;
  final String? helperText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final bool readOnly;
  final bool required;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final String? Function(String?)? validator;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.hint,
    this.helperText,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.maxLines = 1,
    this.readOnly = false,
    this.required = false,
    this.onTap,
    this.onChanged,
    this.onEditingComplete,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        helperText: helperText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        border: _kOutlineBorder,
        filled: true,
        isDense: true,
      ),
      keyboardType: keyboardType,
      textInputAction:
          textInputAction ??
          (maxLines > 1 ? TextInputAction.newline : TextInputAction.next),
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      readOnly: readOnly,
      enabled: enabled,
      onTap: onTap,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      validator:
          validator ??
          (required
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'هذا الحقل مطلوب';
                  }
                  return null;
                }
              : null),
      enableInteractiveSelection: true,
    );
  }
}

// ==================== CustomDropdown ====================

/// قائمة منسدلة موحدة مع تصميم Material 3
class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final String label;
  final IconData? prefixIcon;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final bool required;
  final String? Function(T?)? validator;
  final String? hint;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
    this.prefixIcon,
    this.required = false,
    this.validator,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: _kOutlineBorder,
        filled: true,
        isDense: true,
      ),
      items: items,
      onChanged: onChanged,
      isExpanded: true,
      isDense: true,
      validator:
          validator ??
          (required
              ? (value) {
                  if (value == null) {
                    return 'هذا الحقل مطلوب';
                  }
                  return null;
                }
              : null),
    );
  }
}

// ==================== StatCard ====================

/// بطاقة إحصائية فخمة مع gradient
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String? subtitle;
  final Widget? trailing;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.05), color.withOpacity(0.02)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              const Spacer(),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: color),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== InfoCard ====================

/// بطاقة معلومات مع أيقونة
class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = iconColor ?? Theme.of(context).colorScheme.primary;

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: effectiveColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: effectiveColor, size: 24),
        ),
        title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
        subtitle: Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      ),
    );
  }
}

// ==================== EmptyStateCard ====================

/// بطاقة حالة فارغة
class EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: primaryColor),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ==================== AlertCard ====================

/// بطاقة تنبيه
class AlertCard extends StatelessWidget {
  final String title;
  final String message;
  final AlertType type;
  final VoidCallback? onDismiss;
  final String? actionText;
  final VoidCallback? onAction;

  const AlertCard({
    super.key,
    required this.title,
    required this.message,
    this.type = AlertType.info,
    this.onDismiss,
    this.actionText,
    this.onAction,
  });

  Color _getColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (type) {
      case AlertType.success:
        return Colors.green;
      case AlertType.warning:
        return Colors.orange;
      case AlertType.error:
        return colorScheme.error;
      case AlertType.info:
        return colorScheme.primary;
    }
  }

  IconData get _icon {
    switch (type) {
      case AlertType.success:
        return Icons.check_circle_outline;
      case AlertType.warning:
        return Icons.warning_amber_rounded;
      case AlertType.error:
        return Icons.error_outline;
      case AlertType.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(context);

    return Card(
      color: color.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(message, style: Theme.of(context).textTheme.bodySmall),
                  if (actionText != null && onAction != null) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: onAction,
                      style: TextButton.styleFrom(
                        foregroundColor: color,
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(actionText!),
                    ),
                  ],
                ],
              ),
            ),
            if (onDismiss != null)
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: onDismiss,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }
}

enum AlertType { success, warning, error, info }

// ==================== ActionCard ====================

/// بطاقة إجراء سريع مع gradient
class ActionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
