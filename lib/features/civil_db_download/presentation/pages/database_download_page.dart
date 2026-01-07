import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/download_progress.dart';
import '../providers/database_download_provider.dart';
import 'config/download_config.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// 📥 Database Download Page - First Time Setup
class DatabaseDownloadPage extends ConsumerStatefulWidget {
  const DatabaseDownloadPage({super.key});

  @override
  ConsumerState<DatabaseDownloadPage> createState() => _DatabaseDownloadPageState();
}

class _DatabaseDownloadPageState extends ConsumerState<DatabaseDownloadPage> {
  // Download URL from config
  static const String _downloadUrl = DownloadConfig.downloadUrl;

  @override
  void initState() {
    super.initState();
    _checkAndStartDownload();
  }

  Future<void> _checkAndStartDownload() async {
    // Wait a bit for UI to settle
    await Future.delayed(const Duration(milliseconds: 500));

    final state = ref.read(databaseDownloadProvider);

    if (!state.isAvailable && state.progress.status == DownloadStatus.idle) {
      // Auto-start download
      ref.read(databaseDownloadProvider.notifier).downloadDatabase(_downloadUrl);
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    // عرض تأكيد
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج؟\nسيتم إيقاف التنزيل إذا كان جارياً.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // إيقاف التنزيل إذا كان جارياً
      ref.read(databaseDownloadProvider.notifier).cancelDownload();

      // تسجيل الخروج
      await ref.read(authNotifierProvider.notifier).logout();

      // العودة لصفحة تسجيل الدخول
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(databaseDownloadProvider);
    final progress = state.progress;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // 🚪 زر تسجيل الخروج
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIcon(progress.status),
                  SizedBox(height: 32.h),
                  _buildTitle(progress.status),
                  SizedBox(height: 16.h),
                  _buildDescription(progress.status),
                  SizedBox(height: 48.h),
                  if (progress.isDownloading || progress.status == DownloadStatus.extracting)
                    _buildProgressIndicator(progress),
                  if (progress.status == DownloadStatus.checking) _buildCheckingIndicator(),
                  if (progress.hasError) _buildErrorMessage(progress),
                  if (progress.isComplete) _buildCompleteButton(),
                  if (progress.isDownloading) _buildCancelButton(),
                  if (progress.hasError) _buildRetryButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(DownloadStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case DownloadStatus.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case DownloadStatus.failed:
        icon = Icons.error;
        color = Colors.red;
        break;
      case DownloadStatus.downloading:
      case DownloadStatus.extracting:
      case DownloadStatus.checking:
        icon = Icons.cloud_download;
        color = Theme.of(context).colorScheme.primary;
        break;
      default:
        icon = Icons.cloud_download;
        color = Colors.grey;
    }

    return Icon(icon, size: 120.sp, color: color);
  }

  Widget _buildTitle(DownloadStatus status) {
    String title;

    switch (status) {
      case DownloadStatus.checking:
        title = 'جاري التحقق من البيانات...';
        break;
      case DownloadStatus.downloading:
        title = 'جاري تحميل بيانات السجل المدني';
        break;
      case DownloadStatus.extracting:
        title = 'جاري استخراج البيانات...';
        break;
      case DownloadStatus.verifying:
        title = 'جاري التحقق من سلامة البيانات...';
        break;
      case DownloadStatus.completed:
        title = 'تم التحميل بنجاح! ✓';
        break;
      case DownloadStatus.failed:
        title = 'فشل التحميل';
        break;
      default:
        title = 'مرحباً بك في بناء';
    }

    return Text(
      title,
      style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(DownloadStatus status) {
    String description;

    switch (status) {
      case DownloadStatus.downloading:
        description = 'يتم الآن تحميل قاعدة بيانات السجل المدني (ملف مضغوط)\nالرجاء الانتظار...';
        break;
      case DownloadStatus.extracting:
        description =
            'يتم الآن فك ضغط الملف واستخراج قاعدة البيانات\nهذا قد يستغرق بضع دقائق... الرجاء عدم إغلاق التطبيق';
        break;
      case DownloadStatus.verifying:
        description = 'يتم الآن التحقق من سلامة قاعدة البيانات\nتقريباً انتهينا...';
        break;
      case DownloadStatus.completed:
        description = 'تم تحميل واستخراج جميع البيانات بنجاح ✓\nيمكنك الآن البدء باستخدام التطبيق';
        break;
      case DownloadStatus.failed:
        description = 'حدث خطأ أثناء التحميل أو الاستخراج\nالرجاء التحقق من الاتصال بالإنترنت والمحاولة مرة أخرى';
        break;
      default:
        description =
            'لاستخدام التطبيق، يجب تحميل قاعدة بيانات السجل المدني\nالحجم المتوقع: ~${DownloadConfig.expectedSizeMB} MB (مضغوط ~150 MB)';
    }

    return Text(
      description,
      style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildProgressIndicator(DownloadProgress progress) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: LinearProgressIndicator(
                  value: progress.percentage / 100,
                  minHeight: 12.h,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    progress.displayPercentage,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    '${progress.downloadedSize} / ${progress.totalSize}',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                ],
              ),

              if (progress.downloadSpeed != null) ...[
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'السرعة:',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      progress.speedMBps,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'يُرجى عدم إغلاق التطبيق حتى انتهاء التحميل',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.orange,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCheckingIndicator() {
    return Column(
      children: [
        SizedBox(
          width: 60.w,
          height: 60.h,
          child: CircularProgressIndicator(strokeWidth: 6.w),
        ),
        SizedBox(height: 16.h),
        Text(
          'جاري التحقق من توفر البيانات...',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(DownloadProgress progress) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              progress.errorMessage ?? 'حدث خطأ غير متوقع',
              style: TextStyle(fontSize: 14.sp, color: Colors.red[900]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteButton() {
    return ElevatedButton(
      onPressed: () {
        // Navigate to main app
        if (mounted && context.mounted) {
          context.go('/dashboard');
        }
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ابدأ الاستخدام',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8.w),
          Icon(Icons.arrow_forward, size: 24.sp),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return TextButton(
      onPressed: () {
        ref.read(databaseDownloadProvider.notifier).cancelDownload();
      },
      child: Text(
        'إلغاء التحميل',
        style: TextStyle(fontSize: 16.sp, color: Colors.red),
      ),
    );
  }

  Widget _buildRetryButton() {
    final state = ref.read(databaseDownloadProvider);
    final hasPartialDownload = state.progress.downloadedBytes > 0;

    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            ref.read(databaseDownloadProvider.notifier).downloadDatabase(_downloadUrl);
          },
          icon: Icon(hasPartialDownload ? Icons.play_arrow : Icons.refresh),
          label: Text(
            hasPartialDownload ? 'استكمال التنزيل' : 'إعادة المحاولة',
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
        if (hasPartialDownload) ...[
          SizedBox(height: 12.h),
          Text(
            'تم تنزيل ${state.progress.downloadedSize} - سيتم الاستكمال من حيث توقفت',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.green[700],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
