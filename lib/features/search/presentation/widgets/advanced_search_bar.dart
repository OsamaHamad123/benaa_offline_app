import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/search_filter_provider.dart';

/// 🔍 Advanced Search Bar Widget
///
/// شريط بحث متقدم مع دعم البحث الصوتي والفلاتر

class AdvancedSearchBar extends ConsumerStatefulWidget {
  final String hintText;
  final Function(String) onSearch;
  final VoidCallback? onFilterTap;
  final bool showVoiceSearch;
  final bool showFilterButton;

  const AdvancedSearchBar({
    super.key,
    this.hintText = 'ابحث عن مستفيد...',
    required this.onSearch,
    this.onFilterTap,
    this.showVoiceSearch = true,
    this.showFilterButton = true,
  });

  @override
  ConsumerState<AdvancedSearchBar> createState() => _AdvancedSearchBarState();
}

class _AdvancedSearchBarState extends ConsumerState<AdvancedSearchBar> {
  final TextEditingController _controller = TextEditingController();
  bool _isListening = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startVoiceSearch() {
    setState(() => _isListening = true);

    // TODO: Implement speech recognition
    // For now, just a placeholder
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isListening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('البحث الصوتي قيد التطوير'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _onClear() {
    _controller.clear();
    widget.onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(searchFilterProvider);
    final hasActiveFilters = !filterState.currentFilter.isEmpty;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search Field
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onSearch,
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: 16.sp),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintTextDirection: TextDirection.rtl,
                prefixIcon: _isListening
                    ? Padding(
                        padding: EdgeInsets.all(12.w),
                        child: SizedBox(
                          width: 24.w,
                          height: 24.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      )
                    : Icon(Icons.search, size: 24.sp),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 20.sp),
                        onPressed: _onClear,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
            ),
          ),

          SizedBox(width: 8.w),

          // Voice Search Button
          if (widget.showVoiceSearch)
            Container(
              decoration: BoxDecoration(
                color: _isListening
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: _isListening
                    ? Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      )
                    : null,
              ),
              child: IconButton(
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).iconTheme.color,
                  size: 24.sp,
                ),
                onPressed: _isListening ? null : _startVoiceSearch,
                tooltip: 'البحث الصوتي',
              ),
            ),

          SizedBox(width: 8.w),

          // Filter Button
          if (widget.showFilterButton)
            Container(
              decoration: BoxDecoration(
                color: hasActiveFilters
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.filter_list,
                      color: hasActiveFilters
                          ? Colors.white
                          : Theme.of(context).iconTheme.color,
                      size: 24.sp,
                    ),
                    onPressed: widget.onFilterTap,
                    tooltip: 'الفلاتر المتقدمة',
                  ),
                  if (hasActiveFilters)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
