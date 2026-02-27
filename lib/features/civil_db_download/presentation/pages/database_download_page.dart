import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/sync/background_sync_worker.dart';
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
  DateTime? _processingStartedAt;

  @override
  void initState() {
    super.initState();
    unawaited(_checkAndStartDownload());
  }

  Future<void> _checkAndStartDownload() async {
    // Wait a bit for UI to settle
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final state = ref.read(databaseDownloadProvider);
    final status = state.progress.status;
    final shouldAutoStart = !state.isAvailable &&
        !state.wasSkipped &&
        (status == DownloadStatus.idle || status == DownloadStatus.cancelled);

    if (shouldAutoStart) {
      // Auto-start download
      _processingStartedAt ??= DateTime.now();
      unawaited(ref.read(databaseDownloadProvider.notifier).downloadDatabase(_downloadUrl));
    }
  }

  bool _shouldShowBackgroundContinue(DownloadStatus status) {
    final startedAt = _processingStartedAt;
    if (startedAt == null) return false;
    final isBusy = status == DownloadStatus.downloading ||
        status == DownloadStatus.extracting ||
        status == DownloadStatus.verifying ||
        status == DownloadStatus.checking;
    if (!isBusy) return false;
    return DateTime.now().difference(startedAt) >= const Duration(seconds: 4);
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
    final status = progress.status;
    final isProcessing = status == DownloadStatus.downloading ||
        status == DownloadStatus.extracting ||
        status == DownloadStatus.verifying;
    final isReady = progress.isComplete || state.isAvailable;
    final canStartNow = !state.isAvailable && status == DownloadStatus.idle;
    final canRetry = progress.hasError || status == DownloadStatus.cancelled;

    if (isProcessing && _processingStartedAt == null) {
      _processingStartedAt = DateTime.now();
    }
    if (!isProcessing && status != DownloadStatus.checking) {
      _processingStartedAt = null;
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        title: const Text('تنزيل السجل المدني'),
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
              child: Container(
                constraints: BoxConstraints(maxWidth: 620.w),
                padding: EdgeInsets.all(22.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIcon(status),
                    SizedBox(height: 22.h),
                    _buildTitle(status),
                    SizedBox(height: 12.h),
                    _buildDescription(status),
                    if (!state.isAvailable && state.wasSkipped && status == DownloadStatus.idle) ...[
                      SizedBox(height: 12.h),
                      _buildSkippedInfoNotice(),
                    ],
                    SizedBox(height: 16.h),
                    _buildPhaseStepper(status),
                    if (canStartNow || canRetry || status == DownloadStatus.idle) ...[
                      SizedBox(height: 16.h),
                      _buildPrerequisitesCard(),
                    ],
                    SizedBox(height: 28.h),
                    if (isProcessing) _buildProgressIndicator(progress),
                    if (status == DownloadStatus.checking) _buildCheckingIndicator(),
                    if (progress.hasError) _buildErrorMessage(progress),
                    if (canStartNow) _buildStartButton(),
                    if (isReady) _buildCompleteButton(),
                    if (isReady) ...[
                      SizedBox(height: 14.h),
                      _buildReadySummary(state),
                    ],
                    if (isProcessing || status == DownloadStatus.checking) _buildCancelButton(),
                    if (_shouldShowBackgroundContinue(status)) ...[
                      SizedBox(height: 8.h),
                      _buildContinueInBackgroundButton(),
                    ],
                    if (canRetry) _buildRetryButton(),
                    if (!state.isAvailable &&
                        (status == DownloadStatus.idle ||
                            status == DownloadStatus.failed ||
                            status == DownloadStatus.cancelled ||
                            status == DownloadStatus.downloading ||
                            status == DownloadStatus.extracting)) ...[
                      SizedBox(height: 20.h),
                      _buildSkipButton(),
                    ],
                  ],
                ),
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
      case DownloadStatus.cancelled:
        icon = Icons.pause_circle_outline;
        color = Colors.orange;
        break;
      case DownloadStatus.downloading:
      case DownloadStatus.extracting:
      case DownloadStatus.checking:
      case DownloadStatus.verifying:
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
      case DownloadStatus.cancelled:
        title = 'تم إيقاف التحميل';
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
      case DownloadStatus.cancelled:
        description = 'تم إيقاف التنزيل مؤقتاً\nيمكنك المتابعة من حيث توقفت في أي وقت';
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
    final phaseLabel = _phaseLabel(progress.status);
    final etaText = _etaText(progress);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.timelapse_rounded, size: 18.sp, color: Theme.of(context).colorScheme.primary),
                  SizedBox(width: 8.w),
                  Text(
                    'المرحلة الحالية: $phaseLabel',
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  if (etaText != null)
                    Text(
                      etaText,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 14.h),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: LinearProgressIndicator(
                  value: progress.percentage / 100,
                  minHeight: 14.h,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                        color: Theme.of(context).colorScheme.onSurface,
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

  String _phaseLabel(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.downloading:
        return 'تحميل الملف';
      case DownloadStatus.extracting:
        return 'استخراج البيانات';
      case DownloadStatus.verifying:
        return 'التحقق النهائي';
      case DownloadStatus.checking:
        return 'فحص أولي';
      default:
        return 'تهيئة';
    }
  }

  String? _etaText(DownloadProgress progress) {
    final speed = progress.downloadSpeed;
    if (speed == null || speed <= 0 || progress.totalBytes <= 0 || progress.status != DownloadStatus.downloading) {
      return null;
    }

    final remainingBytes = progress.totalBytes - progress.downloadedBytes;
    if (remainingBytes <= 0) return null;
    final remainingMB = remainingBytes / (1024 * 1024);
    final remainingSeconds = (remainingMB / speed).round();
    if (remainingSeconds <= 0) return null;

    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    if (minutes > 0) {
      return 'متبقي ~${minutes}د ${seconds}ث';
    }
    return 'متبقي ~${seconds}ث';
  }

  Widget _buildStartButton() {
    return ElevatedButton.icon(
      onPressed: () {
        _processingStartedAt = DateTime.now();
        unawaited(ref.read(databaseDownloadProvider.notifier).downloadDatabase(_downloadUrl));
      },
      icon: const Icon(Icons.download_rounded),
      label: const Text('بدء التحميل'),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
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
        'إيقاف مؤقت',
        style: TextStyle(fontSize: 16.sp, color: Colors.red),
      ),
    );
  }

  Widget _buildRetryButton() {
    final state = ref.read(databaseDownloadProvider);
    final hasPartialDownload = state.progress.downloadedBytes > 0;
    final isCancelled = state.progress.status == DownloadStatus.cancelled;

    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            _processingStartedAt = DateTime.now();
            unawaited(ref.read(databaseDownloadProvider.notifier).downloadDatabase(_downloadUrl));
          },
          icon: Icon(hasPartialDownload || isCancelled ? Icons.play_arrow : Icons.refresh),
          label: Text(
            hasPartialDownload || isCancelled ? 'استكمال التنزيل' : 'إعادة المحاولة',
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

  /// 🆕 زر التخطي - للدخول بدون تحميل السجل المدني
  Widget _buildSkipButton() {
    return Column(
      children: [
        const Divider(height: 32),
        Text(
          'أو يمكنك التخطي والتحميل لاحقاً',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 12.h),
        OutlinedButton.icon(
          onPressed: () => _showSkipConfirmation(),
          icon: const Icon(Icons.skip_next_rounded),
          label: const Text('تخطي الآن'),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'ملاحظة: بعض الميزات لن تعمل بدون السجل المدني\n(البحث عن المواطنين، الملء التلقائي)',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.orange[700],
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// تأكيد التخطي
  Future<void> _showSkipConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.info_outline, size: 48.sp, color: Colors.orange),
        title: const Text('تخطي تحميل السجل المدني؟'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('يمكنك استخدام التطبيق بدون السجل المدني، لكن:'),
            SizedBox(height: 12.h),
            _buildWarningItem('لن تتمكن من البحث عن المواطنين'),
            _buildWarningItem('لن يعمل الملء التلقائي للبيانات'),
            _buildWarningItem('ستحتاج لإدخال البيانات يدوياً'),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.download_rounded, color: Colors.green[700], size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'يمكنك التحميل لاحقاً من الإعدادات',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.green[700],
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
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تخطي والمتابعة'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted && context.mounted) {
      // إيقاف التحميل إذا كان جارياً
      final notifier = ref.read(databaseDownloadProvider.notifier);
      final state = ref.read(databaseDownloadProvider);

      if (state.progress.status == DownloadStatus.downloading ||
          state.progress.status == DownloadStatus.extracting ||
          state.progress.status == DownloadStatus.verifying ||
          state.progress.status == DownloadStatus.checking) {
        notifier.cancelDownload();
      }

      // 🆕 حفظ حالة التخطي
      await notifier.skipDownload();
      if (!mounted || !context.mounted) return;

      // الذهاب للـ Dashboard
      context.go('/dashboard');
    }
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 16.sp, color: Colors.orange),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseStepper(DownloadStatus status) {
    final steps = [
      ('تحميل', DownloadStatus.downloading),
      ('استخراج', DownloadStatus.extracting),
      ('تحقق', DownloadStatus.verifying),
      ('جاهز', DownloadStatus.completed),
    ];

    int activeIndex = 0;
    switch (status) {
      case DownloadStatus.downloading:
        activeIndex = 0;
        break;
      case DownloadStatus.extracting:
        activeIndex = 1;
        break;
      case DownloadStatus.verifying:
        activeIndex = 2;
        break;
      case DownloadStatus.completed:
        activeIndex = 3;
        break;
      default:
        activeIndex = 0;
    }

    return Row(
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          Expanded(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 13.r,
                  backgroundColor: i <= activeIndex
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                  child: Icon(
                    i < activeIndex ? Icons.check : Icons.circle,
                    size: 12.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  steps[i].$1,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: i <= activeIndex ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (i < steps.length - 1)
            Expanded(
              child: Divider(
                thickness: 2,
                color: i < activeIndex
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildPrerequisitesCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'قبل البدء',
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6.h),
          Text('• الحجم المتوقع: ~${DownloadConfig.expectedSizeMB} MB', style: TextStyle(fontSize: 12.sp)),
          Text('• المساحة المقترحة: 700 MB على الأقل', style: TextStyle(fontSize: 12.sp)),
          Text('• الزمن التقريبي: 5-15 دقيقة حسب الشبكة', style: TextStyle(fontSize: 12.sp)),
        ],
      ),
    );
  }

  Widget _buildSkippedInfoNotice() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 18.sp,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'تم تخطي التنزيل سابقاً. يمكنك الآن الضغط على "بدء التحميل" للمتابعة.',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueInBackgroundButton() {
    return TextButton.icon(
      onPressed: () async {
        final notifier = ref.read(databaseDownloadProvider.notifier);
        notifier.cancelDownload();
        await BackgroundSyncWorker.triggerCivilDbDownload(downloadUrl: _downloadUrl);

        if (!mounted || !context.mounted) return;
        if (!mounted || !context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحويل التنزيل إلى الخلفية (حتى بعد إغلاق التطبيق)')),
        );
        context.go('/dashboard');
      },
      icon: const Icon(Icons.minimize_rounded),
      label: const Text('متابعة بالخلفية'),
    );
  }

  Widget _buildReadySummary(DatabaseDownloadState state) {
    final downloadedAt = state.downloadDate;
    final dateText = downloadedAt == null
        ? 'غير متوفر'
        : '${downloadedAt.year}/${downloadedAt.month.toString().padLeft(2, '0')}/${downloadedAt.day.toString().padLeft(2, '0')} '
            '${downloadedAt.hour.toString().padLeft(2, '0')}:${downloadedAt.minute.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.green.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ملخص السجل المدني', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 6.h),
          Text('• الحجم: ${state.fileSizeFormatted}', style: TextStyle(fontSize: 12.sp)),
          Text('• آخر تحديث: $dateText', style: TextStyle(fontSize: 12.sp)),
          Text('• الحالة: جاهز للاستخدام', style: TextStyle(fontSize: 12.sp)),
        ],
      ),
    );
  }
}
