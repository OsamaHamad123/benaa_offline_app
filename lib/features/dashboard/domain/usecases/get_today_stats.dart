import '../entities/dashboard_statistics.dart';
import '../repositories/dashboard_repository.dart';
import '../../../../core/error_handling/result.dart';

/// Use Case: Get Today's Stats Only
/// Lighter operation for quick updates
class GetTodayStats {
  final DashboardRepository repository;

  GetTodayStats(this.repository);

  Future<Result<TodayStats>> call() async {
    return await repository.getTodayStats();
  }
}
