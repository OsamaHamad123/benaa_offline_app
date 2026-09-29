import 'package:benaa_offline_app/features/associations/domain/entities/association.dart';
import 'package:benaa_offline_app/features/associations/presentation/widgets/enhanced_associations_stats_card.dart';
import 'package:benaa_offline_app/features/associations/presentation/widgets/modern_association_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Enhanced Associations Cards Tests', () {
    testWidgets('EnhancedAssociationsStatsCard renders with correct stats', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          child: MaterialApp(
            home: Scaffold(
              body: EnhancedAssociationsStatsCard(
                totalCount: 10,
                activeCount: 7,
                inactiveCount: 3,
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - التحقق من وجود الأرقام
      expect(find.text('10'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      // Assert - التحقق من وجود التسميات
      expect(find.text('الإجمالي'), findsOneWidget);
      expect(find.text('نشطة'), findsOneWidget);
      expect(find.text('معطلة'), findsOneWidget);

      // Assert - التحقق من النسب المئوية
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('70%'), findsOneWidget);
      expect(find.text('30%'), findsOneWidget);
    });

    testWidgets('EnhancedAssociationsStatsCard uses Wrap layout', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          child: MaterialApp(
            home: Scaffold(
              body: EnhancedAssociationsStatsCard(
                totalCount: 5,
                activeCount: 3,
                inactiveCount: 2,
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - التحقق من استخدام Wrap بدلاً من Column
      expect(find.byType(Wrap), findsWidgets);
    });

    testWidgets('EnhancedAssociationsStatsCard handles zero counts', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          child: MaterialApp(
            home: Scaffold(
              body: EnhancedAssociationsStatsCard(
                totalCount: 0,
                activeCount: 0,
                inactiveCount: 0,
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('0'), findsNWidgets(3)); // ثلاث أصفار
    });

    testWidgets('ModernAssociationCard renders all required information', (WidgetTester tester) async {
      // Arrange
      final testAssociation = Association(
        id: '1',
        name: 'جمعية الخير',
        shortName: 'الخير',
        phone: '07701234567',
        email: 'test@example.com',
        bankName: 'البنك المركزي',
        accountNumber: '123456789',
        accountCurrency: 'IQD',
        swiftCode: 'SWIFT123',
        bankPhone: '07801112233',
        isActive: true,
        representativeId: 'rep-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          child: MaterialApp(
            home: Scaffold(
              body: ModernAssociationCard(
                association: testAssociation,
                representativeName: 'أحمد محمد',
                onTap: () {},
                onDelete: () {},
                onEdit: () {},
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - التحقق من عرض المعلومات الأساسية
      expect(find.text('جمعية الخير'), findsOneWidget);
      // ملاحظة: الحالة الآن تعرض كنقطة ملونة وليس نص

      // Assert - التحقق من معلومات الاتصال
      expect(find.text('07701234567'), findsOneWidget);
      // التصميم الجديد مركز على المعلومات الأساسية فقط (هاتف، بنك، مندوب)

      // Assert - التحقق من أزرار الإجراءات
      expect(find.text('تعديل'), findsOneWidget);
      expect(find.text('حذف'), findsOneWidget);
    });

    testWidgets('ModernAssociationCard handles inactive status', (WidgetTester tester) async {
      // Arrange
      final inactiveAssociation = Association(
        id: '2',
        name: 'جمعية غير نشطة',
        phone: '07701234567',
        bankName: 'البنك',
        accountNumber: '123',
        accountCurrency: 'IQD',
        isActive: false,
        representativeId: 'rep-2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          child: MaterialApp(
            home: Scaffold(
              body: ModernAssociationCard(
                association: inactiveAssociation,
                onTap: () {},
                onDelete: () {},
                onEdit: () {},
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - نقطة الحالة موجودة (التصميم الجديد لا يعرض نص "معطل")
      expect(find.byType(ModernAssociationCard), findsOneWidget);
    });

    testWidgets('ModernAssociationCard buttons are tappable', (WidgetTester tester) async {
      // Arrange
      bool editTapped = false;
      bool deleteTapped = false;

      final testAssociation = Association(
        id: '3',
        name: 'جمعية الاختبار',
        phone: '07701234567',
        bankName: 'البنك',
        accountNumber: '123',
        accountCurrency: 'IQD',
        isActive: true,
        representativeId: 'rep-3',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          child: MaterialApp(
            home: Scaffold(
              body: ModernAssociationCard(
                association: testAssociation,
                onTap: () {},
                onDelete: () => deleteTapped = true,
                onEdit: () => editTapped = true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act & Assert - اختبار زر التعديل
      await tester.tap(find.text('تعديل'));
      await tester.pumpAndSettle();
      expect(editTapped, isTrue);

      // Act & Assert - اختبار زر الحذف
      await tester.tap(find.text('حذف'));
      await tester.pumpAndSettle();
      expect(deleteTapped, isTrue);
    });

    testWidgets('ModernAssociationCard shows representative name when provided', (WidgetTester tester) async {
      // Arrange
      final testAssociation = Association(
        id: '4',
        name: 'جمعية المندوب',
        phone: '07701234567',
        bankName: 'البنك',
        accountNumber: '123',
        accountCurrency: 'IQD',
        isActive: true,
        representativeId: 'rep-4',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          child: MaterialApp(
            home: Scaffold(
              body: ModernAssociationCard(
                association: testAssociation,
                representativeName: 'علي حسن',
                onTap: () {},
                onDelete: () {},
                onEdit: () {},
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - التصميم الجديد يعرض فقط الاسم بدون "المندوب:"
      expect(find.text('علي حسن'), findsOneWidget);
    });

    testWidgets('ModernAssociationCard hides representative when not provided', (WidgetTester tester) async {
      // Arrange
      final testAssociation = Association(
        id: '5',
        name: 'جمعية بدون مندوب',
        phone: '07701234567',
        bankName: 'البنك',
        accountNumber: '123',
        accountCurrency: 'IQD',
        isActive: true,
        representativeId: 'rep-5',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          child: MaterialApp(
            home: Scaffold(
              body: ModernAssociationCard(
                association: testAssociation,
                representativeName: null,
                onTap: () {},
                onDelete: () {},
                onEdit: () {},
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - المندوب غير موجود
      expect(find.byIcon(Icons.person), findsNothing);
    });
  });

  group('Responsive Layout Tests', () {
    testWidgets('Cards render correctly on small screens (280px)', (WidgetTester tester) async {
      // Arrange
      await tester.binding.setSurfaceSize(const Size(280, 600));

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(280, 600),
          minTextAdapt: true,
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    EnhancedAssociationsStatsCard(
                      totalCount: 10,
                      activeCount: 7,
                      inactiveCount: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - التحقق من عدم وجود overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('Cards render correctly on tablet screens (800px)', (WidgetTester tester) async {
      // Arrange
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      final testAssociation = Association(
        id: '6',
        name: 'جمعية التابلت',
        phone: '07701234567',
        bankName: 'البنك',
        accountNumber: '123',
        accountCurrency: 'IQD',
        isActive: true,
        representativeId: 'rep-6',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(800, 1200),
          minTextAdapt: true,
          child: MaterialApp(
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    EnhancedAssociationsStatsCard(
                      totalCount: 10,
                      activeCount: 7,
                      inactiveCount: 3,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: ModernAssociationCard(
                        association: testAssociation,
                        onTap: () {},
                        onDelete: () {},
                        onEdit: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(tester.takeException(), isNull);
    });
  });
}
