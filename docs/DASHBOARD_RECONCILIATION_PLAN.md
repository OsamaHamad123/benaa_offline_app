# DASHBOARD RECONCILIATION PLAN

**Date:** 2026-05-28  
**Purpose:** Reconcile audit reports with current codebase state, define exact remaining work.

---

## 1. WHAT THE REPORTS REQUESTED

| #   | Request                                                               | Source                         |
| --- | --------------------------------------------------------------------- | ------------------------------ |
| 1   | Gate admin/monitoring tools behind `isAdminProvider`                  | SECURITY_PRIVACY_AUDIT         |
| 2   | Remove TaxonomyStatusBadge from AppBar (technical, not user-facing)   | DASHBOARD_UX_PERFORMANCE_AUDIT |
| 3   | Move Export button to popup menu gated by admin                       | DASHBOARD_UX_PERFORMANCE_AUDIT |
| 4   | Reduce Quick Actions to exactly 6, all unconditional                  | DASHBOARD_UX_PERFORMANCE_AUDIT |
| 5   | Label: "الزيارات" → "زيارات اليوم"                                    | DASHBOARD_UX_PERFORMANCE_AUDIT |
| 6   | Add `autoDispose` to FutureProviders                                  | DASHBOARD_UX_PERFORMANCE_AUDIT |
| 7   | Fix `Future.microtask` race condition                                 | STATE_MANAGEMENT_AUDIT         |
| 8   | Add `provider.select()` for targeted rebuilds                         | STATE_MANAGEMENT_AUDIT         |
| 9   | Avoid watching `trendChartDataProvider` in operational mode           | STATE_MANAGEMENT_AUDIT         |
| 10  | Create and USE `LogSanitizer` (masking nationalId, phone, name)       | SECURITY_PRIVACY_AUDIT         |
| 11  | Create `isAdminProvider` using Firebase Auth token claims             | SECURITY_PRIVACY_AUDIT         |
| 12  | Fix duplicate Firestore rules for `/associations` and `/sponsorships` | SECURITY_PRIVACY_AUDIT         |
| 13  | Add performance logs: `[Dashboard] loadMetrics started/completed`     | DASHBOARD_UX_PERFORMANCE_AUDIT |
| 14  | Dashboard previews load max 3–5 items, not full collections           | PAGINATION_STRATEGY            |
| 15  | Delete old/conflicting tests, create new comprehensive test suite     | DASHBOARD_UX_PERFORMANCE_AUDIT |
| 16  | Create `docs/DASHBOARD_TESTING_STRATEGY.md`                           | All reports                    |
| 17  | Post-sync: invalidate Dashboard providers                             | STATE_MANAGEMENT_AUDIT         |

---

## 2. WHAT IS ALREADY IMPLEMENTED

| #   | Item                                                                  | Status  | File                                              |
| --- | --------------------------------------------------------------------- | ------- | ------------------------------------------------- |
| 1   | `LogSanitizer` class created                                          | ✅ Done | `lib/core/utils/log_sanitizer.dart`               |
| 2   | `isAdminProvider` + `userRoleProvider` created                        | ✅ Done | `lib/core/auth/role_provider.dart`                |
| 3   | `DashboardAppBar` reads `isAdminProvider` internally                  | ✅ Done | `presentation/widgets/dashboard_app_bar.dart`     |
| 4   | `Future.microtask` race condition fixed                               | ✅ Done | `presentation/state/dashboard_notifier.dart`      |
| 5   | `autoDispose` added to 5 FutureProviders                              | ✅ Done | `presentation/providers/dashboard_providers.dart` |
| 6   | Duplicate Firestore rules for `/associations`/`/sponsorships` removed | ✅ Done | `firestore.rules`                                 |
| 7   | Quick actions reduced from 8 to 6 in grid layout                      | ✅ Done | `presentation/widgets/quick_actions.dart`         |
| 8   | `statValue` font 28.sp → 24.sp                                        | ✅ Done | `presentation/utils/dashboard_text_styles.dart`   |
| 9   | `ref.watch(dashboardProvider.select(...))` for `pendingTasksCount`    | ✅ Done | `presentation/pages/dashboard_page.dart`          |

---

## 3. WHAT WAS PARTIALLY IMPLEMENTED (All resolved in Phase 1)

| #   | Item                | What Was Done                    | Resolution (Phase 1)                                                                           |
| --- | ------------------- | -------------------------------- | ---------------------------------------------------------------------------------------------- |
| 1   | `DashboardAppBar`   | Rewritten with admin gate        | ✅ Wired into `dashboard_page.dart` — `ModernSliverAppBar` replaced with `DashboardAppBar`     |
| 2   | Quick Actions       | 6 cards defined                  | ✅ Kafalat & Associations are unconditional — all 6 always rendered                            |
| 3   | Quick Action labels | "المستفيدون", "الزيارات" defined | ✅ Label changed to "زيارات اليوم"                                                             |
| 4   | Admin tool gating   | `isAdminProvider` created        | ✅ Applied in `DashboardAppBar` — `TaxonomyStatusBadge` removed, `Export` moved to admin popup |
| 5   | `provider.select()` | Used for `pendingTasksCount`     | ⏸ `trendChartDataProvider` still watched unconditionally — deferred, info-level only           |
| 6   | `LogSanitizer`      | Class exists with all methods    | ✅ Used in `DashboardNotifier` logs and enabled at startup                                     |
| 7   | Performance logs    | None yet                         | ✅ `[Dashboard] loadMetrics started/completed ms=X` added to notifier                          |

---

## 4. IMPLEMENTATION STATUS (Updated 2026-05-28 — Phase 1 + Phase 2 Complete)

| #   | Item                                                                          | Status     | Notes                                                    |
| --- | ----------------------------------------------------------------------------- | ---------- | -------------------------------------------------------- |
| 1   | Gate `TaxonomyStatusBadge` and `Export` button in AppBar behind `isAdmin`     | ✅ Done    | Phase 1                                                  |
| 2   | Add admin popup menu in AppBar for: Export, Monitoring, Diagnostics           | ✅ Done    | Phase 1                                                  |
| 3   | Remove conditional rendering for Kafalat & Associations in `QuickActionsGrid` | ✅ Done    | Phase 1                                                  |
| 4   | Label "الزيارات" → "زيارات اليوم"                                             | ✅ Done    | Phase 1                                                  |
| 5   | Conditional watch of `trendChartDataProvider` (only in analytical mode)       | ⏸ Deferred | Low priority — info-level only                           |
| 6   | Use `LogSanitizer` in `dashboard_notifier.dart` error/info logs               | ✅ Done    | Phase 1                                                  |
| 7   | Add `[Dashboard] loadMetrics` logs to notifier                                | ✅ Done    | Phase 1                                                  |
| 8   | Sync status section/card in Dashboard (last sync, pending count, button)      | ⏸ Deferred | Not in scope                                             |
| 9   | Post-sync invalidation of dashboard providers                                 | ⏸ Deferred | Documented gap — `dashboard_sync_invalidation_test.dart` |
| 10  | Beneficiaries pagination (load 20–30 per page, not all)                       | ✅ Done    | Phase 2 — `InfiniteScrollNotifier` + 9 tests             |
| 11  | New comprehensive test suite (92 tests across 10 files)                       | ✅ Done    | Phase 1 + Phase 2                                        |
| 12  | `docs/DASHBOARD_TESTING_STRATEGY.md`                                          | ✅ Done    | Phase 1                                                  |
| 13  | Confirm `sync_health_checks` Firestore rules                                  | ⏸ Deferred | Out of Dashboard scope                                   |

---

## 5. OLD TESTS REQUIRING DELETION/REPLACEMENT

| File                                                                        | Reason for Deletion/Replacement                                                                             |
| --------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| `test/features/dashboard/presentation/widgets/quick_actions_test.dart.skip` | Skipped; asserts old 8-action grid and old labels; conflicts with new 6-action spec                         |
| `test/features/dashboard/dashboard_performance_test.dart`                   | Tests only math calculations (RepaintBoundary %, haptic timing) — no actual widget/provider behavior tested |

**Keep (with no changes needed):**

- `statistics_section_test.dart` — tests `StatCard` widget independently, still valid
- `activities_logic_test.dart`, `activities_section_test.dart` — test activities logic, still valid
- `daily_performance_section_test.dart` — tests DailyPerformanceSection, still valid
- `urgent_cases_section_test.dart` — tests UrgentCasesSection, still valid

---

## 6. FINAL IMPLEMENTATION CHECKLIST (Phase 1 + Phase 2 — All Done ✅)

### Phase A — Dashboard AppBar (ModernSliverAppBar in dashboard_page.dart)

- [x] A1: Remove `TaxonomyStatusBadge` from main AppBar actions (move to admin popup or remove entirely)
- [x] A2: Move `Export` button to admin-gated popup menu
- [x] A3: Keep only Search + Notifications in visible AppBar actions
- [x] A4: Add admin popup menu for: Export, Monitoring, Taxonomy Management

### Phase B — Quick Actions

- [x] B1: Remove `if (onKafalatTap != null)` and `if (onAssociationsTap != null)` guards
- [x] B2: Change "الزيارات" label to "زيارات اليوم"

### Phase C — Performance

- [ ] C1: Conditional `trendChartDataProvider` watch (only in analytical mode) — _deferred, low priority_
- [x] C2: Add `[Dashboard] loadMetrics started/completed ms=X` logs to notifier

### Phase D — Security/Privacy

- [x] D1: Use `LogSanitizer.maskNationalId()` / `maskPhone()` / `maskName()` in notifier error logs
- [x] D2: Add `[Security] sensitive log masking enabled` log on startup

### Phase E — Tests

- [x] E1: Delete `quick_actions_test.dart.skip`
- [x] E2: Delete `dashboard_performance_test.dart` (replace with real tests)
- [x] E3: Create `test/core/utils/log_sanitizer_test.dart`
- [x] E4: Create `test/features/dashboard/dashboard_quick_actions_test.dart`
- [x] E5: Create `test/features/dashboard/dashboard_security_visibility_test.dart`
- [x] E6: Create `test/features/dashboard/dashboard_app_bar_test.dart`
- [x] E7: Create `docs/DASHBOARD_TESTING_STRATEGY.md`
- [x] E8: Create `test/core/auth/role_provider_test.dart` (Phase 2)
- [x] E9: Create `test/features/dashboard/dashboard_notifier_test.dart` (Phase 2)
- [x] E10: Create `test/features/dashboard/dashboard_filters_test.dart` (Phase 2)
- [x] E11: Create `test/features/dashboard/dashboard_page_render_test.dart` (Phase 2)
- [x] E12: Create `test/features/beneficiaries/beneficiaries_pagination_test.dart` (Phase 2)

### Phase F — Docs

- [x] F1: Update `DASHBOARD_UX_PERFORMANCE_AUDIT.md` — add "Implementation Status" section
- [x] F2: Update `STATE_MANAGEMENT_AUDIT.md` — add "Implemented Fixes" section
- [x] F3: Update `SECURITY_PRIVACY_AUDIT.md` — add "Implemented Fixes" section
- [x] F4: Update `PAGINATION_STRATEGY.md` — add "Implemented / Remaining" section
- [x] F5: Create `docs/DASHBOARD_PRODUCTION_QA_CHECKLIST.md` (Phase 2)
- [x] F6: Create `docs/DASHBOARD_BASELINE_2026_05_28.md` (Phase 2)
