import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/app_animations.dart';
import '../../../../core/widgets/enhanced_refresh_indicator.dart';
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

class _VisitsListPageM3State extends ConsumerState<VisitsListPageM3> {
  String _selectedFilter = 'all'; // all, pending, synced
  DateTime? _selectedDate; // null = بدون فلتر تاريخ

  @override
  void initState() {
    super.initState();
    _loadVisits();
  }

  Future<void> _loadVisits() async {
    if (widget.beneficiaryId != null) {
      await ref.read(visitNotifierProvider.notifier).loadBeneficiaryVisits(widget.beneficiaryId!);
    }
  }

  List<VisitEntity> get _filteredVisits {
    final state = ref.watch(visitNotifierProvider);
    return state.visits.where((visit) {
      // فلتر المزامنة
      if (_selectedFilter == 'pending' && visit.syncState != 'pending') {
        return false;
      }
      if (_selectedFilter == 'synced' && visit.syncState != 'synced') {
        return false;
      }
      // فلتر التاريخ — مقارنة السنة/الشهر/اليوم فقط
      if (_selectedDate != null) {
        final vd = visit.visitDate;
        if (vd.year != _selectedDate!.year || vd.month != _selectedDate!.month || vd.day != _selectedDate!.day) {
          return false;
        }
      }
      return true;
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          // Calendar Date Picker
          IconButton(
            icon: Badge(
              isLabelVisible: _selectedDate != null,
              smallSize: 8,
              child: const Icon(Icons.calendar_month, size: 22),
            ),
            tooltip: 'تصفية حسب التاريخ',
            onPressed: _pickDate,
          ),
          // Merged options menu
          PopupMenuButton<String>(
            icon: Badge(
              isLabelVisible: _selectedFilter != 'all',
              label: const Text('1'),
              child: const Icon(Icons.more_vert, size: 22),
            ),
            onSelected: (value) async {
              if (value == 'export') {
                await _exportVisits();
              } else if (value == 'refresh') {
                await _loadVisits();
                if (mounted) {
                  EnhancedSnackbar.showSuccess(context, message: 'تم تحديث البيانات');
                }
              } else {
                setState(() => _selectedFilter = value);
                HapticPatterns.selection();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuDivider(),
              CheckedPopupMenuItem(
                value: 'all',
                checked: _selectedFilter == 'all',
                child: const Text('الكل'),
              ),
              CheckedPopupMenuItem(
                value: 'pending',
                checked: _selectedFilter == 'pending',
                child: const Text('قيد المزامنة'),
              ),
              CheckedPopupMenuItem(
                value: 'synced',
                checked: _selectedFilter == 'synced',
                child: const Text('مزامنة'),
              ),
              const PopupMenuDivider(),
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
      ),
      body: Column(
        children: [
          _buildFilterBar(visits.length),
          if (_selectedDate != null) _buildDateFilterChip(),
          Expanded(
            child: state.isLoading
                ? _buildLoadingSkeleton()
                : visits.isEmpty
                    ? _buildEmptyState()
                    : _buildTimelineView(visits),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticPatterns.submit();
          _navigateToRecordVisit();
        },
        icon: const Icon(Icons.add),
        label: const Text('تسجيل زيارة'),
        elevation: 4,
      ),
    );
  }

  /// يفتح DatePicker لاختيار تاريخ للتصفية.
  Future<void> _pickDate() async {
    HapticPatterns.selection();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
      helpText: 'اختر تاريخاً لتصفية الزيارات',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  void _clearDateFilter() {
    setState(() => _selectedDate = null);
    HapticPatterns.selection();
  }

  /// ينقل إلى صفحة تسجيل الزيارة.
  /// إذا كانت الصفحة مفتوحة في سياق مستفيد معين، ينتقل لاحقاً.
  /// إذا لم يكن هناك مستفيد، يوجّه المستخدم لاختيار مستفيد أولاً.
  void _navigateToRecordVisit() {
    if (widget.beneficiaryId != null) {
      // Navigate to beneficiary details where user can record a visit
      context.push('/beneficiaries/${widget.beneficiaryId}');
    } else {
      // No beneficiary context — direct user to beneficiaries list to select one
      context.push('/beneficiaries');
    }
  }

  Widget _buildFilterBar(int totalCount) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              label: 'الكل ($totalCount)',
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
        child: const SkeletonListItem(),
      ),
    );
  }

  Widget _buildDateFilterChip() {
    final label = DateFormat('yyyy/MM/dd', 'ar').format(_selectedDate!);
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 8.h),
      child: Row(
        children: [
          Icon(Icons.event, size: 16.sp, color: AppColors.primary),
          SizedBox(width: 6.w),
          Text(
            'التاريخ: $label',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 8.w),
          InkWell(
            onTap: _clearDateFilter,
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.all(4.r),
              child: Icon(Icons.close, size: 16.sp, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    // حالة فلتر تاريخ بدون نتائج
    if (_selectedDate != null) {
      final label = DateFormat('yyyy/MM/dd', 'ar').format(_selectedDate!);
      return EmptyStateWidget(
        icon: Icons.event_busy_outlined,
        title: 'لا توجد زيارات في $label',
        message: 'لم يتم تسجيل أي زيارة في هذا اليوم',
        action: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _clearDateFilter,
              icon: const Icon(Icons.clear),
              label: const Text('مسح التاريخ'),
            ),
            SizedBox(width: 8.w),
            ElevatedButton.icon(
              onPressed: _navigateToRecordVisit,
              icon: const Icon(Icons.add),
              label: const Text('تسجيل زيارة'),
            ),
          ],
        ),
      );
    }
    // حالة عدم وجود زيارات عامة
    return EmptyStateWidget(
      icon: Icons.event_note_outlined,
      title: 'لا توجد زيارات',
      message: _selectedFilter == 'all'
          ? 'ابدأ بتسجيل زيارة جديدة'
          : 'لا توجد زيارات ${_selectedFilter == 'pending' ? 'قيد المزامنة' : 'مكتملة'}',
      action: ElevatedButton.icon(
        onPressed: _navigateToRecordVisit,
        icon: const Icon(Icons.add),
        label: const Text('تسجيل أول زيارة'),
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

    return EnhancedRefreshIndicator(
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
          side: BorderSide(color: AppColors.divider.withOpacity(0.2)),
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
    final match = RegExp(r'^\s*نوع\s+الزيارة\s*:\s*(.+?)\s*$', multiLine: true).firstMatch(visit.notes);
    if (match != null) {
      final extracted = match.group(1)?.trim();
      if (extracted != null && extracted.isNotEmpty) {
        return extracted;
      }
    }

    return 'غير محدد';
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
