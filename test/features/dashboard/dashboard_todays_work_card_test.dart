import 'package:benaa_offline_app/features/dashboard/domain/entities/dashboard_statistics.dart';
import 'package:benaa_offline_app/features/dashboard/presentation/widgets/dashboard_todays_work_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildCard(
  TodayStats stats, {
  VoidCallback? onViewVisits,
  VoidCallback? onAddVisit,
  VoidCallback? onViewUrgent,
}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (context, _) => MaterialApp(
      home: Scaffold(
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: DashboardTodaysWorkCard(
              todayStats: stats,
              onViewVisits: onViewVisits ?? () {},
              onAddVisit: onAddVisit,
              onViewUrgent: onViewUrgent,
            ),
          ),
        ),
      ),
    ),
  );
}

const _emptyStats = TodayStats(
  newBeneficiaries: 0,
  completedVisits: 0,
  pendingTasks: 0,
  syncedRecords: 0,
);

const _activeStats = TodayStats(
  newBeneficiaries: 2,
  completedVisits: 5,
  pendingTasks: 3,
  syncedRecords: 10,
);

void main() {
  group('DashboardTodaysWorkCard', () {
    testWidgets('renders card title', (tester) async {
      await tester.pumpWidget(_buildCard(_emptyStats));
      await tester.pumpAndSettle();
      expect(find.text('عمل اليوم'), findsOneWidget);
    });

    testWidgets('renders empty state when no visits and no pending tasks', (tester) async {
      await tester.pumpWidget(_buildCard(_emptyStats));
      await tester.pumpAndSettle();
      expect(find.textContaining('لا توجد زيارات'), findsOneWidget);
    });

    testWidgets('renders visit count when completedVisits > 0', (tester) async {
      await tester.pumpWidget(_buildCard(_activeStats));
      await tester.pumpAndSettle();
      expect(find.textContaining('5 زيارة'), findsOneWidget);
    });

    testWidgets('renders pending tasks count', (tester) async {
      await tester.pumpWidget(_buildCard(_activeStats));
      await tester.pumpAndSettle();
      expect(find.textContaining('3 حالة'), findsOneWidget);
    });

    testWidgets('"عرض الكل" callback fires on tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_buildCard(_emptyStats, onViewVisits: () => tapped = true));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('todays_work_view_all')));
      expect(tapped, isTrue);
    });
  });
}
