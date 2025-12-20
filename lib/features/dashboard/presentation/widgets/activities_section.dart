import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/activity.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/widgets/swipeable_card.dart';

/// Activity Item Widget - Single activity in the list
class ActivityItem extends StatelessWidget {
  final Activity activity;

  const ActivityItem({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return SwipeableCard(
      key: ValueKey(activity.id), // ✅ Performance optimization
      onSwipeRight: () {
        // View action
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('عرض ${activity.description}')));
      },
      onSwipeLeft: () {
        // Delete action
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('حذف ${activity.description}')));
      },
      leftActionColor: Colors.blue,
      leftActionIcon: Icons.visibility,
      leftActionLabel: 'عرض',
      rightActionColor: Colors.red,
      rightActionIcon: Icons.delete,
      rightActionLabel: 'حذف',
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getActivityColor(),
            child: Icon(_getActivityIcon(), color: Colors.white, size: 20.sp),
          ),
          title: Text(activity.description, style: TextStyle(fontSize: 14.sp)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (activity.beneficiaryName != null)
                Text(
                  activity.beneficiaryName!,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              Text(
                _formatTime(activity.timestamp),
                style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
              ),
            ],
          ),
          trailing: Icon(Icons.chevron_right, size: 20.sp),
        ),
      ),
    );
  }

  Color _getActivityColor() {
    switch (activity.type) {
      case 'create':
        return Colors.green;
      case 'update':
        return Colors.blue;
      case 'delete':
        return Colors.red;
      case 'upload':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon() {
    switch (activity.type) {
      case 'create':
        return Icons.add;
      case 'update':
        return Icons.edit;
      case 'delete':
        return Icons.delete;
      case 'upload':
        return Icons.upload;
      default:
        return Icons.info;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inDays < 1) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return intl.DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    }
  }
}

/// Recent Activities List - Paginated list of activities
class RecentActivitiesList extends ConsumerWidget {
  final List<Activity> activities;
  final bool isLoading;
  final bool hasMore;
  final VoidCallback? onLoadMore;

  const RecentActivitiesList({
    super.key,
    required this.activities,
    required this.isLoading,
    required this.hasMore,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (activities.isEmpty && !isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80.sp,
              color: Colors.blue.withOpacity(0.3),
            ),
            SizedBox(height: 16.h),
            Text(
              'ابدأ بإضافة مستفيدين لرؤية الإحصائيات',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'ستظهر هنا أنشطتك اليومية وتقاريرك',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      key: const PageStorageKey('activities_list'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == activities.length) {
          // Load more button
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Center(
              child: isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: onLoadMore,
                      child: const Text('تحميل المزيد'),
                    ),
            ),
          );
        }

        return ActivityItem(activity: activities[index]);
      },
    );
  }
}
