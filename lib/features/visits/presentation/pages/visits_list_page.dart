import 'package:benaa_offline_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/app_animations.dart';
import '../../../../core/error_handling/error_handler.dart';
import '../../../../core/utils/haptic_patterns.dart';
import '../../../../core/ux/ux_widgets.dart';
import '../../domain/entities/visit_entity.dart';
import '../providers/visit_providers.dart';

/// 📋 Visits List Page - Modern Timeline & Calendar View
class VisitsListPage extends ConsumerStatefulWidget {
  final String? beneficiaryId;

  const VisitsListPage({super.key, this.beneficiaryId});

  @override
  ConsumerState<VisitsListPage> createState() => _VisitsListPageState();
}

class _VisitsListPageState extends ConsumerState<VisitsListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedMonth = DateTime.now();
  String _selectedFilter = 'all'; // all, pending, submitted
  bool _isLoading = true;
  List<VisitEntity> _visits = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadVisits();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadVisits() async {
    setState(() => _isLoading = true);
    try {
      // Load visits from provider
      if (widget.beneficiaryId != null) {
        await ref
            .read(visitNotifierProvider.notifier)
            .loadBeneficiaryVisits(widget.beneficiaryId!);
      }

      final state = ref.read(visitNotifierProvider);

      setState(() {
        _visits = state.visits.where((visit) {
          if (_selectedFilter == 'all') return true;
          if (_selectedFilter == 'pending') return visit.syncState == 'pending';
          if (_selectedFilter == 'synced') return visit.syncState == 'synced';
          return true;
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        GlobalErrorHandler.handleError(
          context,
          AppError(
            type: ErrorType.database,
            message: 'فشل تحميل الزيارات',
            originalError: e,
          ),
          onRetry: _loadVisits,
        );
      }
    }
  }

  Future<void> _exportVisits() async {
    HapticPatterns.selection();

    await showDialog(
      context: context,
      builder: (context) => ScaleTransitionWidget(
        duration: AppDurations.fast,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Icon(Icons.download, color: AppColors.primary),
              SizedBox(width: 12.w),
              const Text('تصدير الزيارات'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildExportOption(
                icon: Icons.picture_as_pdf,
                title: 'PDF',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoon('PDF Export');
                },
              ),
              SizedBox(height: 12.h),
              _buildExportOption(
                icon: Icons.table_chart,
                title: 'Excel',
                color: Colors.green,
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoon('Excel Export');
                },
              ),
              SizedBox(height: 12.h),
              _buildExportOption(
                icon: Icons.share,
                title: 'مشاركة',
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoon('Share');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12.r),
          color: color.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16.sp, color: color),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    EnhancedSnackbar.showInfo(context, message: 'قريباً: $feature');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل الزيارات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'فلترة',
            onPressed: _showFilters,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'تصدير',
            onPressed: _exportVisits,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.timeline), text: 'الجدول الزمني'),
            Tab(icon: Icon(Icons.calendar_month), text: 'التقويم'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildTimelineView(), _buildCalendarView()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/visits/add');
        },
        icon: const Icon(Icons.add),
        label: const Text('زيارة جديدة'),
      ),
    );
  }

  Widget _buildTimelineView() {
    if (_isLoading) {
      return ListView.builder(
        padding: EdgeInsets.all(16.r),
        itemCount: 5,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: SkeletonListItem(),
        ),
      );
    }

    if (_visits.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.event_busy,
        title: 'لا توجد زيارات',
        message: 'لم يتم تسجيل أي زيارات بعد',
        action: ElevatedButton.icon(
          onPressed: () => context.push('/visits/add'),
          icon: const Icon(Icons.add),
          label: const Text('تسجيل زيارة'),
        ),
      );
    }

    return PullToRefreshWrapper(
      onRefresh: _loadVisits,
      child: ListView.builder(
        padding: EdgeInsets.all(16.r),
        itemCount: _visits.length,
        itemBuilder: (context, index) {
          final visit = _visits[index];
          return FadeSlideTransition(
            duration: AppDurations.fast,
            child: _buildVisitTimelineCard(visit, index),
          );
        },
      ),
    );
  }

  Widget _buildVisitTimelineCard(VisitEntity visit, int index) {
    final statusColor = _getStatusColor(visit.syncState);

    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Row(
        children: [
          // Timeline line
          SizedBox(
            width: 60.w,
            child: Column(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: statusColor, width: 2),
                  ),
                  child: Icon(
                    _getStatusIcon(visit.syncState),
                    color: statusColor,
                    size: 20.sp,
                  ),
                ),
                if (index < _visits.length - 1)
                  Container(width: 2, height: 60.h, color: Colors.grey[300]),
              ],
            ),
          ),

          // Card
          Expanded(
            child: ScaleTransitionWidget(
              duration: AppDurations.fast,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  side: BorderSide(color: statusColor.withOpacity(0.3)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              DateFormat(
                                'dd/MM/yyyy - HH:mm',
                                'ar',
                              ).format(visit.visitDate),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          _buildStatusBadge(visit.syncState),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Icon(Icons.person, size: 16.sp, color: Colors.grey),
                          SizedBox(width: 8.w),
                          Text(
                            visit.staffName,
                            style: TextStyle(fontSize: 13.sp),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        visit.notes,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              _showVisitDetails(visit);
                            },
                            icon: Icon(Icons.visibility, size: 16.sp),
                            label: const Text('عرض'),
                          ),
                          if (visit.syncState == 'pending')
                            TextButton.icon(
                              onPressed: () {
                                _editVisit(visit);
                              },
                              icon: Icon(Icons.edit, size: 16.sp),
                              label: const Text('تعديل'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    return Column(
      children: [
        // Month Selector
        FadeSlideTransition(
          duration: AppDurations.fast,
          child: Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime(
                        _selectedMonth.year,
                        _selectedMonth.month - 1,
                      );
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    DateFormat('MMMM yyyy', 'ar').format(_selectedMonth),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime(
                        _selectedMonth.year,
                        _selectedMonth.month + 1,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        ),

        Expanded(
          child: Center(
            child: ScaleTransitionWidget(
              duration: AppDurations.normal,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_month,
                    size: 100.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'عرض التقويم',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'قريباً: عرض الزيارات في التقويم الشهري',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    final text = _getStatusText(status);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'synced':
        return Colors.green;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد المزامنة';
      case 'synced':
        return 'تم المزامنة';
      case 'error':
        return 'خطأ';
      default:
        return 'غير معروف';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.sync;
      case 'synced':
        return Icons.check_circle;
      case 'error':
        return Icons.error;
      default:
        return Icons.help;
    }
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
                    'فلترة الزيارات',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              _buildFilterOption('all', 'الكل', Icons.list),
              _buildFilterOption('pending', 'قيد المزامنة', Icons.sync),
              _buildFilterOption('synced', 'تم المزامنة', Icons.check_circle),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _loadVisits();
                      },
                      child: const Text('تطبيق'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOption(String value, String label, IconData icon) {
    final isSelected = _selectedFilter == value;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = value;
          });
        },
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

  void _showVisitDetails(VisitEntity visit) {
    showDialog(
      context: context,
      builder: (context) => ScaleTransitionWidget(
        duration: AppDurations.fast,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Icon(Icons.event_note, color: AppColors.primary),
              SizedBox(width: 12.w),
              const Text('تفاصيل الزيارة'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                'التاريخ',
                DateFormat('dd/MM/yyyy - HH:mm', 'ar').format(visit.visitDate),
                Icons.calendar_today,
              ),
              SizedBox(height: 16.h),
              _buildDetailRow('الموظف', visit.staffName, Icons.person),
              SizedBox(height: 16.h),
              _buildDetailRow(
                'الحالة',
                _getStatusText(visit.syncState),
                _getStatusIcon(visit.syncState),
              ),
              SizedBox(height: 16.h),
              Text(
                'الملاحظات:',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(visit.notes, style: TextStyle(fontSize: 13.sp)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: AppColors.primary),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  void _editVisit(VisitEntity visit) {
    EnhancedSnackbar.showInfo(context, message: 'قريباً: تعديل الزيارة');
  }
}
