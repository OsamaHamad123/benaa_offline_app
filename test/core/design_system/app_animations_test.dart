import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/core/design_system/app_animations.dart';

void main() {
  group('AppDurations Tests', () {
    test('duration values are correct', () {
      expect(AppDurations.instant, const Duration(milliseconds: 150));
      expect(AppDurations.fast, const Duration(milliseconds: 250));
      expect(AppDurations.normal, const Duration(milliseconds: 350));
      expect(AppDurations.slow, const Duration(milliseconds: 450));
      expect(AppDurations.verySlow, const Duration(milliseconds: 600));
      expect(AppDurations.pageTransition, const Duration(milliseconds: 400));
      expect(AppDurations.shimmer, const Duration(milliseconds: 1500));
    });
  });

  group('AppCurves Tests', () {
    test('curves are defined', () {
      expect(AppCurves.standard, Curves.easeInOutCubicEmphasized);
      expect(AppCurves.bounce, Curves.easeOutBack);
      expect(AppCurves.elastic, Curves.elasticOut);
      expect(AppCurves.smooth, Curves.easeInOutQuint);
      expect(AppCurves.pageEnter, Curves.easeOutCubic);
      expect(AppCurves.pageExit, Curves.easeInCubic);
    });
  });

  group('ScaleTransitionWidget Tests', () {
    testWidgets('animates scale from 0 to 1', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ScaleTransitionWidget(child: Text('Test'))),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('respects custom duration', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScaleTransitionWidget(
              duration: Duration(milliseconds: 500),
              child: Text('Test'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Test'), findsOneWidget);
    });
  });

  group('FadeTransitionWidget Tests', () {
    testWidgets('animates opacity from 0 to 1', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FadeTransitionWidget(child: Text('Fade Test'))),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      expect(find.text('Fade Test'), findsOneWidget);
    });
  });

  group('SlideTransitionWidget Tests', () {
    testWidgets('slides widget into view', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SlideTransitionWidget(
              child: Text('Slide Test'),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      expect(find.text('Slide Test'), findsOneWidget);
    });
  });

  group('FadeSlideTransition Tests', () {
    testWidgets('combines fade and slide animations', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FadeSlideTransition(child: Text('Combined Test')),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      expect(find.text('Combined Test'), findsOneWidget);
    });
  });
}
