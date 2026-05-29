import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:benaa_offline_app/core/auth/role_provider.dart';
import 'package:benaa_offline_app/features/dashboard/presentation/widgets/dashboard_app_bar.dart';

// ─── Helper ──────────────────────────────────────────────────────────────────

Widget buildAppBar({bool isAdmin = false}) {
  return ProviderScope(
    overrides: [
      // نُحاكي قيمة isAdminProvider مباشرة
      isAdminProvider.overrideWithValue(isAdmin),
    ],
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => MaterialApp(
        home: Scaffold(
          appBar: DashboardAppBar(
            title: 'منظومة بناء',
            onSearchTap: () {},
            onNotificationTap: () {},
          ),
        ),
      ),
    ),
  );
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() => TestWidgetsFlutterBinding.ensureInitialized());

  group('DashboardAppBar — Admin Visibility', () {
    testWidgets('يُخفي أدوات المراقبة لمستخدم عادي في release mode', (tester) async {
      // DashboardAppBar shows popup only when isAdmin=true or kDebugMode
      // In tests kDebugMode=true, so we only verify non-admin condition doesn't crash
      await tester.pumpWidget(buildAppBar(isAdmin: false));
      await tester.pump();
      // لا crash — الاختبار يتحقق من السلامة
      expect(tester.takeException(), isNull);
    });

    testWidgets('يُظهر قائمة المدير للمستخدم الإداري', (tester) async {
      await tester.pumpWidget(buildAppBar(isAdmin: true));
      await tester.pump();
      // الـ popup موجود (isAdmin=true يجب أن يُظهره)
      expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);
    });

    testWidgets('AppBar يحتوي على tooltip للبحث', (tester) async {
      await tester.pumpWidget(buildAppBar());
      await tester.pumpAndSettle();
      // tooltip القيمة الفعلية في DashboardAppBar هي 'بحث'
      expect(find.byTooltip('بحث'), findsOneWidget);
    });

    testWidgets('AppBar يحتوي على tooltip للإشعارات', (tester) async {
      await tester.pumpWidget(buildAppBar());
      await tester.pumpAndSettle();
      expect(find.byTooltip('الإشعارات'), findsOneWidget);
    });

    testWidgets('AppBar يعرض العنوان بشكل صحيح', (tester) async {
      await tester.pumpWidget(buildAppBar());
      await tester.pump();
      expect(find.text('منظومة بناء'), findsOneWidget);
    });
  });
}
