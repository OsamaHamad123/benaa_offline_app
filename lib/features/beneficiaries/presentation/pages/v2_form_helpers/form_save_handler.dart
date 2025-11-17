import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/beneficiary.dart';
import '../../providers/beneficiary_dependencies.dart';

/// 💾 Form Save Handler
///
/// Handles save, auto-save, and duplicate checking logic
class BeneficiaryFormSaveHandler {
  /// Check if national ID already exists (for new beneficiaries only)
  static Future<bool> checkDuplicateNationalId({
    required BuildContext context,
    required WidgetRef ref,
    required String nationalId,
    required String? beneficiaryId,
  }) async {
    // Skip check for existing beneficiary edits
    if (beneficiaryId != null) return false;

    try {
      final repository = ref.read(beneficiaryRepositoryProvider);

      // Search for existing beneficiary with same national ID
      final existingList = await repository.list(
        searchQuery: nationalId,
        limit: 5,
      );

      // Check if any result has exact match of national ID
      for (final b in existingList) {
        if (b.nationalId == nationalId) {
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
      }

      return false; // No duplicate
    } catch (e) {
      debugPrint('Error checking duplicate: $e');
      return false; // Continue with save even if check fails
    }
  }

  /// Generate automatic file number
  static String generateFileNumber({
    required String? beneficiaryId,
    required Beneficiary? existingBeneficiary,
  }) {
    final now = DateTime.now();

    if (beneficiaryId != null && existingBeneficiary?.fileNo != null) {
      return existingBeneficiary!.fileNo!;
    }

    return 'F-${now.millisecondsSinceEpoch}';
  }

  /// Validate form before save
  static bool validateForm({
    required GlobalKey<FormState> formKey,
    required BuildContext context,
    required bool isAutoSave,
    required VoidCallback scrollToError,
  }) {
    if (!formKey.currentState!.validate()) {
      // Don't show errors for auto-save
      if (isAutoSave) return false;

      // Scroll to first error field
      scrollToError();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('يرجى إكمال الحقول المطلوبة'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
      return false;
    }
    return true;
  }
}
