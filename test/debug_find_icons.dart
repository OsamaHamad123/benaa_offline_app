import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/list_widgets/statistics_dashboard.dart';

void main() {
  testWidgets('debug icons', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ScreenUtilInit(
          designSize: Size(375, 812),
          child: MaterialApp(home: Scaffold(body: StatisticsDashboard())),
        ),
      ),
    );

    final icons = tester.widgetList<Icon>(find.byType(Icon)).toList();
    for (var i = 0; i < icons.length; i++) {
      final icon = icons[i];
      final data = icon.icon;
      print('Icon $i: $data (codePoint: ${data!.codePoint.toRadixString(16)})');
    }

    print('filter_list: ${Icons.filter_list.codePoint.toRadixString(16)}');
    print('cloud_upload: ${Icons.cloud_upload.codePoint.toRadixString(16)}');
    print('people: ${Icons.people.codePoint.toRadixString(16)}');

    expect(icons.isNotEmpty, true);
  });
}
