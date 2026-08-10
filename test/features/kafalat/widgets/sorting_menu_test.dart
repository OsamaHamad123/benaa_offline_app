import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:benaa_offline_app/features/kafalat/presentation/widgets/filters/sorting_menu.dart';

void main() {
  group('SortingMenu Tests', () {
    testWidgets('should display sort icon button', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SortingMenu(
              currentSort: SortOption.dateNewest,
              onSortChanged: (_) {},
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
        MaterialApp(
          home: Scaffold(
            body: SortingMenu(
              currentSort: SortOption.dateNewest,
              onSortChanged: (_) {},
            ),
          ),
        ),
      );

      // Tap the sort button
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Assert - should show all 8 sort options
      expect(find.text('📅 التاريخ: الأحدث أولاً'), findsOneWidget);
      expect(find.text('📅 التاريخ: الأقدم أولاً'), findsOneWidget);
      expect(find.text('💰 المبلغ: الأعلى أولاً'), findsOneWidget);
      expect(find.text('💰 المبلغ: الأقل أولاً'), findsOneWidget);
      expect(find.text('👤 الاسم: أ - ي'), findsOneWidget);
      expect(find.text('👤 الاسم: ي - أ'), findsOneWidget);
      expect(find.text('📄 رقم الملف: تصاعدي'), findsOneWidget);
      expect(find.text('📄 رقم الملف: تنازلي'), findsOneWidget);
    });

    testWidgets('should mark current sort option with checkmark', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SortingMenu(
              currentSort: SortOption.nameAZ,
              onSortChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Assert - should show checkmark next to current option
      final nameAZItem = find.ancestor(
        of: find.text('👤 الاسم: أ - ي'),
        matching: find.byType(PopupMenuItem<SortOption>),
      );

      expect(nameAZItem, findsOneWidget);
    });

    testWidgets('should call onSortChanged when option selected', (tester) async {
      // Arrange
      SortOption? selectedSort;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SortingMenu(
              currentSort: SortOption.dateNewest,
              onSortChanged: (sort) => selectedSort = sort,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('💰 المبلغ: الأعلى أولاً'));
      await tester.pumpAndSettle();

      // Assert
      expect(selectedSort, SortOption.amountHighest);
    });

    testWidgets('should close menu after selection', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SortingMenu(
              currentSort: SortOption.dateNewest,
              onSortChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('📅 التاريخ: الأقدم أولاً'));
      await tester.pumpAndSettle();

      // Assert - menu should be closed
      expect(find.text('📅 التاريخ: الأقدم أولاً'), findsNothing);
    });

    testWidgets('all sort options should be selectable', (tester) async {
      for (final option in SortOption.values) {
        SortOption? selectedSort;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SortingMenu(
                currentSort: SortOption.dateNewest,
                onSortChanged: (sort) => selectedSort = sort,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        // Find and tap the option
        final optionText = _getSortOptionText(option);
        await tester.tap(find.text(optionText));
        await tester.pumpAndSettle();

        expect(selectedSort, option);

        // Clean up for next iteration
        await tester.pumpWidget(Container());
      }
    });
  });
}

String _getSortOptionText(SortOption option) {
  switch (option) {
    case SortOption.dateNewest:
      return '📅 التاريخ: الأحدث أولاً';
    case SortOption.dateOldest:
      return '📅 التاريخ: الأقدم أولاً';
    case SortOption.amountHighest:
      return '💰 المبلغ: الأعلى أولاً';
    case SortOption.amountLowest:
      return '💰 المبلغ: الأقل أولاً';
    case SortOption.nameAZ:
      return '👤 الاسم: أ - ي';
    case SortOption.nameZA:
      return '👤 الاسم: ي - أ';
    case SortOption.fileNoAsc:
      return '📄 رقم الملف: تصاعدي';
    case SortOption.fileNoDesc:
      return '📄 رقم الملف: تنازلي';
  }
}
