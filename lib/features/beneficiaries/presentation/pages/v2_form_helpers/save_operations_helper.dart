import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import '../../../domain/repositories/beneficiary_repository.dart';
import '../../../../../data/db/drift_database.dart';
import '../../../../attachments/data/datasources/attachment_datasource.dart';
import 'file_size_validator.dart';

/// 💾 Save Operations Helper
///
/// Handles duplicate check and attachment saving
class SaveOperationsHelper {
  /// Check for duplicate national ID
  static Future<bool> checkDuplicate({
    required BuildContext context,
    required BeneficiaryRepository repository,
    required String nationalId,
    required bool isNewBeneficiary,
  }) async {
    if (!isNewBeneficiary)
      return false; // Skip check for existing beneficiaries

    try {
      final existing = await repository.getByNationalId(nationalId);

      if (existing != null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('يوجد مستفيد بنفس الرقم الوطني'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          );
        }
        return true; // Duplicate found
      }
      return false; // No duplicate
    } catch (e) {
      debugPrint('Error checking duplicate: $e');
      return false; // Continue with save even if check fails
    }
  }

  /// Save attachments and return count (with file size validation)
  static Future<AttachmentSaveResult> saveAttachments({
    required AppDatabase database,
    required String beneficiaryId,
    required List<File> pendingFiles,
  }) async {
    debugPrint('💾 [SaveOperationsHelper] Starting to save attachments');
    debugPrint('💾 [SaveOperationsHelper] Beneficiary ID: $beneficiaryId');
    debugPrint(
      '💾 [SaveOperationsHelper] Number of files: ${pendingFiles.length}',
    );

    // ✅ التحقق من حجم الملفات قبل الحفظ
    final validation = FileSizeValidator.validateFiles(pendingFiles);

    if (!validation.isAllValid) {
      debugPrint('💾 [SaveOperationsHelper] ❌ Some files exceed size limit');
      return AttachmentSaveResult(
        savedCount: 0,
        failedCount: pendingFiles.length,
        oversizedFiles: validation.invalidFiles.keys.toList(),
      );
    }

    int savedCount = 0;
    int failedCount = 0;

    try {
      final datasource = AttachmentDataSource(database);

      for (final file in pendingFiles) {
        try {
          debugPrint('💾 [SaveOperationsHelper] Saving file: ${file.path}');
          await datasource.addAttachment(
            beneficiaryId: beneficiaryId,
            sourceFile: file,
          );
          savedCount++;
          debugPrint(
            '💾 [SaveOperationsHelper] ✅ File saved successfully. Total: $savedCount',
          );
        } catch (e) {
          debugPrint('💾 [SaveOperationsHelper] ❌ Error saving attachment: $e');
          failedCount++;
        }
      }
    } catch (e) {
      debugPrint(
        '💾 [SaveOperationsHelper] ❌❌ Fatal error saving attachments: $e',
      );
    }

    debugPrint(
      '💾 [SaveOperationsHelper] ✅ Finished. Saved: $savedCount, Failed: $failedCount',
    );
    return AttachmentSaveResult(
      savedCount: savedCount,
      failedCount: failedCount,
    );
  }

  /// Show success message
  static void showSuccessMessage({
    required BuildContext context,
    required AttachmentSaveResult attachmentResult,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('تم الحفظ بنجاح'),
                  if (attachmentResult.savedCount > 0)
                    Text(
                      'تم حفظ ${attachmentResult.savedCount} مرفق',
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  if (attachmentResult.failedCount > 0)
                    Text(
                      'فشل حفظ ${attachmentResult.failedCount} مرفق',
                      style: TextStyle(fontSize: 12.sp, color: Colors.orange),
                    ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  /// Show error message
  static void showErrorMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            const Expanded(
              child: Text('فشل في حفظ البيانات. يرجى المحاولة مرة أخرى'),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}

/// Result of attachment save operation
class AttachmentSaveResult {
  final int savedCount;
  final int failedCount;
  final List<File>? oversizedFiles;

  AttachmentSaveResult({
    required this.savedCount,
    required this.failedCount,
    this.oversizedFiles,
  });
}
