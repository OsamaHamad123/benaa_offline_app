import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:intl/intl.dart';
import '../../../../visits/domain/entities/visit_entity.dart';

/// Timeline View for Visits
class VisitsTimeline extends StatelessWidget {
  final List<VisitEntity> visits;
  final VoidCallback? onVisitTap;

  const VisitsTimeline({super.key, required this.visits, this.onVisitTap});

  @override
  Widget build(BuildContext context) {
    if (visits.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.r),
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

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visits.length,
      itemBuilder: (context, index) {
        final visit = visits[index];
        final isFirst = index == 0;
        final isLast = index == visits.length - 1;

        return TimelineTile(
          alignment: TimelineAlign.manual,
          lineXY: 0.2,
          isFirst: isFirst,
          isLast: isLast,
          indicatorStyle: IndicatorStyle(
            width: 32.w,
            height: 32.h,
            indicator: Container(
              decoration: BoxDecoration(
                color: isFirst ? Colors.blue : Colors.blue[100],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue, width: 2.w),
              ),
              child: Icon(
                isFirst ? Icons.check_circle : Icons.event,
                color: isFirst ? Colors.white : Colors.blue,
                size: 16.sp,
              ),
            ),
            drawGap: true,
          ),
          beforeLineStyle: LineStyle(color: Colors.blue[200]!, thickness: 2.w),
          endChild: _VisitTimelineCard(
            visit: visit,
            isLatest: isFirst,
            onTap: onVisitTap,
          ),
        );
      },
    );
  }
}

class _VisitTimelineCard extends StatelessWidget {
  final VisitEntity visit;
  final bool isLatest;
  final VoidCallback? onTap;

  const _VisitTimelineCard({
    required this.visit,
    required this.isLatest,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(left: 16.w, bottom: 16.h),
        child: Card(
          elevation: isLatest ? 3 : 1,
          color: isLatest ? Colors.blue[50] : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(
              color: isLatest ? Colors.blue : Colors.grey[300]!,
              width: isLatest ? 2.w : 1.w,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    if (isLatest)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'أحدث زيارة',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const Spacer(),
                    Icon(
                      Icons.access_time,
                      size: 14.sp,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _formatDate(visit.visitDate),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                // Staff Name
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 16.sp, color: Colors.blue),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        visit.staffName,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                // Notes
                if (visit.notes.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.note_outlined,
                          size: 14.sp,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            visit.notes,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[700],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'قبل ${difference.inDays} أيام';
    } else {
      return DateFormat('yyyy-MM-dd').format(date);
    }
  }
}
