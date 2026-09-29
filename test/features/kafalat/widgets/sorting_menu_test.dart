import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:benaa_offline_app/features/kafalat/presentation/widgets/filters/sorting_menu.dart';

void main() {
  group('SortingMenu Tests', () {
    testWidgets('should display sort icon button', (tester) async {
      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => MaterialApp(
            home: Scaffold(
              body: SortingMenu(
                currentSort: SortOption.dateNewest,
                onSortChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.sort_rounded), findsOneWidget);
    });

    testWidgets('should show menu when tapped', (tester) async {
      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => MaterialApp(
            home: Scaffold(
              body: SortingMenu(
                currentSort: SortOption.dateNewest,
                onSortChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      // Tap the sort button
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Assert - should show all 8 sort options
      expect(SortOption.values, hasLength(8));
      for (final option in SortOption.values) {
        expect(find.text(option.label), findsOneWidget);
      }
    });

    testWidgets('should mark current sort option with checkmark',
        (tester) async {
      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => MaterialApp(
            home: Scaffold(
              body: SortingMenu(
                currentSort: SortOption.nameAZ,
                onSortChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Assert - should show checkmark next to current option
      final nameAZItem = find.ancestor(
        of: find.text(SortOption.nameAZ.label),
        matching: find.byType(PopupMenuItem<SortOption>),
      );

      expect(nameAZItem, findsOneWidget);
      expect(
        find.descendant(
          of: nameAZItem,
          matching: find.byIcon(Icons.check_rounded),
        ),
        findsOneWidget,
      );
      // ...and only next to the current option.
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('should call onSortChanged when option selected',
        (tester) async {
      // Arrange
      SortOption? selectedSort;

      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => MaterialApp(
            home: Scaffold(
              body: SortingMenu(
                currentSort: SortOption.dateNewest,
                onSortChanged: (sort) => selectedSort = sort,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text(SortOption.amountHighest.label));
      await tester.pumpAndSettle();

      // Assert
      expect(selectedSort, SortOption.amountHighest);
    });

    testWidgets('should close menu after selection', (tester) async {
      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => MaterialApp(
            home: Scaffold(
              body: SortingMenu(
                currentSort: SortOption.dateNewest,
                onSortChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text(SortOption.dateOldest.label));
      await tester.pumpAndSettle();

      // Assert - menu should be closed
      expect(find.text(SortOption.dateOldest.label), findsNothing);
    });

    testWidgets('all sort options should be selectable', (tester) async {
      for (final option in SortOption.values) {
        SortOption? selectedSort;

        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(390, 844),
            builder: (_, __) => MaterialApp(
              home: Scaffold(
                body: SortingMenu(
                  currentSort: SortOption.dateNewest,
                  onSortChanged: (sort) => selectedSort = sort,
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        // Find and tap the option (the menu scrolls when it is taller than
        // the screen, so bring the option into view first, as a user would)
        await tester.ensureVisible(find.text(option.label));
        await tester.pumpAndSettle();
        await tester.tap(find.text(option.label));
        await tester.pumpAndSettle();

        expect(selectedSort, option);

        // Clean up for next iteration
        await tester.pumpWidget(ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => Container(),
        ));
      }
    });
  });
}
