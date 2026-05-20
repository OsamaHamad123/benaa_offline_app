import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/db/drift_database.dart';
import '../../domain/repositories/beneficiary_repository.dart';
import '../../domain/usecases/beneficiary_usecases.dart';
import '../../domain/usecases/guardian_bank_account_usecases.dart';
import '../../data/datasources/beneficiary_local_datasource.dart';
import '../../data/repositories/beneficiary_repository_impl.dart';
import '../../data/repositories/guardian_bank_account_repository_impl.dart';
import '../../domain/repositories/guardian_bank_account_repository.dart';

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
  final db = ref.watch(databaseProvider);
  return BeneficiaryRepositoryImpl(dataSource, db);
});

final guardianBankAccountRepositoryProvider = Provider<GuardianBankAccountRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return GuardianBankAccountRepositoryImpl(db);
});

final loadGuardianBankAccountUseCaseProvider = Provider<LoadGuardianBankAccountUseCase>((ref) {
  final repository = ref.watch(guardianBankAccountRepositoryProvider);
  return LoadGuardianBankAccountUseCase(repository);
});

final saveGuardianBankAccountUseCaseProvider = Provider<SaveGuardianBankAccountUseCase>((ref) {
  final repository = ref.watch(guardianBankAccountRepositoryProvider);
  return SaveGuardianBankAccountUseCase(repository);
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
// 🆕 CIVIL REGISTRY PROVIDERS - SAFE & LAZY
// ============================================================================

/// ✅ Check if civil registry database is available (async, safe)
final civilRegistryAvailableProvider = FutureProvider<bool>((ref) async {
  return await CivilRegistryDatabase.isAvailable();
});

/// ✅ Civil Registry Database Provider - SAFE, returns null if not available
final civilRegistryDatabaseAsyncProvider = FutureProvider<CivilRegistryDatabase?>((ref) async {
  final isAvailable = await CivilRegistryDatabase.isAvailable();
  if (!isAvailable) {
    return null; // Database not downloaded yet
  }
  return CivilRegistryDatabase.instance;
});

// Civil Registry Data Source - only works if database is available
final civilRegistryDataSourceProvider = FutureProvider<CivilRegistryLocalDataSource?>((ref) async {
  final civilDb = await ref.watch(civilRegistryDatabaseAsyncProvider.future);
  if (civilDb == null) return null;
  return CivilRegistryLocalDataSource(civilDb);
});

// Civil Registry Repository - nullable
final civilRegistryRepositoryProvider = FutureProvider<CivilRegistryRepository?>((ref) async {
  final dataSource = await ref.watch(civilRegistryDataSourceProvider.future);
  if (dataSource == null) return null;
  return CivilRegistryRepositoryImpl(dataSource);
});

// Civil Registry Use Cases - nullable
final fetchCivilRegistryDataUseCaseProvider = FutureProvider<FetchCivilRegistryDataUseCase?>((ref) async {
  final repository = await ref.watch(civilRegistryRepositoryProvider.future);
  if (repository == null) return null;
  return FetchCivilRegistryDataUseCase(repository);
});

final autofillFromCivilRegistryUseCaseProvider = Provider((ref) {
  return AutofillFromCivilRegistryUseCase();
});

// Civil Registry State Provider - safe, works even if database not available
final civilRegistryProvider = StateNotifierProvider<CivilRegistryNotifier, CivilRegistryState>((ref) {
  // Use null-safe approach - fetch use case may be null
  return CivilRegistryNotifier(
    fetchUseCaseProvider: fetchCivilRegistryDataUseCaseProvider,
    autofillUseCase: ref.watch(autofillFromCivilRegistryUseCaseProvider),
    ref: ref,
  );
});
