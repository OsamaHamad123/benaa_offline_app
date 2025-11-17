import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/list_widgets/statistics_dashboard.dart';

/// 🧪 Widget Tests للـ Statistics Dashboard
void main() {
  testWidgets('StatisticsDashboard displays using provider data', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: StatisticsDashboard())),
      ),
    );

    // Widget should render (actual values from provider)
    expect(find.byType(StatisticsDashboard), findsOneWidget);
    expect(find.text('الإجمالي'), findsOneWidget);
    expect(find.text('المعروضة'), findsOneWidget);
    expect(find.text('قيد المزامنة'), findsOneWidget);
  });

  testWidgets('StatisticsDashboard has gradient background', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: StatisticsDashboard())),
      ),
    );

    final container = tester.widget<Container>(find.byType(Container).first);

    expect(container.decoration, isA<BoxDecoration>());
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.gradient, isA<LinearGradient>());
  });

  testWidgets('StatisticsDashboard contains stat icons', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: StatisticsDashboard())),
      ),
    );

    // Should have icons for stats
    expect(find.byIcon(Icons.people), findsOneWidget);
    expect(find.byIcon(Icons.filter_list), findsOneWidget);
    expect(find.byIcon(Icons.cloud_upload), findsOneWidget);
  });
}
