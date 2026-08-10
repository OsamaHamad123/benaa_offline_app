import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/dashboard_haptics.dart';

/// Dashboard Navigation Service - إدارة التنقل في الداشبورد
///
/// الفوائد:
/// 1. فصل منطق التنقل عن UI
/// 2. سهولة الاختبار
/// 3. إعادة استخدام
/// 4. haptic feedback موحد
class DashboardNavigationService {
  // Prevent instantiation
  DashboardNavigationService._();

  // === Beneficiaries ===

  static void navigateToBeneficiariesList(BuildContext context) {
    DashboardHaptics.onNavigation();
    context.push('/beneficiaries');
  }

  static void navigateToAddBeneficiary(BuildContext context) {
    DashboardHaptics.onQuickAction();
    context.push('/beneficiaries/add');
  }

  static void navigateToBeneficiaryDetails(
    BuildContext context,
    String beneficiaryId,
  ) {
    DashboardHaptics.onNavigation();
    context.push('/beneficiaries/$beneficiaryId');
  }

  // === Kafalat ===

  static void navigateToKafalat(BuildContext context) {
    DashboardHaptics.onNavigation();
    context.push('/kafalat');
  }

  static void navigateToAddKafalat(BuildContext context) {
    DashboardHaptics.onQuickAction();
    context.push('/kafalat/add');
  }

  // === Sync ===

  static void navigateToSync(BuildContext context) {
    DashboardHaptics.onNavigation();
    context.push('/sync');
  }

  // === Reports ===

  static void navigateToReports(BuildContext context) {
    DashboardHaptics.onNavigation();
    context.push('/reports');
  }

  // === Search/Civil Registry ===

  static void navigateToCivilRegistry(BuildContext context) {
    DashboardHaptics.onNavigation();
    context.push('/search');
  }

  // === Visits ===

  static void navigateToVisits(BuildContext context) {
    DashboardHaptics.onNavigation();
    context.push('/visits');
  }

  static void navigateToAddVisit(BuildContext context) {
    DashboardHaptics.onQuickAction();
    context.push('/visits/add');
  }

  // === Associations ===

  static void navigateToAssociations(BuildContext context) {
    DashboardHaptics.onNavigation();
    context.push('/associations');
  }

  // === Activities ===

  static void navigateToAllActivities(BuildContext context) {
    DashboardHaptics.onNavigation();
    context.push('/activities');
  }

  // === Settings ===

  static void navigateToSettings(BuildContext context) {
    DashboardHaptics.onNavigation();
    context.push('/settings');
  }

  // === Monitoring (Admin) ===

  static void navigateToPerformanceDashboard(BuildContext context) {
    DashboardHaptics.onNavigation();
    context.push('/performance');
  }

  static void navigateToMonitoringDashboard(BuildContext context) {
    DashboardHaptics.onNavigation();
    context.push('/monitoring');
  }

  // === Helper Methods ===

  /// Navigate back
  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    }
  }

  /// Navigate and replace current route
  static void navigateAndReplace(BuildContext context, String path) {
    DashboardHaptics.onNavigation();
    context.pushReplacement(path);
  }

  /// Navigate and clear stack
  static void navigateAndClearStack(BuildContext context, String path) {
    DashboardHaptics.onNavigation();
    while (context.canPop()) {
      context.pop();
    }
    context.pushReplacement(path);
  }
}
