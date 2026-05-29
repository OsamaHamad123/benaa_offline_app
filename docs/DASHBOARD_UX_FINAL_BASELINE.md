# DASHBOARD UX FINAL BASELINE

**App:** منظومة بناء — Gaza/Cedar Beneficiary Management  
**Closed:** 2026-05-28  
**Scope:** All Dashboard UX/UI phases (1–4) complete. No further UX changes planned.

---

## 1. Final Dashboard Section Order

### Operational View (default mode, top → bottom)

```
ModernSliverAppBar
  └─ Admin debug tool button: hidden from normal users (role-gated)
OperationalStatusStrip
  └─ Shows online/offline + sync pending count (always visible)
CivilRegistryStatusBanner     [conditional — shown when civil registry data is pending]
TaxonomyStatusBanner          [admin only]
WelcomeBanner                 [normal users only, dismissed on first load]
DashboardSummaryWidget        [key KPI counters]
QuickActionsGrid              [6 items — see §2]
DashboardTodaysWorkCard       [operational view only]
DashboardSyncHealthCard       [operational view only]
SizedBox(24.h)
Row: SectionTitle('عرض البيانات') + Advanced Filters button
FilterChipGroup               [الكل / النشطون / بحاجة زيارة / الطوارئ]
SizedBox(24.h)
SectionTitle('تفاصيل المتابعة')
UrgentCasesSection
SizedBox(24.h)
Row: SectionTitle('الأنشطة الحديثة') + 'عرض الكل' button
RecentActivitiesList
SizedBox(32.h)
```

### Analytical View (toggle mode)

```
[same header through FilterChips]
Charts (mock data — see §10 deferred)
SectionTitle('تفاصيل المتابعة')
UrgentCasesSection
SectionTitle('الأداء اليومي')
[daily performance widgets]
```

---

## 2. Final Quick Actions Spec

| #   | Label        | Icon               | Action                         | Test |
| --- | ------------ | ------------------ | ------------------------------ | ---- |
| 1   | إضافة مستفيد | person_add         | Navigate to add beneficiary    | ✅   |
| 2   | المستفيدون   | people             | Navigate to beneficiaries list | ✅   |
| 3   | زيارات اليوم | calendar_today     | Navigate to today's visits     | ✅   |
| 4   | الكفالات     | volunteer_activism | Navigate to sponsorships       | ✅   |
| 5   | الجمعيات     | corporate_fare     | Navigate to associations       | ✅   |
| 6   | المزامنة     | sync               | Navigate to sync               | ✅   |

**Rules:** Do not add, remove, or reorder Quick Actions without updating `dashboard_quick_actions_test.dart`.

---

## 3. Final AppBar / Admin Visibility Behavior

- `ModernSliverAppBar` renders for all users.
- Admin debug/seed tool button is role-gated: **hidden** from `UserRole.normal` and `UserRole.reviewer`.
- Admin button is visible only to `UserRole.admin` (verified in `admin_tool_visibility_test.dart`).
- No seed data triggers, no direct Firestore writes, no debug tools exposed on Dashboard open.

---

## 4. Final Operational Status Strip Behavior

- Always rendered at top of scrollable content.
- Shows: online/offline indicator + pending sync count.
- Tapping opens sync page via `DashboardNavigationService.navigateToSync`.
- Color changes: green (online, synced) → amber (online, pending) → red (offline).
- Added in Phase 2; preserved unchanged through Phases 3–4.

---

## 5. Final Today's Work Card Behavior (`DashboardTodaysWorkCard`)

- Shown in **operational view only** (after QuickActions, before SyncHealth).
- Reads data from `DashboardStatistics.todayStats` — already-loaded provider, no new query.
- Displays: pending tasks count, today visits count, today new beneficiaries.
- Row label "حالات تحتاج متابعة" inside the card = summary counter label (not renamed — it is distinct from the section title).
- Added in Phase 3. Tests: `dashboard_todays_work_card_test.dart` (10 tests ✅).

---

## 6. Final Sync Health Card Behavior (`DashboardSyncHealthCard`)

- Shown in **operational view only** (after TodaysWorkCard).
- Reads `pendingSync`, `isOnline`, `lastSyncTime` from already-loaded provider — no new query.
- Displays: sync status chip (synced/pending/offline) + last sync timestamp + "افتح المزامنة" button.
- No countdown timers, no auto-refresh triggers.
- Added in Phase 3. Tests: `dashboard_sync_health_card_test.dart` (15 tests ✅).

---

## 7. Final Banner Behavior

- **CivilRegistryStatusBanner:** shown when civil registry data is incomplete; conditional, dismissable.
- **TaxonomyStatusBanner:** admin-only; shown when taxonomy is incomplete.
- **WelcomeBanner:** normal users only; shown once per session.
- **Rule:** Never show more than one top banner at a time. Banners stack only when their conditions are independently true and the role permits.
- Simplified in Phase 2; preserved unchanged through Phases 3–4.

---

## 8. Final Empty-State / Microcopy Improvements

| Widget                                             | Old Text                              | New Text (Phase 4)                            |
| -------------------------------------------------- | ------------------------------------- | --------------------------------------------- |
| `activities_section.dart` — empty state title      | ابدأ بإضافة مستفيدين لرؤية الإحصائيات | لا توجد أنشطة حديثة حتى الآن                  |
| `activities_section.dart` — empty state subtitle   | ستظهر هنا أنشطتك اليومية وتقاريرك     | ستظهر هنا أنشطتك اليومية بعد إضافة أول مستفيد |
| `urgent_cases_section.dart` — empty state title    | لا توجد حالات طارئة                   | أحسنت! لا توجد حالات تحتاج متابعة اليوم       |
| `dashboard_page.dart` — section title (both views) | حالات تحتاج متابعة                    | تفاصيل المتابعة                               |

Icon in `activities_section.dart` empty state changed from `analytics_outlined` → `history_outlined` (better semantic match).  
Deprecated `.withOpacity(0.3)` → `.withValues(alpha: 0.3)` in `activities_section.dart`.

---

## 9. Accessibility / RTL Improvements Completed

- All new widgets (`DashboardTodaysWorkCard`, `DashboardSyncHealthCard`) use `Directionality` RTL-safe layout.
- `Row` children ordered for RTL: icon → label → value (natural Arabic reading order).
- `SizedBox` spacing uses `.h` / `.w` from ScreenUtil (responsive, not hardcoded).
- Empty-state copy uses natural Arabic phrasing (human, not machine-translated).
- No hardcoded colors — all use `DashboardColors` tokens or `Theme.of(context)`.

---

## 10. Remaining Deferred Items

| Item                                                 | Reason Deferred                                                         | Owner          |
| ---------------------------------------------------- | ----------------------------------------------------------------------- | -------------- |
| Chart widgets (analytical view) use mock data        | Not replacing with live queries; out of scope                           | Future plan    |
| Post-sync auto-refresh wiring                        | Known gap, documented in `dashboard_sync_invalidation_test.dart` line 6 | Future plan    |
| Full `flutter test` run                              | Not run; targeted baseline verification only (see §11)                  | Future plan    |
| `.withOpacity()` deprecations in non-dashboard files | Pre-existing, 1482 info items, out of scope                             | Future cleanup |
| Sentry `setExtra` deprecation in `error_logger.dart` | Pre-existing, out of scope                                              | Future cleanup |

---

## 11. Final Test Results (2026-05-28)

| Suite                                                           | Count                     | Result            |
| --------------------------------------------------------------- | ------------------------- | ----------------- |
| `test/features/dashboard/` (all dashboard tests)                | 190                       | ✅ All passed     |
| `test/core/utils/log_sanitizer_test.dart`                       | included in 101           | ✅                |
| `test/core/security/security_logging_test.dart`                 | included in 101           | ✅                |
| `test/core/auth/role_provider_test.dart`                        | included in 101           | ✅                |
| `test/core/auth/role_permissions_test.dart`                     | included in 101           | ✅                |
| `test/features/security/admin_tool_visibility_test.dart`        | included in 101           | ✅                |
| `test/features/sync/sync_safety_test.dart`                      | included in 101           | ✅                |
| **Security + Auth baseline total**                              | **101**                   | **✅ All passed** |
| `test/features/dashboard/dashboard_sync_invalidation_test.dart` | 6                         | ✅ All passed     |
| **flutter analyze --no-fatal-infos**                            | 0 errors in changed files | ✅                |

> Note: Full `flutter test` was **not** run. Closure used targeted baseline verification. Pre-existing info-level items (1482) are unrelated to Dashboard UX changes.

---

## 12. Rules for Future Dashboard Changes

1. **Do not change Quick Actions** without updating `dashboard_quick_actions_test.dart` and documenting the change here.
2. **Do not expose debug/admin/seed tools** to `UserRole.normal` or `UserRole.reviewer`.
3. **Do not add heavy providers or queries** to the Dashboard open path (all data must come from already-loaded providers).
4. **Do not add multiple top banners** simultaneously without role/condition gating.
5. **Do not remove the Operational Status Strip** without a direct replacement that shows online/offline + sync state.
6. **Do not add Dashboard features** without focused widget tests (minimum: widget renders, empty state, data state).
7. **Keep Arabic/RTL microcopy clear and human** — avoid machine-translated phrasing; use natural Egyptian/Levantine Arabic.
8. **Do not start a new Dashboard phase** without creating a new phase plan doc and getting test baseline results first.
9. **Do not inline Firestore/sync logic** into Dashboard widgets — route through existing providers and repositories.
10. **Document deferred items** in this file when closing a phase, rather than silently leaving them.
