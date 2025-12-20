import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/advanced_filters_panel.dart';
import '../widgets/advanced_search_bar.dart';
import '../widgets/saved_filters_list.dart';

/// 🔍 Advanced Search Demo Page
///
/// صفحة توضيحية لنظام البحث المتقدم

class AdvancedSearchDemoPage extends ConsumerStatefulWidget {
  const AdvancedSearchDemoPage({super.key});

  @override
  ConsumerState<AdvancedSearchDemoPage> createState() =>
      _AdvancedSearchDemoPageState();
}

class _AdvancedSearchDemoPageState
    extends ConsumerState<AdvancedSearchDemoPage> {
  String _searchQuery = '';

  void _showFiltersPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdvancedFiltersPanel(
        onApply: () {
          Navigator.pop(context);
          // Apply filters to search
          _performSearch();
        },
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _showSavedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 24.sp),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'الفلاتر المحفوظة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  SizedBox(width: 48.w), // Balance the close button
                ],
              ),
            ),
            Expanded(
              child: SavedFiltersList(
                onFilterSelected: (id) => _performSearch(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _performSearch() {
    // TODO: Implement actual search logic
    setState(() {
      // Trigger rebuild to show updated results
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'البحث المتقدم',
          textDirection: TextDirection.rtl,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: _showSavedFilters,
            tooltip: 'الفلاتر المحفوظة',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          AdvancedSearchBar(
            onSearch: (query) {
              setState(() => _searchQuery = query);
              _performSearch();
            },
            onFilterTap: _showFiltersPanel,
          ),

          // Results
          Expanded(
            child: _buildResultsSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_searchQuery.isEmpty) {
      return _buildEmptyState(
        Icons.search,
        'ابدأ البحث',
        'استخدم شريط البحث أو الفلاتر للعثور على المستفيدين',
      );
    }

    // TODO: Replace with actual search results
    return _buildEmptyState(
      Icons.filter_list,
      'لا توجد نتائج',
      'جرب استخدام فلاتر مختلفة',
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80.sp,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
            textDirection: TextDirection.rtl,
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}
