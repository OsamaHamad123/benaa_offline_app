import '../entities/dashboard_statistics.dart';
import '../repositories/dashboard_repository.dart';

/// Use Case: Get Dashboard Statistics
/// Single Responsibility: Fetch and return dashboard statistics
class GetDashboardStatistics {
  final DashboardRepository repository;

  GetDashboardStatistics(this.repository);

  /// Execute the use case
  Future<DashboardStatistics> call({bool forceRefresh = false}) async {
    return await repository.getStatistics(forceRefresh: forceRefresh);
  }

  /// Watch for real-time updates
  Stream<DashboardStatistics>? watch() {
    return repository.watchStatistics();
  }
}
