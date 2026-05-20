import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/design_system/app_animations.dart';
import '../core/analytics/analytics_widgets.dart';
import '../core/analytics/realtime_performance_monitor.dart';
import '../core/debug/sentry_test_page.dart';
import '../features/auth/presentation/pages/login_page_v2.dart';
import '../features/initialization/initialization_page.dart';
import '../features/initialization/presentation/pages/app_initialization_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/beneficiaries/presentation/pages/beneficiaries_list_page_v2.dart';
import '../features/beneficiaries/presentation/pages/beneficiary_form_page_v3.dart';
import '../features/beneficiaries/presentation/pages/beneficiary_details_page_v2.dart';
import '../features/search/presentation/pages/civil_search_page.dart';
import '../features/search/presentation/pages/update_normalization_page.dart';
import '../features/civil_db_download/presentation/pages/welcome_page.dart';
import '../features/civil_db_download/presentation/pages/download_civil_db_page.dart';
import '../features/civil_db_download/presentation/pages/database_download_page.dart';
import '../features/sync/mobile_sync_page.dart';
import '../features/reports/reports_page.dart';
import '../features/reports/presentation/pages/beneficiaries_report_page.dart';
import '../features/attachments/attachments_page.dart';
import '../features/visits/presentation/pages/visits_list_page_m3.dart';
import '../features/associations/presentation/pages/associations_list_page_v2.dart';
import '../features/kafalat/presentation/pages/kafalat_page.dart';
import '../features/kafalat/presentation/pages/kafalat_import_page.dart';
import '../features/kafalat/presentation/pages/sponsorship_charts_page.dart';
import '../features/kafalat/presentation/pages/advanced_filters_page.dart';
import '../features/kafalat/presentation/pages/export_page.dart';
import '../features/kafalat/presentation/pages/smart_notifications_page.dart';
import '../features/kafalat/presentation/pages/theme_settings_page.dart';
import '../features/kafalat/presentation/pages/additional_features_pages.dart';
import '../features/dashboard/presentation/pages/all_activities_page_m3.dart';
import '../features/dashboard/presentation/pages/dashboard_settings_page.dart';
import '../core/settings/clean_settings_page.dart';
import '../core/storage/secure_storage.dart';
import '../features/civil_db_download/data/datasources/database_download_service.dart';
import '../features/civil_db_download/presentation/pages/config/download_config.dart';
import '../features/dashboard/presentation/widgets/performance_dashboard.dart';
import '../features/dashboard/presentation/widgets/monitoring_dashboard.dart';
import '../features/taxonomies/presentation/pages/taxonomy_management_page.dart';
import '../features/taxonomies/presentation/providers/taxonomy_providers.dart' as taxonomy_ui;

/// 🎬 Custom Page Transition Helper
Page<T> _buildPageWithTransition<T>({
  required Widget child,
  required GoRouterState state,
  PageTransitionType type = PageTransitionType.fade,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      switch (type) {
        case PageTransitionType.fade:
          return FadeTransition(opacity: animation, child: child);
        case PageTransitionType.slideFromBottom:
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
              CurvedAnimation(
                parent: animation,
                curve: AppCurves.pageEnter,
              ),
            ),
            child: child,
          );
        case PageTransitionType.slideFromRight:
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(
              CurvedAnimation(
                parent: animation,
                curve: AppCurves.pageEnter,
              ),
            ),
            child: child,
          );
        case PageTransitionType.scale:
          return ScaleTransition(
            scale: CurvedAnimation(parent: animation, curve: AppCurves.smooth),
            child: child,
          );
      }
    },
  );
}

enum PageTransitionType { fade, slideFromBottom, slideFromRight, scale }

final appRouterProvider = Provider<GoRouter>((ref) {
  final secureStorage = SecureStorage();
  final dbDownloadService = DatabaseDownloadService();

  Future<String> resolvePostAuthDestination() async {
    final isDbAvailable = await dbDownloadService.isDatabaseAvailable();
    final prefs = await SharedPreferences.getInstance();
    final wasSkipped = prefs.getBool(DownloadConfig.skipPreferenceKey) ?? false;
    return (isDbAvailable || wasSkipped) ? '/dashboard' : '/database-download';
  }

  void updateSyncGuards(String routePath) {
    Future.microtask(() {
      ref.read(taxonomy_ui.taxonomyAutoSyncRoutePathProvider.notifier).state = routePath;
      final emergency = ref.read(taxonomy_ui.taxonomyAutoSyncEmergencyModeProvider);
      final suspended = emergency || taxonomy_ui.isHeavyUiRouteForSync(routePath);
      ref.read(taxonomy_ui.taxonomyAutoSyncSuspendedProvider.notifier).state = suspended;
    });
  }

  return GoRouter(
    initialLocation: '/app-init',
    redirect: (context, state) async {
      updateSyncGuards(state.matchedLocation);

      const blockedInReleaseRoutes = <String>{
        '/civil-test',
        '/import-test',
        '/test-mobile-api',
        '/sentry-test',
        '/widgets-example',
      };

      if (!kDebugMode && blockedInReleaseRoutes.contains(state.matchedLocation)) {
        return '/dashboard';
      }

      final isGoingToAppInit = state.matchedLocation == '/app-init';
      final isGoingToInit = state.matchedLocation == '/init';
      final isGoingToWelcome = state.matchedLocation == '/welcome';
      final isGoingToDownload = state.matchedLocation == '/download-civil-db';
      final isGoingToDbDownload = state.matchedLocation == '/database-download';
      // استخدام Session صالحة بدل التحقق من وجود token فقط
      final isAuth = await secureStorage.hasValidSession();
      final isGoingToLogin = state.matchedLocation == '/login';

      if (isAuth && isGoingToAppInit) {
        return await resolvePostAuthDestination();
      }

      // السماح بالذهاب لصفحات التهيئة والتحميل ونسيت كلمة المرور
      if (isGoingToAppInit || isGoingToInit || isGoingToWelcome || isGoingToDownload || isGoingToDbDownload) {
        return null;
      }

      if (!isAuth && !isGoingToLogin) {
        return '/login';
      }

      // إذا كان المستخدم مصادق ويحاول فتح صفحة Login نعيد توجيهه فورًا
      if (isAuth && isGoingToLogin) {
        return await resolvePostAuthDestination();
      }

      return null;
    },
    routes: [
      // 🚀 New: Modern Database Download System
      GoRoute(
        path: '/app-init',
        builder: (context, state) => const AppInitializationPage(),
      ),
      GoRoute(
        path: '/database-download',
        builder: (context, state) => const DatabaseDownloadPage(),
      ),

      // 🔄 Legacy: Old Download System (kept for compatibility)
      GoRoute(
        path: '/init',
        builder: (context, state) => const InitializationPage(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/download-civil-db',
        builder: (context, state) => const DownloadCivilDbPage(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPageV2()),
      GoRoute(
        path: '/dashboard',
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: const DashboardPage(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/beneficiaries',
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: const BeneficiariesListPageV2(),
          state: state,
          type: PageTransitionType.slideFromRight,
        ),
      ),
      GoRoute(
        path: '/beneficiaries/add',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: BeneficiaryFormPageV3(
            civilRegistryData: state.extra as Map<String, dynamic>?,
          ),
        ),
      ),
      GoRoute(
        path: '/beneficiaries/:id/edit',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return NoTransitionPage(
            key: state.pageKey,
            child: BeneficiaryFormPageV3(beneficiaryId: id),
          );
        },
      ),

      GoRoute(
        path: '/beneficiaries/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BeneficiaryDetailsPageV2(beneficiaryId: id);
        },
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const CivilSearchPage(),
      ),
      GoRoute(
        path: '/update-normalization',
        builder: (context, state) => const UpdateNormalizationPage(),
      ),
      GoRoute(
        path: '/attachments/:beneficiaryId',
        builder: (context, state) {
          final beneficiaryId = state.pathParameters['beneficiaryId']!;
          return AttachmentsPage(beneficiaryId: beneficiaryId);
        },
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsPage(),
      ),
      GoRoute(
        path: '/reports/beneficiaries',
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: const BeneficiariesReportPage(),
          state: state,
          type: PageTransitionType.slideFromRight,
        ),
      ),
      GoRoute(
        path: '/sync',
        builder: (context, state) => const MobileSyncPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const CleanSettingsPage(),
      ),
      GoRoute(
        path: '/settings/dashboard',
        builder: (context, state) => const DashboardSettingsPage(),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const UxAnalyticsDashboard(),
      ),
      GoRoute(
        path: '/performance-monitor',
        builder: (context, state) => const RealTimePerformanceMonitor(),
      ),
      if (kDebugMode)
        GoRoute(
          path: '/sentry-test',
          builder: (context, state) => const SentryTestPage(),
        ),
      GoRoute(
        path: '/visits',
        builder: (context, state) => const VisitsListPageM3(),
      ),
      GoRoute(
        path: '/associations',
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: const AssociationsListPageV2(),
          state: state,
          type: PageTransitionType.slideFromRight,
        ),
      ),
      GoRoute(
        path: '/kafalat',
        pageBuilder: (context, state) {
          final tab = state.uri.queryParameters['tab'];
          final initialTabIndex = tab == 'sponsored' ? 1 : 0;
          final sponsoredStatus = state.uri.queryParameters['sponsored_status'] ?? 'all';
          final sponsoredType = state.uri.queryParameters['sponsored_type'] ?? 'all';
          final sponsoredQuery = state.uri.queryParameters['sponsored_query'] ?? '';
          final sponsoredShowFilters = state.uri.queryParameters['sponsored_show_filters'] == '1';
          return _buildPageWithTransition(
            child: KafalatPage(
              initialTabIndex: initialTabIndex,
              initialSponsoredStatus: sponsoredStatus,
              initialSponsoredType: sponsoredType,
              initialSponsoredQuery: sponsoredQuery,
              initialSponsoredShowFilters: sponsoredShowFilters,
            ),
            state: state,
            type: PageTransitionType.slideFromRight,
          );
        },
      ),

      // 🚀 Kafalat Advanced Features Routes
      GoRoute(
        path: '/kafalat/charts',
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: const SponsorshipChartsPage(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/kafalat/filters',
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: const AdvancedFiltersPage(),
          state: state,
          type: PageTransitionType.slideFromBottom,
        ),
      ),
      GoRoute(
        path: '/kafalat/export',
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: const ExportPage(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/kafalat/notifications',
        builder: (context, state) => const SmartNotificationsPage(),
      ),
      GoRoute(
        path: '/kafalat/themes',
        builder: (context, state) => const ThemeSettingsPage(),
      ),
      GoRoute(
        path: '/kafalat/sync',
        builder: (context, state) => const SyncSettingsPage(),
      ),
      GoRoute(
        path: '/kafalat/permissions',
        builder: (context, state) => const PermissionsPage(),
      ),
      GoRoute(
        path: '/kafalat/mobile-features',
        builder: (context, state) => const MobileFeaturesPage(),
      ),
      GoRoute(
        path: '/kafalat/advanced-dashboard',
        builder: (context, state) => const AdvancedDashboardPage(),
      ),
      GoRoute(
        path: '/kafalat/import',
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: const KafalatImportPage(),
          state: state,
          type: PageTransitionType.slideFromRight,
        ),
      ),
      GoRoute(
        path: '/activities',
        builder: (context, state) => const AllActivitiesPageM3(),
      ),
      GoRoute(
        path: '/mobile-sync',
        builder: (context, state) => const MobileSyncPage(),
      ),
      // Performance & Monitoring Dashboards
      GoRoute(
        path: '/performance',
        builder: (context, state) => const PerformanceDashboard(),
      ),
      GoRoute(
        path: '/monitoring',
        builder: (context, state) => const MonitoringDashboard(),
      ),
      // 🏷️ Taxonomies Management
      GoRoute(
        path: '/taxonomies',
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: const TaxonomyManagementPage(),
          state: state,
          type: PageTransitionType.slideFromRight,
        ),
      ),
    ],
  );
});
