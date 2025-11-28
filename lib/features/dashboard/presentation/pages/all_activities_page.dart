import 'package:benaa_offline_app/core/error_handling/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../core/utils/haptic_patterns.dart';
import '../../../../core/design_system/app_animations.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../../core/ux/ux_widgets.dart';
import '../../../../core/error_handling/error_handler.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/entities/activity.dart';
import '../widgets/activities_section.dart';
import '../providers/activity_providers.dart';

/// 📜 All Activities Page - قائمة كل الأنشطة مع Pagination
class AllActivitiesPage extends ConsumerStatefulWidget {
  const AllActivitiesPage({super.key});

  @override
  ConsumerState<AllActivitiesPage> createState() => _AllActivitiesPageState();
}

class _AllActivitiesPageState extends ConsumerState<AllActivitiesPage> {
  final ScrollController _scrollController = ScrollController();
  late final Throttler _scrollThrottler; // ✅ Throttler for scroll
  final List<Activity> _activities = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  static const int _pageSize = 20;

  String _filterType = 'all'; // all, create, update, delete

  @override
  void initState() {
    super.initState();
    _scrollThrottler = Throttler(interval: const Duration(milliseconds: 100));
    _scrollController.addListener(_onScroll);
    _loadActivities();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    _scrollThrottler(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
        if (!_isLoading && _hasMore) {
          _loadActivities();
        }
      }
    });
  }

  Future<void> _loadActivities() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // ✅ Load from database instead of Mock data
      final repository = ref.read(activityRepositoryProvider);
      final result = await repository.getAllActivities();

      if (result is Failure<List<Activity>>) {
        throw Exception(result.error.message);
      }

      final allActivities = (result as Success<List<Activity>>).value;

      // Pagination logic
      final startIndex = _currentPage * _pageSize;
      final endIndex = startIndex + _pageSize;
      final newActivities = allActivities.skip(startIndex).take(_pageSize).toList();

      setState(() {
        _activities.addAll(newActivities);
        _currentPage++;
        _hasMore = endIndex < allActivities.length;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        EnhancedSnackbar.showError(context, message: 'فشل تحميل الأنشطة: $e');
      }
    }
  }

  // 🗑️ Mock data methods removed - now using real database data
  // Activities are loaded from activityRepositoryProvider

  Future<void> _clearCache() async {
    HapticPatterns.refresh();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ScaleTransitionWidget(
        duration: AppDurations.fast,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Icon(Icons.delete_sweep, color: Colors.orange),
              SizedBox(width: 12.w),
              const Text('مسح الذاكرة المؤقتة'),
            ],
          ),
          content: const Text(
            'سيتم مسح جميع الأنشطة المخزنة مؤقتاً. هل تريد المتابعة؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('مسح'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _activities.clear();
        _currentPage = 0;
        _hasMore = true;
      });
      await _loadActivities();

      if (mounted) {
        EnhancedSnackbar.showSuccess(
          context,
          message: 'تم مسح الذاكرة المؤقتة',
        );
      }
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _activities.clear();
      _currentPage = 0;
      _hasMore = true;
    });
    await _loadActivities();
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScaleTransitionWidget(
        duration: AppDurations.fast,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.filter_list, color: AppColors.primary),
                  SizedBox(width: 12.w),
                  Text(
                    'تصفية الأنشطة',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              _buildFilterOption('all', 'الكل', Icons.list),
              _buildFilterOption('create', 'الإضافة', Icons.add),
              _buildFilterOption('update', 'التحديث', Icons.edit),
              _buildFilterOption('delete', 'الحذف', Icons.delete),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _refresh();
                  },
                  child: const Text('تطبيق'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOption(String value, String label, IconData icon) {
    final isSelected = _filterType == value;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: () => setState(() => _filterType = value),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : Colors.grey,
                size: 24.sp,
              ),
              SizedBox(width: 16.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primary : Colors.grey[700],
                ),
              ),
              if (isSelected) ...[
                const Spacer(),
                Icon(Icons.check, color: AppColors.primary, size: 24.sp),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جميع الأنشطة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'فلترة',
            onPressed: _showFilters,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'clear_cache') {
                _clearCache();
              } else if (value == 'refresh') {
                _refresh();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 20),
                    SizedBox(width: 12),
                    Text('تحديث'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_cache',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, size: 20, color: Colors.orange),
                    SizedBox(width: 12),
                    Text('مسح الذاكرة المؤقتة'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: PullToRefreshWrapper(
        onRefresh: _refresh,
        child: _activities.isEmpty && !_isLoading
            ? EmptyStateWidget(
                icon: Icons.analytics_outlined,
                title: 'لا توجد أنشطة',
                message: 'ستظهر هنا جميع أنشطتك',
              )
            : ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(16.r),
                itemCount: _activities.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _activities.length) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.r),
                        child: const SmallLoadingIndicator(),
                      ),
                    );
                  }

                  final activity = _activities[index];
                  return FadeSlideTransition(
                    duration: AppDurations.fast,
                    child: ActivityItem(activity: activity),
                  );
                },
              ),
      ),
    );
  }
}
