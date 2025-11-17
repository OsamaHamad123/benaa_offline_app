import 'package:flutter/material.dart';

/// 🔍 Search bar widget مع debounce - Reusable component
///
/// يوفر:
/// - حقل بحث مع أيقونة
/// - زر مسح
/// - دعم الـ RTL
/// - دعم الـ debounce من الـ provider
class BeneficiariesSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String hintText;
  final EdgeInsetsGeometry? padding;

  const BeneficiariesSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClear,
    this.hintText = 'بحث عن مستفيد...',
    this.padding,
  });

  @override
  State<BeneficiariesSearchBar> createState() => _BeneficiariesSearchBarState();
}

class _BeneficiariesSearchBarState extends State<BeneficiariesSearchBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: widget.controller,
        onChanged: (value) {
          setState(() {}); // Update UI to show/hide clear button
          widget.onChanged(value);
        },
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
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
          fillColor: Colors.grey[100],
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
