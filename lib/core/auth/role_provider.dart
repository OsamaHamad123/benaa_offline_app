import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// أدوار المستخدمين في النظام
enum UserRole {
  admin,
  fieldWorker,
  reviewer,
  readOnly,
  unauthenticated,
}

/// Pure helper: resolves a [UserRole] from Firebase Auth custom claims.
/// Extracted for testability — no Firebase dependency.
UserRole resolveUserRoleFromClaims(Map<String, dynamic>? claims) {
  if (claims == null) return UserRole.fieldWorker;
  if (claims['admin'] == true) return UserRole.admin;
  return switch (claims['role']) {
    'field_worker' => UserRole.fieldWorker,
    'reviewer' => UserRole.reviewer,
    'read_only' => UserRole.readOnly,
    _ => UserRole.fieldWorker,
  };
}

/// Provider يقرأ custom claims من Firebase Auth token لتحديد دور المستخدم
final userRoleProvider = FutureProvider.autoDispose<UserRole>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return UserRole.unauthenticated;

  // forceRefresh: false — يستخدم الـ token المحلي إن لم ينته صلاحيته
  final token = await user.getIdTokenResult();
  return resolveUserRoleFromClaims(token.claims);
});

/// Provider مختصر لمعرفة هل المستخدم الحالي مدير
final isAdminProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(userRoleProvider).valueOrNull == UserRole.admin;
});

// ────────────────────────────────────────────────────────────────────────────
// دوال الصلاحيات — Permission Helpers
// ────────────────────────────────────────────────────────────────────────────

/// هل يمكن للدور الوصول إلى أدوات الإدارة (admin tools / monitoring / diagnostics)؟
bool canAccessAdminTools(UserRole role) => role == UserRole.admin;

/// هل يمكن للدور تشغيل أدوات البذر (Cedar Seed / Taxonomy Seed)؟
bool canRunSeeds(UserRole role) => role == UserRole.admin;

/// هل يمكن للدور إعادة تعيين الكاش المحلي؟
bool canResetLocalCache(UserRole role) => role == UserRole.admin || role == UserRole.fieldWorker;

/// هل يمكن للدور تصدير البيانات؟
bool canExportData(UserRole role) =>
    role == UserRole.admin || role == UserRole.fieldWorker || role == UserRole.reviewer;

/// هل يمكن للدور حذف بيانات بعيدة (Firestore delete)؟
bool canDeleteRemoteData(UserRole role) => role == UserRole.admin;
