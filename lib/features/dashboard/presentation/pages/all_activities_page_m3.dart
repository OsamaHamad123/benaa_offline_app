import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/app_animations.dart';
import '../../../../core/ux/ux_widgets.dart';
import '../../../../core/error_handling/error_handler.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/entities/activity.dart';
import '../../domain/services/cache_manager.dart';
import '../../../dashboard/presentation/providers.dart';

/// 📜 All Activities Page - Material 3 Design
/// عرض جميع الأنشطة من قاعدة البيانات الفعلية
class AllActivitiesPageM3 extends ConsumerStatefulWidget {
  const AllActivitiesPageM3({super.key});

  @override
  ConsumerState<AllActivitiesPageM3> createState() => _AllActivitiesPageM3State();
}

class _AllActivitiesPageM3State extends ConsumerState<AllActivitiesPageM3> {
  String _filterType = 'all'; // all, beneficiary, visit, sync, attachment
  DateTime? _selectedDate;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ✅ استخدام Provider بدلاً من getter
  List<Activity> get _filteredActivities {
    return ref.watch(filteredActivitiesProvider({
      'type': _filterType,
      'date': _selectedDate,
    }));
  }

  Map<String, List<Activity>> get _groupedActivities {
    final activities = _filteredActivities;
    final grouped = <String, List<Activity>>{};

    for (final activity in activities) {
      final dateKey = DateFormat('yyyy-MM-dd').format(activity.timestamp);
      grouped.putIfAbsent(dateKey, () => []).add(activity);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    final groupedActivities = _groupedActivities;
    final dates = groupedActivities.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'سجل الأنشطة',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Date Filter
          IconButton(
            icon: Badge(
              isLabelVisible: _selectedDate != null,
              label: const Text('1'),
              child: const Icon(Icons.calendar_today),
            ),
            tooltip: 'تصفية بالتاريخ',
            onPressed: () => _selectDate(),
          ),
          // More Options
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'clear_cache') {
                await _clearCache();
              } else if (value == 'refresh') {
                await ref.read(dashboardProvider.notifier).refresh();
                if (mounted) {
                  EnhancedSnackbar.showSuccess(
                    context,
                    message: 'تم تحديث البيانات',
                  );
                }
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
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(70.h),
          child: Column(
            children: [
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: 'الكل',
                      value: 'all',
                      icon: Icons.list,
                      count: state.activities.length,
                    ),
                    SizedBox(width: 8.w),
                    _buildFilterChip(
                      label: 'المستفيدين',
                      value: 'beneficiary',
                      icon: Icons.person,
                      count: state.activities.where((a) => a.type == 'beneficiary').length,
                    ),
                    SizedBox(width: 8.w),
                    _buildFilterChip(
                      label: 'الزيارات',
                      value: 'visit',
                      icon: Icons.event_note,
                      count: state.activities.where((a) => a.type == 'visit').length,
                    ),
                    SizedBox(width: 8.w),
                    _buildFilterChip(
                      label: 'المزامنة',
                      value: 'sync',
                      icon: Icons.sync,
                      count: state.activities.where((a) => a.type == 'sync').length,
                    ),
                    SizedBox(width: 8.w),
                    _buildFilterChip(
                      label: 'المرفقات',
                      value: 'attachment',
                      icon: Icons.attach_file,
                      count: state.activities.where((a) => a.type == 'attachment').length,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: state.isLoadingActivities
          ? _buildLoadingSkeleton()
          : _filteredActivities.isEmpty
              ? _buildEmptyState()
              : _buildActivitiesList(dates, groupedActivities),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required IconData icon,
    required int count,
  }) {
    final isSelected = _filterType == value;

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp),
          SizedBox(width: 6.w),
          Text('$label ($count)'),
        ],
      ),
      onSelected: (_) {
        setState(() => _filterType = value);
        HapticFeedback.selectionClick();
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        fontSize: 13.sp,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: 8,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: SkeletonListItem(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      icon: Icons.analytics_outlined,
      title: 'لا توجد أنشطة',
      message:
          _filterType == 'all' ? 'ستظهر هنا جميع أنشطتك' : 'لا توجد أنشطة من نوع "${_getFilterLabel(_filterType)}"',
      action: _selectedDate != null
          ? ElevatedButton.icon(
              onPressed: () => setState(() => _selectedDate = null),
              icon: const Icon(Icons.clear),
              label: const Text('إزالة التصفية'),
            )
          : null,
    );
  }

  String _getFilterLabel(String type) {
    switch (type) {
      case 'beneficiary':
        return 'المستفيدين';
      case 'visit':
        return 'الزيارات';
      case 'sync':
        return 'المزامنة';
      case 'attachment':
        return 'المرفقات';
      default:
        return 'الكل';
    }
  }

  Widget _buildActivitiesList(
    List<String> dates,
    Map<String, List<Activity>> groupedActivities,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(dashboardProvider.notifier).refresh();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(16.r),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final dateKey = dates[index];
          final dateActivities = groupedActivities[dateKey]!;
          final date = DateTime.parse(dateKey);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(date, dateActivities.length),
              SizedBox(height: 12.h),
              ...dateActivities.map((activity) => _buildActivityCard(activity)),
              SizedBox(height: 24.h),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateHeader(DateTime date, int count) {
    final isToday = DateTime.now().difference(date).inDays == 0;
    final isYesterday = DateTime.now().difference(date).inDays == 1;

    String dateLabel;
    if (isToday) {
      dateLabel = 'اليوم';
    } else if (isYesterday) {
      dateLabel = 'أمس';
    } else {
      dateLabel = DateFormat('EEEE، d MMMM y', 'ar').format(date);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, size: 16.sp, color: AppColors.primary),
          SizedBox(width: 8.w),
          Text(
            dateLabel,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Activity activity) {
    final activityConfig = _getActivityConfig(activity.type);

    return FadeSlideTransition(
      duration: AppDurations.fast,
      child: Card(
        margin: EdgeInsets.only(bottom: 12.h),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: AppColors.divider.withOpacity(0.2), width: 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            HapticFeedback.selectionClick();
            _showActivityDetails(activity);
          },
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                // Activity Icon
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        activityConfig.color,
                        activityConfig.color.withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    activityConfig.icon,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                // Activity Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.description,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            _formatTimestamp(activity.timestamp),
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (activity.beneficiaryName != null) ...[
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 14.sp,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              activity.beneficiaryName!,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Type Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: activityConfig.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    activityConfig.label,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: activityConfig.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ActivityConfig _getActivityConfig(String type) {
    switch (type) {
      case 'beneficiary':
      case 'create':
        return ActivityConfig(
          icon: Icons.person_add,
          label: 'مستفيد',
          color: AppColors.success,
        );
      case 'visit':
        return ActivityConfig(
          icon: Icons.event_note,
          label: 'زيارة',
          color: const Color(0xFF9C27B0),
        );
      case 'sync':
        return ActivityConfig(
          icon: Icons.sync,
          label: 'مزامنة',
          color: AppColors.info,
        );
      case 'attachment':
      case 'upload':
        return ActivityConfig(
          icon: Icons.attach_file,
          label: 'مرفق',
          color: AppColors.warning,
        );
      case 'update':
        return ActivityConfig(
          icon: Icons.edit,
          label: 'تحديث',
          color: AppColors.primary,
        );
      case 'delete':
        return ActivityConfig(
          icon: Icons.delete,
          label: 'حذف',
          color: AppColors.error,
        );
      default:
        return ActivityConfig(
          icon: Icons.info,
          label: 'نشاط',
          color: AppColors.textSecondary,
        );
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return DateFormat('yyyy-MM-dd hh:mm a', 'ar').format(timestamp);
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
    );

    if (date != null) {
      setState(() => _selectedDate = date);
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _clearCache() async {
    HapticFeedback.mediumImpact();

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
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('مسح'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && mounted) {
      final cacheManager = ref.read(cacheManagerProvider);
      await cacheManager.clearActivitiesCache();

      if (mounted) {
        EnhancedSnackbar.showSuccess(
          context,
          message: 'تم مسح الذاكرة المؤقتة',
        );
      }
    }
  }

  Future<void> _showActivityDetails(Activity activity) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScaleTransitionWidget(
        duration: AppDurations.fast,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getActivityConfig(activity.type).icon,
                    color: AppColors.primary,
                    size: 28.sp,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'تفاصيل النشاط',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              _buildDetailRow('النوع', _getActivityConfig(activity.type).label),
              _buildDetailRow('الوصف', activity.description),
              _buildDetailRow(
                'التاريخ والوقت',
                DateFormat(
                  'yyyy-MM-dd hh:mm a',
                  'ar',
                ).format(activity.timestamp),
              ),
              if (activity.beneficiaryName != null) _buildDetailRow('المستفيد', activity.beneficiaryName!),
              if (activity.metadata != null && activity.metadata!.isNotEmpty) ...[
                SizedBox(height: 16.h),
                Text(
                  'معلومات إضافية:',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                ...activity.metadata!.entries.map(
                  (entry) => _buildDetailRow(entry.key, entry.value.toString()),
                ),
              ],
              SizedBox(height: 24.h),
              if (activity.beneficiaryId != null)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push(
                        '/beneficiaries/details/${activity.beneficiaryId}',
                      );
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('عرض المستفيد'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityConfig {
  final IconData icon;
  final String label;
  final Color color;

  ActivityConfig({
    required this.icon,
    required this.label,
    required this.color,
  });
}
