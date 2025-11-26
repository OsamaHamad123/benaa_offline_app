import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../features/visits/domain/entities/visit_entity.dart';
import '../../design_system/app_animations.dart';

/// Reusable Visit Card Widget
class VisitCard extends StatelessWidget {
  final VisitEntity visit;
  final VoidCallback? onTap;

  const VisitCard({super.key, required this.visit, this.onTap});

  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return FadeSlideTransition(
      duration: AppDurations.fast,
      slideOffset: const Offset(0, 0.1),
      child: Card(
        margin: EdgeInsets.only(bottom: 8.h),
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: Colors.green.withOpacity(0.1),
            child: Icon(
              Icons.event_available,
              color: Colors.green,
              size: 20.sp,
            ),
          ),
          title: Text(
            visit.staffName,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4.h),
              Text(
                formatDateTime(visit.visitDate),
                style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
              ),
              if (visit.notes.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  visit.notes,
                  style: TextStyle(fontSize: 11.sp),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
          trailing: visit.isSubmitted
              ? Icon(Icons.check_circle, color: Colors.green, size: 20.sp)
              : Icon(Icons.pending, color: Colors.orange, size: 20.sp),
        ),
      ),
    );
  }
}
