import 'package:benaa_offline_app/core/analytics/app_analytics.dart';
import 'package:benaa_offline_app/core/analytics/ux_feature_flags.dart';
import 'package:benaa_offline_app/core/providers/providers.dart' as core_providers;
import 'package:benaa_offline_app/core/settings/clean_settings_page.dart';
import 'package:benaa_offline_app/core/settings/settings_provider.dart' as app_settings;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders beneficiary personal UX KPI preview card', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();

    AppAnalytics.clear();
    AppAnalytics.logEvent(
      'beneficiary_personal_auto_advance',
      parameters: <String, dynamic>{
        'field': 'national_id',
        'input_length': 11,
      },
    );
    AppAnalytics.logEvent(
      'beneficiary_personal_quick_next',
      parameters: <String, dynamic>{
        'source': 'personal_tab_cta',
      },
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          app_settings.settingsProvider.overrideWith(
            (ref) => app_settings.SettingsNotifier(prefs),
          ),
          core_providers.sharedPreferencesProvider.overrideWith((ref) async => prefs),
          core_providers.uxFeatureFlagsStoreProvider.overrideWith((ref) => UxFeatureFlagsStore(prefs)),
          core_providers.uxFeatureFlagsProvider.overrideWith((ref) async => const UxFeatureFlags()),
        ],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, __) => const MaterialApp(
            home: CleanSettingsPage(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('KPI تحسينات إضافة المستفيد (آخر 7 أيام)'), findsOneWidget);
    expect(find.textContaining('Auto-advance:'), findsOneWidget);
    expect(find.textContaining('Quick-next:'), findsOneWidget);
  });
}
