import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/db/drift_database.dart';
import '../../domain/repositories/beneficiary_repository.dart';
import '../../domain/usecases/beneficiary_usecases.dart';
import '../../data/datasources/beneficiary_local_datasource.dart';
import '../../data/repositories/beneficiary_repository_impl.dart';

// 🆕 Civil Registry Imports
import '../../domain/repositories/civil_registry_repository.dart';
import '../../domain/usecases/fetch_civil_registry_data.dart';
import '../../domain/usecases/autofill_from_civil_registry.dart';
import '../../data/datasources/civil_registry_local_datasource.dart';
import '../../data/repositories/civil_registry_repository_impl.dart';
import 'civil_registry_provider.dart';
import '../../../search/data/datasources/civil_registry_database.dart';

/// 🔌 Dependency Injection Setup for Beneficiaries Feature

// Database dependency (from main app)
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Database provider must be overridden');
});

// 🆕 Civil Registry Database Provider (persons.db)
final civilRegistryDatabaseProvider = Provider<CivilRegistryDatabase>((ref) {
  return CivilRegistryDatabase.instance;
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

// ============================================================================
// 🆕 CIVIL REGISTRY PROVIDERS
// ============================================================================

// Civil Registry Data Source
final civilRegistryDataSourceProvider = Provider<CivilRegistryLocalDataSource>((
  ref,
) {
  final civilDb = ref.watch(civilRegistryDatabaseProvider);
  return CivilRegistryLocalDataSource(civilDb);
});

// Civil Registry Repository
final civilRegistryRepositoryProvider = Provider<CivilRegistryRepository>((
  ref,
) {
  final dataSource = ref.watch(civilRegistryDataSourceProvider);
  return CivilRegistryRepositoryImpl(dataSource);
});

// Civil Registry Use Cases
final fetchCivilRegistryDataUseCaseProvider = Provider((ref) {
  final repository = ref.watch(civilRegistryRepositoryProvider);
  return FetchCivilRegistryDataUseCase(repository);
});

final autofillFromCivilRegistryUseCaseProvider = Provider((ref) {
  return AutofillFromCivilRegistryUseCase();
});

// Civil Registry State Provider
final civilRegistryProvider =
    StateNotifierProvider<CivilRegistryNotifier, CivilRegistryState>((ref) {
  final fetchUseCase = ref.watch(fetchCivilRegistryDataUseCaseProvider);
  final autofillUseCase = ref.watch(
    autofillFromCivilRegistryUseCaseProvider,
  );

  return CivilRegistryNotifier(
    fetchUseCase: fetchUseCase,
    autofillUseCase: autofillUseCase,
  );
});
