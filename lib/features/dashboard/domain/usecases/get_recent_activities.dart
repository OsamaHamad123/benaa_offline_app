import '../entities/activity.dart';
import '../repositories/dashboard_repository.dart';

/// Use Case: Get Recent Activities
/// Supports pagination for performance
class GetRecentActivities {
  final DashboardRepository repository;

  GetRecentActivities(this.repository);

  Future<List<Activity>> call({int limit = 10, int offset = 0}) async {
    return await repository.getRecentActivities(limit: limit, offset: offset);
  }
}
