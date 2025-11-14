import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/login_page.dart';
import '../features/initialization/initialization_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/beneficiaries/beneficiaries_list_page.dart';
import '../features/beneficiaries/presentation/pages/beneficiary_form_page.dart';
import '../features/beneficiaries/presentation/pages/beneficiary_form_page_v2.dart';
import '../features/beneficiaries/view_beneficiary_page.dart';
import '../features/search/presentation/pages/civil_search_page.dart';
import '../features/civil_registry/civil_registry_test_page.dart';
import '../features/civil_db_download/presentation/pages/welcome_page.dart';
import '../features/civil_db_download/presentation/pages/download_civil_db_page.dart';
import '../features/sync/sync_page.dart';
import '../features/sync/import_test_data_page.dart';
import '../features/sync/test_sync_page.dart';
import '../features/reports/reports_page.dart';
import '../features/attachments/attachments_page.dart';
import '../core/storage/secure_store.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/welcome',
    redirect: (context, state) async {
      final isGoingToInit = state.matchedLocation == '/init';
      final isGoingToWelcome = state.matchedLocation == '/welcome';
      final isGoingToDownload = state.matchedLocation == '/download-civil-db';
      final isAuth = await SecureStore.isAuthenticated();
      final isGoingToLogin = state.matchedLocation == '/login';

      // السماح بالذهاب لصفحات التهيئة والتحميل
      if (isGoingToInit || isGoingToWelcome || isGoingToDownload) {
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
        builder: (context, state) => const BeneficiariesListPage(),
      ),
      GoRoute(
        path: '/beneficiaries/add',
        builder: (context, state) => const BeneficiaryFormPageV2(),
      ),
      GoRoute(
        path: '/beneficiaries/:id/edit',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BeneficiaryFormPageV2(beneficiaryId: id);
        },
      ),
      GoRoute(
        path: '/beneficiaries/add-old',
        builder: (context, state) => const BeneficiaryFormPage(),
      ),
      GoRoute(
        path: '/beneficiaries/:id/edit-old',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BeneficiaryFormPage(beneficiaryId: id);
        },
      ),
      GoRoute(
        path: '/beneficiaries/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ViewBeneficiaryPage(beneficiaryId: id);
        },
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const CivilSearchPage(),
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
      GoRoute(path: '/sync', builder: (context, state) => const SyncPage()),
      GoRoute(
        path: '/import-test',
        builder: (context, state) => const ImportTestDataPage(),
      ),
      GoRoute(
        path: '/test-sync',
        builder: (context, state) => const TestSyncPage(),
      ),
    ],
  );
});
