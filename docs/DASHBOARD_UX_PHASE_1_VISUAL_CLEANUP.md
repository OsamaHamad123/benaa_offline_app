# DASHBOARD UX — PHASE 1: VISUAL CLEANUP

**Date:** 2026-05-28  
**Phase:** Phase 1 — Visual Cleanup Only  
**Input Plan:** `docs/DASHBOARD_UX_NEXT_LEVEL_PLAN.md`  
**Reference Baseline:** `docs/DASHBOARD_BASELINE_2026_05_28.md`

> **SCOPE NOTICE:** This phase is visual cleanup ONLY.  
> No new cards, no new architecture, no provider refactor, no sync/security/auth logic changes.  
> All baselines (Dashboard 150/150, Security 101/101, Sync targets, Analyzer 0 errors) must remain intact.

---

## 1. Scope

Phase 1 targets the safest visual cleanup items identified in `DASHBOARD_UX_NEXT_LEVEL_PLAN.md`:

- Microcopy label improvements (no route/logic changes)
- Mode switcher: hide orphan chip when feature flag is off; rename chips when both are visible
- Section title rename: "التصنيفات السريعة" → "عرض البيانات"
- Notification snackbar text clarity
- Banner stacking: hide "all-green" Civil Registry banner when already ready
- RTL icon fix: ActivityItem trailing chevron
- RTL icon fix: "عرض الكل" arrows in Recent Activities section

---

## 2. Files Inspected

| File                                                                        | Status                                                     |
| --------------------------------------------------------------------------- | ---------------------------------------------------------- |
| `docs/DASHBOARD_UX_NEXT_LEVEL_PLAN.md`                                      | ✅ Read — source plan                                      |
| `docs/DASHBOARD_BASELINE_2026_05_28.md`                                     | ✅ Read — baseline contracts                               |
| `lib/features/dashboard/presentation/pages/dashboard_page.dart`             | ✅ Read — full page (1100+ lines)                          |
| `lib/features/dashboard/presentation/widgets/dashboard_app_bar.dart`        | ✅ Read — dead code (2 DashboardAppBar variants exist)     |
| `lib/features/dashboard/presentation/widgets/dashboard_summary_widget.dart` | ✅ Read — already uses FittedBox, no overflow risk         |
| `lib/features/dashboard/presentation/widgets/activities_section.dart`       | ✅ Read — trailing icon LTR-only                           |
| `lib/features/dashboard/presentation/widgets/banners/offline_banner.dart`   | ✅ Read — icon + text, accessible                          |
| `lib/features/dashboard/presentation/utils/dashboard_text_styles.dart`      | ✅ Read — statValue already 24.sp                          |
| `lib/features/dashboard/presentation/utils/dashboard_colors.dart`           | ✅ Read — color system consistent                          |
| `test/features/dashboard/dashboard_filters_test.dart`                       | ✅ Read — tests FilterChipGroup labels (not section title) |
| `test/features/dashboard/dashboard_quick_actions_test.dart`                 | ✅ Read — tests Quick Actions labels                       |
| `test/features/dashboard/dashboard_page_render_test.dart`                   | ✅ Read — tests isolated widget rendering                  |
| `test/features/dashboard/dashboard_security_visibility_test.dart`           | ✅ Read — tests LogSanitizer                               |
| `test/features/dashboard/dashboard_app_bar_test.dart`                       | ✅ Read — tests dead-code DashboardAppBar widget           |

---

## 3. Low-Risk Changes Selected

### Change 1 — Notification Snackbar Microcopy

**File:** `dashboard_page.dart`  
**Location:** `_buildDashboard()` → ModernActionButton `onPressed` for notifications  
**Before:** `'لديك $count مهمة معلقة'` / `'لا توجد مهام معلقة'`  
**After:** `'$count سجل بانتظار الرفع'` / `'لا توجد سجلات معلقة'`  
**Reason:** "مهمة معلقة" is vague; "سجل بانتظار الرفع" directly describes what the count means to a field worker.  
**Risk:** Zero — display text only, no logic change

---

### Change 2 — Section Title: "التصنيفات السريعة" → "عرض البيانات"

**File:** `dashboard_page.dart`  
**Location:** `_buildContent()` → filter chips section header SectionTitle  
**Before:** `title: 'التصنيفات السريعة'`  
**After:** `title: 'عرض البيانات'`  
**Reason:** "التصنيفات السريعة" sounds like taxonomy browsing. "عرض البيانات" clearly communicates that these chips filter/scope what's displayed.  
**Risk:** Zero — label text only; `dashboard_filters_test.dart` tests FilterChipGroup chip labels (الكل/اليوم/هذا الأسبوع/تحتاج متابعة), NOT the SectionTitle text. No test update needed.

---

### Change 3 — Mode Switcher: Hide When Feature Flag Off, Rename When Visible

**File:** `dashboard_page.dart`  
**Locations:**

- `_buildContent()`: call site of `_buildHomeModeSwitcher()`
- `_buildHomeModeSwitcher()`: method body

**Before:**

- Always renders (even when `!enableAnalyticalMode`), showing lone "تشغيلي" chip
- Labels: "تشغيلي" / "تحليلي"

**After:**

- When `!enableAnalyticalMode`: not rendered (hidden completely)
- When `enableAnalyticalMode=true`: renders both chips with labels "عرض مبسط" / "عرض تفصيلي"

**Reason:** A single permanently-selected chip is confusing UX. "عرض مبسط"/"عرض تفصيلي" is clearer than "تشغيلي"/"تحليلي".  
**Risk:** Very low — `enableAnalyticalMode=false` means the operational mode is always effective anyway (see `effectiveViewMode` calculation). No tests assert on "تشغيلي" or "تحليلي" labels. No route or logic change.

---

### Change 4 — Civil Registry Banner: Hide When Already Ready

**File:** `dashboard_page.dart`  
**Location:** `_CivilRegistryBanner.build()` — early return when `isReady`  
**Before:** Always renders (green "السجل المدني جاهز" banner adds clutter when already fine)  
**After:** Returns `SizedBox.shrink()` when `isReady=true` (no need to announce success permanently)  
**Reason:** Reduces maximum banner stacking from 4 to 3 without adding any new priority logic. The "not loaded" and "downloading" states still show correctly.  
**Risk:** Very low — the "all good" green banner only hides; warning states remain fully visible.

---

### Change 5 — "عرض الكل" Arrow: RTL-Safe Icon

**File:** `dashboard_page.dart`  
**Locations:** Two `TextButton.icon` with `Icons.arrow_forward` in Recent Activities header rows (operational and analytical branches)  
**Before:** `const Icon(Icons.arrow_forward, size: 16)` — LTR-directional  
**After:** `Icon(Directionality.of(context) == TextDirection.rtl ? Icons.arrow_back : Icons.arrow_forward, size: 16)` — RTL-aware  
**Reason:** In Arabic RTL layout, "view all" arrow should point left (→ left = "forward" in RTL)  
**Risk:** Very low — display-only icon, no logic change. App is Arabic RTL so this always renders `Icons.arrow_back`.

---

### Change 6 — ActivityItem Trailing Chevron: RTL-Safe Icon

**File:** `lib/features/dashboard/presentation/widgets/activities_section.dart`  
**Location:** `ActivityItem.build()` → `trailing: Icon(Icons.chevron_right, ...)`  
**Before:** `trailing: Icon(Icons.chevron_right, size: 20.sp)` — LTR-only  
**After:** `trailing: Icon(Directionality.of(context) == TextDirection.rtl ? Icons.chevron_left : Icons.chevron_right, size: 20.sp)` — RTL-aware  
**Reason:** Trailing navigation icons in RTL lists should point left.  
**Risk:** Very low — display-only icon change.

---

## 4. Items Intentionally Deferred

| Deferred Item                                       | Reason                                                                                                                                                                                                           |
| --------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Today's Work card                                   | New widget/architecture — Phase 3                                                                                                                                                                                |
| Compact Sync Health card                            | New widget/architecture — Phase 3                                                                                                                                                                                |
| Priority Alerts strip (full banner priority engine) | New logic — Phase 2/3                                                                                                                                                                                            |
| Role-personalized dashboard header                  | Needs role-aware rendering — Phase 5                                                                                                                                                                             |
| SpeedDial FAB                                       | New interaction pattern — Phase 4                                                                                                                                                                                |
| Analytics/reporting page relocation                 | Page restructure — Phase 6                                                                                                                                                                                       |
| `DashboardAppBar` dead code removal                 | There are 2 DashboardAppBar variants (features + core); `dashboard_app_bar_test.dart` imports and tests the features widget. Removing without updating test risks a baseline break. Deferred to Phase 3 cleanup. |
| Swipe-to-delete removal on ActivityItem             | Behavior change; needs careful UX decision — Phase 3                                                                                                                                                             |
| ActivityItem swipe direction RTL fix                | Touches SwipeableCard behavior — deferred to Phase 4                                                                                                                                                             |
| DashboardSummaryWidget header cleanup               | Already uses FittedBox; statValue is 24.sp (acceptable). Minor cleanup in Phase 2 optional.                                                                                                                      |
| Refresh IconButton removal from filter row          | Could affect usability — left for Phase 2 review                                                                                                                                                                 |
| Welcome Banner stacking-priority logic              | Needs alert priority engine — Phase 2/3                                                                                                                                                                          |
| WCAG contrast audit                                 | Research + testing needed — Phase 4                                                                                                                                                                              |
| Focus order / keyboard navigation audit             | Research needed — Phase 4                                                                                                                                                                                        |

---

## 5. Tests to Run

### During Implementation (focused only)

```
flutter test test/features/dashboard/dashboard_quick_actions_test.dart
flutter test test/features/dashboard/dashboard_filters_test.dart
flutter test test/features/dashboard/dashboard_page_render_test.dart
flutter test test/features/dashboard/dashboard_app_bar_test.dart
```

### At End (verification)

```
flutter test test/features/dashboard/
flutter test test/core/utils/log_sanitizer_test.dart test/core/security/security_logging_test.dart test/core/auth/role_provider_test.dart test/core/auth/role_permissions_test.dart test/features/security/admin_tool_visibility_test.dart test/features/sync/sync_safety_test.dart
flutter test test/features/dashboard/dashboard_sync_invalidation_test.dart
flutter analyze --no-fatal-infos
```

---

## 6. Rollback Notes

All changes in this phase are label/icon changes. To roll back:

- `dashboard_page.dart`: revert string literals and icon references (6 changes in 1 file)
- `activities_section.dart`: revert one icon reference

No new files created. No files deleted. No providers changed. No routes changed.  
Git: `git diff lib/features/dashboard/` shows all changes; `git checkout lib/features/dashboard/` reverts all.

---

## 7. Implementation Results

_(Filled in after implementation)_

### Changes Implemented

- [x] Change 1: Notification snackbar text → "سجل بانتظار الرفع"
- [x] Change 2: Section title → "عرض البيانات"
- [x] Change 3: Mode switcher hidden when feature flag off; renamed to "عرض مبسط"/"عرض تفصيلي"
- [x] Change 4: \_CivilRegistryBanner hides when isReady
- [x] Change 5: "عرض الكل" arrow RTL-safe (2 places)
- [x] Change 6: ActivityItem trailing chevron RTL-safe

### Tests Run During Implementation

| Test File                           | Result  |
| ----------------------------------- | ------- |
| `dashboard_quick_actions_test.dart` | ✅ PASS |
| `dashboard_filters_test.dart`       | ✅ PASS |
| `dashboard_page_render_test.dart`   | ✅ PASS |
| `dashboard_app_bar_test.dart`       | ✅ PASS |

### Final Verification

| Suite                                   | Result                  |
| --------------------------------------- | ----------------------- |
| `flutter test test/features/dashboard/` | ✅ PASS                 |
| Security baseline                       | ✅ PASS                 |
| Sync smoke                              | ✅ PASS                 |
| `flutter analyze --no-fatal-infos`      | ✅ 0 errors, 0 warnings |

### Deferred Items

_(see Section 4 above — all deferred, none added during implementation)_

---

## 8. Confirmations

- ✅ No Dashboard redesign
- ✅ Quick Actions unchanged (exactly 6)
- ✅ No provider/sync/security logic changed
- ✅ No AppBar structure changed
- ✅ No route names changed
- ✅ No new widgets added
- ✅ No files deleted
- ✅ Security/State/Sync baselines preserved
- ✅ No broad refactor
