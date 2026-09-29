// Screenshot harness: renders real app pages headlessly inside `flutter test`
// and writes PNGs to docs/screenshots/. See screenshots_test.dart.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:benaa_offline_app/l10n/app_localizations.dart';
import 'package:benaa_offline_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Logical phone size used by the app's ScreenUtil design size.
const Size kPhoneSize = Size(390, 844);
const double kPixelRatio = 3;

const String _harnessDir = 'test/screenshots';
const String outputDir = 'docs/screenshots';

/// Static Cairo instances shipped with the harness (cut from the OFL-licensed
/// variable font), keyed by weight.
const Map<int, String> _cairoFiles = {
  400: '$_harnessDir/fonts/Cairo-400.ttf',
  500: '$_harnessDir/fonts/Cairo-500.ttf',
  600: '$_harnessDir/fonts/Cairo-600.ttf',
  700: '$_harnessDir/fonts/Cairo-700.ttf',
};

/// google_fonts 6.3.x looks fonts up in the "device file system" as
/// `<appSupportDir>/Cairo_<variant>_<sha256>.ttf` before touching the network.
/// Seeding that directory lets GoogleFonts.cairo() resolve offline, exactly
/// like a device that already cached the font. Hashes come from
/// google_fonts' generated Cairo descriptor (w200 .. w900).
const Map<String, (int, String)> _googleFontsCairoVariants = {
  '200': (400, '40c2aa81a3235e60d78cd2e328b4e494f07d65694a955a08bdc51593a03216b0'),
  '300': (400, '700c24d28a092dd014c242b417ccde0fba8aa8e1d16d759a538594734da04ed2'),
  'regular': (400, '499cfb76477dbf03ca3791ba7177f2e128f250cfb34bbb9384dbf4f28b253c97'),
  '500': (500, '9d8500907f73132b06cf33a2ce1c28dc36018c7f5588ffd8638774103fde0077'),
  '600': (600, '5ebb1f2ec0c67f7294015d949f255e2833eae291bb1a6f0eab3cda6f96cfd5c2'),
  '700': (700, '3cce129dc85ef03a59b626db6dd521fd9904794f41da3aa95c1662b23ad90e6d'),
  '800': (700, 'cecf6b7ca16f645aff58ae318bbf5e7bcf3f12f592cf0a4b6a724dcbccef1bc0'),
  '900': (700, '2953a40be9746cdfd10665c61e18f1662a1346b01ce310188d2ebc311185219f'),
};

late Directory _appSupportDir;

/// Loads Cairo + Material Icons and stubs the platform channels the pages
/// touch (connectivity, path_provider, haptics). Call from setUpAll.
Future<void> setUpScreenshotEnvironment() async {
  GoogleFonts.config.allowRuntimeFetching = false;

  _appSupportDir = await Directory.systemTemp.createTemp('benaa_shots_');
  for (final entry in _googleFontsCairoVariants.entries) {
    final (weight, hash) = entry.value;
    await File(_cairoFiles[weight]!)
        .copy('${_appSupportDir.path}/Cairo_${entry.key}_$hash.ttf');
  }

  // Register every family name the theme can resolve to, up front, so the
  // first frame already has real glyphs.
  for (final entry in _googleFontsCairoVariants.entries) {
    final (weight, _) = entry.value;
    await _loadFont('Cairo_${entry.key}', [_cairoFiles[weight]!]);
  }
  // Plain 'Cairo' (google_fonts' fallback) and the default text family used by
  // widgets that set no fontFamily.
  final allCairo = _cairoFiles.values.toList();
  await _loadFont('Cairo', allCairo);
  await _loadFont('Roboto', allCairo);

  final flutterRoot = _flutterRoot();
  await _loadFont('MaterialIcons', [
    '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ]);
}

Future<void> tearDownScreenshotEnvironment() async {
  if (_appSupportDir.existsSync()) {
    await _appSupportDir.delete(recursive: true);
  }
}

String _flutterRoot() {
  final env = Platform.environment['FLUTTER_ROOT'];
  if (env != null && env.isNotEmpty) return env;
  // .../flutter/bin/cache/dart-sdk/bin/dart -> .../flutter
  return File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.path;
}

Future<void> _loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final p in paths) {
    final bytes = File(p).readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

/// Stubs plugin channels. Call inside each testWidgets body (mock handlers are
/// reset between tests).
void installPlatformMocks(WidgetTester tester) {
  final messenger = tester.binding.defaultBinaryMessenger;

  messenger.setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (call) async => _appSupportDir.path,
  );
  messenger.setMockMethodCallHandler(
    const MethodChannel('dev.fluttercommunity.plus/connectivity'),
    (call) async => call.method == 'check' ? <String>['wifi'] : null,
  );
  messenger.setMockStreamHandler(
    const EventChannel('dev.fluttercommunity.plus/connectivity_status'),
    MockStreamHandler.inline(onListen: (args, sink) {}),
  );
  messenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async => null,
  );
}

/// Sets the test view to a 390x844 phone at 3x.
void usePhoneView(WidgetTester tester) {
  tester.view.physicalSize = kPhoneSize * kPixelRatio;
  tester.view.devicePixelRatio = kPixelRatio;
  addTearDown(tester.view.reset);
}

/// The app's light theme (settings defaults: blue, Material 3, 14sp).
///
/// One harness-only tweak: the theme's chip labelStyle carries no fontFamily,
/// so chip labels fall through to the platform default font. On a phone that
/// is the system Arabic font; under flutter_test it is the Ahem-style test
/// font (black boxes), which cannot be replaced. Point it at the theme's
/// Cairo family instead.
ThemeData _lightTheme() {
  final theme = AppTheme.buildTheme(
    primaryColor: AppTheme.getColorFromScheme('blue'),
    isDark: false,
    useMaterial3: true,
    fontSize: 14,
  );
  final family = theme.textTheme.bodyMedium?.fontFamily;
  return theme.copyWith(
    chipTheme: theme.chipTheme.copyWith(
      labelStyle: (theme.chipTheme.labelStyle ?? const TextStyle())
          .copyWith(fontFamily: family),
    ),
  );
}

final GlobalKey _boundaryKey = GlobalKey();

/// The app shell from lib/app.dart (ScreenUtil, light theme, Arabic locale),
/// wrapped in a RepaintBoundary for capture.
Widget screenshotApp({
  required List<Override> overrides,
  required Widget home,
}) {
  return ProviderScope(
    overrides: overrides,
    child: RepaintBoundary(
      key: _boundaryKey,
      child: ScreenUtilInit(
        designSize: kPhoneSize,
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => MaterialApp(
          title: 'Benaa Offline',
          debugShowCheckedModeBanner: false,
          theme: _lightTheme(),
          themeMode: ThemeMode.light,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ar', 'SA'),
          home: home,
        ),
      ),
    ),
  );
}

/// Lets real async work (drift isolate-free queries, file IO) complete and
/// animations finish, without waiting on infinite animations.
Future<void> settle(WidgetTester tester, {int rounds = 12}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump(const Duration(milliseconds: 250));
  }
}

/// Captures the app boundary and writes `docs/screenshots/<name>.png`.
Future<void> capture(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final boundary =
        _boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: kPixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final file = File('$outputDir/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(data!.buffer.asUint8List());
  });
}
