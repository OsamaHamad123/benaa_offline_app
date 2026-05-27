import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import '../../../domain/repositories/beneficiary_repository.dart';
import '../../../../../data/db/drift_database.dart';
import '../../../../attachments/data/datasources/attachment_datasource.dart';
import '../../../../attachments/domain/models/pending_attachment.dart';
import 'file_size_validator.dart';
import '../../../../../core/error_handling/result.dart';

/// 💾 Save Operations Helper
///
/// Handles duplicate check and attachment saving
class SaveOperationsHelper {
  static void _log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  /// Check for duplicate national ID
  static Future<bool> checkDuplicate({
    required BuildContext context,
    required BeneficiaryRepository repository,
    required String nationalId,
    required bool isNewBeneficiary,
    String? currentBeneficiaryId,
  }) async {
    // تنظيف الرقم الوطني
    final cleanedNationalId = nationalId.trim();
    if (cleanedNationalId.isEmpty) return false;

    _log('[BeneficiarySave] duplicate check started nationalId=$cleanedNationalId');
    _log('🔍 Is New: $isNewBeneficiary');
    _log('🔍 Current ID: $currentBeneficiaryId');

    try {
      final result = await repository.getByNationalId(cleanedNationalId);

      if (result.isFailure) {
        try {
          result.getOrThrow();
        } catch (error) {
          if (error is NotFoundFailure) {
            _log('[BeneficiarySave] duplicate check result=success no_duplicate');
            return false;
          }

          _log('[BeneficiarySave] duplicate check result=failure');
          _log('[BeneficiarySave] duplicate check failure code=lookup_failed message=$error');

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('تعذر التحقق من التكرار. يرجى المحاولة مرة أخرى.'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            );
          }

          // Controlled validation error: block save safely.
          return true;
        }
      }

      final existing = result.getOrNull();
      if (existing == null) {
        _log('[BeneficiarySave] duplicate check result=failure');
        _log('[BeneficiarySave] duplicate check failure code=empty_success message=null_result');
        return true;
      }
      _log(
        '🔍 Query result: Found (ID: ${existing.id})',
      );

      // إذا كان تعديل لمستفيد موجود، تجاهل نفس المستفيد
      if (!isNewBeneficiary && existing.id == currentBeneficiaryId) {
        _log('[BeneficiarySave] duplicate check result=success same_beneficiary');
        return false; // نفس المستفيد، لا يعتبر تكرار
      }

      // يوجد مستفيد آخر بنفس الرقم الوطني
      _log(
        '⚠️ checkDuplicate: Found duplicate - ID: ${existing.id}',
      );
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
    } catch (e) {
      _log('[BeneficiarySave] duplicate check result=failure');
      _log('[BeneficiarySave] duplicate check failure code=exception message=$e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تعذر التحقق من التكرار. يرجى المحاولة مرة أخرى.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      }
      return true;
    }
  }

  /// Save attachments and return count (with file size validation)
  static Future<AttachmentSaveResult> saveAttachments({
    required AppDatabase database,
    required String beneficiaryId,
    required List<File> pendingFiles,
  }) async {
    _log('💾 [SaveOperationsHelper] Starting to save attachments');
    _log('💾 [SaveOperationsHelper] Beneficiary ID: $beneficiaryId');
    _log(
      '💾 [SaveOperationsHelper] Number of files: ${pendingFiles.length}',
    );

    // ✅ التحقق من حجم الملفات قبل الحفظ
    final validation = FileSizeValidator.validateFiles(pendingFiles);

    if (!validation.isAllValid) {
      _log('💾 [SaveOperationsHelper] ❌ Some files exceed size limit');
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
          _log('💾 [SaveOperationsHelper] Saving file: ${file.path}');
          await datasource.addAttachment(
            beneficiaryId: beneficiaryId,
            sourceFile: file,
          );
          savedCount++;
          _log(
            '💾 [SaveOperationsHelper] ✅ File saved successfully. Total: $savedCount',
          );
        } catch (e) {
          _log('💾 [SaveOperationsHelper] ❌ Error saving attachment: $e');
          failedCount++;
        }
      }
    } catch (e) {
      _log(
        '💾 [SaveOperationsHelper] ❌❌ Fatal error saving attachments: $e',
      );
    }

    _log(
      '💾 [SaveOperationsHelper] ✅ Finished. Saved: $savedCount, Failed: $failedCount',
    );
    return AttachmentSaveResult(
      savedCount: savedCount,
      failedCount: failedCount,
    );
  }

  /// Save pending attachments (with metadata) and return count
  static Future<AttachmentSaveResult> savePendingAttachments({
    required AppDatabase database,
    required String beneficiaryId,
    required List<PendingAttachment> pendingAttachments,
  }) async {
    final pendingFiles = pendingAttachments.map((attachment) => attachment.file).toList(growable: false);

    _log('💾 [SaveOperationsHelper] Starting to save pending attachments with metadata');
    _log('💾 [SaveOperationsHelper] Beneficiary ID: $beneficiaryId');
    _log('💾 [SaveOperationsHelper] Number of pending attachments: ${pendingAttachments.length}');

    final validation = FileSizeValidator.validateFiles(pendingFiles);

    if (!validation.isAllValid) {
      _log('💾 [SaveOperationsHelper] ❌ Some files exceed size limit');
      return AttachmentSaveResult(
        savedCount: 0,
        failedCount: pendingAttachments.length,
        oversizedFiles: validation.invalidFiles.keys.toList(),
      );
    }

    int savedCount = 0;
    int failedCount = 0;
    final failedPendingAttachments = <PendingAttachment>[];

    try {
      final datasource = AttachmentDataSource(database);

      for (final pending in pendingAttachments) {
        try {
          await datasource.addAttachment(
            beneficiaryId: beneficiaryId,
            sourceFile: pending.file,
            documentType: pending.documentType,
            personType: pending.personType,
            personId: pending.personId,
            notes: pending.notes,
          );
          savedCount++;
        } catch (e) {
          _log('💾 [SaveOperationsHelper] ❌ Error saving pending attachment: $e');
          failedCount++;
          failedPendingAttachments.add(pending);
        }
      }
    } catch (e) {
      _log('💾 [SaveOperationsHelper] ❌❌ Fatal error saving pending attachments: $e');
    }

    _log('💾 [SaveOperationsHelper] ✅ Finished pending attachments. Saved: $savedCount, Failed: $failedCount');
    return AttachmentSaveResult(
      savedCount: savedCount,
      failedCount: failedCount,
      failedPendingAttachments: failedPendingAttachments,
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
  final List<PendingAttachment> failedPendingAttachments;

  AttachmentSaveResult({
    required this.savedCount,
    required this.failedCount,
    this.oversizedFiles,
    this.failedPendingAttachments = const <PendingAttachment>[],
  });
}
