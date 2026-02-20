import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/providers.dart';
import '../../data/datasources/file_id_remote_datasource.dart';
import '../../data/repositories/file_id_reservation_repository_impl.dart';
import '../../domain/repositories/file_id_reservation_repository.dart';
import '../../services/file_id_service.dart';

/// 🌐 File ID Remote Data Source Provider
final fileIdRemoteDataSourceProvider = Provider<FileIdRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FileIdRemoteDataSourceImpl(apiClient.dio);
});

/// 🗄️ File ID Reservation Repository Provider
final fileIdReservationRepositoryProvider = Provider<FileIdReservationRepository>((ref) {
  final remote = ref.watch(fileIdRemoteDataSourceProvider);
  final db = ref.watch(databaseProvider);
  return FileIdReservationRepositoryImpl(
    remoteDataSource: remote,
    localDao: db.fileIdReservationDao,
  );
});

/// 🆔 File ID Service Provider
final fileIdServiceProvider = Provider<FileIdService>((ref) {
  final repository = ref.watch(fileIdReservationRepositoryProvider);
  return FileIdService(repository);
});
