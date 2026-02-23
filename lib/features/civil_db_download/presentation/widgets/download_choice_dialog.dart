import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/entities/download_progress.dart';
import '../providers/database_download_provider.dart';
import '../pages/config/download_config.dart';

/// 🔄 خيارات تحميل قاعدة البيانات
enum DownloadChoice {
  /// تحميل الآن - صفحة كاملة مع إظهار التقدم
  downloadNow,

  /// تحميل في الخلفية - متابعة العمل أثناء التحميل
  downloadBackground,

  /// تخطي - التحميل لاحقاً من الإعدادات
  skip,
}

/// 🎯 Dialog للاختيار بين طرق تحميل قاعدة البيانات
///
/// Hybrid Approach: يتيح للمستخدم اختيار الطريقة المناسبة له
class DownloadChoiceDialog extends ConsumerStatefulWidget {
  /// إذا كان true، يمنع الإغلاق بالنقر خارج الـ Dialog
  final bool mandatory;

  const DownloadChoiceDialog({
    super.key,
    this.mandatory = false,
  });

  /// عرض الـ Dialog
  static Future<DownloadChoice?> show(
    BuildContext context, {
    bool mandatory = false,
  }) {
    return showDialog<DownloadChoice>(
      context: context,
      barrierDismissible: !mandatory,
      builder: (context) => DownloadChoiceDialog(mandatory: mandatory),
    );
  }

  @override
  ConsumerState<DownloadChoiceDialog> createState() => _DownloadChoiceDialogState();
}

class _DownloadChoiceDialogState extends ConsumerState<DownloadChoiceDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(maxWidth: 400.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_download_rounded,
            size: 48.sp,
            color: Colors.white,
          ),
          SizedBox(height: 12.h),
          Text(
            'تحميل قاعدة بيانات السجل المدني',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'الحجم المتوقع: ~${DownloadConfig.expectedSizeMB} MB',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          // وصف
          Text(
            'كيف تريد تحميل قاعدة البيانات؟',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),

          // خيار 1: تحميل الآن
          _buildChoiceCard(
            icon: Icons.download_rounded,
            iconColor: AppColors.primary,
            title: 'تحميل الآن',
            description: 'سيُظهر صفحة التقدم حتى انتهاء التحميل',
            isRecommended: true,
            onTap: () => _handleChoice(DownloadChoice.downloadNow),
          ),
          SizedBox(height: 12.h),

          // خيار 2: تحميل في الخلفية
          _buildChoiceCard(
            icon: Icons.sync_rounded,
            iconColor: Colors.blue,
            title: 'تحميل في الخلفية',
            description: 'تابع العمل أثناء التحميل في الخلفية',
            badge: 'جديد',
            onTap: () => _handleChoice(DownloadChoice.downloadBackground),
          ),
          SizedBox(height: 12.h),

          // خيار 3: تخطي
          _buildChoiceCard(
            icon: Icons.skip_next_rounded,
            iconColor: Colors.grey,
            title: 'تخطي الآن',
            description: 'بعض الميزات لن تعمل بدون السجل المدني',
            isSecondary: true,
            onTap: () => _handleChoice(DownloadChoice.skip),
          ),

          // رسالة تحذير للتخطي
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info, size: 18.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'يمكنك التحميل لاحقاً من الإعدادات',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // زر إلغاء (إذا غير إلزامي)
          if (!widget.mandatory) ...[
            SizedBox(height: 16.h),
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              child: const Text(
                'إلغاء',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChoiceCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required VoidCallback onTap, String? badge,
    bool isRecommended = false,
    bool isSecondary = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            border: Border.all(
              color: isRecommended
                  ? AppColors.primary
                  : isSecondary
                      ? Colors.grey.shade300
                      : Colors.grey.shade400,
              width: isRecommended ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12.r),
            color: isRecommended ? AppColors.primary.withValues(alpha: 0.05) : null,
          ),
          child: Row(
            children: [
              // أيقونة
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: iconColor, size: 24.sp),
              ),
              SizedBox(width: 12.w),

              // النص
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: isSecondary ? Colors.grey.shade600 : null,
                          ),
                        ),
                        if (badge != null) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              badge,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        if (isRecommended) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'موصى به',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // سهم
              Icon(
                Icons.chevron_left_rounded,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleChoice(DownloadChoice choice) async {
    setState(() => _isLoading = true);

    try {
      switch (choice) {
        case DownloadChoice.downloadNow:
          // الانتقال لصفحة التحميل الكاملة
          if (mounted) Navigator.pop(context, choice);
          break;

        case DownloadChoice.downloadBackground:
          // بدء التحميل في الخلفية
          final notifier = ref.read(databaseDownloadProvider.notifier);
          notifier.downloadDatabase(DownloadConfig.downloadUrl);
          if (mounted) Navigator.pop(context, choice);
          break;

        case DownloadChoice.skip:
          // حفظ حالة التخطي
          final notifier = ref.read(databaseDownloadProvider.notifier);
          await notifier.skipDownload();
          if (mounted) Navigator.pop(context, choice);
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

/// 🔔 مؤشر التحميل في الخلفية (يُستخدم في Dashboard)
class BackgroundDownloadIndicator extends ConsumerWidget {
  const BackgroundDownloadIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(databaseDownloadProvider);
    final progress = state.progress;

    // لا نعرض شيئاً إذا لم يكن هناك تحميل جاري
    if (!progress.isDownloading && progress.status != DownloadStatus.extracting) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // أيقونة متحركة
          SizedBox(
            width: 24.w,
            height: 24.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: progress.percentage / 100,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          SizedBox(width: 12.w),

          // النص
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  progress.status == DownloadStatus.extracting ? 'جاري استخراج البيانات...' : 'جاري تحميل السجل المدني',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${progress.displayPercentage} - ${progress.downloadedSize}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // زر الإلغاء
          IconButton(
            icon: Icon(Icons.close, size: 20.sp),
            onPressed: () {
              ref.read(databaseDownloadProvider.notifier).cancelDownload();
            },
            tooltip: 'إلغاء التحميل',
          ),
        ],
      ),
    );
  }
}
