import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import '../../../../core/widgets/app_async_state_view.dart';
import '../../../beneficiaries/presentation/pages/v2_form_helpers/widgets/empty_state_widget.dart'
    as BeneficiaryEmpty; // ✅ Avoid conflict

/// 📎 Pending Attachments Section - للاستخدام في نموذج إضافة مستفيد
///
/// يعرض ويدير الملفات المعلقة (pending files) قبل الحفظ النهائي
class PendingAttachmentsSection extends StatefulWidget {
  final List<File> initialFiles;
  final Function(List<File>)? onFilesChanged;
  final bool showTitle;

  const PendingAttachmentsSection({
    super.key,
    this.initialFiles = const [],
    this.onFilesChanged,
    this.showTitle = true,
  });

  @override
  State<PendingAttachmentsSection> createState() => _PendingAttachmentsSectionState();
}

class _PendingAttachmentsSectionState extends State<PendingAttachmentsSection> {
  late List<File> _pendingFiles;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _pendingFiles = List.from(widget.initialFiles);
  }

  void _notifyChanges() {
    widget.onFilesChanged?.call(_pendingFiles);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showTitle) _buildHeader(context),
        if (widget.showTitle) SizedBox(height: 12.h),
        _buildContent(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          Icons.attach_file_outlined,
          color: colorScheme.onSurfaceVariant,
          size: 22.sp,
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            'المرفقات${_pendingFiles.isNotEmpty ? ' (${_pendingFiles.length})' : ''}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isUploading) {
      return _buildLoading(context);
    }

    if (_pendingFiles.isEmpty) {
      return _buildEmpty(context);
    }

    return _buildFilesList(context);
  }

  Widget _buildLoading(BuildContext context) {
    return AppAsyncStateView.loading(
      message: 'جاري إضافة الملف...',
      padding: EdgeInsets.all(24.r),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return BeneficiaryEmpty.EmptyStateWidget.noAttachments(
      onAdd: () => _showAddOptions(context),
    );
  }

  Widget _buildFilesList(BuildContext context) {
    return Column(
      children: [
        _buildAddButton(context),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 0.85,
          ),
          itemCount: _pendingFiles.length,
          itemBuilder: (context, index) {
            final file = _pendingFiles[index];
            return _PendingFileCard(
              file: file,
              onTap: () => _openFile(file),
              onDelete: () => _deleteFile(index),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _showAddOptions(context),
      icon: const Icon(Icons.add),
      label: const Text('إضافة مرفق'),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Future<void> _showAddOptions(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;

    await showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'إضافة مرفق',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.h),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: colorScheme.primary,
                      size: 24.sp,
                    ),
                  ),
                  title: const Text('التقاط صورة'),
                  subtitle: const Text('استخدام الكاميرا'),
                  trailing: Icon(Icons.chevron_right, size: 20.sp),
                  onTap: () {
                    Navigator.pop(context);
                    _addImageFromCamera();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.photo_library,
                      color: colorScheme.tertiary,
                      size: 24.sp,
                    ),
                  ),
                  title: const Text('اختيار من المعرض'),
                  subtitle: const Text('اختيار صورة أو أكثر'),
                  trailing: Icon(Icons.chevron_right, size: 20.sp),
                  onTap: () {
                    Navigator.pop(context);
                    _addImageFromGallery();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.picture_as_pdf,
                      color: colorScheme.error,
                      size: 24.sp,
                    ),
                  ),
                  title: const Text('اختيار ملف PDF'),
                  subtitle: const Text('تحديد ملف أو أكثر'),
                  trailing: Icon(Icons.chevron_right, size: 20.sp),
                  onTap: () {
                    Navigator.pop(context);
                    _addPdfFile();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addImageFromCamera() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        await _addFile(File(image.path));
      }
    } on Exception catch (e) {
      if (mounted) {
        _showErrorSnackBar(
          e.toString().contains('camera_access_denied')
              ? 'لا يوجد صلاحية للوصول إلى الكاميرا'
              : e.toString().contains('already_active')
                  ? 'الكاميرا مشغولة بالفعل، أغلق التطبيق الآخر أولاً'
                  : 'فشل فتح الكاميرا: ${e.toString()}',
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('خطأ غير متوقع: ${e.toString()}');
      }
    }
  }

  Future<void> _addImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final images = await picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (images.isEmpty) return;

      for (final image in images) {
        await _addFile(File(image.path));
      }
    } on Exception catch (e) {
      if (mounted) {
        _showErrorSnackBar(
          e.toString().contains('photo_access_denied')
              ? 'لا يوجد صلاحية للوصول إلى المعرض'
              : 'فشل فتح المعرض: ${e.toString()}',
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('خطأ غير متوقع: ${e.toString()}');
      }
    }
  }

  Future<void> _addPdfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        for (final file in result.files) {
          if (file.path != null) {
            await _addFile(File(file.path!));
          }
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        _showErrorSnackBar('فشل اختيار الملف: ${e.toString()}');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('خطأ غير متوقع: ${e.toString()}');
      }
    }
  }

  Future<void> _addFile(File file) async {
    setState(() => _isUploading = true);

    try {
      // Validate file size
      final fileSize = await file.length();
      const maxSize = 10 * 1024 * 1024; // 10 MB

      if (fileSize > maxSize) {
        if (mounted) {
          _showErrorSnackBar('حجم الملف يتجاوز 10 ميجابايت');
        }
        setState(() => _isUploading = false);
        return;
      }

      setState(() {
        _pendingFiles.add(file);
        _isUploading = false;
      });

      _notifyChanges();

      if (mounted) {
        _showSuccessSnackBar('✓ تمت إضافة الملف');
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        _showErrorSnackBar('خطأ: $e');
      }
    }
  }

  void _deleteFile(int index) {
    setState(() {
      _pendingFiles.removeAt(index);
    });
    _notifyChanges();

    _showSuccessSnackBar('✓ تم حذف الملف');
  }

  Future<void> _openFile(File file) async {
    if (await file.exists()) {
      await OpenFile.open(file.path);
    } else if (mounted) {
      _showErrorSnackBar('الملف غير موجود');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: colorScheme.onError, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: colorScheme.error,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: colorScheme.onPrimary, size: 20.sp),
            SizedBox(width: 12.w),
            Text(message),
          ],
        ),
        backgroundColor: colorScheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Pending File Card Widget
class _PendingFileCard extends StatelessWidget {
  final File file;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _PendingFileCard({
    required this.file,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail/Icon
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12.r),
                    ),
                    child: _buildThumbnail(context),
                  ),
                  // Delete button
                  Positioned(
                    top: 2.h,
                    right: 2.w,
                    child: GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        padding: EdgeInsets.all(3.r),
                        decoration: BoxDecoration(
                          color: colorScheme.error.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.shadow.withOpacity(0.3),
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.close,
                          color: colorScheme.onError,
                          size: 14.sp,
                        ),
                      ),
                    ),
                  ),
                  // Type badge
                  Positioned(
                    bottom: 2.h,
                    left: 2.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getTypeColor(context).withOpacity(0.85),
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                      child: Text(
                        _getTypeLabel(),
                        style: TextStyle(
                          color: colorScheme.onInverseSurface,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info section - Fixed height to prevent overflow
            Container(
              height: 52.h,
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(12.r),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      _getFileName(),
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Flexible(
                    child: Row(
                      children: [
                        Icon(
                          Icons.storage,
                          size: 9.sp,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: FutureBuilder<int>(
                            future: file.length(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Text(
                                  _formatFileSize(snapshot.data!),
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                );
                              }
                              return Text(
                                '...',
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isImage()) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: colorScheme.surfaceContainerHigh,
        child: Image.file(
          file,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => _buildIcon(Icons.broken_image, colorScheme.error),
        ),
      );
    } else if (_isPdf()) {
      return _buildIcon(Icons.picture_as_pdf, colorScheme.error);
    } else {
      return _buildIcon(Icons.insert_drive_file, colorScheme.onSurfaceVariant);
    }
  }

  Widget _buildIcon(IconData icon, Color color) {
    return Container(
      color: color.withOpacity(0.1),
      child: Center(
        child: Icon(icon, size: 48.sp, color: color),
      ),
    );
  }

  bool _isImage() {
    final ext = path.extension(file.path).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'].contains(ext);
  }

  bool _isPdf() {
    return path.extension(file.path).toLowerCase() == '.pdf';
  }

  Color _getTypeColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (_isImage()) return colorScheme.tertiary;
    if (_isPdf()) return colorScheme.error;
    return colorScheme.onSurfaceVariant;
  }

  String _getTypeLabel() {
    if (_isImage()) return 'صورة';
    if (_isPdf()) return 'PDF';
    return 'ملف';
  }

  String _getFileName() {
    final name = path.basename(file.path);
    if (name.length > 20) {
      return '${name.substring(0, 17)}...';
    }
    return name;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
