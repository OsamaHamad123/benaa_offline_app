import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:benaa_offline_app/features/kafalat/presentation/widgets/empty_states/empty_states.dart';

void main() {
  group('EmptySponsorshipsState Tests', () {
    testWidgets('should show "no sponsorships" message when no filters', (tester) async {
      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: const MaterialApp(
            home: Scaffold(
              body: EmptySponsorshipsState(hasFilters: false),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('لا توجد كفالات بعد'), findsOneWidget);
      expect(find.textContaining('ابدأ بإضافة كفالة جديدة'), findsOneWidget);
      expect(find.byIcon(Icons.handshake_outlined), findsOneWidget);
    });

    testWidgets('should show "no results" message when filters active', (tester) async {
      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: const MaterialApp(
            home: Scaffold(
              body: EmptySponsorshipsState(hasFilters: true),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('لا توجد نتائج'), findsOneWidget);
      expect(find.textContaining('لا توجد كفالات مطابقة'), findsOneWidget);
      expect(find.byIcon(Icons.filter_alt_off), findsOneWidget);
    });

    testWidgets('should show clear filters button when filters active', (tester) async {
      // Arrange
      var cleared = false;

      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: MaterialApp(
            home: Scaffold(
              body: EmptySponsorshipsState(
                hasFilters: true,
                onClearFilters: () => cleared = true,
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('مسح الفلاتر'), findsOneWidget);

      await tester.tap(find.text('مسح الفلاتر'));
      expect(cleared, isTrue);
    });

    testWidgets('should not show clear button when no filters', (tester) async {
      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: const MaterialApp(
            home: Scaffold(
              body: EmptySponsorshipsState(hasFilters: false),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('مسح الفلاتر'), findsNothing);
    });
  });

  group('EmptyBeneficiariesState Tests', () {
    testWidgets('should show "no beneficiaries" message', (tester) async {
      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: const MaterialApp(
            home: Scaffold(
              body: EmptyBeneficiariesState(),
            ),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('جميع المستفيدين مكفولون'), findsOneWidget);
      expect(find.textContaining('جميع المستفيدين لديهم كفالات نشطة'), findsOneWidget);
      expect(find.text('إضافة مستفيد جديد'), findsOneWidget);
    });
  });
}
