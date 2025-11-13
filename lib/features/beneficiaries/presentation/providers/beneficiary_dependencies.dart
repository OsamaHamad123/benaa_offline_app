import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/db/drift_database.dart';
import '../../domain/repositories/beneficiary_repository.dart';
import '../../domain/usecases/beneficiary_usecases.dart';
import '../../data/datasources/beneficiary_local_datasource.dart';
import '../../data/repositories/beneficiary_repository_impl.dart';

/// 🔌 Dependency Injection Setup for Beneficiaries Feature

// Database dependency (from main app)
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Database provider must be overridden');
});

// Data Source
final beneficiaryDataSourceProvider = Provider<BeneficiaryLocalDataSource>((
  ref,
) {
  final db = ref.watch(databaseProvider);
  return BeneficiaryLocalDataSource(db);
});

// Repository
final beneficiaryRepositoryProvider = Provider<BeneficiaryRepository>((ref) {
  final dataSource = ref.watch(beneficiaryDataSourceProvider);
  return BeneficiaryRepositoryImpl(dataSource);
});

// Use Cases
final createBeneficiaryUseCaseProvider = Provider((ref) {
  final repository = ref.watch(beneficiaryRepositoryProvider);
  return CreateBeneficiaryUseCase(repository);
});

final updateBeneficiaryUseCaseProvider = Provider((ref) {
  final repository = ref.watch(beneficiaryRepositoryProvider);
  return UpdateBeneficiaryUseCase(repository);
});

final getBeneficiaryUseCaseProvider = Provider((ref) {
  final repository = ref.watch(beneficiaryRepositoryProvider);
  return GetBeneficiaryUseCase(repository);
});

final deleteBeneficiaryUseCaseProvider = Provider((ref) {
  final repository = ref.watch(beneficiaryRepositoryProvider);
  return DeleteBeneficiaryUseCase(repository);
});

final listBeneficiariesUseCaseProvider = Provider((ref) {
  final repository = ref.watch(beneficiaryRepositoryProvider);
  return ListBeneficiariesUseCase(repository);
});

final loadFromCivilRegistryUseCaseProvider = Provider((ref) {
  final repository = ref.watch(beneficiaryRepositoryProvider);
  return LoadFromCivilRegistryUseCase(repository);
});
