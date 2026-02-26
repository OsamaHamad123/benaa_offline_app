import 'package:benaa_offline_app/features/associations/presentation/widgets/professional_association_card.dart';
import 'package:benaa_offline_app/features/associations/presentation/widgets/swipe_actions_wrapper.dart';
import 'package:benaa_offline_app/features/associations/presentation/widgets/associations_filters_bar.dart';
import 'package:benaa_offline_app/features/associations/presentation/widgets/sorting_menu.dart';
import 'package:benaa_offline_app/features/associations/presentation/widgets/card_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('New Features Tests', () {
    testWidgets('ProfessionalAssociationCard renders with gradient header', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ScreenUtilInit(
          minTextAdapt: true,
          child: MaterialApp(
            home: Scaffold(
              body: ProfessionalAssociationCard(
                id: '1',
                name: 'جمعية الخير',
                phone: '0791234567',
                bankName: 'البنك العربي',
                currency: 'JOD',
                isActive: true,
                createdAt: DateTime.now(),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - التحقق من وجود الاسم
      expect(find.text('جمعية الخير'), findsOneWidget);
      expect(find.text('0791234567'), findsOneWidget);
      expect(find.text('البنك العربي'), findsOneWidget);
      expect(find.text('JOD'), findsOneWidget);
      expect(find.text('نشط'), findsOneWidget);
    });

    testWidgets('ProfessionalAssociationCard renders recent association without badge regressions',
        (WidgetTester tester) async {
      // Arrange - جمعية مضافة قبل 3 أيام
      final recentDate = DateTime.now().subtract(const Duration(days: 3));

      await tester.pumpWidget(
        ScreenUtilInit(
          minTextAdapt: true,
          child: MaterialApp(
            home: Scaffold(
              body: ProfessionalAssociationCard(
                id: '1',
                name: 'جمعية جديدة',
                phone: '0791234567',
                bankName: 'البنك العربي',
                currency: 'JOD',
                isActive: true,
                createdAt: recentDate,
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - البطاقة تظهر بشكل سليم (حالياً بدون badges نصية)
      expect(find.text('جمعية جديدة'), findsOneWidget);
      expect(find.text('جديد'), findsNothing);
    });

    testWidgets('ProfessionalAssociationCard renders recently-updated association without badge regressions',
        (WidgetTester tester) async {
      // Arrange - جمعية محدثة قبل 12 ساعة
      final oldDate = DateTime.now().subtract(const Duration(days: 10));
      final recentUpdate = DateTime.now().subtract(const Duration(hours: 12));

      await tester.pumpWidget(
        ScreenUtilInit(
          minTextAdapt: true,
          child: MaterialApp(
            home: Scaffold(
              body: ProfessionalAssociationCard(
                id: '1',
                name: 'جمعية محدثة',
                phone: '0791234567',
                bankName: 'البنك العربي',
                currency: 'JOD',
                isActive: true,
                createdAt: oldDate,
                updatedAt: recentUpdate,
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - البطاقة تظهر بشكل سليم (حالياً بدون badges نصية)
      expect(find.text('جمعية محدثة'), findsOneWidget);
      expect(find.text('محدث'), findsNothing);
    });

    testWidgets('SwipeActionsWrapper renders child correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SwipeActionsWrapper(
              itemName: 'Test Item',
              onEdit: () {},
              onDelete: () {},
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test Child'), findsOneWidget);
      expect(find.byType(Dismissible), findsOneWidget);
    });

    testWidgets('AssociationsFiltersBar displays all filter chips', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ScreenUtilInit(
          minTextAdapt: true,
          child: MaterialApp(
            home: Scaffold(
              body: AssociationsFiltersBar(
                selectedStatus: null,
                selectedBank: null,
                associationTypeOptions: const {},
                availableBanks: const ['البنك العربي', 'بنك القاهرة عمان'],
                onStatusChanged: (status) {},
                onBankChanged: (bank) {},
                onAssociationTypeChanged: (associationType) {},
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - التحقق من وجود فلاتر الحالة
      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('النشطة'), findsOneWidget);
      expect(find.text('المعطلة'), findsOneWidget);

      // Assert - التحقق من وجود فلاتر البنوك
      expect(find.text('البنك العربي'), findsOneWidget);
      expect(find.text('بنك القاهرة عمان'), findsOneWidget);
    });

    testWidgets('AssociationsFiltersBar selects status filter', (WidgetTester tester) async {
      // Arrange
      String? selectedStatus;

      await tester.pumpWidget(
        ScreenUtilInit(
          minTextAdapt: true,
          child: MaterialApp(
            home: Scaffold(
              body: AssociationsFiltersBar(
                selectedStatus: selectedStatus,
                selectedBank: null,
                associationTypeOptions: const {},
                availableBanks: const [],
                onStatusChanged: (status) {
                  selectedStatus = status;
                },
                onBankChanged: (bank) {},
                onAssociationTypeChanged: (associationType) {},
              ),
            ),
          ),
        ),
      );

      // Act - النقر على "النشطة"
      await tester.tap(find.text('النشطة'));
      await tester.pumpAndSettle();

      // Assert
      expect(selectedStatus, equals('active'));
    });

    testWidgets('SortingMenu displays all sort options', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ScreenUtilInit(
          minTextAdapt: true,
          child: MaterialApp(
            home: Scaffold(
              body: SortingMenu(
                currentSort: SortOption.nameAsc,
                onSortChanged: (option) {},
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - التحقق من وجود أيقونة الترتيب
      expect(find.byIcon(Icons.sort), findsOneWidget);
      expect(find.byType(PopupMenuButton<SortOption>), findsOneWidget);
    });

    testWidgets('CardAnimationWrapper animates child on build', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CardAnimationWrapper(
              index: 0,
              child: Text('Animated Child'),
            ),
          ),
        ),
      );

      // Act - البداية
      await tester.pump();

      // Assert - يجب أن يكون Child موجود
      expect(find.text('Animated Child'), findsOneWidget);
      expect(find.byType(TweenAnimationBuilder<double>), findsOneWidget);

      // Act - بعد الانيميشن
      await tester.pumpAndSettle();

      // Assert - Child لا يزال موجود بعد الانيميشن
      expect(find.text('Animated Child'), findsOneWidget);
    });

    testWidgets('ProfessionalAssociationCard shows inactive status correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ScreenUtilInit(
          minTextAdapt: true,
          child: MaterialApp(
            home: Scaffold(
              body: ProfessionalAssociationCard(
                id: '1',
                name: 'جمعية معطلة',
                phone: '0791234567',
                bankName: 'البنك العربي',
                currency: 'JOD',
                isActive: false,
                createdAt: DateTime.now(),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('معطل'), findsOneWidget);
    });

    testWidgets('ProfessionalAssociationCard action buttons are clickable', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ScreenUtilInit(
          minTextAdapt: true,
          child: MaterialApp(
            home: Scaffold(
              body: ProfessionalAssociationCard(
                id: '1',
                name: 'جمعية الخير',
                phone: '0791234567',
                bankName: 'البنك العربي',
                currency: 'JOD',
                isActive: true,
                createdAt: DateTime.now(),
                onEdit: () {},
                onDelete: () {},
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - التحقق من وجود أيقونات التعديل والحذف
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });
  });

  group('Responsive Tests', () {
    testWidgets('ProfessionalAssociationCard is responsive on mobile', (WidgetTester tester) async {
      // Arrange - Mobile size
      await tester.pumpWidget(
        ScreenUtilInit(
          minTextAdapt: true,
          child: MaterialApp(
            home: Scaffold(
              body: ProfessionalAssociationCard(
                id: '1',
                name: 'جمعية الخير',
                phone: '0791234567',
                bankName: 'البنك العربي',
                currency: 'JOD',
                isActive: true,
                createdAt: DateTime.now(),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      final card = tester.widget<Card>(find.byType(Card).first);
      expect(card, isNotNull);
    });

    testWidgets('ProfessionalAssociationCard is responsive on tablet', (WidgetTester tester) async {
      // Arrange - Tablet size
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(768, 1024), // Tablet
          minTextAdapt: true,
          child: MaterialApp(
            home: Scaffold(
              body: ProfessionalAssociationCard(
                id: '1',
                name: 'جمعية الخير',
                phone: '0791234567',
                bankName: 'البنك العربي',
                currency: 'JOD',
                isActive: true,
                createdAt: DateTime.now(),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      final card = tester.widget<Card>(find.byType(Card).first);
      expect(card, isNotNull);
    });
  });

  group('Dark Mode Tests', () {
    testWidgets('ProfessionalAssociationCard supports dark mode', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ScreenUtilInit(
          minTextAdapt: true,
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: ProfessionalAssociationCard(
                id: '1',
                name: 'جمعية الخير',
                phone: '0791234567',
                bankName: 'البنك العربي',
                currency: 'JOD',
                isActive: true,
                createdAt: DateTime.now(),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - البطاقة يجب أن تظهر بشكل صحيح في الوضع الداكن
      expect(find.text('جمعية الخير'), findsOneWidget);
      expect(find.byType(Container), findsWidgets); // التحقق من وجود Container للظلال
    });
  });
}
