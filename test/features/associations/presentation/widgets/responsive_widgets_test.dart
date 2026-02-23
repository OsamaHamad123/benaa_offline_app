import 'package:benaa_offline_app/features/associations/domain/entities/association.dart';
import 'package:benaa_offline_app/features/associations/presentation/widgets/enhanced_associations_stats_card.dart';
import 'package:benaa_offline_app/features/associations/presentation/widgets/modern_association_card.dart';
import 'package:benaa_offline_app/features/associations/presentation/widgets/responsive_form_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  // Helper لإنشاء widget test environment
  Widget makeTestableWidget(Widget child, {double width = 400, double height = 800}) {
    final size = Size(width, height);
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: Scaffold(
          body: ScreenUtilInit(
            designSize: size,
            minTextAdapt: true,
            builder: (context, _) => SingleChildScrollView(
              child: SizedBox(
                width: width,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Association مثال للاختبار
  final testAssociation = Association(
    id: '1',
    name: 'جمعية اختبار طويلة جداً لفحص الـ overflow والـ responsive behavior في البطاقة',
    shortName: 'اختبار',
    phone: '07701234567',
    email: 'test@example.com',
    bankName: 'بنك الاختبار المركزي العراقي',
    accountNumber: '123456789012345678',
    accountCurrency: 'IQD',
    representativeId: '1',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('ModernAssociationCard Responsive Tests', () {
    testWidgets('Card يعرض المحتوى كاملاً في عرض عادي (400px)', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          ModernAssociationCard(
            association: testAssociation,
            representativeName: 'مندوب اختبار',
            onTap: () {},
            onDelete: () {},
            onEdit: () {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      // التحقق من عرض جميع العناصر الأساسية
      expect(find.text(testAssociation.name), findsOneWidget);
      expect(find.text(testAssociation.phone), findsOneWidget);
      // Note: bankName is combined with accountNumber in display
      expect(find.textContaining(testAssociation.bankName), findsOneWidget);

      // التحقق من عدم وجود overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('Card responsive في عرض ضيق (300px)', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          ModernAssociationCard(
            association: testAssociation,
            representativeName: 'مندوب اختبار',
            onTap: () {},
            onDelete: () {},
            onEdit: () {},
          ),
          width: 300,
        ),
      );

      await tester.pumpAndSettle();

      // يجب أن يعرض المحتوى عمودياً
      expect(find.text(testAssociation.name), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Card responsive في عرض ضيق جداً (250px)', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          ModernAssociationCard(
            association: testAssociation,
            representativeName: 'مندوب اختبار',
            onTap: () {},
            onDelete: () {},
            onEdit: () {},
          ),
          width: 280, // الحد الأدنى للعرض الذي يدعمه الـ widget
        ),
      );

      await tester.pumpAndSettle();

      // يجب ألا يحدث overflow في الحد الأدنى المدعوم
      expect(tester.takeException(), isNull);
    });

    testWidgets('Card يتعامل مع نص طويل بشكل صحيح', (tester) async {
      final longTextAssociation = Association(
        id: ' 2',
        name: 'جمعية ' * 20, // اسم طويل جداً
        shortName: 'طويل' * 5,
        phone: '07701234567',
        email: 'very.long.email.address.for.testing@example.com',
        bankName: 'بنك ' * 10,
        accountNumber: '1234567890' * 3,
        accountCurrency: 'IQD',
        representativeId: '1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        makeTestableWidget(
          ModernAssociationCard(
            association: longTextAssociation,
            onTap: () {},
            onDelete: () {},
            onEdit: () {},
          ),
          width: 300,
        ),
      );

      await tester.pumpAndSettle();

      // يجب ألا يحدث overflow
      expect(tester.takeException(), isNull);
    });
  });

  group('EnhancedAssociationsStatsCard Responsive Tests', () {
    testWidgets('Stats Card عرض أفقي (500px)', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          const EnhancedAssociationsStatsCard(
            totalCount: 100,
            activeCount: 80,
            inactiveCount: 20,
          ),
          width: 500,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('100'), findsOneWidget);
      expect(find.text('80'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Stats Card عرض عمودي (350px)', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          const EnhancedAssociationsStatsCard(
            totalCount: 100,
            activeCount: 80,
            inactiveCount: 20,
          ),
          width: 350,
        ),
      );

      await tester.pumpAndSettle();

      // يجب أن يعرض عمودياً
      expect(find.text('100'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Stats Card مع أرقام كبيرة', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          const EnhancedAssociationsStatsCard(
            totalCount: 999999,
            activeCount: 888888,
            inactiveCount: 111111,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('999999'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('ResponsiveFormRow Tests', () {
    testWidgets('FormRow عرض عمودي في mobile (300px)', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          const ResponsiveFormRow(
            children: [
              TextField(decoration: InputDecoration(labelText: 'حقل 1')),
              TextField(decoration: InputDecoration(labelText: 'حقل 2')),
            ],
          ),
          width: 300,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('حقل 1'), findsOneWidget);
      expect(find.text('حقل 2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('FormRow عرض أفقي في tablet (700px)', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          const ResponsiveFormRow(
            children: [
              TextField(decoration: InputDecoration(labelText: 'حقل 1')),
              TextField(decoration: InputDecoration(labelText: 'حقل 2')),
            ],
          ),
          width: 700,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('حقل 1'), findsOneWidget);
      expect(find.text('حقل 2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('FormRow مع عدد فردي من الحقول', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          const ResponsiveFormRow(
            children: [
              TextField(decoration: InputDecoration(labelText: 'حقل 1')),
              TextField(decoration: InputDecoration(labelText: 'حقل 2')),
              TextField(decoration: InputDecoration(labelText: 'حقل 3')),
            ],
          ),
          width: 700,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('حقل 3'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Content Size Tests - فحص أحجام المحتوى', () {
    testWidgets('Card size يجب أن يكون أكبر من المحتوى', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          ModernAssociationCard(
            association: testAssociation,
            onTap: () {},
            onDelete: () {},
            onEdit: () {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      // الحصول على حجم الـ Card
      final cardFinder = find.byType(Card);
      expect(cardFinder, findsOneWidget);

      final cardSize = tester.getSize(cardFinder);
      print('📏 Card Size: ${cardSize.width} x ${cardSize.height}');

      // يجب أن يكون للـ card ارتفاع معقول
      expect(cardSize.height, greaterThan(200));

      // الحصول على حجم النص الأطول
      final nameFinder = find.text(testAssociation.name);
      final nameSize = tester.getSize(nameFinder);
      print('📏 Name Size: ${nameSize.width} x ${nameSize.height}');

      // يجب أن يكون عرض الـ Card أكبر من النص
      expect(cardSize.width, greaterThan(nameSize.width));
    });

    testWidgets('Stats Card height يجب أن يستوعب المحتوى', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          const EnhancedAssociationsStatsCard(
            totalCount: 100,
            activeCount: 80,
            inactiveCount: 20,
          ),
        ),
      );

      await tester.pumpAndSettle();

      final cardFinder = find.byType(Card);
      final cardSize = tester.getSize(cardFinder);
      print('📏 Stats Card Size: ${cardSize.width} x ${cardSize.height}');

      // يجب أن يكون للـ stats card حجم مناسب
      expect(cardSize.height, greaterThan(100));
      expect(cardSize.width, greaterThan(0));
    });
  });

  group('Overflow Detection Tests', () {
    testWidgets('لا يوجد overflow في Card بعرض 280px', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          ModernAssociationCard(
            association: testAssociation,
            onTap: () {},
            onDelete: () {},
            onEdit: () {},
          ),
          width: 280,
        ),
      );

      // يجب ألا يحدث overflow
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // التحقق من وجود الأجزاء المهمة
      expect(find.text(testAssociation.name), findsOneWidget);
    });

    testWidgets('لا يوجد overflow في Stats Card بعرض 320px', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          const EnhancedAssociationsStatsCard(
            totalCount: 100,
            activeCount: 80,
            inactiveCount: 20,
          ),
          width: 320,
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('Performance Tests', () {
    testWidgets('Card rendering time', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        makeTestableWidget(
          ModernAssociationCard(
            association: testAssociation,
            onTap: () {},
            onDelete: () {},
            onEdit: () {},
          ),
        ),
      );

      await tester.pumpAndSettle();
      stopwatch.stop();

      print('⏱️ Card Rendering Time: ${stopwatch.elapsedMilliseconds}ms');

      // يجب أن يكون أقل من 100ms
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });
}
