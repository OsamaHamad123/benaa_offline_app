import 'package:flutter/material.dart';
import '../error_handling/error_logger.dart';

/// Wraps the app to catch any uncaught widget errors
class ErrorBoundary extends StatelessWidget {
  final Widget child;

  const ErrorBoundary({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Set custom error builder
    ErrorWidget.builder = (FlutterErrorDetails details) {
      // Log the error
      ErrorLogger.logError(
        details.exception,
        details.stack,
        context: {
          'library': details.library ?? 'unknown',
          'context': details.context?.toString() ?? 'unknown',
        },
        hint: 'Widget rendering error',
      );

      // Show user-friendly error screen
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'حدث خطأ غير متوقع',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'تم إرسال تقرير عن المشكلة\nحاول إعادة تشغيل التطبيق',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // في التطبيق الحقيقي، أضف restart logic
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    };

    return child;
  }
}
