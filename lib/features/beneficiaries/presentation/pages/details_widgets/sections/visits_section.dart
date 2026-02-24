import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/widgets/beneficiary/visit_card.dart';
import '../visits_timeline.dart';

/// 📅 Visits Section Widget
///
/// Displays beneficiary visits in timeline or card view
class VisitsSection extends ConsumerWidget {
  final dynamic beneficiary;
  final String beneficiaryId;
  final dynamic visitState;
  final bool showTimelineView;
  final VoidCallback onToggleView;
  final VoidCallback? onRetry;

  const VisitsSection({
    required this.beneficiary,
    required this.beneficiaryId,
    required this.visitState,
    required this.showTimelineView,
    required this.onToggleView,
    this.onRetry,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.event_outlined, color: colorScheme.primary, size: 22.sp),
            SizedBox(width: 10.w),
            Text(
              'سجل الزيارات',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(
                showTimelineView ? Icons.list : Icons.timeline,
                size: 20.sp,
              ),
              tooltip: showTimelineView ? 'عرض القائمة' : 'عرض Timeline',
              onPressed: onToggleView,
            ),
          ],
        ),
        SizedBox(height: 12.h),
        showTimelineView
            ? Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: VisitsTimeline(visits: visitState.visits),
                ),
              )
            : VisitsCard(
                visitState: visitState,
                beneficiaryId: beneficiaryId,
                beneficiary: beneficiary,
                onRetry: onRetry,
              ),
      ],
    );
  }
}

/// Visits Card Widget (List View)
class VisitsCard extends ConsumerStatefulWidget {
  final dynamic visitState;
  final String beneficiaryId;
  final dynamic beneficiary;
  final VoidCallback? onRetry;

  const VisitsCard({
    required this.visitState,
    required this.beneficiaryId,
    required this.beneficiary,
    this.onRetry,
    super.key,
  });

  @override
  ConsumerState<VisitsCard> createState() => _VisitsCardState();
}

class _VisitsCardState extends ConsumerState<VisitsCard> {
  bool _showAllVisits = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.visitState.isLoading) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
        ),
      );
    }

    if (widget.visitState.errorMessage != null) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48.sp, color: colorScheme.error),
              SizedBox(height: 12.h),
              Text(
                widget.visitState.errorMessage!,
                style: TextStyle(fontSize: 14.sp, color: colorScheme.error),
                textAlign: TextAlign.center,
              ),
              if (widget.onRetry != null) ...[
                SizedBox(height: 12.h),
                OutlinedButton.icon(
                  onPressed: widget.onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final visits = widget.visitState.visits;

    if (visits.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            children: [
              Icon(Icons.event_busy, size: 48.sp, color: colorScheme.outline),
              SizedBox(height: 12.h),
              Text(
                'لا توجد زيارات مسجلة',
                style: TextStyle(fontSize: 14.sp, color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          // Summary
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.35),
              border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
            ),
            child: Row(
              children: [
                Icon(Icons.event_available, color: colorScheme.primary, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'عدد الزيارات: ${visits.length}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const Spacer(),
                if (visits.isNotEmpty)
                  Text(
                    'آخر زيارة: ${_formatDateShort(visits.first.visitDate)}',
                    style: TextStyle(fontSize: 11.sp, color: colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),

          // Visits List with pagination
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _showAllVisits ? visits.length : (visits.length > 3 ? 3 : visits.length),
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final visit = visits[index];
              return VisitCard(visit: visit, onTap: () {});
            },
          ),

          // Show/Hide All button
          if (visits.length > 3)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showAllVisits = !_showAllVisits;
                  });
                },
                icon: Icon(
                  _showAllVisits ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 20.sp,
                ),
                label: Text(
                  _showAllVisits ? 'إخفاء الزيارات' : 'عرض جميع الزيارات (${visits.length})',
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDateShort(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }
}
