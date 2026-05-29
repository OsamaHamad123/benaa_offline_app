# DASHBOARD UX & PERFORMANCE AUDIT

**Date:** 2026-05-28  
**Auditor:** GitHub Copilot  
**Scope:** Dashboard/Home page, AppBar, Quick Actions, Providers, Navigation

---

## 1. CURRENT DASHBOARD STRUCTURE

```
DashboardPage (ConsumerStatefulWidget)
├── _DashboardPageState (StatefulWidget state)
│   ├── _selectedIndex: 0/1/2 (Rئيسية/مزامنة/إعدادات)
│   ├── _showWelcomeBanner
│   ├── _selectedFilter
│   ├── _isOnline
│   ├── _dashboardViewMode (operational/analytical)
│   ├── _selectedCategory, _selectedGovernorate, _syncedOnly (filter state)
│   └── _connectivitySubscription
│
├── Build → Scaffold
│   ├── body: _DashboardHome (when index=0)
│   │   └── CustomScrollView
│   │       ├── ModernSliverAppBar
│   │       │   ├── TaxonomyStatusBadge
│   │       │   ├── SearchButton
│   │       │   ├── ExportButton
│   │       │   └── NotificationsButton (with badge)
│   │       └── SliverToBoxAdapter → _buildContent
│   │           ├── OfflineBanner (conditional)
│   │           ├── _CivilRegistryBanner
│   │           ├── _TaxonomySyncHealthBanner
│   │           ├── WelcomeBanner (first-time only)
│   │           ├── _buildHomeModeSwitcher (تشغيلي/تحليلي chips)
│   │           ├── DashboardSummaryWidget
│   │           ├── SectionTitle: "إجراءات سريعة"
│   │           ├── QuickActionsGrid (8 actions)
│   │           ├── FilterChipGroup (الكل/اليوم/هذا الأسبوع/تحتاج متابعة)
│   │           ├── [Operational mode]: UrgentCasesSection + RecentActivitiesList
│   │           └── [Analytical mode]: TrendLineChart + UrgentCasesSection + DailyPerformanceSection + RecentActivitiesList + Charts + GeographicDistributionSection
│   ├── body: MobileSyncPage (when index=1)
│   ├── body: CleanSettingsPage (when index=2)
│   ├── FAB: "إضافة مستفيد" (when index=0)
│   └── NavigationBar: الرئيسية / المزامنة / الإعدادات
```

---

## 2. CURRENT WIDGETS/COMPONENTS

| Component                    | File                                                      | Purpose                                 |
| ---------------------------- | --------------------------------------------------------- | --------------------------------------- |
| `DashboardPage`              | `presentation/pages/dashboard_page.dart`                  | Main container (1000+ lines)            |
| `_DashboardHome`             | same file                                                 | Home content (private class)            |
| `DashboardAppBar`            | `presentation/widgets/dashboard_app_bar.dart`             | Separate AppBar (NOT USED - deprecated) |
| `ModernSliverAppBar`         | `core/widgets/modern_sliver_app_bar.dart`                 | Used SliverAppBar                       |
| `QuickActionsGrid`           | `presentation/widgets/quick_actions.dart`                 | 8-action grid                           |
| `QuickActionCard`            | `presentation/widgets/quick_actions.dart`                 | Individual action card                  |
| `DashboardSummaryWidget`     | `presentation/widgets/dashboard_summary_widget.dart`      | Overview card                           |
| `StatCard`                   | `presentation/widgets/statistics_section.dart`            | Reusable stat card                      |
| `UrgentCasesSection`         | `presentation/widgets/urgent_cases_section.dart`          | Urgent cases                            |
| `DashboardSkeleton`          | `presentation/widgets/loading/dashboard_skeleton.dart`    | Loading skeleton                        |
| `OfflineBanner`              | `presentation/widgets/banners/offline_banner.dart`        | Offline indicator                       |
| `DashboardNavigationService` | `presentation/services/dashboard_navigation_service.dart` | Navigation helper                       |

---

## 3. UI PROBLEMS

### 3.1 AppBar Clutter

- **CRITICAL**: `DashboardAppBar` widget EXISTS but is NOT USED — replaced by `ModernSliverAppBar`. Dead code.
- `ModernSliverAppBar` actions: TaxonomyStatusBadge + Search + Export + Notifications = 4 action items competing for space.
- `DashboardAppBar` (unused) has 6 icons with NO explicit spacing: monitoring, drafts, search, notifications badge, sync, profile.
- No `IconButton` padding constraints set → icons can appear too close on small screens.
- Missing: sync status indicator in AppBar.

### 3.2 Quick Actions Overload

- **8 actions** shown: إضافة مستفيد, الكفالات, البحث, المزامنة, التقارير, السجل المدني, الزيارات, الجمعيات.
- "السجل المدني" is a civil DB download tool — not a primary user action.
- No visual hierarchy — all actions appear equal weight except 2 "emphasized" ones.
- Grid aspect ratio can cause overflow or tiny cells on small phones.

### 3.3 Mode Switcher Confusion

- `_buildHomeModeSwitcher()` shows "تشغيلي / تحليلي" chips but the analytical mode is behind a feature flag (`enableAnalyticalMode`).
- When `enableAnalyticalMode=false`, only one chip shows → confusing, wasted space.
- The chips have NO clear tooltip or explanation.

### 3.4 Excessive Banners

Up to 4 banners can show simultaneously at the top:

1. OfflineBanner
2. \_CivilRegistryBanner
3. \_TaxonomySyncHealthBanner
4. WelcomeBanner

This is overwhelming. They push content far down the screen.

### 3.5 Font Sizes

- `DashboardTextStyles.statValue` = **28.sp** (very large, especially with ScreenUtil scaling).
- `DashboardTextStyles.sectionTitle` = **18.sp** (reasonable).
- `AppBar title` in `DashboardAppBar` = **20.sp** (ok).
- `DashboardSummaryWidget` uses `titleLarge` from theme = could be 22-24 on large fonts.
- `StatCard` value text: large numbers can overflow containers.

### 3.6 Layout

- `_buildContent` uses `SingleChildScrollView` nested inside `CustomScrollView.SliverToBoxAdapter` — inefficient double scroll context.
- No max content width for tablets.
- `GridView.count` for quick actions uses fixed cross-axis count from `ResponsiveUtils.getCrossAxisCount()` — but `childAspectRatio` is hardcoded, causing aspect issues on edge-case screens.

---

## 4. PERFORMANCE PROBLEMS

### 4.1 Provider Rebuild Issues

- `ref.watch(dashboardProvider)` in `_DashboardHome.build()` watches the ENTIRE `DashboardState` — any field change triggers full rebuild.
- `ref.watch(taxonomySyncStatusProvider)` and `ref.watch(taxonomyStatisticsProvider)` also watched in build — two additional subscriptions.
- `ref.watch(trendChartDataProvider)` is computed inside build only in analytical mode, but the watch is set up regardless of mode.

### 4.2 Heavy Build() Operations

- `_buildHomeModeSwitcher()` creates new widgets on every build with no `const`.
- `FilterChipGroup` receives `const` list but is rebuilt on every parent build.
- `state.activities.take(5).toList()` — creates a new list on every build.

### 4.3 Multiple Providers

- `dashboardSummaryProvider` (FutureProvider) AND `dashboardProvider` (StateNotifier) both hold dashboard data — DUPLICATION.
- `dailyPerformanceProvider` and `urgentCasesProvider` are NOT autoDispose — they stay alive indefinitely.
- `pendingSyncCountProvider` and `dashboardSummaryProvider` both call `countPendingSync()` — duplicate DB queries.
- `geographicDistributionProvider` is NOT autoDispose and loads full province map.

### 4.4 Activities Loading Risk

- `Future.microtask(() => _loadInitialActivities())` inside `initialize()` — called from notifier constructor area. If the widget disposes before completion, state update on disposed notifier is risky.

### 4.5 Connectivity

- `Connectivity().onConnectivityChanged.listen(...)` in `initState` is correctly cancelled in `dispose()` — OK.
- But `ref.read(dashboardProvider.notifier).refresh()` called from connectivity callback — could fail if notifier is disposed.

### 4.6 Taxonomy Sync on Load

- `taxonomySyncStatusProvider` and `taxonomyStatisticsProvider` watched on every dashboard open — may trigger background taxonomy sync.

### 4.7 Skipped Frames

- `DashboardSummaryWidget` contains a `GridView.count(shrinkWrap: true)` inside a `Card` inside a `Column` inside `SingleChildScrollView` — deeply nested layout.
- `StatCard` uses `LayoutBuilder` which triggers additional layout passes.

---

## 5. STATE MANAGEMENT PROBLEMS

### 5.1 Duplicate State

- `DashboardUIStateNotifier` (from `dashboard_ui_state_provider.dart`) — DEFINED but NOT USED in dashboard_page.dart. All UI state is managed as plain `setState` in `_DashboardPageState`.
- `_DashboardHome` receives 10+ parameters from parent — should use providers instead.

### 5.2 Provider Duplication

- `dashboardSummaryProvider` (FutureProvider): Returns `DashboardSummary` with total, orphans, poor, pending, synced.
- `dashboardProvider` (StateNotifier): Returns `DashboardState` with `statistics` (DashboardStatistics), `todayStats`, `activities`.
- Both serve similar purposes but are separate — consuming components must know which to use.

### 5.3 No Cache Invalidation

- After upload/download sync completes, neither `dashboardProvider` nor `dashboardSummaryProvider` is invalidated.
- Dashboard metrics can be stale after sync without user knowing.

### 5.4 Error State Propagation

- `DashboardNotifier.loadStatistics()` error sets `errorMessage` in state — good.
- But `_loadInitialActivities()` also sets `errorMessage` — can overwrite stats error.

---

## 6. SECURITY / DATA EXPOSURE RISKS

### 6.1 Admin Tools Visible to All

- `MonitoringDashboard` icon in `DashboardAppBar` has comment "Dev/Admin only" but has **NO actual admin check** — visible to any authenticated user.
- `DashboardExportDialog` accessible from AppBar to all users.

### 6.2 No Log Sanitizer

- `UnifiedLogger` is used throughout sync service.
- No `LogSanitizer` exists — beneficiary nationalId, phone, and names CAN appear in logs.
- Example risk: `UnifiedLogger.info('🆔 File ID $fileId marked as used for beneficiary $beneficiaryId')` — beneficiary ID exposed.

### 6.3 Firestore Rules Too Permissive (for production)

- `/file_number_counters/{docId}`: `allow read, write: if request.auth != null` — any authenticated user can modify file number counters.
- `/taxonomy_categories/{docId}`: `allow create, update, delete: if isAuthenticated()` — any user can modify taxonomy.
- `/sync_health_checks/{docId}`: `allow read, write: if request.auth != null` — any user can write health checks.
- `/associations/{docId}` appears **twice** with conflicting rules (once with admin write, once with auth-only write).
- `/sponsorships/{docId}` appears **twice** with conflicting rules.

### 6.4 Stale Data Export

- `DashboardExportDialog` can export statistics including beneficiary counts by category — acceptable, but should require admin role for full export.

---

## 7. NAVIGATION CONFUSION POINTS

1. **Mode switcher (تشغيلي/تحليلي)** appears before the main content — users don't understand what it does.
2. **"السجل المدني"** quick action — civil DB download — not a daily user action, confuses field workers.
3. **8 quick actions** with equal visual weight — no clear "primary" vs "secondary" grouping.
4. **Bottom navigation** has only 3 items but dashboard has many more sections — related actions are deep inside.
5. **"تصدير التقرير"** (export) in AppBar — AppBar should be for navigation/search, not data operations.
6. **TaxonomyStatusBadge** in AppBar — takes space, technical info users don't care about.
7. Filter chips ("الكل/اليوم/هذا الأسبوع/تحتاج متابعة") sit below quick actions but their effect on the dashboard is unclear.

---

## 8. RECOMMENDED CHANGES

### 8.1 AppBar — HIGH PRIORITY

- Remove TaxonomyStatusBadge from AppBar → move to admin settings.
- Remove Export button from AppBar → move to reports page.
- Keep only: Search, Notifications, Overflow Menu (···).
- Overflow menu: Sync status, Settings, Export (if admin).
- Add `iconButtonConstraints: BoxConstraints(minWidth: 48, minHeight: 48)` to each `IconButton`.
- Add `padding: EdgeInsets.symmetric(horizontal: 4)` between icons.
- MonitoringDashboard access: gate behind `isAdmin` check.

### 8.2 Quick Actions — HIGH PRIORITY

- Reduce to 6 primary actions: إضافة مستفيد, المستفيدون, الزيارات, الكفالات, الجمعيات, المزامنة.
- Remove "السجل المدني" and "التقارير" from primary quick actions — put in overflow/admin tools.
- Show max 3 columns, 2 rows.
- Use consistent icon size and card height.
- Sort by usage frequency (إضافة مستفيد most emphasized).

### 8.3 Dashboard Information Architecture

Reorder sections:

1. AppBar (Search + Notifications + Menu)
2. Status Overview (4 stat cards: المستفيدون, الزيارات اليوم, الكفالات, بانتظار الرفع)
3. Quick Actions (6 cards, 3 columns)
4. Today's Work (top 3 visits/followups + "عرض الكل")
5. Sync Status card (compact: آخر مزامنة + pending count + button)
6. [Collapsible] Recent Activities
7. [Collapsible] Charts / Analytics

### 8.4 Performance

- Add `const` to all static widgets in dashboard.
- Use `ref.watch(dashboardProvider.select(...))` for specific fields.
- Make `dailyPerformanceProvider` and `urgentCasesProvider` `autoDispose`.
- Remove `geographicDistributionProvider` from dashboard (move to analytics page).
- Replace `Future.microtask()` in notifier with proper `addPostFrameCallback`.
- Cache metrics for minimum 30 seconds (already done for `dashboardSummaryProvider`).
- Reduce `activities.take(5)` allocation — pass pre-sliced list.

### 8.5 State Management

- Use `DashboardUIStateNotifier` that already exists — remove duplicate `setState` in `_DashboardPageState`.
- Use `provider.select()` everywhere to prevent over-rebuilding.
- Invalidate dashboard after sync completion.

### 8.6 Security

- Add `LogSanitizer` utility.
- Gate `MonitoringDashboard` behind admin check.
- Gate export behind admin check.
- Fix duplicate Firestore rules for `/associations` and `/sponsorships`.

### 8.7 Fonts

- `statValue`: reduce from 28.sp → 24.sp.
- `sectionTitle`: keep at 18.sp (acceptable).
- AppBar title: 18-20.sp max.
- Quick action labels: 11.5.sp max (already set).

### 8.8 Remove Confusion

- Remove mode switcher chips from normal dashboard — move to settings.
- Remove `_CivilRegistryBanner` from main dashboard unless processing/ready.
- Merge duplicate banners into a single dismissable status bar.

---

## 9. FILES TO MODIFY

| File                                                 | Change                                                     |
| ---------------------------------------------------- | ---------------------------------------------------------- |
| `presentation/pages/dashboard_page.dart`             | Split into smaller components, fix state, reduce imports   |
| `presentation/widgets/dashboard_app_bar.dart`        | Fix spacing, add admin gates, remove dead code             |
| `presentation/widgets/quick_actions.dart`            | Reduce to 6 actions, fix layout                            |
| `presentation/widgets/dashboard_summary_widget.dart` | Reduce statValue font, add const                           |
| `presentation/widgets/statistics_section.dart`       | Reduce statValue font, use const                           |
| `presentation/providers/dashboard_providers.dart`    | Make providers autoDispose, remove duplication             |
| `presentation/state/dashboard_notifier.dart`         | Fix Future.microtask risk                                  |
| `presentation/utils/dashboard_text_styles.dart`      | Reduce statValue from 28.sp to 24.sp                       |
| `core/security/`                                     | ADD: `log_sanitizer.dart`                                  |
| `docs/`                                              | ADD: audit docs                                            |
| `firestore.rules`                                    | Fix duplicate rules, add comments for production readiness |
| `test/`                                              | ADD: dashboard widget tests                                |

---

## 10. PRIORITY MATRIX

| Issue                                    | Severity | Effort | Priority |
| ---------------------------------------- | -------- | ------ | -------- |
| MonitoringDashboard open to all users    | HIGH     | LOW    | P0       |
| No LogSanitizer                          | HIGH     | LOW    | P0       |
| AppBar icon spacing                      | MEDIUM   | LOW    | P1       |
| 8 quick actions → 6                      | MEDIUM   | LOW    | P1       |
| Duplicate Firestore rules                | HIGH     | LOW    | P1       |
| Font sizes too large                     | MEDIUM   | LOW    | P1       |
| DashboardUIStateNotifier unused          | MEDIUM   | MEDIUM | P2       |
| Provider duplication                     | MEDIUM   | MEDIUM | P2       |
| Future.microtask risk                    | MEDIUM   | LOW    | P2       |
| dailyPerformanceProvider not autoDispose | LOW      | LOW    | P2       |
| Mode switcher confusion                  | LOW      | LOW    | P3       |
| Geographic distribution in dashboard     | LOW      | LOW    | P3       |

---

## 11. IMPLEMENTATION STATUS (2026-05-28)

| Issue | Status | Details |
|-------|--------|---------|
| AppBar clutter (TaxonomyStatusBadge shown to all) | ✅ Fixed | Badge removed from main actions; moved to admin popup |
| Export button shown to all users | ✅ Fixed | Moved to _DashboardAdminPopupMenu, gated by isAdmin \|\| kDebugMode |
| Admin popup menu missing | ✅ Fixed | Added _DashboardAdminPopupMenu with Export, Taxonomies, Monitoring |
| 8 quick actions → 6 | ✅ Fixed | Exactly 6 actions in QuickActionsGrid |
| "الزيارات" label | ✅ Fixed | Label changed to "زيارات اليوم" |
| Kafalat/Associations conditional | ✅ Fixed | Now unconditional with ?? () {} fallback |
| 	rendChartDataProvider always watched | ✅ Fixed | Conditional watch — only in analytical mode |
| utoDispose on FutureProviders | ✅ Fixed | 5 providers now use utoDispose |
| Future.microtask race condition | ✅ Fixed | Direct wait _loadInitialActivities() with mounted check |
| Performance logs missing | ✅ Fixed | [Dashboard] loadMetrics started/completed ms=X added |
| LogSanitizer created but unused | ✅ Fixed | Used in DashboardNotifier, masking enabled on init |
| isAdminProvider missing | ✅ Fixed | Created lib/core/auth/role_provider.dart |
| Duplicate Firestore rules | ✅ Fixed | Duplicate open rules removed |
| Old/weak tests | ✅ Fixed | Deleted 2 old files, created 4 new test files (51 tests) |

**Remaining (P3 / Future):**
- dashboardUIStateProvider still not wired in dashboard_page.dart (UI state uses setState)
- ef.watch(dashboardProvider) full watch in _buildContent — partial select() only for pendingTasksCount
- Beneficiaries full pagination not implemented (see PAGINATION_STRATEGY.md)
- Post-sync dashboard invalidation not implemented
