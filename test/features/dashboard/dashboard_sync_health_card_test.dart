import 'package:benaa_offline_app/features/dashboard/presentation/widgets/dashboard_sync_health_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildCard({
  required int pendingSync,
  required bool isOnline,
  DateTime? lastSyncTime,
  VoidCallback? onOpenSync,
}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (context, _) => MaterialApp(
      home: Scaffold(
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: DashboardSyncHealthCard(
              pendingSync: pendingSync,
              isOnline: isOnline,
              lastSyncTime: lastSyncTime,
              onOpenSync: onOpenSync ?? () {},
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('DashboardSyncHealthCard', () {
    testWidgets('renders all-synced state when online and pending=0', (tester) async {
      await tester.pumpWidget(_buildCard(pendingSync: 0, isOnline: true));
      await tester.pumpAndSettle();
      expect(find.textContaining('تم تزامن جميع البيانات'), findsOneWidget);
    });

    testWidgets('renders pending state with count', (tester) async {
      await tester.pumpWidget(_buildCard(pendingSync: 7, isOnline: true));
      await tester.pumpAndSettle();
      expect(find.textContaining('7 سجل'), findsOneWidget);
    });

    testWidgets('renders offline state when not connected', (tester) async {
      await tester.pumpWidget(_buildCard(pendingSync: 0, isOnline: false));
      await tester.pumpAndSettle();
      expect(find.textContaining('وضع عدم الاتصال'), findsOneWidget);
    });

    testWidgets('"فتح مركز المزامنة" button callback fires', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _buildCard(pendingSync: 0, isOnline: true, onOpenSync: () => tapped = true),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('sync_health_open_sync')));
      expect(tapped, isTrue);
    });

    testWidgets('shows last sync as "غير متوفر" when lastSyncTime is null', (tester) async {
      await tester.pumpWidget(_buildCard(pendingSync: 0, isOnline: true));
      await tester.pumpAndSettle();
      expect(find.textContaining('غير متوفر'), findsOneWidget);
    });
  });
}
