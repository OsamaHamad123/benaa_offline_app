import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/core/auth/role_provider.dart';

/// اختبارات صلاحيات الأدوار
///
/// تتحقق من أن دوال الصلاحيات تُنفّذ نموذج التحكم في الوصول بشكل صحيح.
void main() {
  group('Permission Helpers — canAccessAdminTools', () {
    test('1. admin يمكنه الوصول إلى أدوات الإدارة', () {
      expect(canAccessAdminTools(UserRole.admin), isTrue);
    });

    test('2. fieldWorker لا يمكنه الوصول إلى أدوات الإدارة', () {
      expect(canAccessAdminTools(UserRole.fieldWorker), isFalse);
    });

    test('3. reviewer لا يمكنه الوصول إلى أدوات الإدارة', () {
      expect(canAccessAdminTools(UserRole.reviewer), isFalse);
    });

    test('4. readOnly لا يمكنه الوصول إلى أدوات الإدارة', () {
      expect(canAccessAdminTools(UserRole.readOnly), isFalse);
    });

    test('5. unauthenticated لا يمكنه الوصول إلى أدوات الإدارة', () {
      expect(canAccessAdminTools(UserRole.unauthenticated), isFalse);
    });
  });

  group('Permission Helpers — canRunSeeds', () {
    test('admin يمكنه تشغيل البذر', () {
      expect(canRunSeeds(UserRole.admin), isTrue);
    });

    test('fieldWorker لا يمكنه تشغيل البذر', () {
      expect(canRunSeeds(UserRole.fieldWorker), isFalse);
    });

    test('reviewer لا يمكنه تشغيل البذر', () {
      expect(canRunSeeds(UserRole.reviewer), isFalse);
    });

    test('readOnly لا يمكنه تشغيل البذر', () {
      expect(canRunSeeds(UserRole.readOnly), isFalse);
    });

    test('unauthenticated لا يمكنه تشغيل البذر', () {
      expect(canRunSeeds(UserRole.unauthenticated), isFalse);
    });
  });

  group('Permission Helpers — canResetLocalCache', () {
    test('admin يمكنه إعادة تعيين الكاش المحلي', () {
      expect(canResetLocalCache(UserRole.admin), isTrue);
    });

    test('fieldWorker يمكنه إعادة تعيين الكاش المحلي', () {
      expect(canResetLocalCache(UserRole.fieldWorker), isTrue);
    });

    test('reviewer لا يمكنه إعادة تعيين الكاش المحلي', () {
      expect(canResetLocalCache(UserRole.reviewer), isFalse);
    });

    test('readOnly لا يمكنه إعادة تعيين الكاش المحلي', () {
      expect(canResetLocalCache(UserRole.readOnly), isFalse);
    });

    test('unauthenticated لا يمكنه إعادة تعيين الكاش المحلي', () {
      expect(canResetLocalCache(UserRole.unauthenticated), isFalse);
    });
  });

  group('Permission Helpers — canExportData', () {
    test('admin يمكنه تصدير البيانات', () {
      expect(canExportData(UserRole.admin), isTrue);
    });

    test('fieldWorker يمكنه تصدير البيانات', () {
      expect(canExportData(UserRole.fieldWorker), isTrue);
    });

    test('reviewer يمكنه تصدير البيانات', () {
      expect(canExportData(UserRole.reviewer), isTrue);
    });

    test('readOnly لا يمكنه تصدير البيانات', () {
      expect(canExportData(UserRole.readOnly), isFalse);
    });

    test('unauthenticated لا يمكنه تصدير البيانات', () {
      expect(canExportData(UserRole.unauthenticated), isFalse);
    });
  });

  group('Permission Helpers — canDeleteRemoteData', () {
    test('admin يمكنه حذف البيانات البعيدة', () {
      expect(canDeleteRemoteData(UserRole.admin), isTrue);
    });

    test('fieldWorker لا يمكنه حذف البيانات البعيدة', () {
      expect(canDeleteRemoteData(UserRole.fieldWorker), isFalse);
    });

    test('reviewer لا يمكنه حذف البيانات البعيدة', () {
      expect(canDeleteRemoteData(UserRole.reviewer), isFalse);
    });

    test('readOnly لا يمكنه حذف البيانات البعيدة', () {
      expect(canDeleteRemoteData(UserRole.readOnly), isFalse);
    });

    test('unauthenticated لا يمكنه حذف البيانات البعيدة', () {
      expect(canDeleteRemoteData(UserRole.unauthenticated), isFalse);
    });
  });

  group('resolveUserRoleFromClaims — defensive', () {
    test('6. unknown role يرجع إلى fieldWorker بشكل آمن', () {
      final role = resolveUserRoleFromClaims({'role': 'super_hacker'});
      expect(role, UserRole.fieldWorker, reason: 'دور مجهول يجب أن يرجع إلى fieldWorker بشكل آمن');
    });

    test('7. claims مشوّهة (non-string role) لا تُعطل', () {
      expect(
        () => resolveUserRoleFromClaims({'role': 12345, 'admin': 'not-a-bool'}),
        returnsNormally,
      );
    });

    test('7b. non-bool admin claim لا يمنح admin role', () {
      final role = resolveUserRoleFromClaims({'admin': 'true'});
      expect(role, isNot(UserRole.admin), reason: 'admin يجب أن يكون bool true فقط');
    });
  });
}
