# STATE MANAGEMENT IMPLEMENTATION PLAN

**Date:** 2026-05-28  
**Phase:** State Management Audit Implementation  
**Baseline:** Dashboard 131/131 ✅ | Security 101/101 ✅ | Analyzer 0 errors 0 warnings ✅

---

## 1. EXISTING STATE PROVIDERS INVENTORY

### 1.1 Dashboard Core Providers

| Provider                           | File                               | Type                                                                | autoDispose                                   | Status                                              |
| ---------------------------------- | ---------------------------------- | ------------------------------------------------------------------- | --------------------------------------------- | --------------------------------------------------- |
| `dashboardProvider`                | `providers.dart`                   | `StateNotifierProvider<DashboardNotifier, DashboardState>`          | ❌ No (intentional — global)                  | In use                                              |
| `dashboardSummaryProvider`         | `dashboard_providers.dart`         | `FutureProvider.autoDispose` + 30s keepAlive                        | ✅ Yes                                        | In use by `DashboardSummaryWidget`                  |
| `dailyPerformanceProvider`         | `dashboard_providers.dart`         | `FutureProvider.autoDispose`                                        | ✅ Yes (already fixed)                        | Used by widgets                                     |
| `urgentCasesProvider`              | `dashboard_providers.dart`         | `FutureProvider.autoDispose`                                        | ✅ Yes (already fixed)                        | Used by widgets                                     |
| `geographicDistributionProvider`   | `dashboard_providers.dart`         | `FutureProvider.autoDispose`                                        | ✅ Yes (already fixed)                        | Used by widgets                                     |
| `pendingSyncCountProvider`         | `dashboard_providers.dart`         | `FutureProvider.autoDispose`                                        | ✅ Yes (already fixed)                        | **DUPLICATE** of `dashboardSummaryProvider.pending` |
| `dataQualityProvider`              | `dashboard_providers.dart`         | `FutureProvider.autoDispose`                                        | ✅ Yes (already fixed)                        | Uses **hardcoded 0.85** estimate — fake data        |
| `dashboardUIStateProvider`         | `dashboard_ui_state_provider.dart` | `StateNotifierProvider<DashboardUIStateNotifier, DashboardUIState>` | ❌ No                                         | **DEFINED BUT UNUSED** in `dashboard_page.dart`     |
| `dashboardSettingsProvider`        | `dashboard_settings_provider.dart` | `StateNotifierProvider`                                             | ❌ No                                         | Used by settings panel widgets                      |
| `trendChartDataProvider`           | `providers.dart`                   | `Provider<List<double>>`                                            | ❌ No (derived from dashboardProvider.select) | Used in analytical mode only (conditional) ✅       |
| `trendChartLabelsProvider`         | `providers.dart`                   | `Provider<List<String>>`                                            | ❌ No (derived)                               | Used in analytical mode only                        |
| `notificationsCountProvider`       | `providers.dart`                   | `Provider<int>`                                                     | ❌ No (derived)                               | Derived from `dashboardProvider`                    |
| `todayStatsAutoRefreshProvider`    | `providers.dart`                   | `FutureProvider.autoDispose` + 2min keepAlive                       | ✅ Yes                                        | Convenience provider                                |
| `dashboardLocalDataSourceProvider` | `providers.dart`                   | `Provider`                                                          | ❌ No                                         | Infrastructure                                      |
| `dashboardRepositoryProvider`      | `providers.dart`                   | `Provider`                                                          | ❌ No                                         | Infrastructure                                      |
| `getDashboardStatisticsProvider`   | `providers.dart`                   | `Provider`                                                          | ❌ No                                         | Use-case provider                                   |
| `getTodayStatsProvider`            | `providers.dart`                   | `Provider`                                                          | ❌ No                                         | Use-case provider                                   |
| `getRecentActivitiesProvider`      | `providers.dart`                   | `Provider`                                                          | ❌ No                                         | Use-case provider                                   |

### 1.2 Taxonomy Providers Watched in Dashboard

| Provider                     | File                      | Impact                                                                   |
| ---------------------------- | ------------------------- | ------------------------------------------------------------------------ |
| `taxonomySyncStatusProvider` | `taxonomy_providers.dart` | Watched in `_TaxonomySyncHealthBanner` — full rebuild on taxonomy change |
| `taxonomyStatisticsProvider` | `taxonomy_providers.dart` | Watched in `_TaxonomySyncHealthBanner` — triggers dashboard rebuild      |

### 1.3 Auth/Role Providers

| Provider           | File                 | autoDispose | Status                |
| ------------------ | -------------------- | ----------- | --------------------- |
| `userRoleProvider` | `role_provider.dart` | ✅ Yes      | Correct — autoDispose |
| `isAdminProvider`  | `role_provider.dart` | ✅ Yes      | Correct — autoDispose |

### 1.4 Sync-Related Providers (used by Dashboard indirectly)

| Provider                            | File                           | Notes                                              |
| ----------------------------------- | ------------------------------ | -------------------------------------------------- |
| `syncProgressProvider`              | `sync_progress_providers.dart` | Used in `MobileSyncPage`, NOT watched in Dashboard |
| `syncControllerProvider`            | sync providers                 | Not watched in Dashboard page                      |
| `fileNumberPoolStatusProvider`      | `file_id_providers.dart`       | Invalidated after sync ops in MobileSyncPage       |
| `kafalatActiveAssociationsProvider` | `kafalat_providers.dart`       | Invalidated after associations sync                |

---

## 2. PROVIDERS IN USE (CONFIRMED)

- `dashboardProvider` — main data provider, watched in `_DashboardHome._buildDashboard()`
- `dashboardSummaryProvider` — watched in `DashboardSummaryWidget`
- `dailyPerformanceProvider` — watched in widget sections
- `urgentCasesProvider` — watched in widget sections
- `geographicDistributionProvider` — watched in widget sections
- `pendingSyncCountProvider` — watched somewhere (candidates: sync badge, stats)
- `dataQualityProvider` — watched somewhere (data quality section)
- `dashboardSettingsProvider` — watched in settings panel
- `trendChartDataProvider` — conditionally watched in analytical mode ✅
- `trendChartLabelsProvider` — conditionally watched
- `notificationsCountProvider` — likely used by notifications badge
- `isAdminProvider` — watched in `_buildDashboard()` for admin AppBar items
- `taxonomySyncStatusProvider` — watched in `_TaxonomySyncHealthBanner`
- `taxonomyStatisticsProvider` — watched in `_TaxonomySyncHealthBanner`

---

## 3. UNUSED / DEAD PROVIDERS

| Provider                   | Status                                                                                           | Action                                                               |
| -------------------------- | ------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------- |
| `dashboardUIStateProvider` | **DEFINED BUT NEVER USED** in `dashboard_page.dart` — all UI state is in local `setState` fields | Part D: Wire into `dashboard_page.dart` for selected UI state fields |

---

## 4. DUPLICATE DATA PROVIDERS

| Duplication                                                                      | Details                                                                                                          | Risk                                                                                                                        |
| -------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| `pendingSyncCountProvider` vs `dashboardSummaryProvider.pending`                 | Both call `db.beneficiariesDao.countPendingSync()` — exact same query                                            | **LOW RISK** to remove `pendingSyncCountProvider` if no widget depends solely on it; delegate to `dashboardSummaryProvider` |
| `dashboardProvider.statistics.pendingSync` vs `dashboardSummaryProvider.pending` | Both query pending count — `dashboardProvider` fetches via use case, `dashboardSummaryProvider` fetches directly | **DOCUMENT** — keep both for now, note the overlap                                                                          |
| `dataQualityProvider`                                                            | Uses hardcoded `total * 0.85` — fake data, not real DB query                                                     | **DOCUMENT** — mark as TODO, do not silently deliver fake quality scores                                                    |

---

## 5. BROAD REBUILD CAUSES

| Location                           | Watch Pattern                            | Problem                                                                                          | Fix                                                                  |
| ---------------------------------- | ---------------------------------------- | ------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------- |
| `_DashboardHome._buildDashboard()` | `ref.watch(dashboardProvider)`           | **Full state object** — rebuilds on ANY field change (stats, activities, error, lastRefreshTime) | Split into selective watches via `provider.select()`                 |
| `_DashboardHome._buildDashboard()` | `ref.watch(taxonomySyncStatusProvider)`  | Full rebuild on any taxonomy sync status change                                                  | Move to `_TaxonomySyncHealthBanner` widget only                      |
| `_DashboardHome._buildDashboard()` | `ref.watch(taxonomyStatisticsProvider)`  | Full rebuild on taxonomy stats change                                                            | Move to `_TaxonomySyncHealthBanner` widget only                      |
| `_DashboardHome._buildContent()`   | `state.statistics` + many derived fields | Derives many values from full state object                                                       | Already partially addressed by `trendChartDataProvider` using select |

### Currently OK (already using select)

- `pendingTasksCount` → `dashboardProvider.select((s) => s.todayStats?.pendingTasks)` ✅
- `trendChartDataProvider` → uses `dashboardProvider.select((s) => s.statistics?.growthData)` ✅
- `trendChartLabelsProvider` → same ✅

---

## 6. PROVIDERS THAT SHOULD BE autoDispose

**All FutureProviders in `dashboard_providers.dart` already have autoDispose** per earlier fix.

Remaining non-autoDispose providers:

| Provider                            | Should Be autoDispose? | Reason                                                  |
| ----------------------------------- | ---------------------- | ------------------------------------------------------- |
| `dashboardProvider` (StateNotifier) | ❌ No                  | Global — must persist across tab switches. Intentional. |
| `dashboardUIStateProvider`          | ❌ No                  | Global UI state — must persist across tab switches      |
| `dashboardSettingsProvider`         | ❌ No                  | Settings persist across sessions                        |
| `trendChartDataProvider`            | ❌ No                  | Derived — disposes automatically when parent disposes   |
| `notificationsCountProvider`        | ❌ No                  | Derived                                                 |
| Infrastructure providers            | ❌ No                  | Always needed                                           |

**Conclusion:** No additional autoDispose changes needed — all screen-only heavy providers already have autoDispose.

---

## 7. PROVIDERS NEEDING provider.select()

| Location                                 | Current Pattern                                                 | Recommended                                                     |
| ---------------------------------------- | --------------------------------------------------------------- | --------------------------------------------------------------- |
| `_buildDashboard()` — loading state      | `state.isLoadingStats` from full `ref.watch(dashboardProvider)` | `ref.watch(dashboardProvider.select((s) => s.isLoadingStats))`  |
| `_buildDashboard()` — error state        | `state.hasError` from full watch                                | `ref.watch(dashboardProvider.select((s) => s.errorMessage))`    |
| `_buildContent()` — statistics           | `state.statistics` from full watch                              | Extract via selective sub-watches in child widgets              |
| `_buildDashboard()` — taxonomy providers | Watched in parent widget                                        | Move taxonomy watches into `_TaxonomySyncHealthBanner` directly |

---

## 8. DASHBOARD METRICS INVALIDATION POINTS

### Current invalidation behavior:

- `dashboardProvider` (StateNotifier): refreshed on pull-to-refresh and on connectivity restore.
- `dashboardSummaryProvider` (FutureProvider.autoDispose): auto-expires every 30s via keepAlive timer. **NOT invalidated after sync.**
- After sync operations in `MobileSyncPage`: `_refreshDashboardData()` refreshes sync-page local stats (setState in MobileSyncPage), but does **NOT invalidate** `dashboardSummaryProvider` or call `dashboardProvider.notifier.refresh()`.

### Missing invalidation:

After any of these sync operations in `MobileSyncPage`:

- Beneficiaries upload
- Beneficiaries download
- Visits/sponsorships upload/download
- Associations sync
- File number sync
- Taxonomy sync

Dashboard shows **stale counts** until the 30s timer expires or user pulls to refresh.

---

## 9. SYNC COMPLETION → DASHBOARD INVALIDATION

### Where sync completes (locations in `mobile_sync_page.dart`):

1. Line ~590: After beneficiary upload
2. Line ~624: After beneficiary download
3. Line ~675: After file number sync
4. Line ~751: After associations sync
5. Line ~944: After taxonomy sync
6. Line ~1128, ~1169: After visits/sponsorship sync
7. Line ~1298: After kafalat sync

### Required action:

After each successful sync completion in `MobileSyncPage._refreshDashboardData(force: true)`, also:

```dart
ref.invalidate(dashboardSummaryProvider);
if (mounted) {
  ref.read(dashboardProvider.notifier).refresh();
}
```

However, a simpler approach: add dashboard invalidation **inside `_refreshDashboardData()`** itself, since it's always called after sync operations.

This avoids modifying each sync operation handler individually.

---

## 10. RACE CONDITIONS AND DISPOSE RISKS

### Already Fixed

- `Future.microtask` in `loadStatistics` → replaced with `if (mounted) await _loadInitialActivities()` ✅

### Remaining Issues

#### 10.1 Silent catch in connectivity listener

```dart
// dashboard_page.dart ~line 157
try {
  ref.read(dashboardProvider.notifier).refresh();
} catch (_) {
  // Ignore if provider is not available
}
```

Silent swallow hides real errors. Replace with mounted guard.

#### 10.2 `_loadInitialActivities` error does not check mounted

```dart
// dashboard_notifier.dart
} catch (e) {
  state = state.copyWith(
    isLoadingActivities: false,
    errorMessage: 'فشل تحميل الأنشطة',  // ← no mounted check
  );
}
```

If notifier disposed between try start and catch, this crashes.

#### 10.3 `refreshTodayStats` has silent catch

```dart
} catch (e) {
  // Silent fail for today stats refresh
}
```

This is intentional for non-critical refresh — acceptable but should be documented.

#### 10.4 `loadMoreActivities` — no mounted check after await

After `await getRecentActivities(offset: ...)`, state update could run on disposed notifier.

#### 10.5 `unawaited` in connectivity restore

In `MobileSyncPage.initState()`:

```dart
unawaited(_refreshDashboardData());
```

If widget disposed before completes → setState on disposed widget (guarded by `if (!mounted) return` inside — OK).

---

## 11. IMPLEMENTATION CHECKLIST

### P0 — Correctness / Stale Data / Race Issues

- [ ] **P0-1**: Add `mounted` guard in `_loadInitialActivities` catch block (`dashboard_notifier.dart`)
- [ ] **P0-2**: Add `mounted` guard in `loadMoreActivities` after await (`dashboard_notifier.dart`)
- [ ] **P0-3**: Replace silent `catch (_) {}` in connectivity listener with proper mounted guard (`dashboard_page.dart`)
- [ ] **P0-4**: Add `dashboardSummaryProvider` invalidation inside `_refreshDashboardData()` in `MobileSyncPage` — so Dashboard metrics refresh after any sync completion
- [ ] **P0-5**: Add `dashboardProvider.notifier.refresh()` inside `_refreshDashboardData()` in `MobileSyncPage` after sync
- [ ] **P0-6**: Document `dataQualityProvider` fake data prominently (TODO comment + audit note)

### P1 — Rebuild / Performance Improvements

- [ ] **P1-1**: Split broad `ref.watch(dashboardProvider)` in `_buildDashboard()` into selective watches for `isLoadingStats`, `hasError`, `errorMessage` (`dashboard_page.dart`)
- [ ] **P1-2**: Move `taxonomySyncStatusProvider` and `taxonomyStatisticsProvider` watches out of `_buildDashboard()` into `_TaxonomySyncHealthBanner` widget (already a separate ConsumerWidget — verify)
- [ ] **P1-3**: Wire `dashboardUIStateProvider` into `dashboard_page.dart` for `selectedFilter`, `dashboardViewMode`, `selectedCategory`, `selectedGovernorate`, `syncedOnly` — replacing `setState` fields
- [ ] **P1-4**: Write focused `dashboard_ui_state_provider_test.dart`

### P2 — Cleanup

- [ ] **P2-1**: Audit where `pendingSyncCountProvider` is actually used — remove if unused, or document intentional duplication
- [ ] **P2-2**: Add explicit TODO comment on `dataQualityProvider` hardcoded estimate
- [ ] **P2-3**: Document `dashboardSettingsProvider` intentional non-autoDispose
- [ ] **P2-4**: Add `dashboardUIStateProvider` to provider inventory docs

### P3 — Docs / Future Refactor

- [ ] **P3-1**: Update `STATE_MANAGEMENT_AUDIT.md` with implementation status
- [ ] **P3-2**: Update `DASHBOARD_BASELINE_2026_05_28.md` with state-management note
- [ ] **P3-3**: Mark this checklist with completion status after each part

---

## 12. IMPLEMENTATION ORDER

```
Part H (P0 race/dispose fixes) — lowest risk, no visible behavior change
  ↓
Part G (P0 sync invalidation) — critical for stale data fix
  ↓
Part B (P2 provider cleanup/audit)
  ↓
Part C (P1 rebuild reduction — provider.select in dashboard_page)
  ↓
Part D (P1 UI state separation — wire dashboardUIStateProvider)
  ↓
Part E (verify autoDispose — already done, just document)
  ↓
Part F (clarify duplicates — pendingSyncCountProvider)
  ↓
Part I (documentation)
  ↓
Part K (final verification)
```

---

## 13. FILES TO CHANGE

### Production Files

| File                                                                     | Parts   | Changes                                                                     |
| ------------------------------------------------------------------------ | ------- | --------------------------------------------------------------------------- |
| `lib/features/dashboard/presentation/state/dashboard_notifier.dart`      | H       | mounted guards in catch blocks                                              |
| `lib/features/dashboard/presentation/pages/dashboard_page.dart`          | C, D, H | provider.select, remove silent catch, optionally wire UI state provider     |
| `lib/features/sync/mobile_sync_page.dart`                                | G       | add dashboard invalidation in `_refreshDashboardData()`                     |
| `lib/features/dashboard/presentation/providers/dashboard_providers.dart` | B, F    | document/remove pendingSyncCountProvider if unused; add TODO on dataQuality |

### Test Files

| File                                                            | Parts | Changes                            |
| --------------------------------------------------------------- | ----- | ---------------------------------- |
| `test/features/dashboard/dashboard_ui_state_provider_test.dart` | D     | NEW — focused UI state tests       |
| `test/features/dashboard/dashboard_notifier_test.dart`          | H     | add dispose-safety tests if needed |
| `test/features/dashboard/dashboard_sync_invalidation_test.dart` | G     | update with wiring tests           |

### Docs Files

| File                                           | Parts | Changes                           |
| ---------------------------------------------- | ----- | --------------------------------- |
| `docs/STATE_MANAGEMENT_AUDIT.md`               | I     | add implementation status section |
| `docs/DASHBOARD_BASELINE_2026_05_28.md`        | I     | add short follow-up note          |
| `docs/STATE_MANAGEMENT_IMPLEMENTATION_PLAN.md` | I     | mark checklist items complete     |

---

## 14. CONSTRAINTS AND RULES

- Dashboard layout: **FROZEN — do not touch**
- Quick Actions: **FROZEN — exactly 6, labels unchanged**
- AppBar spec: **FROZEN**
- Security hardening: **do not weaken**
- Admin visibility: **do not change**
- Do not run full `flutter test` after every change
- No broad refactor — targeted changes only
- Do not swallow exceptions silently
- Do not introduce circular provider dependencies
- Sync layer must not import UI widgets

---

## 15. KNOWN RISKS

| Risk                                                                                                         | Mitigation                                                                                    |
| ------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------- |
| Wiring `dashboardUIStateProvider` causes StatefulWidget → ConsumerWidget migration for `_DashboardPageState` | Migrate only the `_DashboardPageState` fields needed; keep analytics/connectivity state local |
| `_refreshDashboardData()` adding provider invalidation causes double-load on Dashboard                       | Guard with debounce — already has `_lastDashboardRefreshAt` + 2s debounce                     |
| provider.select in `_buildDashboard` causes widget split                                                     | Keep widgets in same file; only replace watch pattern, no structural change                   |
| `pendingSyncCountProvider` removal breaks hidden widget                                                      | Audit usages before removing                                                                  |

---

## IMPLEMENTATION STATUS

_Updated as each part completes._

| Part                         | Status                               | Notes         |
| ---------------------------- | ------------------------------------ | ------------- |
| Part A — Plan                | ✅ Complete                          | This document |
| Part B — Provider inventory  | ⬜ Not started                       |               |
| Part C — Reduce rebuilds     | ⬜ Not started                       |               |
| Part D — UI state separation | ⬜ Not started                       |               |
| Part E — autoDispose         | ⬜ Not started (likely already done) |               |
| Part F — Duplicate state     | ⬜ Not started                       |               |
| Part G — Sync invalidation   | ⬜ Not started                       |               |
| Part H — Race/dispose safety | ⬜ Not started                       |               |
| Part I — Documentation       | ⬜ Not started                       |               |
| Part K — Final verification  | ⬜ Not started                       |               |
