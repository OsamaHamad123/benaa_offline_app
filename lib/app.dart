import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';
import 'core/settings/settings_provider.dart';
import 'core/error_handling/error_handler.dart';
import 'core/design_system/app_animations.dart';
import 'core/analytics/ux_analytics.dart';

class BenaaApp extends ConsumerWidget {
  const BenaaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    // 📊 Start analytics session
    UxAnalytics.startSession();

    // Watch settings for theme configuration
    final settingsAsync = ref.watch(sharedPreferencesProvider);

    return ErrorBoundary(
      child: settingsAsync.when(
        data: (_) {
          final settings = ref.watch(settingsProvider);

          // Determine ThemeMode based on settings
          ThemeMode themeMode;
          switch (settings.themeMode) {
            case 'light':
              themeMode = ThemeMode.light;
              break;
            case 'dark':
              themeMode = ThemeMode.dark;
              break;
            default:
              themeMode = ThemeMode.system;
          }

          // Get color scheme
          Color primaryColor = AppTheme.getColorFromScheme(
            settings.colorScheme,
          );

          return ScreenUtilInit(
            designSize: const Size(390, 844),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp.router(
                title: 'Benaa Offline',
                theme: AppTheme.buildTheme(
                  primaryColor: primaryColor,
                  isDark: false,
                  useMaterial3: settings.useMaterial3,
                  fontSize: settings.fontSize,
                ),
                darkTheme: AppTheme.buildTheme(
                  primaryColor: primaryColor,
                  isDark: true,
                  useMaterial3: settings.useMaterial3,
                  fontSize: settings.fontSize,
                ),
                themeMode: themeMode,
                routerConfig: router,
                debugShowCheckedModeBanner: false,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('ar', 'SA'),
                  Locale('en', 'US'),
                ],
                locale: const Locale('ar', 'SA'),
              );
            },
          );
        },
        loading: () => MaterialApp(
          home: Scaffold(
            body: Center(
              child: FadeTransitionWidget(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'جاري تحميل التطبيق...',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        error: (error, _) => MaterialApp(
          home: Scaffold(
            body: Center(
              child: RetryWidget(
                message: 'فشل تحميل التطبيق',
                onRetry: () {
                  ref.invalidate(sharedPreferencesProvider);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
