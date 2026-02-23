import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';

/// حقل بحث قابل لإعادة الاستخدام مع Debouncing
///
/// استخدامات:
/// - البحث في السجل المدني
/// - البحث في المستفيدين
/// - أي صفحة بحث
class SearchField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final Function(String) onSearch;
  final VoidCallback? onClear;
  final int debounceMs;
  final bool autofocus;
  final IconData prefixIcon;
  final Widget? suffix;

  const SearchField({
    required this.controller, required this.hint, required this.onSearch, super.key,
    this.onClear,
    this.debounceMs = 300,
    this.autofocus = false,
    this.prefixIcon = Icons.search,
    this.suffix,
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

  void _onChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      Duration(milliseconds: widget.debounceMs),
      () => widget.onSearch(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isMobile = mediaQuery.size.width < 600;

    return TextField(
      controller: widget.controller,
      onChanged: _onChanged,
      autofocus: widget.autofocus,
      style: TextStyle(fontSize: (isMobile ? 14 : 16).sp),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurface.withOpacity(0.5),
          fontSize: (isMobile ? 14 : 16).sp,
        ),
        prefixIcon: Icon(
          widget.prefixIcon,
          color: theme.colorScheme.primary,
          size: (isMobile ? 20 : 24).sp,
        ),
        suffixIcon: widget.controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  widget.controller.clear();
                  widget.onClear?.call();
                  widget.onSearch('');
                },
              )
            : widget.suffix,
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular((isMobile ? 10 : 12).r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular((isMobile ? 10 : 12).r),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1.w,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular((isMobile ? 10 : 12).r),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.w),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 12 : 14,
        ),
      ),
    );
  }
}

/// حقل بحث مع أيقونة مخصصة
class SearchFieldWithAction extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Function(String) onSearch;
  final VoidCallback onActionPressed;
  final IconData actionIcon;
  final String? actionTooltip;

  const SearchFieldWithAction({
    required this.controller, required this.hint, required this.onSearch, required this.onActionPressed, super.key,
    this.actionIcon = Icons.filter_list,
    this.actionTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SearchField(
            controller: controller,
            hint: hint,
            onSearch: onSearch,
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: onActionPressed,
          icon: Icon(actionIcon),
          tooltip: actionTooltip ?? 'فلترة',
        ),
      ],
    );
  }
}
