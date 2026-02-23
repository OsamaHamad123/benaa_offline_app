import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/dashboard/domain/entities/dashboard_statistics.dart';

void main() {
  group('Dashboard Statistics Entity Tests', () {
    test('DashboardStatistics creates correctly', () {
      // Arrange & Act
      const stats = DashboardStatistics(
        totalBeneficiaries: 100,
        activeBeneficiaries: 80,
        pendingSync: 5,
        completedVisitsToday: 10,
        growthData: [],
        categoryCounts: {'orphan': 20, 'widow': 15},
        todayStats: TodayStats(
          newBeneficiaries: 3,
          completedVisits: 10,
          pendingTasks: 2,
          syncedRecords: 8,
        ),
      );

      // Assert
      expect(stats.totalBeneficiaries, 100);
      expect(stats.activeBeneficiaries, 80);
      expect(stats.pendingSync, 5);
      expect(stats.completedVisitsToday, 10);
      expect(stats.categoryCounts['orphan'], 20);
      expect(stats.categoryCounts['widow'], 15);
      expect(stats.todayStats.newBeneficiaries, 3);
    });

    test('DashboardStatistics equality works correctly', () {
      // Arrange
      const stats1 = DashboardStatistics(
        totalBeneficiaries: 100,
        activeBeneficiaries: 80,
        pendingSync: 5,
        completedVisitsToday: 10,
        growthData: [],
        categoryCounts: {'orphan': 20},
        todayStats: TodayStats(
          newBeneficiaries: 3,
          completedVisits: 10,
          pendingTasks: 2,
          syncedRecords: 8,
        ),
      );

      const stats2 = DashboardStatistics(
        totalBeneficiaries: 100,
        activeBeneficiaries: 80,
        pendingSync: 5,
        completedVisitsToday: 10,
        growthData: [],
        categoryCounts: {'orphan': 20},
        todayStats: TodayStats(
          newBeneficiaries: 3,
          completedVisits: 10,
          pendingTasks: 2,
          syncedRecords: 8,
        ),
      );

      // Assert
      expect(stats1, equals(stats2), reason: 'Equatable should work');
    });

    test('GrowthDataPoint creates correctly', () {
      // Arrange & Act
      final dataPoint = GrowthDataPoint(date: DateTime(2025), count: 50);

      // Assert
      expect(dataPoint.date, DateTime(2025));
      expect(dataPoint.count, 50);
    });

    test('GrowthDataPoint equality works', () {
      // Arrange
      final point1 = GrowthDataPoint(date: DateTime(2025), count: 50);
      final point2 = GrowthDataPoint(date: DateTime(2025), count: 50);

      // Assert
      expect(point1, equals(point2));
    });

    test('TodayStats creates correctly', () {
      // Arrange & Act
      const todayStats = TodayStats(
        newBeneficiaries: 5,
        completedVisits: 12,
        pendingTasks: 3,
        syncedRecords: 10,
      );

      // Assert
      expect(todayStats.newBeneficiaries, 5);
      expect(todayStats.completedVisits, 12);
      expect(todayStats.pendingTasks, 3);
      expect(todayStats.syncedRecords, 10);
    });

    test('DashboardStatistics calculates active percentage correctly', () {
      // Arrange
      const stats = DashboardStatistics(
        totalBeneficiaries: 100,
        activeBeneficiaries: 75,
        pendingSync: 5,
        completedVisitsToday: 10,
        growthData: [],
        categoryCounts: {},
        todayStats: TodayStats(
          newBeneficiaries: 3,
          completedVisits: 10,
          pendingTasks: 2,
          syncedRecords: 8,
        ),
      );
      // Act
      final activePercentage =
          stats.activeBeneficiaries / stats.totalBeneficiaries * 100;

      // Assert
      expect(activePercentage, 75.0);
    });

    test('CategoryCounts totals correctly', () {
      // Arrange
      final categoryCounts = {
        'orphan': 20,
        'widow': 15,
        'poor': 30,
        'disabled': 10,
      };

      // Act
      final total = categoryCounts.values.fold(0, (a, b) => a + b);

      // Assert
      expect(total, 75);
    });

    test('GrowthData trend calculation', () {
      // Arrange
      final growthData = [
        GrowthDataPoint(date: DateTime(2025), count: 10),
        GrowthDataPoint(date: DateTime(2025, 1, 2), count: 15),
        GrowthDataPoint(date: DateTime(2025, 1, 3), count: 20),
        GrowthDataPoint(date: DateTime(2025, 1, 4), count: 25),
      ];

      // Act
      final isGrowing = growthData.last.count > growthData.first.count;
      final growthAmount = growthData.last.count - growthData.first.count;
      final growthPercentage = growthAmount / growthData.first.count * 100;

      // Assert
      expect(isGrowing, true);
      expect(growthAmount, 15);
      expect(growthPercentage, 150.0);
    });
  });
}
