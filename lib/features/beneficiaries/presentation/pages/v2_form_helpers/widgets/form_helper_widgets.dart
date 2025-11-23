import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/utils/responsive_utils_v2.dart';

/// 🎯 Field Focus Helper Widget
///
/// Helps navigate between form fields with next/previous buttons
class FieldNavigationHelper extends StatelessWidget {
  final FocusNode currentFocus;
  final FocusNode? nextFocus;
  final FocusNode? previousFocus;
  final VoidCallback? onDone;

  const FieldNavigationHelper({
    super.key,
    required this.currentFocus,
    this.nextFocus,
    this.previousFocus,
    this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (previousFocus != null)
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => previousFocus?.requestFocus(),
            tooltip: 'الحقل السابق',
            iconSize: 18,
          ),
        if (nextFocus != null)
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () => nextFocus?.requestFocus(),
            tooltip: 'الحقل التالي',
            iconSize: 18,
          ),
        if (onDone != null && nextFocus == null)
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: onDone,
            tooltip: 'إنهاء',
            color: Colors.green,
            iconSize: 18,
          ),
      ],
    );
  }
}

/// 📝 Smart Text Field with Auto-Save
///
/// TextField with automatic save on blur and change detection
class SmartTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final VoidCallback? onSave;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffix;

  const SmartTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onSave,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.suffix,
  });

  @override
  State<SmartTextField> createState() => _SmartTextFieldState();
}

class _SmartTextFieldState extends State<SmartTextField> {
  late String _initialValue;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initialValue = widget.controller.text;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasChanges = widget.controller.text != _initialValue;
    if (hasChanges != _hasChanges) {
      setState(() => _hasChanges = hasChanges);
    }
  }

  void _handleSave() {
    if (_hasChanges && widget.onSave != null) {
      widget.onSave!();
      _initialValue = widget.controller.text;
      setState(() => _hasChanges = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          _handleSave();
        }
      },
      child: TextFormField(
        controller: widget.controller,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
          suffix: widget.suffix,
          suffixIcon: _hasChanges
              ? Icon(
                  Icons.edit_outlined,
                  color: theme.colorScheme.primary,
                  size: 16,
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        validator: widget.validator,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
      ),
    );
  }
}

/// 🔍 Search Field Widget
///
/// Optimized search field with clear button and debouncing
class SearchField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onClear;
  final Duration debounceDuration;

  const SearchField({
    super.key,
    required this.controller,
    this.hint = 'بحث...',
    this.onSearch,
    this.onClear,
    this.debounceDuration = const Duration(milliseconds: 500),
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      widget.onSearch?.call(value);
    });
  }

  void _handleClear() {
    widget.controller.clear();
    widget.onClear?.call();
    widget.onSearch?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: widget.controller.text.isNotEmpty
            ? IconButton(icon: const Icon(Icons.clear), onPressed: _handleClear)
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        filled: true,
      ),
      onChanged: _onSearchChanged,
    );
  }
}

/// 🎨 Validation Message Widget
///
/// Shows validation messages with icons and colors
class ValidationMessage extends StatelessWidget {
  final String message;
  final ValidationStatus status;

  const ValidationMessage({
    super.key,
    required this.message,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color getColor() {
      switch (status) {
        case ValidationStatus.success:
          return Colors.green;
        case ValidationStatus.warning:
          return Colors.orange;
        case ValidationStatus.error:
          return Colors.red;
        case ValidationStatus.info:
          return theme.colorScheme.primary;
      }
    }

    IconData getIcon() {
      switch (status) {
        case ValidationStatus.success:
          return Icons.check_circle_outline;
        case ValidationStatus.warning:
          return Icons.warning_amber_outlined;
        case ValidationStatus.error:
          return Icons.error_outline;
        case ValidationStatus.info:
          return Icons.info_outline;
      }
    }

    return Container(
      margin: EdgeInsets.only(top: ResponsiveUtils.xSmallSpace),
      padding: EdgeInsets.all(ResponsiveUtils.smallSpace),
      decoration: BoxDecoration(
        color: getColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: getColor().withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(getIcon(), size: 16, color: getColor()),
          SizedBox(width: ResponsiveUtils.xSmallSpace),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 11.sp, color: getColor()),
            ),
          ),
        ],
      ),
    );
  }
}

enum ValidationStatus { success, warning, error, info }

/// ⏱️ Timer Widget
///
/// Shows elapsed time for form filling
class FormTimer extends StatefulWidget {
  final DateTime startTime;

  const FormTimer({super.key, required this.startTime});

  @override
  State<FormTimer> createState() => _FormTimerState();
}

class _FormTimerState extends State<FormTimer> {
  late Timer _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateElapsed();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateElapsed();
    });
  }

  void _updateElapsed() {
    setState(() {
      _elapsed = DateTime.now().difference(widget.startTime);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration() {
    final hours = _elapsed.inHours;
    final minutes = _elapsed.inMinutes.remainder(60);
    final seconds = _elapsed.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time_rounded,
            size: 14,
            color: theme.colorScheme.primary,
          ),
          SizedBox(width: 4.w),
          Text(
            _formatDuration(),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
