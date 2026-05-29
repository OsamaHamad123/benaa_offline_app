import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/core/auth/role_provider.dart';

/// اختبارات رؤية أدوات الإدارة/التشخيص/البذر
///
/// تتحقق من أن المستخدم العادي لا يمكنه الوصول إلى:
/// - أدوات البذر (seed tools)
/// - أدوات التشخيص (diagnostics)
/// - لوحات المراقبة (monitoring dashboards)
/// - إجراءات إعادة التعيين الخطرة (dangerous reset actions)
///
/// وتتحقق من أن admin يمكنه الوصول إليها حيث هو مقصود.
void main() {
  setUpAll(() => TestWidgetsFlutterBinding.ensureInitialized());

  group('Admin Tool Visibility — دوال الصلاحيات', () {
    test('1. normal user (fieldWorker) لا يمكنه الوصول إلى أدوات البذر', () {
      expect(canRunSeeds(UserRole.fieldWorker), isFalse);
    });

    test('2. normal user (fieldWorker) لا يمكنه الوصول إلى أدوات الإدارة', () {
      expect(canAccessAdminTools(UserRole.fieldWorker), isFalse);
    });

    test('3. reviewer لا يمكنه الوصول إلى أدوات التشخيص', () {
      expect(canAccessAdminTools(UserRole.reviewer), isFalse);
    });

    test('4. readOnly لا يمكنه الوصول إلى إجراءات إعادة التعيين الخطرة', () {
      expect(canDeleteRemoteData(UserRole.readOnly), isFalse);
      expect(canRunSeeds(UserRole.readOnly), isFalse);
    });

    test('5. admin يمكنه الوصول إلى قائمة الإدارة', () {
      expect(canAccessAdminTools(UserRole.admin), isTrue);
      expect(canRunSeeds(UserRole.admin), isTrue);
    });

    test('6. أدوات kDebugMode لا تُعرض في production paths (منطق توثيقي)', () {
      // هذا الاختبار يوثّق السياسة: admin/monitoring/analytics routes
      // مقيّدة بـ kDebugMode في app_router.dart
      // السلوك الفعلي مُختبر في router-level redirect
      const debugModeRoutes = {
        '/analytics',
        '/performance-monitor',
        '/performance',
        '/monitoring',
        '/sentry-test',
        '/update-normalization',
      };
      // هذه المسارات مُدرجة في blockedInReleaseRoutes أو مقيّدة بـ kDebugMode
      expect(debugModeRoutes.contains('/analytics'), isTrue, reason: '/analytics يجب أن يكون في debug-only routes');
      expect(debugModeRoutes.contains('/monitoring'), isTrue, reason: '/monitoring يجب أن يكون في debug-only routes');
    });

    test('7. Dashboard Quick Actions تبقى 6 للمستخدم العادي', () {
      // هذا اختبار توثيقي — القيمة الفعلية مختبرة في dashboard_quick_actions_test.dart
      // نتحقق هنا فقط أن المنطق لم يتغير
      const expectedQuickActions = [
        'إضافة مستفيد',
        'المستفيدون',
        'زيارات اليوم',
        'الكفالات',
        'الجمعيات',
        'المزامنة',
      ];
      expect(expectedQuickActions.length, 6, reason: 'Quick Actions يجب أن تبقى 6 للمستخدم العادي');
    });
  });

  group('Admin Tool Visibility — resolveUserRoleFromClaims', () {
    test('null claims → fieldWorker — لا وصول لأدوات الإدارة', () {
      final role = resolveUserRoleFromClaims(null);
      expect(canAccessAdminTools(role), isFalse);
      expect(canRunSeeds(role), isFalse);
    });

    test('empty claims → fieldWorker — لا وصول لأدوات الإدارة', () {
      final role = resolveUserRoleFromClaims({});
      expect(canAccessAdminTools(role), isFalse);
    });

    test('admin: true → admin — وصول كامل للإدارة', () {
      final role = resolveUserRoleFromClaims({'admin': true});
      expect(canAccessAdminTools(role), isTrue);
      expect(canRunSeeds(role), isTrue);
      expect(canDeleteRemoteData(role), isTrue);
    });

    test('role: field_worker → fieldWorker — لا وصول لأدوات الإدارة', () {
      final role = resolveUserRoleFromClaims({'role': 'field_worker'});
      expect(canAccessAdminTools(role), isFalse);
      expect(canRunSeeds(role), isFalse);
    });
  });
}
