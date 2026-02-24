import 'package:flutter/material.dart';

/// 🔍 Search bar widget مع debounce - Reusable component
///
/// يوفر:
/// - حقل بحث مع أيقونة
/// - زر مسح
/// - دعم الـ RTL
class BeneficiariesSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final Function(String)? onSubmitted;
  final String hintText;
  final EdgeInsetsGeometry? padding;

  const BeneficiariesSearchBar({
    required this.controller,
    this.focusNode,
    required this.onChanged,
    super.key,
    this.onClear,
    this.onSubmitted,
    this.hintText = 'بحث عن مستفيد...',
    this.padding,
  });

  @override
  State<BeneficiariesSearchBar> createState() => _BeneficiariesSearchBarState();
}

class _BeneficiariesSearchBarState extends State<BeneficiariesSearchBar> {
  void _onSearchChanged(String value) {
    // Update UI immediately for clear button
    setState(() {});
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        onChanged: _onSearchChanged,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    widget.controller.clear();
                    setState(() {});
                    widget.onChanged('');
                    widget.onClear?.call();
                  },
                )
              : null,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onSubmitted: widget.onSubmitted,
      ),
    );
  }
}
