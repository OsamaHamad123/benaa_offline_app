import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/providers.dart';
import '../../domain/entities/attachment.dart';
import '../../domain/usecases/get_beneficiary_attachments_usecase.dart';
import '../../domain/usecases/add_attachment_usecase.dart';
import '../../domain/usecases/delete_attachment_usecase.dart';
import '../../data/datasources/attachment_datasource.dart';
import '../../data/repositories/attachment_repository_impl.dart';
import '../../../dashboard/domain/usecases/log_activity.dart';
import '../../../dashboard/presentation/providers/activity_providers.dart';
import '../../../../core/error_handling/result.dart';

// ============================================================================
// PROVIDERS
// ============================================================================

/// Attachment Data Source Provider
final attachmentDataSourceProvider = Provider<AttachmentDataSource>((ref) {
  final database = ref.watch(databaseProvider);
  return AttachmentDataSource(database);
});

/// Attachment Repository Provider
final attachmentRepositoryProvider = Provider((ref) {
  final dataSource = ref.watch(attachmentDataSourceProvider);
  return AttachmentRepositoryImpl(dataSource);
});

/// Get Beneficiary Attachments Use Case Provider
final getBeneficiaryAttachmentsUseCaseProvider = Provider((ref) {
  final repository = ref.watch(attachmentRepositoryProvider);
  return GetBeneficiaryAttachmentsUseCase(repository);
});

/// Add Attachment Use Case Provider
final addAttachmentUseCaseProvider = Provider((ref) {
  final repository = ref.watch(attachmentRepositoryProvider);
  return AddAttachmentUseCase(repository);
});

/// Delete Attachment Use Case Provider
final deleteAttachmentUseCaseProvider = Provider((ref) {
  final repository = ref.watch(attachmentRepositoryProvider);
  return DeleteAttachmentUseCase(repository);
});

// ============================================================================
// STATE NOTIFIER
// ============================================================================

/// Attachments State
class AttachmentsState {
  final List<Attachment> attachments;
  final bool isLoading;
  final String? errorMessage;

  const AttachmentsState({
    this.attachments = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  AttachmentsState copyWith({
    List<Attachment>? attachments,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AttachmentsState(
      attachments: attachments ?? this.attachments,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Attachments Notifier
class AttachmentsNotifier extends StateNotifier<AttachmentsState> {
  final GetBeneficiaryAttachmentsUseCase _getAttachmentsUseCase;
  final AddAttachmentUseCase _addAttachmentUseCase;
  final DeleteAttachmentUseCase _deleteAttachmentUseCase;
  final LogActivity? _logActivity;

  AttachmentsNotifier(
    this._getAttachmentsUseCase,
    this._addAttachmentUseCase,
    this._deleteAttachmentUseCase, {
    LogActivity? logActivity,
  })  : _logActivity = logActivity,
        super(const AttachmentsState());

  /// Load attachments for beneficiary
  Future<void> loadAttachments(String beneficiaryId) async {
    debugPrint(
      '🔍 [AttachmentsProvider] Loading attachments for: $beneficiaryId',
    );
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _getAttachmentsUseCase.execute(beneficiaryId);

      if (result is Success<List<Attachment>>) {
        final attachments = result.value;
        debugPrint(
          '✅ [AttachmentsProvider] Loaded ${attachments.length} attachments',
        );
        state = state.copyWith(attachments: attachments, isLoading: false);
      } else if (result is Failure<List<Attachment>>) {
        throw Exception(result.error.message);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [AttachmentsProvider] Error loading attachments: $e');
      debugPrint('Stack trace: $stackTrace');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'خطأ في تحميل المرفقات: $e',
      );
    }
  }

  /// Add new attachment
  Future<bool> addAttachment({
    required String beneficiaryId,
    String? visitId,
    required File sourceFile,
    String? beneficiaryName,
  }) async {
    try {
      final result = await _addAttachmentUseCase.execute(
        beneficiaryId: beneficiaryId,
        visitId: visitId,
        sourceFile: sourceFile,
      );

      if (result is Failure<Attachment>) {
        throw Exception(result.error.message);
      }

      final attachment = (result as Success<Attachment>).value;
      state = state.copyWith(attachments: [...state.attachments, attachment]);

      // Log activity if available
      final logActivity = _logActivity;
      if (logActivity != null) {
        try {
          await logActivity(
            type: 'attachment',
            description: 'تم إضافة مرفق جديد',
            beneficiaryId: beneficiaryId,
            beneficiaryName: beneficiaryName,
            metadata: {
              'action': 'add',
              'attachment_id': attachment.id,
              'attachment_type': attachment.type.name,
              'visit_id': visitId,
            },
          );
        } catch (e) {
          debugPrint('❌ Failed to log activity: $e');
        }
      }

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'خطأ في إضافة المرفق: $e');
      return false;
    }
  }

  /// Delete attachment
  Future<bool> deleteAttachment(
    String attachmentId, {
    String? beneficiaryId,
    String? beneficiaryName,
  }) async {
    try {
      final result = await _deleteAttachmentUseCase.execute(attachmentId);

      if (result is Failure<bool>) {
        throw Exception(result.error.message);
      }

      final success = (result as Success<bool>).value;
      if (success) {
        state = state.copyWith(
          attachments:
              state.attachments.where((a) => a.id != attachmentId).toList(),
        );

        // Log activity if available
        final logActivity = _logActivity;
        if (logActivity != null && beneficiaryId != null) {
          try {
            await logActivity(
              type: 'attachment',
              description: 'تم حذف مرفق',
              beneficiaryId: beneficiaryId,
              beneficiaryName: beneficiaryName,
              metadata: {'action': 'delete', 'attachment_id': attachmentId},
            );
          } catch (e) {
            debugPrint('❌ Failed to log activity: $e');
          }
        }
      }

      return success;
    } catch (e) {
      state = state.copyWith(errorMessage: 'خطأ في حذف المرفق: $e');
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Attachments Provider
final attachmentsProvider =
    StateNotifierProvider.family<AttachmentsNotifier, AttachmentsState, String>(
  (ref, beneficiaryId) {
    final getUseCase = ref.watch(getBeneficiaryAttachmentsUseCaseProvider);
    final addUseCase = ref.watch(addAttachmentUseCaseProvider);
    final deleteUseCase = ref.watch(deleteAttachmentUseCaseProvider);
    final logActivity = ref.watch(logActivityUseCaseProvider);

    final notifier = AttachmentsNotifier(
      getUseCase,
      addUseCase,
      deleteUseCase,
      logActivity: logActivity,
    );

    // Auto-load attachments
    Future.microtask(() => notifier.loadAttachments(beneficiaryId));

    return notifier;
  },
);
