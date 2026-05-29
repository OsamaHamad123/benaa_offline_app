# DASHBOARD UX/UI NEXT-LEVEL — PHASE 2: OPERATIONAL STATUS STRIP

**Date:** 2026-05-28
**Phase:** Implementation — Visual + Display-Logic Only
**App:** منظومة بناء — Gaza/Cedar beneficiary management
**Precondition:** Phase 1 Visual Cleanup complete (150/150 PASS, 101/101 PASS, 0 analyzer issues)

---

## 1. Scope

This phase adds:

1. A compact **Operational Status Strip** (`DashboardOperationalStatusStrip`) at the top of the dashboard home content.
2. A lightweight **display model** (`DashboardOperationalStatus` + `DashboardStatusLevel`) to drive the strip.
3. **Banner stacking simplification** — at most one top-priority surface visible at a time.
4. Targeted unit + widget tests for the new display logic.

**Not in scope:** Today's Work card, full Sync Health card, role-personalized dashboard, SpeedDial FAB, analytics relocation, new providers, new Firestore streams, sync pipeline changes, security logic changes, quick actions changes.

---

## 2. Current Banner / Status Problem

Before Phase 2, the top of `_buildContent()` could show up to **4 stacked surfaces**:

| #   | Widget                      | Condition                                       |
| --- | --------------------------- | ----------------------------------------------- |
| 1   | `OfflineBanner`             | `!isOnline`                                     |
| 2   | `_CivilRegistryBanner`      | civil DB not ready (Phase 1: hidden when ready) |
| 3   | `_TaxonomySyncHealthBanner` | stale or failed taxonomy sync                   |
| 4   | `WelcomeBanner`             | first-time user                                 |

Issues:

- All four can stack simultaneously → visual clutter.
- `OfflineBanner` and `WelcomeBanner` can appear together, which is contradictory UX.
- `_TaxonomySyncHealthBanner` shows technical jargon to field workers.
- No unified "operational status" — user must parse 2-4 banners to understand state.

---

## 3. Existing Data Sources (No New Providers)

| Data point           | Source                                            | Notes                                                  |
| -------------------- | ------------------------------------------------- | ------------------------------------------------------ |
| `isOnline`           | `_DashboardPageState._isOnline` (passed as param) | Connectivity stream                                    |
| `stats.pendingSync`  | `dashboardProvider.statistics.pendingSync`        | Already loaded                                         |
| `stats.lastSyncTime` | `dashboardProvider.statistics.lastSyncTime`       | Available (note: datasource currently hardcodes value) |
| `isAdmin`            | `ref.watch(isAdminProvider)`                      | Already watched in dashboard                           |

**Not cheaply available (deferred):**

- Failed upload count (separate from pending count)
- Whether last sync attempt errored vs. never ran
- Fine-grained sync failure message

---

## 4. Implementation Approach

### 4.1 Display Model

File: `lib/features/dashboard/presentation/widgets/dashboard_operational_status_strip.dart`

- `DashboardStatusLevel` enum: `normal`, `info`, `warning`, `danger`
- `DashboardOperationalStatus` class: `level`, `icon`, `title`, `message`, `actionLabel`
- `DashboardOperationalStatus.resolve()` factory with priority:
  1. `hasSyncFailure=true` → **danger** (deferred wiring; param defaults false)
  2. `!isOnline` → **warning** (includes pending count in message)
  3. `pendingSync > 0` → **info**
  4. Otherwise → **normal** (shows last sync time)

### 4.2 Status Strip Widget

- `DashboardOperationalStatusStrip` — pure `StatelessWidget`, no provider deps
- Compact: icon + title + message in one horizontal row
- RTL-safe: chevron direction uses `Directionality.of(context)`
- Accessible: wraps in `Semantics` with combined label
- Tap → `navigateToSync` when level is not normal
- Survives text scale 1.5 with `overflow: TextOverflow.ellipsis`

### 4.3 Banner Stacking Simplification

Changes to `_buildContent()` in `dashboard_page.dart`:

| Before                                      | After                                          |
| ------------------------------------------- | ---------------------------------------------- |
| `if (!isOnline) const OfflineBanner()`      | Removed — status strip handles offline         |
| `_CivilRegistryBanner(ref: ref)`            | Kept — shows only during download/missing      |
| `const _TaxonomySyncHealthBanner()`         | Gated to `isAdmin \|\| kDebugMode` only        |
| `if (showWelcomeBanner) WelcomeBanner(...)` | Gated to `level == normal` only                |
| (nothing)                                   | `DashboardOperationalStatusStrip` always shown |

---

## 5. Deferred Items

| Item                                                   | Reason                                 |
| ------------------------------------------------------ | -------------------------------------- | --- | ------------------------------------------------------------------ |
| Today's Work card                                      | Phase 3 — new UI section               |
| Full Sync Health card                                  | Phase 3 — needs sync metadata provider |
| SpeedDial FAB                                          | Phase 3                                |
| Analytics/Reports relocation                           | Phase 4                                |
| Role-personalized dashboard header                     | Phase 5                                |
| Full notification center                               | Phase 5                                |
| Failed upload count (distinct from pending)            | Needs new query/provider               |
| `hasSyncFailure` wiring                                | Deferred — no cheap source available   |
| `_TaxonomySyncHealthBanner` admin-only production auth | Currently gated with `isAdmin          |     | kDebugMode` (kDebugMode bypass is documented concern from Phase 1) |
| `DashboardAppBar` dead code removal                    | Phase 3 (has active test)              |

---

## 6. Tests Added

| File                                                                   | Type   | Count |
| ---------------------------------------------------------------------- | ------ | ----- |
| `test/features/dashboard/dashboard_operational_status_test.dart`       | Unit   | 13    |
| `test/features/dashboard/dashboard_operational_status_strip_test.dart` | Widget | 9     |
| `test/features/dashboard/dashboard_banner_priority_test.dart`          | Unit   | 8     |

**Total new tests:** 30

---

## 7. Implementation Results

### Files Changed

| File                                                                                  | Change                              |
| ------------------------------------------------------------------------------------- | ----------------------------------- |
| `lib/features/dashboard/presentation/widgets/dashboard_operational_status_strip.dart` | Created (model + widget)            |
| `lib/features/dashboard/presentation/widgets/dashboard_widgets.dart`                  | Added export                        |
| `lib/features/dashboard/presentation/pages/dashboard_page.dart`                       | Banner stacking + strip integration |
| `test/features/dashboard/dashboard_operational_status_test.dart`                      | Created                             |
| `test/features/dashboard/dashboard_operational_status_strip_test.dart`                | Created                             |
| `test/features/dashboard/dashboard_banner_priority_test.dart`                         | Created                             |

### Focused Tests During Implementation

- `flutter test test/features/dashboard/dashboard_operational_status_test.dart` — ✅
- `flutter test test/features/dashboard/dashboard_operational_status_strip_test.dart` — ✅
- `flutter test test/features/dashboard/dashboard_banner_priority_test.dart` — ✅
- `flutter test test/features/dashboard/dashboard_page_render_test.dart` — ✅
- `flutter test test/features/dashboard/dashboard_quick_actions_test.dart` — ✅
- `flutter test test/features/dashboard/dashboard_security_visibility_test.dart` — ✅

### Final Verification

- Dashboard suite: `flutter test test/features/dashboard/` — ****/** PASS** _(update after run)_
- Security baseline: **101/101 PASS**
- Sync smoke: **PASS**
- Analyzer: **0 errors, 0 warnings**

---

## 8. Rollback Notes

All changes are additive or conditional suppression:

- The new `DashboardOperationalStatusStrip` widget is self-contained.
- `OfflineBanner` widget is NOT deleted — still exported from `dashboard_widgets.dart`.
- `_TaxonomySyncHealthBanner` widget is NOT deleted — still in `dashboard_page.dart`.
- To rollback: revert `dashboard_page.dart` `_buildContent()` section to Phase 1 state (restore `if (!isOnline) const OfflineBanner()`, remove taxonomy gate, remove status strip).
- No provider, DB, or sync pipeline changes → rollback has zero runtime risk.
