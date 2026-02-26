import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/providers/providers.dart';
import '../../domain/entities/attachment.dart';
import '../../domain/usecases/get_beneficiary_attachments_usecase.dart';
import '../../domain/usecases/add_attachment_usecase.dart';
import '../../domain/usecases/delete_attachment_usecase.dart';
import '../../data/datasources/attachment_datasource.dart';
import '../../data/repositories/attachment_repository_impl.dart';
import '../../data/services/compressed_attachment_resolver.dart';
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

final compressedAttachmentResolverProvider = Provider<CompressedAttachmentResolver>((ref) {
  final storage = SecureStorage();
  return CompressedAttachmentResolver(
    allowRemoteFetch: false,
    authTokenProvider: storage.getAuthToken,
  );
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
  final Set<String> resolvingAttachmentIds;
  final Map<String, String> attachmentErrors;
  final Map<String, String>? resolvedAttachmentPaths;
  final Set<String>? previewRequestedIds;

  const AttachmentsState({
    this.attachments = const [],
    this.isLoading = false,
    this.errorMessage,
    this.resolvingAttachmentIds = const {},
    this.attachmentErrors = const {},
    this.resolvedAttachmentPaths = const {},
    this.previewRequestedIds = const {},
  });

  AttachmentsState copyWith({
    List<Attachment>? attachments,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
    Set<String>? resolvingAttachmentIds,
    Map<String, String>? attachmentErrors,
    Map<String, String>? resolvedAttachmentPaths,
    Set<String>? previewRequestedIds,
  }) {
    final currentResolved = this.resolvedAttachmentPaths ?? const <String, String>{};
    final currentPreviewRequested = this.previewRequestedIds ?? const <String>{};

    return AttachmentsState(
      attachments: attachments ?? this.attachments,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      resolvingAttachmentIds: resolvingAttachmentIds ?? this.resolvingAttachmentIds,
      attachmentErrors: attachmentErrors ?? this.attachmentErrors,
      resolvedAttachmentPaths: resolvedAttachmentPaths ?? currentResolved,
      previewRequestedIds: previewRequestedIds ?? currentPreviewRequested,
    );
  }
}

/// Attachments Notifier
class AttachmentsNotifier extends StateNotifier<AttachmentsState> {
  final GetBeneficiaryAttachmentsUseCase _getAttachmentsUseCase;
  final AddAttachmentUseCase _addAttachmentUseCase;
  final DeleteAttachmentUseCase _deleteAttachmentUseCase;
  final CompressedAttachmentResolver _compressedResolver;
  final LogActivity? _logActivity;

  AttachmentsNotifier(
    this._getAttachmentsUseCase,
    this._addAttachmentUseCase,
    this._deleteAttachmentUseCase, {
    required CompressedAttachmentResolver compressedResolver,
    LogActivity? logActivity,
  })  : _logActivity = logActivity,
        _compressedResolver = compressedResolver,
        super(const AttachmentsState());

  /// Load attachments for beneficiary
  Future<void> loadAttachments(String beneficiaryId) async {
    debugPrint(
      '🔍 [AttachmentsProvider] Loading attachments for: $beneficiaryId',
    );
    state = state.copyWith(isLoading: true);

    try {
      final result = await _getAttachmentsUseCase.execute(beneficiaryId);

      if (result is Success<List<Attachment>>) {
        final attachments = result.value;
        debugPrint(
          '✅ [AttachmentsProvider] Loaded ${attachments.length} attachments',
        );
        state = state.copyWith(
          attachments: attachments,
          isLoading: false,
          clearErrorMessage: true,
          previewRequestedIds: const {},
        );
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

  bool isCompressedAttachment(Attachment attachment) {
    return CompressedAttachmentResolver.isCompressedAttachment(attachment);
  }

  String? getAttachmentError(String attachmentId) {
    return state.attachmentErrors[attachmentId];
  }

  Future<File?> resolveAttachmentFile(
    Attachment attachment, {
    bool allowRemoteFetch = false,
  }) async {
    final resolvedPaths = state.resolvedAttachmentPaths ?? const <String, String>{};
    final cachedPath = resolvedPaths[attachment.id];
    if (cachedPath != null) {
      final cachedFile = File(cachedPath);
      if (await cachedFile.exists()) {
        return cachedFile;
      }
    }

    final id = attachment.id;
    final resolving = <String>{...state.resolvingAttachmentIds, id};
    final errors = <String, String>{...state.attachmentErrors}..remove(id);
    state = state.copyWith(
      resolvingAttachmentIds: resolving,
      attachmentErrors: errors,
    );

    try {
      final resolvedFile = await _compressedResolver.resolve(
        attachment,
        allowRemoteFetch: allowRemoteFetch,
      );
      if (resolvedFile == null) {
        final nextErrors = <String, String>{...state.attachmentErrors};
        nextErrors[id] = allowRemoteFetch ? 'الملف غير متوفر محلياً أو من السيرفر' : 'الملف غير متوفر محلياً';
        state = state.copyWith(attachmentErrors: nextErrors);
        return null;
      }
      final nextResolved = <String, String>{...resolvedPaths};
      nextResolved[id] = resolvedFile.path;
      state = state.copyWith(
        resolvedAttachmentPaths: nextResolved,
      );
      return resolvedFile;
    } catch (e) {
      final nextErrors = <String, String>{...state.attachmentErrors};
      nextErrors[id] = 'تعذر فك المرفق المضغوط: $e';
      state = state.copyWith(attachmentErrors: nextErrors);
      return null;
    } finally {
      final nextResolving = <String>{...state.resolvingAttachmentIds}..remove(id);
      state = state.copyWith(resolvingAttachmentIds: nextResolving);
    }
  }

  String? getResolvedAttachmentPath(String attachmentId) {
    final resolvedPaths = state.resolvedAttachmentPaths ?? const <String, String>{};
    return resolvedPaths[attachmentId];
  }

  Future<void> prefetchImagePreviews(List<Attachment> attachments) async {
    final previewRequested = state.previewRequestedIds ?? const <String>{};
    final resolvedPaths = state.resolvedAttachmentPaths ?? const <String, String>{};
    final toResolve = attachments
        .where((attachment) =>
            attachment.isImage &&
            !previewRequested.contains(attachment.id) &&
            !state.resolvingAttachmentIds.contains(attachment.id) &&
            resolvedPaths[attachment.id] == null)
        .toList(growable: false);

    if (toResolve.isEmpty) {
      return;
    }

    final marked = <String>{...previewRequested, ...toResolve.map((attachment) => attachment.id)};
    state = state.copyWith(previewRequestedIds: marked);

    for (final attachment in toResolve) {
      await resolveAttachmentFile(attachment, allowRemoteFetch: false);
    }
  }

  /// Add new attachment
  Future<bool> addAttachment({
    required String beneficiaryId,
    required File sourceFile,
    String? visitId,
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
          attachments: state.attachments.where((a) => a.id != attachmentId).toList(),
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
    state = state.copyWith(clearErrorMessage: true);
  }

  void clearAttachmentError(String attachmentId) {
    if (!state.attachmentErrors.containsKey(attachmentId)) {
      return;
    }
    final nextErrors = <String, String>{...state.attachmentErrors}..remove(attachmentId);
    state = state.copyWith(attachmentErrors: nextErrors);
  }
}

/// Attachments Provider
final attachmentsProvider = StateNotifierProvider.family<AttachmentsNotifier, AttachmentsState, String>(
  (ref, beneficiaryId) {
    final getUseCase = ref.watch(getBeneficiaryAttachmentsUseCaseProvider);
    final addUseCase = ref.watch(addAttachmentUseCaseProvider);
    final deleteUseCase = ref.watch(deleteAttachmentUseCaseProvider);
    final compressedResolver = ref.watch(compressedAttachmentResolverProvider);
    final logActivity = ref.watch(logActivityUseCaseProvider);

    final notifier = AttachmentsNotifier(
      getUseCase,
      addUseCase,
      deleteUseCase,
      compressedResolver: compressedResolver,
      logActivity: logActivity,
    );

    // Auto-load attachments
    Future.microtask(() => notifier.loadAttachments(beneficiaryId));

    return notifier;
  },
);
