import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:drift/native.dart';
import 'package:benaa_offline_app/data/db/drift_database.dart';
import 'package:benaa_offline_app/core/providers/providers.dart';

/// Utility wrapper for widget tests to bootstrap common app-level providers and
/// screen util initialization so tests have a consistent environment.
Widget appWrapper({required Widget child, AppDatabase? testDb}) {
  final db = testDb ?? AppDatabase(NativeDatabase.memory());
  return ProviderScope(
    overrides: [databaseProvider.overrideWithValue(db)],
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, cld) => MaterialApp(home: Scaffold(body: cld)),
      child: child,
    ),
  );
}
