import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import '../features/sync/test_sync_page.dart';
import '../features/sync/mobile_sync_page.dart';
import '../features/sync/test_mobile_api_page.dart';
import '../features/reports/reports_page.dart';
import '../features/attachments/attachments_page.dart';
import '../core/storage/secure_store.dart';
import '../features/dashboard/presentation/widgets/performance_dashboard.dart';
import '../features/dashboard/presentation/widgets/monitoring_dashboard.dart';

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
      if (isGoingToAppInit ||
          isGoingToInit ||
          isGoingToWelcome ||
          isGoingToDownload ||
          isGoingToDbDownload) {
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
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/beneficiaries',
        builder: (context, state) => const BeneficiariesListPageV2(),
      ),
      GoRoute(
        path: '/beneficiaries/add',
        builder: (context, state) => const BeneficiaryFormPageV3(),
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
        path: '/sync',
        builder: (context, state) => const MobileSyncPage(),
      ),
      GoRoute(
        path: '/import-test',
        builder: (context, state) => const ImportTestDataPage(),
      ),
      GoRoute(
        path: '/test-sync',
        builder: (context, state) => const TestSyncPage(),
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
