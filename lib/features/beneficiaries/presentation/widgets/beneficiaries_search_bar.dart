import 'package:flutter/material.dart';
import 'dart:async';

/// 🔍 Search bar widget مع debounce - Reusable component
///
/// يوفر:
/// - حقل بحث مع أيقونة
/// - زر مسح
/// - دعم الـ RTL
/// - ⚡ Debounce 300ms لتحسين الأداء
class BeneficiariesSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String hintText;
  final EdgeInsetsGeometry? padding;
  final Duration debounceDuration;

  const BeneficiariesSearchBar({
    required this.controller, required this.onChanged, super.key,
    this.onClear,
    this.hintText = 'بحث عن مستفيد...',
    this.padding,
    this.debounceDuration = const Duration(milliseconds: 300),
  });

  @override
  State<BeneficiariesSearchBar> createState() => _BeneficiariesSearchBarState();
}

class _BeneficiariesSearchBarState extends State<BeneficiariesSearchBar> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    // Cancel previous timer
    _debounce?.cancel();

    // Update UI immediately for clear button
    setState(() {});

    // Debounce the actual search
    _debounce = Timer(widget.debounceDuration, () {
      widget.onChanged(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: widget.controller,
        onChanged: _onSearchChanged,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    widget.controller.clear();
                    _debounce?.cancel();
                    setState(() {});
                    widget.onChanged('');
                    widget.onClear?.call();
                  },
                )
              : null,
          filled: true,
          fillColor:
              Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
