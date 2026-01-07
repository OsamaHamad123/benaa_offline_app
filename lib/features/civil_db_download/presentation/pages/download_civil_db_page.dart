import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/responsive_utils_v2.dart';
import '../../domain/entities/civil_db_status.dart';
import '../providers/civil_db_download_notifier.dart';

/// ⬇️ Download Civil Database Page
///
/// Page for downloading civil registry database with progress tracking
class DownloadCivilDbPage extends ConsumerStatefulWidget {
  const DownloadCivilDbPage({super.key});

  @override
  ConsumerState<DownloadCivilDbPage> createState() => _DownloadCivilDbPageState();
}

class _DownloadCivilDbPageState extends ConsumerState<DownloadCivilDbPage> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // 🔧 Development: Will copy from Assets (see CivilDbManager.isDevelopmentMode)
  // 🌐 Production: Downloads from API server
  static String get _downloadUrl {
    // In production, this will use the API endpoint from ApiConfig
    return 'https://palestine.benaadev.org/api/mobile/civil-db/download';
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Auto-start download in Development Mode
    Future.microtask(() {
      final state = ref.read(civilDbDownloadProvider);
      if (state.status.status == CivilDbStatusType.notDownloaded && !state.isDownloading) {
        _startDownload();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final downloadState = ref.watch(civilDbDownloadProvider);
    final rv = ResponsiveUtils.getValues(context);

    // Listen to status changes
    ref.listen(civilDbDownloadProvider, (previous, next) {
      if (next.status.status == CivilDbStatusType.ready) {
        // Download complete, navigate to dashboard
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.go('/dashboard');
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
          child: Padding(
            padding: rv.padding,
            child: Column(
              children: [
                // Header
                _buildHeader(rv),
                const Spacer(),

                // Main Content
                _buildMainContent(downloadState, rv),
                const Spacer(),

                // Action Buttons
                _buildActionButtons(downloadState, rv),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ResponsiveValues rv) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildMainContent(CivilDbDownloadState state, ResponsiveValues rv) {
    return Container(
      padding: EdgeInsets.all(rv.spacing * 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getStatusIcon(state.status.status),
                size: 80.sp,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 30.h),

          // Title
          Text(
            _getStatusTitle(state.status.status),
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10.h),

          // Description
          Text(
            _getStatusDescription(state.status.status),
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30.h),

          // Progress Section
          if (state.isDownloading) _buildProgressSection(state, rv),

          // Error Message
          if (state.errorMessage != null)
            Container(
              padding: EdgeInsets.all(15.w),
              decoration: BoxDecoration(
                color: Colors.red.shade400.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 24.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: TextStyle(fontSize: 14.sp, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

          // Success Info
          if (state.status.status == CivilDbStatusType.ready)
            Container(
              padding: EdgeInsets.all(15.w),
              decoration: BoxDecoration(
                color: Colors.green.shade400.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 24.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'تم التنزيل بنجاح! جاري التوجيه...',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(
    CivilDbDownloadState state,
    ResponsiveValues rv,
  ) {
    final progress = state.status.downloadProgress ?? 0.0;
    final percentage = (progress * 100).toStringAsFixed(0);

    return Column(
      children: [
        // Progress Bar
        Stack(
          children: [
            Container(
              height: 12.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 12.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade300, Colors.green.shade500],
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.shade300.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15.h),

        // Percentage & Size
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (state.status.fileSize != null)
              Text(
                _formatBytes(state.status.fileSize!),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(CivilDbDownloadState state, ResponsiveValues rv) {
    if (state.isDownloading) {
      return ElevatedButton.icon(
        onPressed: _cancelDownload,
        icon: Icon(Icons.close, size: 20.sp),
        label: Text(
          'إلغاء التنزيل',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade400,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      );
    }

    if (state.status.status == CivilDbStatusType.ready) {
      return ElevatedButton.icon(
        onPressed: () => context.go('/dashboard'),
        icon: Icon(Icons.arrow_forward, size: 20.sp),
        label: Text(
          'المتابعة',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade400,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: _startDownload,
      icon: Icon(Icons.download_rounded, size: 20.sp),
      label: Text(
        'بدء التنزيل',
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade700,
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 18.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        elevation: 8,
      ),
    );
  }

  IconData _getStatusIcon(CivilDbStatusType status) {
    switch (status) {
      case CivilDbStatusType.downloading:
        return Icons.downloading;
      case CivilDbStatusType.ready:
        return Icons.check_circle;
      case CivilDbStatusType.error:
        return Icons.error_outline;
      default:
        return Icons.cloud_download;
    }
  }

  String _getStatusTitle(CivilDbStatusType status) {
    switch (status) {
      case CivilDbStatusType.downloading:
        return 'جاري التنزيل...';
      case CivilDbStatusType.ready:
        return 'اكتمل التنزيل!';
      case CivilDbStatusType.error:
        return 'فشل التنزيل';
      default:
        return 'تنزيل قاعدة البيانات';
    }
  }

  String _getStatusDescription(CivilDbStatusType status) {
    switch (status) {
      case CivilDbStatusType.downloading:
        return 'الرجاء الانتظار حتى اكتمال التنزيل\nلا تغلق التطبيق';
      case CivilDbStatusType.ready:
        return 'تم تنزيل قاعدة البيانات بنجاح\nيمكنك الآن استخدام التطبيق';
      case CivilDbStatusType.error:
        return 'حدث خطأ أثناء التنزيل\nتحقق من اتصال الإنترنت وحاول مرة أخرى';
      default:
        return 'قاعدة بيانات السجل المدني (تقريباً 4 GB)\nيُنصح باستخدام Wi-Fi';
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  void _startDownload() {
    ref.read(civilDbDownloadProvider.notifier).startDownload(_downloadUrl);
  }

  void _cancelDownload() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'إلغاء التنزيل؟',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل أنت متأكد من إلغاء تنزيل قاعدة البيانات؟',
          style: TextStyle(fontSize: 16.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('لا', style: TextStyle(fontSize: 16.sp)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(civilDbDownloadProvider.notifier).cancelDownload();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('نعم، إلغاء', style: TextStyle(fontSize: 16.sp)),
          ),
        ],
      ),
    );
  }
}
