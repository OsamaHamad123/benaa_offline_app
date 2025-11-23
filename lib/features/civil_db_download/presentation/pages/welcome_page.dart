import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/responsive_utils_v2.dart';
import '../../domain/entities/civil_db_status.dart';
import '../providers/civil_db_download_notifier.dart';

/// 🎉 Welcome Page
///
/// First screen that checks if civil registry database is downloaded
class WelcomePage extends ConsumerStatefulWidget {
  const WelcomePage({super.key});

  @override
  ConsumerState<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends ConsumerState<WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();

    // Check database status
    Future.microtask(() {
      ref.read(civilDbDownloadProvider.notifier).checkStatus();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final downloadState = ref.watch(civilDbDownloadProvider);
    final rv = ResponsiveUtils.getValues(context);

    // Listen to status changes and navigate
    ref.listen(civilDbDownloadProvider, (previous, next) {
      if (next.status.status == CivilDbStatusType.ready) {
        // Database ready, navigate to dashboard
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            context.go('/dashboard');
          }
        });
      } else if (next.status.status == CivilDbStatusType.notDownloaded) {
        // Need to download, navigate to download page automatically
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            context.go('/download-civil-db');
          }
        });
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade700,
              Colors.blue.shade500,
              Colors.cyan.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Padding(
                padding: rv.padding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo/Icon
                    Container(
                      padding: EdgeInsets.all(30.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance,
                        size: 100.sp,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 40.h),

                    // App Title
                    Text(
                      'بناء',
                      style: TextStyle(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'نظام السجل المدني',
                      style: TextStyle(
                        fontSize: 20.sp,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 60.h),

                    // Status Indicator
                    _buildStatusIndicator(downloadState, rv),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(
    CivilDbDownloadState state,
    ResponsiveValues rv,
  ) {
    Widget statusWidget;

    switch (state.status.status) {
      case CivilDbStatusType.ready:
        statusWidget = Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade300, size: 50.sp),
            SizedBox(height: 10.h),
            Text(
              'جاهز للعمل',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
        break;

      case CivilDbStatusType.notDownloaded:
        statusWidget = Column(
          children: [
            SizedBox(
              width: 40.w,
              height: 40.h,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3.w,
              ),
            ),
            SizedBox(height: 15.h),
            Text(
              'جاري التحقق...',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        );
        break;

      case CivilDbStatusType.error:
        statusWidget = Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade300, size: 50.sp),
            SizedBox(height: 10.h),
            Text(
              'حدث خطأ',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
        break;

      default:
        statusWidget = SizedBox(
          width: 40.w,
          height: 40.h,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3.w,
          ),
        );
    }

    return statusWidget;
  }

  // Removed _showDownloadDialog - now navigates directly to download page
  /*
  void _showDownloadDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.download_rounded,
              color: Colors.blue.shade700,
              size: 28.sp,
            ),
            SizedBox(width: 10.w),
            Text(
              'تنزيل قاعدة البيانات',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'لاستخدام التطبيق، تحتاج إلى تنزيل قاعدة بيانات السجل المدني.',
              style: TextStyle(fontSize: 16.sp, height: 1.5),
            ),
            SizedBox(height: 15.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 20.sp,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'الحجم: تقريباً 4 GB\nيُنصح باستخدام Wi-Fi',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Exit app or go back
            },
            child: Text(
              'لاحقاً',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/download-civil-db');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'تنزيل الآن',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
  */
}
