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

  const VisitsSection({
    super.key,
    required this.beneficiary,
    required this.beneficiaryId,
    required this.visitState,
    required this.showTimelineView,
    required this.onToggleView,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.event_outlined, color: Colors.blue, size: 22.sp),
            SizedBox(width: 10.w),
            Text(
              'سجل الزيارات',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
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
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
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

  const VisitsCard({
    super.key,
    required this.visitState,
    required this.beneficiaryId,
    required this.beneficiary,
  });

  @override
  ConsumerState<VisitsCard> createState() => _VisitsCardState();
}

class _VisitsCardState extends ConsumerState<VisitsCard> {
  bool _showAllVisits = false;

  @override
  Widget build(BuildContext context) {
    if (widget.visitState.isLoading) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (widget.visitState.errorMessage != null) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48.sp, color: Colors.red[400]),
              SizedBox(height: 12.h),
              Text(
                widget.visitState.errorMessage!,
                style: TextStyle(fontSize: 14.sp, color: Colors.red[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final visits = widget.visitState.visits;

    if (visits.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            children: [
              Icon(Icons.event_busy, size: 48.sp, color: Colors.grey[400]),
              SizedBox(height: 12.h),
              Text(
                'لا توجد زيارات مسجلة',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Column(
        children: [
          // Summary
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(13),
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Icon(Icons.event_available, color: Colors.blue, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'عدد الزيارات: ${visits.length}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Spacer(),
                if (visits.isNotEmpty)
                  Text(
                    'آخر زيارة: ${_formatDateShort(visits.first.visitDate)}',
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),

          // Visits List with pagination
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _showAllVisits
                ? visits.length
                : (visits.length > 3 ? 3 : visits.length),
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
                  _showAllVisits
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20.sp,
                ),
                label: Text(
                  _showAllVisits
                      ? 'إخفاء الزيارات'
                      : 'عرض جميع الزيارات (${visits.length})',
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
