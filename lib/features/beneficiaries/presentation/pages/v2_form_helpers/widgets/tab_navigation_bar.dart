import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'enhanced_progress_indicator.dart';

/// 🎨 Tab Navigation Bar with Progress
///
/// Reusable tab navigation with progress indicator
class TabNavigationBar extends StatelessWidget {
  final TabController controller;
  final int currentIndex;
  final int totalTabs;

  const TabNavigationBar({
    required this.controller, required this.currentIndex, required this.totalTabs, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          TabBar(
            controller: controller,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant,
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
            labelPadding: EdgeInsets.symmetric(horizontal: 8.w),
            tabs: [
              Tab(
                icon: Icon(Icons.person_rounded, size: 18.sp),
                text: 'أساسي',
              ),
              Tab(
                icon: Icon(Icons.family_restroom_rounded, size: 18.sp),
                text: 'العائلة',
              ),
              Tab(
                icon: Icon(Icons.contact_phone_rounded, size: 18.sp),
                text: 'التواصل',
              ),
              Tab(
                icon: Icon(Icons.dashboard_customize_rounded, size: 18.sp),
                text: 'إضافي',
              ),
              Tab(
                icon: Icon(Icons.sticky_note_2_rounded, size: 18.sp),
                text: 'ملاحظات',
              ),
              Tab(
                icon: Icon(Icons.people_rounded, size: 18.sp),
                text: 'أفراد',
              ),
              Tab(
                icon: Icon(Icons.attach_file_rounded, size: 18.sp),
                text: 'مرفقات',
              ),
            ],
          ),
          // Enhanced Progress indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                // Circular Progress
                EnhancedProgressIndicator(
                  currentStep: currentIndex,
                  totalSteps: totalTabs,
                ),
                SizedBox(width: 12.w),
                // Text Progress
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'التبويب ${currentIndex + 1} من $totalTabs',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _getTabName(currentIndex),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Get tab name based on index
  String _getTabName(int index) {
    switch (index) {
      case 0:
        return 'المعلومات الأساسية';
      case 1:
        return 'معلومات العائلة';
      case 2:
        return 'معلومات التواصل';
      case 3:
        return 'معلومات إضافية';
      case 4:
        return 'الملاحظات';
      case 5:
        return 'أفراد العائلة';
      case 6:
        return 'المرفقات';
      default:
        return '';
    }
  }
}
