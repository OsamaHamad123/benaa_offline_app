import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/civil_db_manager.dart';
import '../../data/repositories/civil_db_repository_impl.dart';
import '../../domain/repositories/civil_db_repository.dart';
import '../../domain/usecases/cancel_download.dart';
import '../../domain/usecases/check_db_status.dart';
import '../../domain/usecases/download_db.dart';

/// 🏗️ Dependency Injection - Civil DB Download
///
/// Providers for managing civil database download

// Data Source
final civilDbManagerProvider = Provider<CivilDbManager>((ref) {
  return CivilDbManager();
});

// Repository
final civilDbRepositoryProvider = Provider<CivilDbRepository>((ref) {
  final manager = ref.watch(civilDbManagerProvider);
  return CivilDbRepositoryImpl(manager);
});

// Use Cases
final checkDbStatusUseCaseProvider = Provider<CheckDbStatusUseCase>((ref) {
  final repository = ref.watch(civilDbRepositoryProvider);
  return CheckDbStatusUseCase(repository);
});

final downloadDbUseCaseProvider = Provider<DownloadDbUseCase>((ref) {
  final repository = ref.watch(civilDbRepositoryProvider);
  return DownloadDbUseCase(repository);
});

final cancelDownloadUseCaseProvider = Provider<CancelDownloadUseCase>((ref) {
  final repository = ref.watch(civilDbRepositoryProvider);
  return CancelDownloadUseCase(repository);
});
