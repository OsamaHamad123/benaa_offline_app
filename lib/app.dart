import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';

class BenaaApp extends ConsumerWidget {
  const BenaaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 13 Pro as reference
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Benaa Offline',
          theme: AppTheme.adaptiveTheme, // استخدام الثيم التكيفي
          darkTheme: AppTheme.adaptiveDarkTheme,
          themeMode: ThemeMode.light,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ar', 'SA'), // Arabic
            Locale('en', 'US'), // English
          ],
          locale: const Locale('ar', 'SA'),
        );
      },
    );
  }
}
