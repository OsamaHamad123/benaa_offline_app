import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';

/// 🔍 Enhanced Search Bar - شريط بحث محسّن مع debouncing
class EnhancedSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final String? hintText;
  final Duration debounceDuration;
  final TextEditingController? controller;

  const EnhancedSearchBar({
    super.key,
    required this.onSearch,
    this.hintText,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.controller,
  });

  @override
  State<EnhancedSearchBar> createState() => _EnhancedSearchBarState();
}

class _EnhancedSearchBarState extends State<EnhancedSearchBar> {
  late TextEditingController _controller;
  Timer? _debounce;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    if (value.isEmpty) {
      setState(() => _isSearching = false);
      widget.onSearch('');
      return;
    }

    setState(() => _isSearching = true);

    _debounce = Timer(widget.debounceDuration, () {
      if (!mounted) return;
      setState(() => _isSearching = false);
      widget.onSearch(value.trim());
    });
  }

  void _clearSearch() {
    // A search typed just before clearing is still waiting on its debounce;
    // left running it would fire after the field is empty and filter by the
    // old text.
    _debounce?.cancel();
    _controller.clear();
    setState(() => _isSearching = false);
    widget.onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        onChanged: _onSearchChanged,
        textDirection: TextDirection.rtl,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'ابحث برقم الملف، الاسم، الهوية...',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
          prefixIcon: _isSearching
              ? Padding(
                  padding: EdgeInsets.all(12.w),
                  child: SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
                )
              : Icon(
                  Icons.search_rounded,
                  color: theme.colorScheme.primary,
                  size: 24.sp,
                ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: _clearSearch,
                  tooltip: 'مسح',
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
        ),
      ),
    );
  }
}
