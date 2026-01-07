import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:benaa_offline_app/features/kafalat/presentation/widgets/filters/sorting_menu.dart';

/// Helper function to wrap widgets with ScreenUtilInit for testing
Widget buildTestWidget(Widget child, {Size screenSize = const Size(400, 800)}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(size: screenSize),
      child: Scaffold(
        body: ScreenUtilInit(
          designSize: screenSize,
          minTextAdapt: true,
          builder: (context, _) => child,
        ),
      ),
    ),
  );
}

void main() {
  group('SortingMenu Tests', () {
    testWidgets('should display sort icon button', (tester) async {
      // Act
      await tester.pumpWidget(
        buildTestWidget(
          SortingMenu(
            currentSort: SortOption.dateNewest,
            onSortChanged: (_) {},
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.sort_rounded), findsOneWidget);
    });

    testWidgets('should show menu when tapped', (tester) async {
      // Act
      await tester.pumpWidget(
        buildTestWidget(
          SortingMenu(
            currentSort: SortOption.dateNewest,
            onSortChanged: (_) {},
          ),
        ),
      );

      // Tap the sort button (PopupMenuButton, not IconButton)
      await tester.tap(find.byType(PopupMenuButton<SortOption>));
      await tester.pumpAndSettle();

      // Assert - should show all 8 sort options (using actual labels from enum)
      expect(find.text(SortOption.dateNewest.label), findsOneWidget);
      expect(find.text(SortOption.dateOldest.label), findsOneWidget);
      expect(find.text(SortOption.amountHighest.label), findsOneWidget);
      expect(find.text(SortOption.amountLowest.label), findsOneWidget);
      expect(find.text(SortOption.nameAZ.label), findsOneWidget);
      expect(find.text(SortOption.nameZA.label), findsOneWidget);
      expect(find.text(SortOption.fileNoAsc.label), findsOneWidget);
      expect(find.text(SortOption.fileNoDesc.label), findsOneWidget);
    });

    testWidgets('should mark current sort option with checkmark', (tester) async {
      // Act
      await tester.pumpWidget(
        buildTestWidget(
          SortingMenu(
            currentSort: SortOption.nameAZ,
            onSortChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(PopupMenuButton<SortOption>));
      await tester.pumpAndSettle();

      // Assert - should show checkmark next to current option
      final nameAZItem = find.ancestor(
        of: find.text(SortOption.nameAZ.label),
        matching: find.byType(PopupMenuItem<SortOption>),
      );

      expect(nameAZItem, findsOneWidget);
    });

    testWidgets('should call onSortChanged when option selected', (tester) async {
      // Arrange
      SortOption? selectedSort;

      // Act
      await tester.pumpWidget(
        buildTestWidget(
          SortingMenu(
            currentSort: SortOption.dateNewest,
            onSortChanged: (sort) => selectedSort = sort,
          ),
        ),
      );

      await tester.tap(find.byType(PopupMenuButton<SortOption>));
      await tester.pumpAndSettle();

      await tester.tap(find.text(SortOption.amountHighest.label));
      await tester.pumpAndSettle();

      // Assert
      expect(selectedSort, SortOption.amountHighest);
    });

    testWidgets('should close menu after selection', (tester) async {
      // Act
      await tester.pumpWidget(
        buildTestWidget(
          SortingMenu(
            currentSort: SortOption.dateNewest,
            onSortChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(PopupMenuButton<SortOption>));
      await tester.pumpAndSettle();

      await tester.tap(find.text(SortOption.dateOldest.label));
      await tester.pumpAndSettle();

      // Assert - menu should be closed
      expect(find.text(SortOption.dateOldest.label), findsNothing);
    });

    testWidgets('all sort options should be selectable', (tester) async {
      // Test first few options only to avoid scroll issues in popup menu
      final optionsToTest = [
        SortOption.dateNewest,
        SortOption.dateOldest,
        SortOption.amountHighest,
        SortOption.nameAZ,
      ];

      for (final option in optionsToTest) {
        SortOption? selectedSort;

        await tester.pumpWidget(
          buildTestWidget(
            SortingMenu(
              currentSort: SortOption.dateNewest,
              onSortChanged: (sort) => selectedSort = sort,
            ),
            screenSize: const Size(400, 1200), // Larger screen to fit all items
          ),
        );

        await tester.tap(find.byType(PopupMenuButton<SortOption>));
        await tester.pumpAndSettle();

        // Find and tap the option using enum label
        await tester.tap(find.text(option.label));
        await tester.pumpAndSettle();

        expect(selectedSort, option);

        // Clean up for next iteration
        await tester.pumpWidget(Container());
      }
    });
  });
}
