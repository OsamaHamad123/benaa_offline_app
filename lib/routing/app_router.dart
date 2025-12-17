import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../core/design_system/app_animations.dart';
import '../core/analytics/analytics_widgets.dart';
import '../core/analytics/realtime_performance_monitor.dart';
import '../core/debug/sentry_test_page.dart';
import '../features/auth/login_page.dart';
import '../features/initialization/initialization_page.dart';
import '../features/initialization/presentation/pages/app_initialization_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/beneficiaries/presentation/pages/beneficiaries_list_page_v2.dart';
import '../features/beneficiaries/presentation/pages/beneficiary_form_page_v3.dart';
import '../features/beneficiaries/presentation/pages/beneficiary_details_page_v2.dart';
import '../features/search/presentation/pages/civil_search_page.dart';
import '../features/search/presentation/pages/update_normalization_page.dart';
import '../features/civil_registry/civil_registry_test_page.dart';
import '../features/civil_db_download/presentation/pages/welcome_page.dart';
import '../features/civil_db_download/presentation/pages/download_civil_db_page.dart';
import '../features/civil_db_download/presentation/pages/database_download_page.dart';
import '../features/sync/sync_page.dart';
import '../features/sync/import_test_data_page.dart';
import '../features/sync/mobile_sync_page.dart';
import '../features/sync/test_mobile_api_page.dart';
import '../features/reports/reports_page.dart';
import '../features/reports/presentation/pages/beneficiaries_report_page.dart';
import '../features/attachments/attachments_page.dart';
import '../features/visits/presentation/pages/visits_list_page_m3.dart';
import '../features/associations/presentation/pages/associations_list_page_v2.dart';
import '../features/dashboard/presentation/pages/all_activities_page_m3.dart';
import '../core/settings/enhanced_settings_page.dart';
import '../core/storage/secure_store.dart';
import '../features/dashboard/presentation/widgets/performance_dashboard.dart';
import '../features/dashboard/presentation/widgets/monitoring_dashboard.dart';

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
  return GoRouter(
    initialLocation: '/app-init',
    redirect: (context, state) async {
      final isGoingToAppInit = state.matchedLocation == '/app-init';
      final isGoingToInit = state.matchedLocation == '/init';
      final isGoingToWelcome = state.matchedLocation == '/welcome';
      final isGoingToDownload = state.matchedLocation == '/download-civil-db';
      final isGoingToDbDownload = state.matchedLocation == '/database-download';
      final isAuth = await SecureStore.isAuthenticated();
      final isGoingToLogin = state.matchedLocation == '/login';

      // السماح بالذهاب لصفحات التهيئة والتحميل
      if (isGoingToAppInit || isGoingToInit || isGoingToWelcome || isGoingToDownload || isGoingToDbDownload) {
        return null;
      }

      if (!isAuth && !isGoingToLogin) {
        return '/login';
      }

      if (isAuth && isGoingToLogin) {
        return '/dashboard';
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
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/dashboard',
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: const DashboardPage(),
          state: state,
          type: PageTransitionType.fade,
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
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: BeneficiaryFormPageV3(
            civilRegistryData: state.extra as Map<String, dynamic>?,
          ),
          state: state,
          type: PageTransitionType.slideFromBottom,
        ),
      ),
      GoRoute(
        path: '/beneficiaries/:id/edit',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BeneficiaryFormPageV3(beneficiaryId: id);
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
        path: '/civil-test',
        builder: (context, state) => const CivilRegistryTestPage(),
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
        builder: (context, state) => const EnhancedSettingsPage(),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const UxAnalyticsDashboard(),
      ),
      GoRoute(
        path: '/performance-monitor',
        builder: (context, state) => const RealTimePerformanceMonitor(),
      ),
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
        path: '/activities',
        builder: (context, state) => const AllActivitiesPageM3(),
      ),
      GoRoute(
        path: '/import-test',
        builder: (context, state) => const ImportTestDataPage(),
      ),
      GoRoute(
        path: '/mobile-sync',
        builder: (context, state) => const MobileSyncPage(),
      ),
      GoRoute(
        path: '/test-mobile-api',
        builder: (context, state) => const TestMobileApiPage(),
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
    ],
  );
});
