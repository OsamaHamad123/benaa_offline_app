import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 📷 Camera & Photo Capture Widgets
///
/// Optimized for field data collection

class PhotoCaptureCard extends StatelessWidget {
  final String label;
  final String? photoPath;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback? onDelete;
  final bool required;

  const PhotoCaptureCard({
    super.key,
    required this.label,
    this.photoPath,
    required this.onCamera,
    required this.onGallery,
    this.onDelete,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(
          color: photoPath != null
              ? Colors.green.shade300
              : Colors.grey.shade300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.photo_camera_rounded,
                color: theme.colorScheme.primary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  label + (required ? ' *' : ''),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (photoPath != null)
                Icon(Icons.check_circle, color: Colors.green, size: 20.sp),
            ],
          ),
          SizedBox(height: 12.h),

          // Photo Preview
          if (photoPath != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      photoPath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.broken_image_rounded,
                            size: 48.sp,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                    if (onDelete != null)
                      Positioned(
                        top: 8.h,
                        left: 8.w,
                        child: Material(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20.r),
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              onDelete!();
                            },
                            borderRadius: BorderRadius.circular(20.r),
                            child: Padding(
                              padding: EdgeInsets.all(8.w),
                              child: Icon(
                                Icons.delete_rounded,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
          ],

          // Capture Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    onCamera();
                  },
                  icon: Icon(Icons.camera_alt_rounded, size: 20.sp),
                  label: const Text('كاميرا'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    onGallery();
                  },
                  icon: Icon(Icons.photo_library_rounded, size: 20.sp),
                  label: const Text('معرض'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 📸 Multiple Photos Grid
class PhotosGrid extends StatelessWidget {
  final List<String> photos;
  final VoidCallback onAddPhoto;
  final Function(int index) onDeletePhoto;
  final int maxPhotos;

  const PhotosGrid({
    super.key,
    required this.photos,
    required this.onAddPhoto,
    required this.onDeletePhoto,
    this.maxPhotos = 10,
  });

  @override
  Widget build(BuildContext context) {
    final canAdd = photos.length < maxPhotos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الصور (${photos.length}/$maxPhotos)',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
            if (canAdd)
              TextButton.icon(
                onPressed: onAddPhoto,
                icon: const Icon(Icons.add_photo_alternate_rounded),
                label: const Text('إضافة صورة'),
              ),
          ],
        ),
        SizedBox(height: 12.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1,
          ),
          itemCount: photos.length + (canAdd ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == photos.length) {
              // Add button
              return InkWell(
                onTap: onAddPhoto,
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_rounded,
                        size: 32.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'إضافة',
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Photo item
            return Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.network(
                    photos[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.broken_image_rounded,
                          size: 32.sp,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 4.h,
                  right: 4.w,
                  child: Material(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16.r),
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        onDeletePhoto(index);
                      },
                      borderRadius: BorderRadius.circular(16.r),
                      child: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// 🎤 Voice Note Recorder
class VoiceNoteRecorder extends StatelessWidget {
  final bool isRecording;
  final Duration? recordingDuration;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final String? savedNotePath;
  final VoidCallback? onPlayNote;
  final VoidCallback? onDeleteNote;

  const VoiceNoteRecorder({
    super.key,
    required this.isRecording,
    this.recordingDuration,
    required this.onStartRecording,
    required this.onStopRecording,
    this.savedNotePath,
    this.onPlayNote,
    this.onDeleteNote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.mic_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'ملاحظة صوتية',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          if (savedNotePath != null)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPlayNote,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('تشغيل التسجيل'),
                  ),
                ),
                SizedBox(width: 8.w),
                IconButton(
                  onPressed: onDeleteNote,
                  icon: const Icon(Icons.delete_rounded),
                  color: Colors.red,
                ),
              ],
            )
          else
            ElevatedButton.icon(
              onPressed: isRecording ? onStopRecording : onStartRecording,
              icon: Icon(
                isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                size: 24.sp,
              ),
              label: Text(
                isRecording
                    ? 'إيقاف (${_formatDuration(recordingDuration)})'
                    : 'بدء التسجيل',
                style: TextStyle(fontSize: 16.sp),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isRecording ? Colors.red : null,
                minimumSize: Size(double.infinity, 56.h),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '0:00';
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
