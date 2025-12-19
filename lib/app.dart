import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';
import 'core/settings/settings_provider.dart';
import 'core/error_handling/error_handler.dart';
import 'core/design_system/app_animations.dart';
import 'core/analytics/ux_analytics.dart';
import 'l10n/app_localizations.dart';

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
            // 🚀 Critical performance fix:
            // Avoid rebuilding the whole app on keyboard open/close.
            // flutter_screenutil rebuilds when MediaQuery changes; keyboard changes viewInsets
            // which can trigger multiple rebuilds during the IME animation.
            rebuildFactor: (old, data) {
              return old.size != data.size ||
                  old.orientation != data.orientation ||
                  old.devicePixelRatio != data.devicePixelRatio ||
                  old.textScaleFactor != data.textScaleFactor ||
                  old.platformBrightness != data.platformBrightness;
            },
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
                // 🚀 IME (keyboard) jank fix:
                // When the keyboard opens/closes, the platform animates viewInsets
                // and Flutter updates MediaQuery every frame. Many widgets depend on
                // MediaQuery (directly or indirectly), so this can cause app-wide relayout jank.
                // We debounce viewInsets changes so the subtree is notified once per transition.
                builder: (context, child) {
                  if (child == null) return const SizedBox.shrink();
                  return _DebouncedKeyboardInsets(child: child);
                },
                localizationsDelegates: [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: AppLocalizations.supportedLocales,
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

class _DebouncedKeyboardInsets extends StatefulWidget {
  final Widget child;

  const _DebouncedKeyboardInsets({required this.child});

  @override
  State<_DebouncedKeyboardInsets> createState() =>
      _DebouncedKeyboardInsetsState();
}

class _DebouncedKeyboardInsetsState extends State<_DebouncedKeyboardInsets>
    with WidgetsBindingObserver {
  static const _debounceDuration = Duration(milliseconds: 90);

  Timer? _debounceTimer;
  EdgeInsets _stableViewInsets = EdgeInsets.zero;
  EdgeInsets _latestRawInsets = EdgeInsets.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize with current value (after first build).
    final view = View.of(context);
    final data = MediaQueryData.fromView(view);
    _stableViewInsets = data.viewInsets;
    _latestRawInsets = data.viewInsets;
  }

  @override
  void didChangeMetrics() {
    // Called repeatedly during IME animation.
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final data = MediaQueryData.fromView(view);
    final rawInsets = data.viewInsets;

    if (rawInsets == _latestRawInsets) return;
    _latestRawInsets = rawInsets;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      if (!mounted) return;
      if (_stableViewInsets == _latestRawInsets) return;
      setState(() {
        _stableViewInsets = _latestRawInsets;
      });
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Base MediaQuery from the current FlutterView; override viewInsets to the debounced value.
    final base = MediaQueryData.fromView(View.of(context));
    final data = base.copyWith(viewInsets: _stableViewInsets);

    return MediaQuery(
      data: data,
      child: widget.child,
    );
  }
}
