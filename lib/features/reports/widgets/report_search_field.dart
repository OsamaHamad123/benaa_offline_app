import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Search Field Widget for Reports
///
/// StatefulWidget حتى يملك المتحكّم ويتخلّص منه بشكل صحيح (كان StatelessWidget
/// ينشئ متحكّماً جديداً في كل build فيتسرّب، وزر المسح لا يظهر أبداً لأن الشرط
/// كان يُقيَّم مرة واحدة على متحكّم فارغ). الآن يستمع للتغييرات ويعيد بناء الزر.
class ReportSearchField extends StatefulWidget {
  final String? hint;
  final Function(String) onSearch;
  final VoidCallback? onClear;
  final TextEditingController? controller;

  const ReportSearchField({
    super.key,
    this.hint,
    required this.onSearch,
    this.onClear,
    this.controller,
  });

  @override
  State<ReportSearchField> createState() => _ReportSearchFieldState();
}

class _ReportSearchFieldState extends State<ReportSearchField> {
  late final TextEditingController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    // إعادة بناء لإظهار/إخفاء زر المسح حسب وجود نص
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    // لا نتخلّص من متحكّم يملكه الأب
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.dividerColor;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: widget.hint ?? 'ابحث...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    widget.onSearch('');
                    widget.onClear?.call();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
        ),
        onChanged: widget.onSearch,
      ),
    );
  }
}
