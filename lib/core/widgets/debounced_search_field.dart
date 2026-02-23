import 'package:flutter/material.dart';
import '../utils/debouncer.dart';

/// 🔍 Debounced Search Field
/// TextField مع debouncer مدمج للبحث الفعال
///
/// Example:
/// ```dart
/// DebouncedSearchField(
///   onSearch: (query) => performSearch(query),
///   hintText: 'ابحث...',
/// )
/// ```
class DebouncedSearchField extends StatefulWidget {
  final Function(String query) onSearch;
  final String? hintText;
  final TextEditingController? controller;
  final Duration delay;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final int? maxLines;

  const DebouncedSearchField({
    required this.onSearch, super.key,
    this.hintText,
    this.controller,
    this.delay = const Duration(milliseconds: 300),
    this.prefixIcon,
    this.suffixIcon,
    this.decoration,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  State<DebouncedSearchField> createState() => _DebouncedSearchFieldState();
}

class _DebouncedSearchFieldState extends State<DebouncedSearchField> {
  late final Debouncer _debouncer;
  late final TextEditingController _controller;
  bool _isControllerOwned = false;

  @override
  void initState() {
    super.initState();
    _debouncer = Debouncer(delay: widget.delay);

    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _isControllerOwned = true;
    }
  }

  @override
  void dispose() {
    _debouncer.dispose();
    if (_isControllerOwned) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value) {
    _debouncer(() {
      widget.onSearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      decoration: widget.decoration ??
          InputDecoration(
            hintText: widget.hintText ?? 'ابحث...',
            prefixIcon: widget.prefixIcon ?? const Icon(Icons.search),
            suffixIcon: widget.suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
    );
  }
}
