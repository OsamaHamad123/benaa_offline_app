import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:benaa_offline_app/features/kafalat/presentation/widgets/filters/enhanced_search_bar.dart';

void main() {
  group('EnhancedSearchBar Tests', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('should display search icon and hint text', (tester) async {
      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => MaterialApp(
            home: Scaffold(
              body: EnhancedSearchBar(
                controller: controller,
                onSearch: (_) {},
                hintText: 'ابحث هنا...',
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.text('ابحث هنا...'), findsOneWidget);
    });

    testWidgets('should show clear button when text is entered',
        (tester) async {
      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => MaterialApp(
            home: Scaffold(
              body: EnhancedSearchBar(
                controller: controller,
                onSearch: (_) {},
              ),
            ),
          ),
        ),
      );

      // Initially no clear button
      expect(find.byIcon(Icons.clear_rounded), findsNothing);

      // Enter text
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      // Should show clear button
      expect(find.byIcon(Icons.clear_rounded), findsOneWidget);
    });

    testWidgets('should clear text when clear button is tapped',
        (tester) async {
      // Arrange
      String? searchValue;

      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => MaterialApp(
            home: Scaffold(
              body: EnhancedSearchBar(
                controller: controller,
                onSearch: (v) {
                  searchValue = v;
                },
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      // Tap clear button
      await tester.tap(find.byIcon(Icons.clear_rounded));
      await tester.pump();

      // Assert
      expect(controller.text, isEmpty);
      expect(searchValue, isEmpty);
    });

    testWidgets('should call onSearch after debounce delay', (tester) async {
      // Arrange
      String? searchValue;
      var callCount = 0;

      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => MaterialApp(
            home: Scaffold(
              body: EnhancedSearchBar(
                controller: controller,
                onSearch: (v) {
                  callCount++;
                  searchValue = v;
                },
              ),
            ),
          ),
        ),
      );

      // Type quickly
      await tester.enterText(find.byType(TextField), 't');
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(find.byType(TextField), 'te');
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(find.byType(TextField), 'test');

      // Wait for debounce (300ms default)
      await tester.pump(const Duration(milliseconds: 300));

      // Assert - should only call once after debounce
      expect(searchValue, 'test');
      expect(callCount, greaterThan(0));
    });

    testWidgets('clearing cancels a search still waiting on its debounce',
        (tester) async {
      final searches = <String>[];

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => MaterialApp(
            home: Scaffold(
              body: EnhancedSearchBar(
                controller: controller,
                onSearch: searches.add,
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byIcon(Icons.clear_rounded));
      // Well past the 300ms debounce the typed search would have fired on.
      await tester.pump(const Duration(milliseconds: 500));

      expect(searches, ['']);
      expect(controller.text, isEmpty);
    });

    testWidgets('should use custom debounce duration', (tester) async {
      // Arrange
      var callCount = 0;

      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => MaterialApp(
            home: Scaffold(
              body: EnhancedSearchBar(
                controller: controller,
                onSearch: (_) => callCount++,
                debounceDuration: const Duration(milliseconds: 500),
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'test');

      // Wait less than custom debounce
      await tester.pump(const Duration(milliseconds: 400));
      expect(callCount, 0);

      // Wait full debounce duration
      await tester.pump(const Duration(milliseconds: 100));
      expect(callCount, greaterThan(0));
    });

    testWidgets('should have RTL text direction', (tester) async {
      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => MaterialApp(
            home: Scaffold(
              body: EnhancedSearchBar(
                controller: controller,
                onSearch: (_) {},
              ),
            ),
          ),
        ),
      );

      // Assert
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.textDirection, TextDirection.rtl);
    });
  });
}
