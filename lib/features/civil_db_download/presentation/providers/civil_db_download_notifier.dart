import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/civil_db_status.dart';
import '../../domain/usecases/cancel_download.dart';
import '../../domain/usecases/check_db_status.dart';
import '../../domain/usecases/download_db.dart';
import 'civil_db_providers.dart';

/// 📊 Civil Database Download State
class CivilDbDownloadState {
  final CivilDbStatus status;
  final bool isDownloading;
  final String? errorMessage;

  const CivilDbDownloadState({
    required this.status,
    this.isDownloading = false,
    this.errorMessage,
  });

  CivilDbDownloadState copyWith({
    CivilDbStatus? status,
    bool? isDownloading,
    String? errorMessage,
  }) {
    return CivilDbDownloadState(
      status: status ?? this.status,
      isDownloading: isDownloading ?? this.isDownloading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// 🎛️ Civil Database Download Provider
class CivilDbDownloadNotifier extends StateNotifier<CivilDbDownloadState> {
  final CheckDbStatusUseCase checkStatusUseCase;
  final DownloadDbUseCase downloadUseCase;
  final CancelDownloadUseCase cancelUseCase;

  CivilDbDownloadNotifier({
    required this.checkStatusUseCase,
    required this.downloadUseCase,
    required this.cancelUseCase,
  }) : super(
         CivilDbDownloadState(
           status: CivilDbStatus(status: CivilDbStatusType.notDownloaded),
         ),
       );

  /// Check database status
  Future<void> checkStatus() async {
    try {
      final status = await checkStatusUseCase();
      state = state.copyWith(status: status);
    } catch (e) {
      state = state.copyWith(
        status: CivilDbStatus(
          status: CivilDbStatusType.error,
          errorMessage: e.toString(),
        ),
        errorMessage: e.toString(),
      );
    }
  }

  /// Start downloading database
  Future<void> startDownload(String downloadUrl) async {
    state = state.copyWith(isDownloading: true, errorMessage: null);

    try {
      await for (final status in downloadUseCase(downloadUrl)) {
        state = state.copyWith(
          status: status,
          isDownloading: status.status == CivilDbStatusType.downloading,
          errorMessage: status.errorMessage,
        );

        // If download complete or error, stop
        if (status.status == CivilDbStatusType.ready ||
            status.status == CivilDbStatusType.error) {
          break;
        }
      }
    } catch (e) {
      state = state.copyWith(
        status: CivilDbStatus(
          status: CivilDbStatusType.error,
          errorMessage: e.toString(),
        ),
        isDownloading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Cancel download
  Future<void> cancelDownload() async {
    await cancelUseCase();
    state = state.copyWith(
      status: CivilDbStatus(status: CivilDbStatusType.notDownloaded),
      isDownloading: false,
    );
  }
}

/// Provider for CivilDbDownloadNotifier
final civilDbDownloadProvider =
    StateNotifierProvider<CivilDbDownloadNotifier, CivilDbDownloadState>((ref) {
      return CivilDbDownloadNotifier(
        checkStatusUseCase: ref.watch(checkDbStatusUseCaseProvider),
        downloadUseCase: ref.watch(downloadDbUseCaseProvider),
        cancelUseCase: ref.watch(cancelDownloadUseCaseProvider),
      );
    });
