import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../pages/v2_form_helpers/widgets/inline_validation_message.dart';
import '../../../../../core/utils/haptic_patterns.dart';

/// 🎯 Animated Form Field - With focus border animation & inline validation
///
/// Enhanced TextField with smooth focus animations and real-time validation feedback
class AnimatedFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final int? maxLines;
  final bool obscureText;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  // ✅ NEW: Inline validation support
  final String? validationMessage;
  final ValidationLevel? validationLevel;
  final bool showValidation;

  const AnimatedFormField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffix,
    this.keyboardType,
    this.maxLines = 1,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.validator,
    this.inputFormatters,
    this.focusNode,
    this.textInputAction,
    this.validationMessage,
    this.validationLevel,
    this.showValidation = false,
  });

  @override
  State<AnimatedFormField> createState() => _AnimatedFormFieldState();
}

class _AnimatedFormFieldState extends State<AnimatedFormField> with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_isFocused) {
      HapticPatterns.light();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isFocused ? theme.colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            maxLines: widget.maxLines,
            obscureText: widget.obscureText,
            readOnly: widget.readOnly,
            onTap: widget.onTap,
            onChanged: widget.onChanged,
            validator: widget.validator,
            inputFormatters: widget.inputFormatters,
            textInputAction: widget.textInputAction,
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hintText,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                    )
                  : null,
              suffix: widget.suffix,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: _isFocused
                  ? theme.colorScheme.primaryContainer.withOpacity(0.1)
                  : theme.colorScheme.surfaceContainerHighest.withOpacity(
                      0.3,
                    ),
            ),
          ),
        ),

        // ✅ Inline Validation Message
        if (widget.showValidation && widget.validationMessage != null && widget.validationLevel != null)
          InlineValidationMessage(
            message: widget.validationMessage!,
            level: widget.validationLevel!,
            show: widget.showValidation,
          ),
      ],
    );
  }
}

/// 🎯 Animated Dropdown Field
class AnimatedDropdownField<T> extends StatefulWidget {
  final T? value;
  final String? labelText;
  final IconData? prefixIcon;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;

  const AnimatedDropdownField({
    super.key,
    this.value,
    this.labelText,
    this.prefixIcon,
    required this.items,
    this.onChanged,
    this.validator,
  });

  @override
  State<AnimatedDropdownField<T>> createState() => _AnimatedDropdownFieldState<T>();
}

class _AnimatedDropdownFieldState<T> extends State<AnimatedDropdownField<T>> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isFocused ? theme.colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: DropdownButtonFormField<T>(
        value: widget.value,
        focusNode: _focusNode,
        items: widget.items,
        onChanged: widget.onChanged,
        validator: widget.validator,
        decoration: InputDecoration(
          labelText: widget.labelText,
          prefixIcon: widget.prefixIcon != null
              ? Icon(
                  widget.prefixIcon,
                  color: _isFocused ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
          filled: true,
          fillColor: _isFocused
              ? theme.colorScheme.primaryContainer.withOpacity(0.1)
              : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        ),
      ),
    );
  }
}
