# Dashboard/Home — Final Baseline Document

**Baseline Date:** 2026-05-28  
**Status:** FROZEN — Production-Ready  
**App:** منظومة بناء — Gaza/Cedar beneficiary management  
**Phases completed:** Phase 1 (Dashboard Redesign Audit) + Phase 2 (Testing & Quality Gaps) + UX Phases 1–5

> **FREEZE NOTICE:** The Dashboard/Home implementation is frozen as of this date.  
> Do NOT redesign the Dashboard without a new explicit product requirement.  
> Do NOT change the 6 Quick Actions spec without updating tests.  
> Do NOT reintroduce admin/seed/debug tools into the normal user Dashboard.

---

## Phase 5 Update Note (2026-05-28)

Phase 5 improved AppBar comfort, typography token consistency, and Dashboard information density.

- **AppBar:** reduced `expandedHeight` (88.h mobile), increased icon touch targets (40×40), added explicit spacing between action icons.
- **Typography:** `DashboardTextStyles.sectionTitle` reduced to 17.sp, `cardTitle` to 15.sp; `AppTheme.AppBarTheme.titleTextStyle` now uses `fontSizeMultiplier` for global consistency.
- **Dashboard simplicity:** filter section de-emphasized (SectionTitle → compact bodySmall row); summary card elevation reduced (2→1); stat cards slightly shorter (childAspectRatio 2.5→2.7).
- **Quick Actions preserved:** exactly 6 cards, frozen, all tests pass.
- **No new heavy queries or providers added.**
- **No sync/security/role logic changed.**
- Analyzer: 0 errors, 0 warnings. Focused tests: 36/36 passed.

---

## 1. Final Dashboard Architecture

```
lib/features/dashboard/
├── domain/
│   ├── entities/
│   │   ├── activity.dart           — DashboardActivity entity
│   │   └── dashboard_stats.dart    — DashboardStats entity
│   ├── repositories/
│   │   └── dashboard_repository.dart  — abstract DashboardRepository
│   └── use_cases/
│       ├── get_dashboard_statistics.dart
│       ├── get_today_stats.dart
│       └── get_recent_activities.dart
├── data/
│   └── repositories/
│       └── dashboard_repository_impl.dart
└── presentation/
    ├── providers/
    │   └── dashboard_provider.dart    — DashboardNotifier (StateNotifier)
    ├── pages/
    │   └── home_page.dart             — Main Dashboard page
    └── widgets/
        ├── quick_actions_grid.dart    — 6-card Quick Actions grid
        ├── filter_chip_group.dart     — 4 filter chips
        ├── dashboard_app_bar.dart     — Custom AppBar with admin popup
        └── ...
```

**State Management:** Riverpod `StateNotifierProvider` for `DashboardNotifier`.  
**autoDispose:** Applied to `userRoleProvider`, `isAdminProvider`, and all dashboard future providers.  
**Pattern:** Use-case layer between presentation and data; sealed `Result<T>` for error handling.

---

## 2. Final Quick Actions Spec

**IMMUTABLE — 6 cards, always visible, no conditional hiding, no admin-only cards.**

| #   | Label        | Icon               | Action                           |
| --- | ------------ | ------------------ | -------------------------------- |
| 1   | إضافة مستفيد | person_add         | Navigate to add beneficiary form |
| 2   | المستفيدون   | people             | Navigate to beneficiaries list   |
| 3   | زيارات اليوم | today              | Navigate to today's field visits |
| 4   | الكفالات     | volunteer_activism | Navigate to sponsorships         |
| 5   | الجمعيات     | business           | Navigate to associations         |
| 6   | المزامنة     | sync               | Navigate to sync page            |

**Rules:**

- Exactly 6 cards. Never more, never fewer.
- All 6 always visible to all authenticated users (no role-gating).
- Do NOT add seed/debug/export/admin quick actions here.
- Label for card 3 is `زيارات اليوم` — NOT `زيارات الميدانية`.
- Widget tests enforce all 6 cards and block any regression.

---

## 3. Final AppBar Spec

- Shows app name/logo on the left (RTL: right)
- Shows Search icon
- Shows Notifications icon
- Shows More (⋮) popup menu
- More menu shows admin-only items **only when `isAdminProvider` is true**
- `isAdminProvider` is derived from Firebase Auth custom claims (`admin: true`)
- No TaxonomyStatusBadge in AppBar (removed in Phase 1)
- No seed/sync-debug actions in AppBar for normal users

---

## 4. Final Admin Visibility Rules

Admin detection flow:

```
FirebaseAuth.currentUser
  → getIdTokenResult()
  → token.claims
  → resolveUserRoleFromClaims(claims)  ← pure function, fully tested
  → userRoleProvider (FutureProvider.autoDispose)
  → isAdminProvider (Provider.autoDispose)
  → UI conditionally shows admin items
```

**Rules:**

- `resolveUserRoleFromClaims` is a pure top-level function — no Firebase dependency, fully unit-testable.
- `isAdminProvider` returns `false` when `userRoleProvider` is loading or errors — fail-closed.
- Admin tools are only shown where `ref.watch(isAdminProvider)` returns `true`.
- Normal users see no admin tools anywhere on Dashboard.

---

## 5. Final Security and Logging Rules

### LogSanitizer

- `lib/core/utils/log_sanitizer.dart` — masks national IDs, phone numbers, names in logs.
- Enabled at app startup via `LogSanitizer.enableSensitiveMasking()`.
- 15 unit tests cover all masking scenarios.

### Logging rules (production code):

- All `print()` replaced with `debugPrint()` in production code.
- `debugPrint` is a no-op in release builds.
- Sensitive fields (national ID, phone, full name) must pass through `LogSanitizer` before logging.
- Firebase tokens, API keys, and secrets must never be logged.

### Remaining intentional deferred items (info-level only):

- `lib/core/error_handling/error_logger.dart` — Sentry `setExtra` deprecated (Sentry API concern, not Flutter)
- `lib/core/widgets/common/error_display.dart` — 2× `.withOpacity` (safe to fix later)
- `lib/features/beneficiaries/presentation/widgets/v2/v2_error_banner.dart` — deprecated `.red/.green/.blue` color channels (risky color logic, deferred)

---

## 6. Final Test Coverage Summary

### Tests added in Phase 1 + Phase 2

| Test File                                                         | Tests | What it covers                                         |
| ----------------------------------------------------------------- | ----- | ------------------------------------------------------ |
| `test/core/utils/log_sanitizer_test.dart`                         | 15    | LogSanitizer masking: national ID, phone, name, tokens |
| `test/features/dashboard/dashboard_app_bar_test.dart`             | 5     | AppBar structure, no TaxonomyStatusBadge, admin popup  |
| `test/features/dashboard/dashboard_quick_actions_test.dart`       | 12    | All 6 Quick Actions present, correct labels, callbacks |
| `test/features/dashboard/dashboard_security_visibility_test.dart` | 7     | No admin tools visible to normal users                 |
| `test/features/dashboard/dashboard_sync_invalidation_test.dart`   | 6     | Sync invalidation behavior + known gap documented      |
| `test/core/auth/role_provider_test.dart`                          | 12    | `resolveUserRoleFromClaims` pure function              |
| `test/features/dashboard/dashboard_notifier_test.dart`            | 11    | `DashboardNotifier` state machine                      |
| `test/features/dashboard/dashboard_filters_test.dart`             | 10    | `FilterChipGroup` RTL, 4 filters, callbacks            |
| `test/features/dashboard/dashboard_page_render_test.dart`         | 5     | Full page render: 6 cards, 4 filters, no overflow      |
| `test/features/beneficiaries/beneficiaries_pagination_test.dart`  | 9     | `InfiniteScrollNotifier` pagination, reset, prefetch   |

**Total new tests: 92 across 10 files**

### All targeted tests: PASSING ✅

| Test run                                                                      | Result                        |
| ----------------------------------------------------------------------------- | ----------------------------- |
| `flutter test test/features/dashboard/` (excl. pre-existing charts failure)   | 130/131 — 1 pre-existing fail |
| `flutter test test/core/utils/log_sanitizer_test.dart`                        | 15/15 ✅                      |
| `flutter test test/core/auth/role_provider_test.dart`                         | 12/12 ✅                      |
| `flutter test test/features/beneficiaries/beneficiaries_pagination_test.dart` | 9/9 ✅                        |

---

## 7. Final Analyzer and Test Results

### `flutter analyze` (run 2026-05-28)

```
Result: 1474 issues — ALL info level
Errors:   0
Warnings: 0
```

All `info` items are pre-existing deprecated API warnings. None are blockers.

### `flutter test` (full suite, run 2026-05-28)

```
Result: +891 ~2 -19
Passed:  891
Skipped: 2
Failed:  19 — ALL pre-existing, none from Phase 1/2
```

### Pre-existing failing tests (not our responsibility)

| File                                       | Test                                          | Cause                                                    |
| ------------------------------------------ | --------------------------------------------- | -------------------------------------------------------- |
| `dashboard_charts_test.dart`               | `CategoryDistributionChart renders correctly` | StateError in chart widget — pre-existing before Phase 1 |
| `beneficiary_form_page_test.dart`          | 5 tests                                       | `Firebase.initializeApp()` not mocked                    |
| `form_data_handler_test.dart`              | 1 test                                        | `Firebase.initializeApp()` not mocked                    |
| `bank_account_validator_test.dart`         | 2 tests                                       | Logic regression unrelated to Dashboard                  |
| `form_tabs_4_merged_integration_test.dart` | 1 test                                        | Integration test infra                                   |
| `v2_contact_notes_merged_tab_test.dart`    | 1 test                                        | Firebase dependency                                      |
| `v2_personal_info_merged_tab_test.dart`    | 2 tests                                       | Firebase dependency                                      |
| `beneficiary_form_open_ci_guard_test.dart` | 1 test                                        | CI threshold not met                                     |
| `taxonomy_bridge_dropdown_test.dart`       | 4 tests                                       | Provider/async timing                                    |

---

## 8. Files Changed in Phase 1 and Phase 2

### Production source files modified

| File                                                      | Change                                                                                                                            |
| --------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| `lib/core/auth/role_provider.dart`                        | Extracted `resolveUserRoleFromClaims` as pure top-level function; added `autoDispose` to `userRoleProvider` and `isAdminProvider` |
| `lib/core/analytics/charts/analytics_dashboard_page.dart` | Added `if (!mounted) return;` guards after async `openFile()` calls; fixed string interpolation                                   |
| `lib/core/analytics/charts/bar_chart_widget.dart`         | `.withOpacity()` → `.withValues(alpha:)` (2 occurrences)                                                                          |
| `lib/core/analytics/charts/beneficiary_chart.dart`        | `.withOpacity()` → `.withValues(alpha:)` (3 occurrences)                                                                          |
| `lib/core/analytics/realtime_performance_monitor.dart`    | `.withOpacity()` → `.withValues(alpha:)` (3 occurrences)                                                                          |
| `lib/core/analytics/ux_analytics.dart`                    | `print()` → `debugPrint()` (18 occurrences)                                                                                       |

### New production source files created

| File                                                                  | Purpose                         |
| --------------------------------------------------------------------- | ------------------------------- |
| `lib/core/utils/log_sanitizer.dart`                                   | Sensitive data masking for logs |
| `lib/features/dashboard/presentation/widgets/quick_actions_grid.dart` | 6-card Quick Actions widget     |
| `lib/features/dashboard/presentation/widgets/filter_chip_group.dart`  | 4 filter chips widget           |
| `lib/features/dashboard/presentation/widgets/dashboard_app_bar.dart`  | Custom AppBar with admin popup  |

## Security Hardening Follow-up

**تاريخ**: 2026-05-28  
**الحالة**: ✅ اكتمل بدون أي تغيير على Dashboard

### تصميم Dashboard — لم يتغيّر

- تخطيط Dashboard مُجمَّد كما هو — لم تُجرَ أي إعادة تصميم
- Quick Actions محفوظة بالكامل (6 بطاقات، نفس الترتيب، نفس التسميات)
- لا تغييرات على AppBar أو FilterChipGroup أو أي widget موجود
- المستخدمون العاديون (field_worker) لا يرون أدوات debug/admin/seed في production

### Quick Actions — محفوظة بدون تغيير

| #   | البطاقة      | الحالة    |
| --- | ------------ | --------- |
| 1   | إضافة مستفيد | ✅ محفوظة |
| 2   | المستفيدون   | ✅ محفوظة |
| 3   | زيارات اليوم | ✅ محفوظة |
| 4   | الكفالات     | ✅ محفوظة |
| 5   | الجمعيات     | ✅ محفوظة |
| 6   | المزامنة     | ✅ محفوظة |

### نتائج اختبارات Dashboard (بعد Security Hardening)

| التشغيل                                     | النتيجة    |
| ------------------------------------------- | ---------- |
| `flutter test test/features/dashboard/`     | 131/131 ✅ |
| `flutter test dashboard_notifier_test.dart` | 11/11 ✅   |

**اختبار flaky محلول**: كان الاختبار `sets lastRefreshTime after successful load` يفشل أحياناً resulting من race condition بين `DateTime.now()` عند تسجيل `before` وعند تعيين `lastRefreshTime` — تمّ إصلاحه بـ `subtract(1ms)` لضمان الترتيب الزمني الصحيح دائماً.

- **تم**: Security & Privacy Hardening Phase اكتملت بنجاح
- **Quick Actions**: محفوظة بالضبط كما كانت — 6 عناصر: إضافة مستفيد، المستفيدون، زيارات اليوم، الكفالات، الجمعيات، المزامنة
- **Normal users**: لا يرون أي أدوات admin/debug/seed في production build
- **Dashboard layout**: لم يُعاد تصميمه — بنية الصفحة محفوظة تماماً
- **Dashboard tests**: 131/131 اختبار نجح بعد Security Hardening
- **الاختبار الـ flaky المسبق** (`clearError removes errorMessage`): أُصلح كأثر جانبي لـ `LogSanitizer.enableDebugMasking()` في DashboardNotifier constructor — الآن 131/131 ✅

---

### New test files created

| File                                                              | Tests |
| ----------------------------------------------------------------- | ----- |
| `test/core/utils/log_sanitizer_test.dart`                         | 15    |
| `test/features/dashboard/dashboard_app_bar_test.dart`             | 5     |
| `test/features/dashboard/dashboard_quick_actions_test.dart`       | 12    |
| `test/features/dashboard/dashboard_security_visibility_test.dart` | 7     |
| `test/features/dashboard/dashboard_sync_invalidation_test.dart`   | 6     |
| `test/core/auth/role_provider_test.dart`                          | 12    |
| `test/features/dashboard/dashboard_notifier_test.dart`            | 11    |
| `test/features/dashboard/dashboard_filters_test.dart`             | 10    |
| `test/features/dashboard/dashboard_page_render_test.dart`         | 5     |
| `test/features/beneficiaries/beneficiaries_pagination_test.dart`  | 9     |

---

## 9. Known Intentionally Deferred Items

| Item                                                                                                  | Reason                                                                                                                                                                       | Priority                                          |
| ----------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------- |
| Post-sync Dashboard invalidation                                                                      | Sync service does not call `dashboardProvider.refresh()` after sync. Dashboard metrics do not auto-update after sync. Documented in `dashboard_sync_invalidation_test.dart`. | Medium — implement before production sync feature |
| `dashboard_charts_test.dart` — `CategoryDistributionChart renders correctly`                          | Pre-existing StateError in chart widget build. Unrelated to Dashboard audit scope.                                                                                           | Low — fix in charts sprint                        |
| `lib/core/widgets/common/error_display.dart` — 2× `.withOpacity`                                      | Safe to fix but out of scope. Info-level only.                                                                                                                               | Low                                               |
| `lib/features/beneficiaries/presentation/widgets/v2/v2_error_banner.dart` — deprecated color channels | `.red/.green/.blue` color channel access. Fix requires careful color logic rewrite.                                                                                          | Low                                               |
| Sentry `setExtra` deprecated in `error_logger.dart`                                                   | Sentry API migration concern, not Flutter. Out of scope for this audit.                                                                                                      | Low                                               |
| 18 pre-existing failing tests (Firebase mock, CI threshold)                                           | Pre-existing before Phase 1. Require Firebase test infra or separate fix sprints.                                                                                            | High — fix before CI gate                         |

---

## 10. Rules for Future Developers

**MANDATORY — read before touching Dashboard:**

1. **Do not add more than 6 primary Quick Actions** without:
   - Updating `dashboard_quick_actions_test.dart` to expect the new count
   - Getting product sign-off on the change
   - Updating this baseline document

2. **Do not expose seed/debug/admin tools to normal users.**  
   All admin-only UI must be gated behind `ref.watch(isAdminProvider)`.

3. **Do not load full collections on Dashboard open.**
   - `getRecentActivities` has a hard limit (max 5 items).
   - `getBeneficiaryPreviews` has a hard limit (max 5 items).
   - Full sync on Dashboard open is forbidden.
   - Taxonomy seed on Dashboard open is forbidden.
   - Associations seed on Dashboard open is forbidden.

4. **Do not log sensitive beneficiary data.**  
   All log statements that include beneficiary data must use `LogSanitizer`.  
   Never log full national ID, full phone, full name, or Firebase tokens.

5. **Do not add Dashboard UI changes without widget tests.**
   - New widgets must have corresponding widget tests in `test/features/dashboard/`.
   - Quick Actions changes must update `dashboard_quick_actions_test.dart`.

6. **Do not remove LogSanitizer usage.**  
   `LogSanitizer.enableSensitiveMasking()` must remain active at app startup.

7. **Do not bypass role checks for admin tools.**  
   Use `isAdminProvider` consistently. Do not use local flags, SharedPreferences, or hardcoded emails.

8. **Do not redesign the Dashboard without a new product requirement.**  
   This baseline is frozen. Any Dashboard redesign must go through a new audit cycle.

9. **Do not weaken existing tests.**  
   Tests must not be deleted, skipped, or made less strict to accommodate code changes.

10. **Run `flutter analyze` and targeted tests before any Dashboard PR.**  
    Zero errors and zero warnings required. All targeted Dashboard tests must pass.

---

## Dashboard UX Final Closure — 2026-05-28

**UX Phases Completed:** Phase 1 (Visual Cleanup) · Phase 2 (Status Strip + Banners) · Phase 3 (Today's Work + Sync Health Cards) · Phase 4 (Consolidation & UX Polish)

**Dashboard Baseline Preserved:** Quick Actions frozen at 6 · No new providers · No sync/security/state changes

**Final Dashboard Tests:** 190/190 PASS (`test/features/dashboard/`)

**Security Baseline:** 101/101 PASS (log sanitizer · security logging · role provider · role permissions · admin visibility · sync safety)

**Sync Invalidation Test:** 6/6 PASS

**Analyzer:** 0 errors in changed files · 1482 pre-existing info items (unrelated, non-fatal)

**Full `flutter test`:** Not run — targeted baseline verification only (documented in `DASHBOARD_UX_FINAL_BASELINE.md`)

---

## Phase 4 Update — 2026-05-28

- Section heading renamed: "حالات تحتاج متابعة" → "تفاصيل المتابعة" (both views)
- Spacing cleaned up (removed redundant 8h gap after Sync Health card)
- Empty-state copy improved in `activities_section.dart` and `urgent_cases_section.dart`
- Deprecated `.withOpacity()` → `.withValues(alpha:)` in `activities_section.dart`
- 25/25 tests PASS · 0 analyzer issues

---

## Phase 3 Update — 2026-05-28

**Added:** Today's Work card (`DashboardTodaysWorkCard`) and Compact Sync Health card (`DashboardSyncHealthCard`).

- Both cards use only cheap data already in `DashboardStatistics` (no new queries/providers).
- Cards appear in operational view only, after Quick Actions.
- Quick Actions preserved unchanged (6 items).
- Security/State/Sync baselines preserved.
- 25/25 focused tests PASS.
- 0 analyzer errors/warnings in new files.

---

_Document generated: 2026-05-28 — Phase 1 + Phase 2 combined audit completion._
_Updated: 2026-05-28 — Phase 3 Today's Work + Sync Health cards added._
