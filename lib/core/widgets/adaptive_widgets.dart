import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import '../../theme/app_colors.dart';

/// بطاقة تكيفية تتغير حسب المنصة (Material / Cupertino)
class AdaptiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const AdaptiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );

    if (Platform.isIOS) {
      // iOS Style - Cupertino
      return Container(
        margin:
            margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color ?? CupertinoColors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: onTap != null
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onTap,
                child: content,
              )
            : content,
      );
    } else {
      // Android Style - Material
      return Card(
        margin:
            margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: elevation ?? 2,
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(16),
        ),
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                borderRadius: borderRadius ?? BorderRadius.circular(16),
                child: content,
              )
            : content,
      );
    }
  }
}

/// زر تكيفي يتغير حسب المنصة
class AdaptiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isDestructive;
  final IconData? icon;
  final bool isLoading;

  const AdaptiveButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.isDestructive = false,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Platform.isIOS
            ? const CupertinoActivityIndicator()
            : const CircularProgressIndicator(),
      );
    }

    if (Platform.isIOS) {
      // iOS Style
      return CupertinoButton.filled(
        onPressed: onPressed,
        disabledColor: CupertinoColors.quaternarySystemFill,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(text),
          ],
        ),
      );
    } else {
      // Android Style
      if (isPrimary) {
        return ElevatedButton.icon(
          onPressed: onPressed,
          icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
          label: Text(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDestructive ? AppColors.error : null,
          ),
        );
      } else {
        return OutlinedButton.icon(
          onPressed: onPressed,
          icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
          label: Text(text),
          style: OutlinedButton.styleFrom(
            foregroundColor: isDestructive ? AppColors.error : null,
            side: BorderSide(
              color: isDestructive ? AppColors.error : AppColors.primary,
            ),
          ),
        );
      }
    }
  }
}

/// حقل إدخال تكيفي
class AdaptiveTextField extends StatelessWidget {
  final String? label;
  final String? placeholder;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final int? maxLines;
  final bool enabled;

  const AdaptiveTextField({
    super.key,
    this.label,
    this.placeholder,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      // iOS Style
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
            const SizedBox(height: 6),
          ],
          CupertinoTextField(
            controller: controller,
            placeholder: placeholder,
            keyboardType: keyboardType,
            obscureText: obscureText,
            onChanged: onChanged,
            maxLines: maxLines,
            enabled: enabled,
            prefix: prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(prefixIcon, size: 20),
                  )
                : null,
            suffix: suffixIcon != null
                ? CupertinoButton(
                    padding: const EdgeInsets.only(right: 8),
                    onPressed: onSuffixIconTap,
                    child: Icon(suffixIcon, size: 20),
                  )
                : null,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: CupertinoColors.systemGrey4,
                width: 0.5,
              ),
            ),
          ),
        ],
      );
    } else {
      // Android Style
      return TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        onChanged: onChanged,
        maxLines: maxLines,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          hintText: placeholder,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          suffixIcon: suffixIcon != null
              ? IconButton(icon: Icon(suffixIcon), onPressed: onSuffixIconTap)
              : null,
        ),
      );
    }
  }
}

/// مؤشر تحميل تكيفي
class AdaptiveLoading extends StatelessWidget {
  final double? size;

  const AdaptiveLoading({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoActivityIndicator(radius: size ?? 10);
    } else {
      return SizedBox(
        width: size != null ? size! * 2 : 20,
        height: size != null ? size! * 2 : 20,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }
  }
}

/// مربع حوار تكيفي
class AdaptiveDialog {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String content,
    List<AdaptiveDialogAction> actions = const [],
  }) {
    if (Platform.isIOS) {
      return showCupertinoDialog<T>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: actions
              .map(
                (action) => CupertinoDialogAction(
                  onPressed: () {
                    if (action.popsDialog) Navigator.pop(context, action.value);
                    action.onPressed?.call();
                  },
                  isDestructiveAction: action.isDestructive,
                  isDefaultAction: action.isDefault,
                  child: Text(action.text),
                ),
              )
              .toList(),
        ),
      );
    } else {
      return showDialog<T>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: actions
              .map(
                (action) => TextButton(
                  onPressed: () {
                    if (action.popsDialog) Navigator.pop(context, action.value);
                    action.onPressed?.call();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: action.isDestructive
                        ? AppColors.error
                        : null,
                  ),
                  child: Text(action.text),
                ),
              )
              .toList(),
        ),
      );
    }
  }
}

class AdaptiveDialogAction {
  final String text;
  final VoidCallback? onPressed;
  final bool isDestructive;
  final bool isDefault;
  final bool popsDialog;
  final dynamic value;

  const AdaptiveDialogAction({
    required this.text,
    this.onPressed,
    this.isDestructive = false,
    this.isDefault = false,
    this.popsDialog = true,
    this.value,
  });
}
