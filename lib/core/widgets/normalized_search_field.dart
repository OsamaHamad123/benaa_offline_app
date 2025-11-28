import 'package:flutter/material.dart';
import '../utils/arabic_normalizer.dart';
import '../utils/debouncer.dart';

/// 🔤 Normalized Search Field
/// TextField مع تطبيع عربي تلقائي + debouncer
///
/// Automatically normalizes Arabic text for better search results
class NormalizedSearchField extends StatefulWidget {
  final Function(String normalizedQuery) onSearch;
  final String? hintText;
  final TextEditingController? controller;
  final Duration delay;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final InputDecoration? decoration;

  const NormalizedSearchField({
    super.key,
    required this.onSearch,
    this.hintText,
    this.controller,
    this.delay = const Duration(milliseconds: 300),
    this.prefixIcon,
    this.suffixIcon,
    this.decoration,
  });

  @override
  State<NormalizedSearchField> createState() => _NormalizedSearchFieldState();
}

class _NormalizedSearchFieldState extends State<NormalizedSearchField> {
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
      final normalizedQuery = ArabicNormalizer.normalize(value);
      widget.onSearch(normalizedQuery);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onChanged,
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
