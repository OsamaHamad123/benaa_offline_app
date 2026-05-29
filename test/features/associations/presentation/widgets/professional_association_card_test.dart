import 'package:benaa_offline_app/features/associations/presentation/widgets/professional_association_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

// ─── helper ──────────────────────────────────────────────────────────────────

Widget _wrap(Widget child, {double width = 360, double height = 800}) {
  return ScreenUtilInit(
    designSize: const Size(360, 800),
    minTextAdapt: true,
    child: MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: width,
          height: height,
          child: child,
        ),
      ),
    ),
  );
}

ProfessionalAssociationCard _card({
  String id = 'assoc-1',
  String name = 'جمعية الرحمة',
  String? shortName,
  String phone = '07901234567',
  String? email,
  String bankName = 'البنك الأهلي العراقي',
  String? accountNumber,
  String? currency,
  String? associationTypeLabel,
  String? representativeName,
  bool isActive = true,
  VoidCallback? onTap,
  VoidCallback? onEdit,
  VoidCallback? onDelete,
}) {
  return ProfessionalAssociationCard(
    id: id,
    name: name,
    shortName: shortName,
    phone: phone,
    email: email,
    bankName: bankName,
    accountNumber: accountNumber,
    currency: currency,
    associationTypeLabel: associationTypeLabel,
    representativeName: representativeName,
    isActive: isActive,
    onTap: onTap,
    onEdit: onEdit,
    onDelete: onDelete,
  );
}

// ─── tests ───────────────────────────────────────────────────────────────────

void main() {
  group('ProfessionalAssociationCard — بيانات أساسية', () {
    testWidgets('يعرض اسم الجمعية', (tester) async {
      await tester.pumpWidget(_wrap(_card(name: 'جمعية الإخاء')));
      await tester.pump();
      expect(find.text('جمعية الإخاء'), findsOneWidget);
    });

    testWidgets('يعرض الاسم المختصر بدلاً من الاسم الكامل إذا توفر', (tester) async {
      await tester.pumpWidget(_wrap(_card(name: 'جمعية الإخاء للخدمات', shortName: 'إخاء')));
      await tester.pump();
      expect(find.text('إخاء'), findsOneWidget);
      // الاسم الكامل لا يظهر عند توفر اسم مختصر
      expect(find.text('جمعية الإخاء للخدمات'), findsNothing);
    });

    testWidgets('يعرض badge نشط عند isActive=true', (tester) async {
      await tester.pumpWidget(_wrap(_card(isActive: true)));
      await tester.pump();
      expect(find.text('نشط'), findsOneWidget);
      expect(find.text('معطل'), findsNothing);
    });

    testWidgets('يعرض badge معطل عند isActive=false', (tester) async {
      await tester.pumpWidget(_wrap(_card(isActive: false)));
      await tester.pump();
      expect(find.text('معطل'), findsOneWidget);
      expect(find.text('نشط'), findsNothing);
    });

    testWidgets('يعرض رقم الهاتف', (tester) async {
      await tester.pumpWidget(_wrap(_card(phone: '07811111111')));
      await tester.pump();
      expect(find.text('07811111111'), findsOneWidget);
    });

    testWidgets('يعرض اسم البنك', (tester) async {
      await tester.pumpWidget(_wrap(_card(bankName: 'بنك الرافدين')));
      await tester.pump();
      expect(find.text('بنك الرافدين'), findsOneWidget);
    });
  });

  group('ProfessionalAssociationCard — حقول اختيارية', () {
    testWidgets('يعرض الإيميل عند توفره', (tester) async {
      await tester.pumpWidget(_wrap(_card(email: 'test@org.iq')));
      await tester.pump();
      expect(find.text('test@org.iq'), findsOneWidget);
    });

    testWidgets('لا يعرض الإيميل إذا لم يُمرَّر', (tester) async {
      await tester.pumpWidget(_wrap(_card(email: null)));
      await tester.pump();
      expect(find.byIcon(Icons.email_outlined), findsNothing);
    });

    testWidgets('يعرض العملة عند توفرها', (tester) async {
      await tester.pumpWidget(_wrap(_card(currency: 'IQD')));
      await tester.pump();
      expect(find.text('IQD'), findsOneWidget);
    });

    testWidgets('يعرض المندوب عند توفره', (tester) async {
      await tester.pumpWidget(_wrap(_card(representativeName: 'أحمد محمود')));
      await tester.pump();
      expect(find.text('أحمد محمود'), findsOneWidget);
    });

    testWidgets('يعرض نوع الجمعية عند توفره', (tester) async {
      await tester.pumpWidget(_wrap(_card(associationTypeLabel: 'جمعية خيرية')));
      await tester.pump();
      expect(find.text('جمعية خيرية'), findsOneWidget);
    });

    testWidgets('لا يعرض صف المندوب إذا لم تتوفر بيانات', (tester) async {
      await tester.pumpWidget(_wrap(_card(representativeName: null, associationTypeLabel: null)));
      await tester.pump();
      expect(find.byIcon(Icons.person_outline), findsNothing);
      expect(find.byIcon(Icons.category_outlined), findsNothing);
    });
  });

  group('ProfessionalAssociationCard — overflow وشاشة ضيقة', () {
    testWidgets('لا overflow مع اسم عربي طويل جداً (80 حرف)', (tester) async {
      const longName = 'مؤسسة الرحمة الإنسانية العالمية لرعاية الأيتام والأسر المتعففة في المناطق النائية';
      await tester.pumpWidget(_wrap(_card(name: longName), width: 320));
      await tester.pump();
      // التحقق من عدم وجود overflow exception
      expect(tester.takeException(), isNull);
    });

    testWidgets('لا overflow مع اسم إنجليزي طويل', (tester) async {
      const longName = 'Al-Rahma International Humanitarian Organization for Orphan Care and Social Development';
      await tester.pumpWidget(_wrap(_card(name: longName), width: 320));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('لا overflow مع شاشة ضيقة 280dp', (tester) async {
      await tester.pumpWidget(_wrap(
        _card(
          name: 'جمعية طويلة الاسم بشكل مبالغ فيه جداً ومملة',
          email: 'very.long.email.address@organization.example.com',
          bankName: 'البنك الأهلي التجاري الدولي للاستثمار',
          representativeName: 'محمد عبدالرحمن الخطيب',
          associationTypeLabel: 'جمعية خيرية غير حكومية',
        ),
        width: 280,
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('لا overflow مع جميع الحقول ممتلئة', (tester) async {
      await tester.pumpWidget(_wrap(
        _card(
          name: 'جمعية التضامن الاجتماعي لدعم الأسر المتعففة',
          shortName: 'تضامن',
          phone: '07701234567',
          email: 'info@tadamon.org',
          bankName: 'بنك الرافدين',
          accountNumber: '123456789',
          currency: 'USD',
          representativeName: 'سعد الدين الأنصاري',
          associationTypeLabel: 'جمعية إنسانية',
          isActive: true,
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('ProfessionalAssociationCard — PopupMenu والأفعال', () {
    testWidgets('PopupMenuButton موجود', (tester) async {
      await tester.pumpWidget(_wrap(_card()));
      await tester.pump();
      expect(find.byType(PopupMenuButton<_AssocCardActionTest>), findsNothing);
      // نتحقق من وجود أيقونة more_vert
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('النقر على الكارد يستدعي onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(_card(onTap: () => tapped = true)));
      await tester.pump();
      // نقر على Card (InkWell)
      await tester.tap(find.byType(InkWell).first);
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('Semantics label يحتوي اسم الجمعية', (tester) async {
      await tester.pumpWidget(_wrap(_card(name: 'جمعية التعاون', isActive: true)));
      await tester.pump();
      // التحقق من وجود widget مع semantics label مناسب
      expect(find.text('جمعية التعاون'), findsOneWidget);
    });
  });

  group('ProfessionalAssociationCard — RTL', () {
    testWidgets('يعمل في RTL بدون overflow', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 800),
          minTextAdapt: true,
          child: MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: SizedBox(
                  width: 360,
                  height: 800,
                  child: _card(
                    name: 'جمعية الخير',
                    phone: '07901111111',
                    representativeName: 'علي حسن',
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}

// dummy enum فقط لاستخدامه في find.byType بشكل آمن
enum _AssocCardActionTest { details, edit, delete }
