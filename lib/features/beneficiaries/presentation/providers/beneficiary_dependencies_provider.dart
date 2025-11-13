import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/providers.dart';
import '../../data/datasources/beneficiary_local_datasource.dart';
import '../../data/repositories/beneficiary_repository_impl.dart';
import '../../domain/repositories/beneficiary_repository.dart';
import '../../domain/usecases/beneficiary_usecases.dart';

/// 🏗️ Dependencies Provider - Injects all dependencies
class BeneficiaryDependencies {
  final BeneficiaryRepository repository;
  final CreateBeneficiaryUseCase createUseCase;
  final UpdateBeneficiaryUseCase updateUseCase;
  final GetBeneficiaryUseCase getUseCase;
  final DeleteBeneficiaryUseCase deleteUseCase;
  final ListBeneficiariesUseCase listUseCase;
  final GetBeneficiaryStatisticsUseCase statsUseCase;
  final LoadFromCivilRegistryUseCase loadFromCivilRegistryUseCase;

  BeneficiaryDependencies({
    required this.repository,
    required this.createUseCase,
    required this.updateUseCase,
    required this.getUseCase,
    required this.deleteUseCase,
    required this.listUseCase,
    required this.statsUseCase,
    required this.loadFromCivilRegistryUseCase,
  });
}

/// Provider that creates and manages all beneficiary dependencies
final beneficiaryDependenciesProvider = Provider<BeneficiaryDependencies>((
  ref,
) {
  final database = ref.watch(databaseProvider);

  // Data Layer
  final dataSource = BeneficiaryLocalDataSource(database);
  final repository = BeneficiaryRepositoryImpl(dataSource);

  // Use Cases
  final createUseCase = CreateBeneficiaryUseCase(repository);
  final updateUseCase = UpdateBeneficiaryUseCase(repository);
  final getUseCase = GetBeneficiaryUseCase(repository);
  final deleteUseCase = DeleteBeneficiaryUseCase(repository);
  final listUseCase = ListBeneficiariesUseCase(repository);
  final statsUseCase = GetBeneficiaryStatisticsUseCase(repository);
  final loadFromCivilRegistryUseCase = LoadFromCivilRegistryUseCase(repository);

  return BeneficiaryDependencies(
    repository: repository,
    createUseCase: createUseCase,
    updateUseCase: updateUseCase,
    getUseCase: getUseCase,
    deleteUseCase: deleteUseCase,
    listUseCase: listUseCase,
    statsUseCase: statsUseCase,
    loadFromCivilRegistryUseCase: loadFromCivilRegistryUseCase,
  );
});
