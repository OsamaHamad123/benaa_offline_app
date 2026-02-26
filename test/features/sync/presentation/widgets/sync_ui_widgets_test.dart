import 'package:benaa_offline_app/features/sync/presentation/widgets/sync_section_card.dart';
import 'package:benaa_offline_app/features/sync/presentation/widgets/sync_status_banner.dart';
import 'package:benaa_offline_app/features/sync/presentation/widgets/sync_ui_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Sync UI Widgets', () {
    testWidgets('SyncSectionCard renders in light theme', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          minTextAdapt: true,
          child: MaterialApp(
            theme: ThemeData.light(),
            home: const Scaffold(
              body: SyncSectionCard(
                title: 'معلومات الاتصال',
                icon: Icons.info,
                tone: SyncTone.surface,
                child:  Text('content'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('معلومات الاتصال'), findsOneWidget);
      expect(find.text('content'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('SyncSectionCard renders in dark theme', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          minTextAdapt: true,
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: SyncSectionCard(
                title: 'تشخيص',
                icon: Icons.bug_report_outlined,
                tone: SyncTone.secondary,
                child: const Text('dark content'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('تشخيص'), findsOneWidget);
      expect(find.text('dark content'), findsOneWidget);
    });

    testWidgets('SyncStatusBanner renders in light and dark themes', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          minTextAdapt: true,
          child: MaterialApp(
            theme: ThemeData.light(),
            home: const Scaffold(
              body: SyncStatusBanner(
                message: 'جاري مزامنة التصنيفات',
                tone: SyncTone.primary,
                icon: Icons.sync,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('جاري مزامنة التصنيفات'), findsOneWidget);

      await tester.pumpWidget(
        ScreenUtilInit(
          minTextAdapt: true,
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const Scaffold(
              body: SyncStatusBanner(
                message: 'جاري مزامنة التصنيفات',
                tone: SyncTone.primary,
                icon: Icons.sync,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('جاري مزامنة التصنيفات'), findsOneWidget);
    });
  });
}
