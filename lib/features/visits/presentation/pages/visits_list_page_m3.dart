import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/app_animations.dart';
import '../../../../core/error_handling/error_handler.dart';
import '../../../../core/ux/ux_widgets.dart';
import '../../../../core/utils/haptic_patterns.dart';
import '../../../../core/services/export/export_models.dart';
import '../../../../core/services/export/export_providers.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/entities/visit_entity.dart';
import '../providers/visit_providers.dart';

/// 📋 Material 3 Visits List Page
/// تصميم حديث مع Timeline & Calendar Integration
class VisitsListPageM3 extends ConsumerStatefulWidget {
  final String? beneficiaryId;

  const VisitsListPageM3({super.key, this.beneficiaryId});

  @override
  ConsumerState<VisitsListPageM3> createState() => _VisitsListPageM3State();
}

class _VisitsListPageM3State extends ConsumerState<VisitsListPageM3> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all'; // all, pending, synced
  bool _showCalendar = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadVisits();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadVisits() async {
    if (widget.beneficiaryId != null) {
      await ref.read(visitNotifierProvider.notifier).loadBeneficiaryVisits(widget.beneficiaryId!);
    }
  }

  List<VisitEntity> get _filteredVisits {
    final state = ref.watch(visitNotifierProvider);
    return state.visits.where((visit) {
      switch (_selectedFilter) {
        case 'pending':
          return visit.syncState == 'pending';
        case 'synced':
          return visit.syncState == 'synced';
        default:
          return true;
      }
    }).toList()
      ..sort((a, b) => b.visitDate.compareTo(a.visitDate));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(visitNotifierProvider);
    final visits = _filteredVisits;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.beneficiaryId != null ? 'زيارات المستفيد' : 'جميع الزيارات',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Calendar Toggle
          IconButton(
            icon: Icon(_showCalendar ? Icons.view_list : Icons.calendar_month),
            tooltip: _showCalendar ? 'عرض القائمة' : 'عرض التقويم',
            onPressed: () {
              setState(() => _showCalendar = !_showCalendar);
              HapticPatterns.selection();
            },
          ),
          // Filter Menu
          PopupMenuButton<String>(
            icon: Badge(
              isLabelVisible: _selectedFilter != 'all',
              label: const Text('1'),
              child: const Icon(Icons.filter_list),
            ),
            onSelected: (value) {
              setState(() => _selectedFilter = value);
              HapticPatterns.selection();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('🔹 الكل')),
              const PopupMenuItem(
                value: 'pending',
                child: Text('⏳ قيد المزامنة'),
              ),
              const PopupMenuItem(value: 'synced', child: Text('✅ مزامنة')),
            ],
          ),
          // More Options
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'export':
                  await _exportVisits();
                  break;
                case 'refresh':
                  await _loadVisits();
                  if (mounted) {
                    EnhancedSnackbar.showSuccess(
                      context,
                      message: 'تم تحديث البيانات',
                    );
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 12),
                    Text('تصدير Excel'),
                  ],
                ),
              ),
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
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'الكل (${visits.length})',
                  value: 'all',
                  icon: Icons.list,
                ),
                SizedBox(width: 8.w),
                _buildFilterChip(
                  label: 'قيد المزامنة',
                  value: 'pending',
                  icon: Icons.sync,
                ),
                SizedBox(width: 8.w),
                _buildFilterChip(
                  label: 'مكتمل',
                  value: 'synced',
                  icon: Icons.check_circle,
                ),
              ],
            ),
          ),
        ),
      ),
      body: state.isLoading
          ? _buildLoadingSkeleton()
          : visits.isEmpty
              ? _buildEmptyState()
              : _showCalendar
                  ? _buildCalendarView(visits)
                  : _buildTimelineView(visits),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticPatterns.submit();
          // Navigate to record visit page
          context.push('/visits/record');
        },
        icon: const Icon(Icons.add),
        label: const Text('تسجيل زيارة'),
        elevation: 4,
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _selectedFilter == value;

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp),
          SizedBox(width: 6.w),
          Text(label),
        ],
      ),
      onSelected: (_) {
        setState(() => _selectedFilter = value);
        HapticPatterns.selection();
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
      itemCount: 6,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: SkeletonListItem(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      icon: Icons.event_note_outlined,
      title: 'لا توجد زيارات',
      message: _selectedFilter == 'all'
          ? 'ابدأ بتسجيل زيارة جديدة'
          : 'لا توجد زيارات ${_selectedFilter == 'pending' ? 'قيد المزامنة' : 'مكتملة'}',
      action: ElevatedButton.icon(
        onPressed: () => context.push('/visits/record'),
        icon: const Icon(Icons.add),
        label: const Text('تسجيل زيارة'),
      ),
    );
  }

  Widget _buildTimelineView(List<VisitEntity> visits) {
    // Group by date
    final groupedByDate = <DateTime, List<VisitEntity>>{};
    for (final visit in visits) {
      final dateKey = DateTime(
        visit.visitDate.year,
        visit.visitDate.month,
        visit.visitDate.day,
      );
      groupedByDate.putIfAbsent(dateKey, () => []).add(visit);
    }

    final dates = groupedByDate.keys.toList()..sort((a, b) => b.compareTo(a));

    return RefreshIndicator(
      onRefresh: _loadVisits,
      child: ListView.builder(
        padding: EdgeInsets.all(16.r),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final dayVisits = groupedByDate[date]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(date, dayVisits.length),
              SizedBox(height: 12.h),
              ...dayVisits.map((visit) => _buildVisitCard(visit)),
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

  Widget _buildVisitCard(VisitEntity visit) {
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
            HapticPatterns.selection();
            _showVisitDetails(visit);
          },
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                // Timeline Dot
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        visit.syncState == 'synced' ? AppColors.success : AppColors.warning,
                        visit.syncState == 'synced'
                            ? AppColors.success.withOpacity(0.6)
                            : AppColors.warning.withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    visit.syncState == 'synced' ? Icons.check_circle : Icons.sync,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                // Visit Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visit.staffName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
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
                            DateFormat('hh:mm a', 'ar').format(visit.visitDate),
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (visit.notes.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        Text(
                          visit.notes,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Sync Status Badge
                _buildSyncBadge(visit.syncState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSyncBadge(String syncState) {
    final isSynced = syncState == 'synced';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isSynced ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSynced ? Icons.cloud_done : Icons.cloud_upload,
            size: 14.sp,
            color: isSynced ? AppColors.success : AppColors.warning,
          ),
          SizedBox(width: 4.w),
          Text(
            isSynced ? 'مزامنة' : 'محلي',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: isSynced ? AppColors.success : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView(List<VisitEntity> visits) {
    return Center(child: Text('Calendar View - Coming Soon'));
  }

  Future<void> _showVisitDetails(VisitEntity visit) async {
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
                  Icon(Icons.event_note, color: AppColors.primary, size: 28.sp),
                  SizedBox(width: 12.w),
                  Text(
                    'تفاصيل الزيارة',
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
              _buildDetailRow(
                'التاريخ',
                DateFormat('yyyy-MM-dd', 'ar').format(visit.visitDate),
              ),
              _buildDetailRow(
                'الوقت',
                DateFormat('hh:mm a', 'ar').format(visit.visitDate),
              ),
              _buildDetailRow('الموظف', visit.staffName),
              _buildDetailRow(
                'الحالة',
                visit.syncState == 'synced' ? 'مزامنة ✅' : 'قيد المزامنة ⏳',
              ),
              if (visit.notes.isNotEmpty) _buildDetailRow('الملاحظات', visit.notes),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Edit visit
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('تعديل'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // View full details or navigate to beneficiary
                      },
                      icon: const Icon(Icons.visibility),
                      label: const Text('عرض التفاصيل'),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
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

  Future<void> _exportVisits() async {
    try {
      HapticPatterns.submit();

      final visits = _filteredVisits;
      if (visits.isEmpty) {
        if (mounted) {
          EnhancedSnackbar.showWarning(
            context,
            message: 'لا توجد زيارات للتصدير',
          );
        }
        return;
      }

      // إنشاء بيانات التصدير
      final excelService = ref.read(excelExportServiceProvider);
      final exportData = VisitsExportData(
        visits: visits
            .map(
              (v) => VisitExportRow(
                beneficiaryName: v.staffName, // Will be replaced with actual beneficiary name if available
                visitDate: DateFormat('yyyy-MM-dd').format(v.visitDate),
                visitType: _getVisitTypeArabic(v),
                staffName: v.staffName,
                notes: v.notes,
              ),
            )
            .toList(),
        statistics: [
          ExportStatistic(
            label: 'إجمالي الزيارات',
            value: visits.length.toString(),
          ),
          ExportStatistic(
            label: 'قيد المزامنة',
            value: visits.where((v) => v.syncState == 'pending').length.toString(),
          ),
          ExportStatistic(
            label: 'مزامنة',
            value: visits.where((v) => v.syncState == 'synced').length.toString(),
          ),
        ],
        subtitle: _selectedFilter != 'all' ? 'تمت التصفية: ${_getFilterName(_selectedFilter)}' : null,
      );

      final result = await excelService.exportToExcel(exportData);

      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تصدير الزيارات بنجاح: ${result.fileName}'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'فتح',
                textColor: Colors.white,
                onPressed: () => excelService.openFile(result.filePath!),
              ),
            ),
          );
        } else {
          EnhancedSnackbar.showError(
            context,
            message: 'فشل التصدير: ${result.errorMessage}',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        EnhancedSnackbar.showError(
          context,
          message: 'خطأ في التصدير: ${e.toString()}',
        );
      }
    }
  }

  String _getVisitTypeArabic(VisitEntity visit) {
    // TODO: Map visit type to Arabic if needed
    return visit.staffName; // Placeholder
  }

  String _getFilterName(String filter) {
    switch (filter) {
      case 'pending':
        return 'قيد المزامنة';
      case 'synced':
        return 'مزامنة';
      default:
        return 'الكل';
    }
  }
}
