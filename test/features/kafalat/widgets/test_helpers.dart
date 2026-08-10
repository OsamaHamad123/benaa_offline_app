import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper function to wrap widgets with ScreenUtilInit for testing
Widget makeTestableWidget(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    child: MaterialApp(
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

/// Helper function to pump a widget wrapped with ScreenUtilInit
Future<void> pumpTestWidget(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(makeTestableWidget(widget));
}
