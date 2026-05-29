import 'package:benaa_offline_app/core/auth/role_provider.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the pure resolveUserRoleFromClaims helper.
/// Firebase Auth is NOT used — only the pure logic is tested.
void main() {
  group('resolveUserRoleFromClaims', () {
    test('null claims → fieldWorker (default safe role)', () {
      expect(resolveUserRoleFromClaims(null), UserRole.fieldWorker);
    });

    test('empty claims map → fieldWorker', () {
      expect(resolveUserRoleFromClaims({}), UserRole.fieldWorker);
    });

    test('admin: true → admin', () {
      expect(
        resolveUserRoleFromClaims({'admin': true}),
        UserRole.admin,
      );
    });

    test('admin: false, role: field_worker → fieldWorker', () {
      expect(
        resolveUserRoleFromClaims({'admin': false, 'role': 'field_worker'}),
        UserRole.fieldWorker,
      );
    });

    test('role: field_worker → fieldWorker', () {
      expect(
        resolveUserRoleFromClaims({'role': 'field_worker'}),
        UserRole.fieldWorker,
      );
    });

    test('role: reviewer → reviewer', () {
      expect(
        resolveUserRoleFromClaims({'role': 'reviewer'}),
        UserRole.reviewer,
      );
    });

    test('role: read_only → readOnly', () {
      expect(
        resolveUserRoleFromClaims({'role': 'read_only'}),
        UserRole.readOnly,
      );
    });

    test('unknown role → fieldWorker (default safe role)', () {
      expect(
        resolveUserRoleFromClaims({'role': 'unknown_role'}),
        UserRole.fieldWorker,
      );
    });

    test('admin: true overrides role claim', () {
      // Even if role says reviewer, admin: true wins
      expect(
        resolveUserRoleFromClaims({'admin': true, 'role': 'reviewer'}),
        UserRole.admin,
      );
    });

    test('unauthenticated is distinct from fieldWorker', () {
      // resolveUserRoleFromClaims never returns unauthenticated
      // unauthenticated is returned by userRoleProvider when currentUser == null
      final role = resolveUserRoleFromClaims(null);
      expect(role, isNot(UserRole.unauthenticated));
    });
  });

  group('UserRole enum', () {
    test('all roles are distinct', () {
      final roles = UserRole.values.toSet();
      expect(roles.length, UserRole.values.length);
    });

    test('admin is not fieldWorker', () {
      expect(UserRole.admin, isNot(UserRole.fieldWorker));
    });
  });
}
