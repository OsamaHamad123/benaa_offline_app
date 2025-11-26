import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/core/error_handling/error_handler.dart';

void main() {
  group('EnhancedSnackbar Tests', () {
    testWidgets('showSuccess displays success message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      EnhancedSnackbar.showSuccess(
                        context,
                        message: 'عملية ناجحة',
                      );
                    },
                    child: const Text('Show'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('عملية ناجحة'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('showError displays error message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      EnhancedSnackbar.showError(context, message: 'حدث خطأ');
                    },
                    child: const Text('Show'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('حدث خطأ'), findsOneWidget);
      expect(find.byIcon(Icons.error_rounded), findsOneWidget);
    });

    testWidgets('showWarning displays warning message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      EnhancedSnackbar.showWarning(context, message: 'تحذير');
                    },
                    child: const Text('Show'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('تحذير'), findsOneWidget);
      expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
    });

    testWidgets('showInfo displays info message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      EnhancedSnackbar.showInfo(context, message: 'معلومة');
                    },
                    child: const Text('Show'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('معلومة'), findsOneWidget);
      expect(find.byIcon(Icons.info_rounded), findsOneWidget);
    });

    testWidgets('snackbar auto-dismisses after duration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      EnhancedSnackbar.showInfo(
                        context,
                        message: 'اختبار',
                        duration: const Duration(seconds: 1),
                      );
                    },
                    child: const Text('Show'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('اختبار'), findsOneWidget);

      // Wait for auto-dismiss
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('اختبار'), findsNothing);
    });
  });

  group('RetryWidget Tests', () {
    testWidgets('displays message and retry button', (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RetryWidget(
              message: 'فشل التحميل',
              onRetry: () {
                retried = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('فشل التحميل'), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      await tester.tap(find.text('إعادة المحاولة'));
      await tester.pump();

      expect(retried, true);
    });

    testWidgets('shows custom icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RetryWidget(
              message: 'خطأ',
              onRetry: () {},
              icon: Icons.warning,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.warning), findsOneWidget);
    });
  });

  group('GlobalErrorHandler Tests', () {
    test('logs errors correctly', () {
      final handler = GlobalErrorHandler();
      handler.clearLog();

      final error = AppError(type: ErrorType.network, message: 'اختبار الخطأ');

      handler.logError(error);

      expect(handler.errorLog.length, 1);
      expect(handler.errorLog.first.message, 'اختبار الخطأ');
      expect(handler.errorLog.first.type, ErrorType.network);
    });

    test('clears error log', () {
      final handler = GlobalErrorHandler();
      handler.logError(AppError(type: ErrorType.unknown, message: 'Test'));

      expect(handler.errorLog.isNotEmpty, true);

      handler.clearLog();
      expect(handler.errorLog.isEmpty, true);
    });
  });
}
