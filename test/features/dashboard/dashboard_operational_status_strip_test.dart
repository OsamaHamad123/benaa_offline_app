import 'package:benaa_offline_app/features/dashboard/presentation/widgets/dashboard_operational_status_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildStrip(
  DashboardOperationalStatus status, {
  VoidCallback? onTap,
  TextDirection textDirection = TextDirection.rtl,
  double textScaleFactor = 1.0,
}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (context, _) => MaterialApp(
      home: Scaffold(
        body: Directionality(
          textDirection: textDirection,
          child: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(textScaleFactor)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DashboardOperationalStatusStrip(
                status: status,
                onTap: onTap,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('DashboardOperationalStatusStrip — widget rendering', () {
    testWidgets('renders normal/synced state without overflow', (tester) async {
      final status = DashboardOperationalStatus.resolve(
        isOnline: true,
        pendingSync: 0,
        lastSyncTime: DateTime.now().subtract(const Duration(minutes: 10)),
      );
      await tester.pumpWidget(_buildStrip(status));
      await tester.pumpAndSettle();

      expect(find.text(status.title), findsOneWidget);
      expect(find.text(status.message), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders pending uploads state', (tester) async {
      final status = DashboardOperationalStatus.resolve(
        isOnline: true,
        pendingSync: 5,
      );
      await tester.pumpWidget(_buildStrip(status));
      await tester.pumpAndSettle();

      expect(find.text(status.title), findsOneWidget);
      expect(find.text(status.message), findsOneWidget);
    });

    testWidgets('renders offline state', (tester) async {
      final status = DashboardOperationalStatus.resolve(
        isOnline: false,
        pendingSync: 0,
      );
      await tester.pumpWidget(_buildStrip(status));
      await tester.pumpAndSettle();

      expect(find.text(status.title), findsOneWidget);
      expect(find.text(status.message), findsOneWidget);
    });

    testWidgets('renders failed state', (tester) async {
      final status = DashboardOperationalStatus.resolve(
        isOnline: false,
        pendingSync: 0,
        hasSyncFailure: true,
      );
      await tester.pumpWidget(_buildStrip(status));
      await tester.pumpAndSettle();

      expect(find.text(status.title), findsOneWidget);
      expect(find.text(status.message), findsOneWidget);
    });

    testWidgets('tap callback is called on tap', (tester) async {
      var tapped = false;
      final status = DashboardOperationalStatus.resolve(
        isOnline: true,
        pendingSync: 3,
      );
      await tester.pumpWidget(_buildStrip(status, onTap: () => tapped = true));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DashboardOperationalStatusStrip));
      expect(tapped, isTrue);
    });

    testWidgets('text scale 1.5 does not overflow', (tester) async {
      final status = DashboardOperationalStatus.resolve(
        isOnline: false,
        pendingSync: 99,
      );
      await tester.pumpWidget(_buildStrip(status, textScaleFactor: 1.5));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('RTL renders without overflow', (tester) async {
      final status = DashboardOperationalStatus.resolve(
        isOnline: true,
        pendingSync: 0,
      );
      await tester.pumpWidget(
        _buildStrip(status, textDirection: TextDirection.rtl),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(DashboardOperationalStatusStrip), findsOneWidget);
    });

    testWidgets('LTR renders without overflow', (tester) async {
      final status = DashboardOperationalStatus.resolve(
        isOnline: true,
        pendingSync: 0,
      );
      await tester.pumpWidget(
        _buildStrip(status, textDirection: TextDirection.ltr),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('widget includes Semantics for accessibility', (tester) async {
      final status = DashboardOperationalStatus.resolve(
        isOnline: false,
        pendingSync: 2,
      );
      await tester.pumpWidget(_buildStrip(status));
      await tester.pumpAndSettle();

      final semantics = tester.getSemantics(
        find.byType(DashboardOperationalStatusStrip),
      );
      expect(semantics.label, contains(status.title));
      expect(semantics.label, contains(status.message));
    });
  });
}
