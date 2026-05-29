# DASHBOARD UX/UI NEXT-LEVEL IMPROVEMENT PLAN

**Date:** 2026-05-28  
**Phase:** Planning Only — No production code changes  
**App:** منظومة بناء — Gaza/Cedar beneficiary management  
**Audience:** Field workers, reviewers, admins operating in Gaza governorate

> **PLANNING NOTICE:** This document is a planning artifact only.  
> No production code, tests, providers, or widgets may be changed during this phase.  
> All baselines (Dashboard 150/150, Security 101/101, Sync targets) remain frozen.

---

## Final Dashboard UX Implementation Status ✅ CLOSED — 2026-05-28

### Phases Completed

| Phase   | Description                                                                                              | Status      |
| ------- | -------------------------------------------------------------------------------------------------------- | ----------- |
| Phase 1 | Visual Cleanup — card polish, spacing, color tokens, typography                                          | ✅ Complete |
| Phase 2 | Operational Status Strip + Banner Simplification — status strip, role-based banners                      | ✅ Complete |
| Phase 3 | Today's Work Card + Compact Sync Health Card — `DashboardTodaysWorkCard`, `DashboardSyncHealthCard`      | ✅ Complete |
| Phase 4 | Consolidation & UX Polish — heading rename, spacing cleanup, empty-state copy, deprecated API fix        | ✅ Complete |
| Phase 5 | AppBar + Typography + Simplicity — AppBar height, icon spacing, typography tokens, information reduction | ✅ Complete |

## Phase 5 AppBar + Typography + Simplicity Status ✅ CLOSED — 2026-05-28

### AppBar Spacing Changes

- `ModernSliverAppBar.expandedHeight`: `100.h` → `88.h` (mobile), `120.h` → `110.h` (tablet) — lighter, more breathable header
- `ModernActionButton` touch area: `38×38` → `40×40` — closer to WCAG 48dp touch target
- Added `SizedBox(width: 6.w)` between Search/Notifications and `SizedBox(width: 4.w)` before admin popup — icons no longer crowded

### Typography / Token Changes

- `DashboardTextStyles.sectionTitle`: `18.sp` → `17.sp` — lighter section headings
- `DashboardTextStyles.cardTitle`: `16.sp` → `15.sp` — lighter card headings
- `AppTheme.AppBarTheme.titleTextStyle.fontSize`: hardcoded `20` → `18 * fontSizeMultiplier` — consistent with global text scale (light + dark theme)
- Global font remains **Cairo** (already the source of truth via `AppTheme._buildTextTheme`)

### Information Reduction Decisions

- Filter section "عرض البيانات" `SectionTitle` replaced with a compact `bodySmall` text row — filters are secondary controls, not a primary section
- `DashboardSummaryWidget` card `elevation`: `2` → `1` — lighter shadow
- `DashboardSummaryWidget._QuickStatCard.childAspectRatio`: `2.5` → `2.7` — shorter stat cards, less visually dominating
- No data removed; content preserved, visual weight reduced

### Deferred Global Font Migration

- `AppTypography` class (`lib/core/theme/app_typography.dart`) exists but is not yet unified with `AppTheme._buildTextTheme`
- Unification deferred — scope too wide for Phase 5

### Preserved Contracts

- Quick Actions: exactly 6 items, frozen labels, unaffected ✅
- No provider/sync/security changes ✅
- No heavy DB queries added ✅
- No broad refactor ✅
- Admin/debug tools remain hidden from normal users ✅

### Tests Run (Phase 5 Closure)

| Suite                                     | Tests                | Result        |
| ----------------------------------------- | -------------------- | ------------- |
| `dashboard_app_bar_test.dart`             | —                    | ✅            |
| `dashboard_security_visibility_test.dart` | —                    | ✅            |
| `dashboard_quick_actions_test.dart`       | —                    | ✅            |
| `dashboard_page_render_test.dart`         | —                    | ✅            |
| **Total**                                 | **36**               | ✅ All passed |
| **Analyzer**                              | 0 errors, 0 warnings | ✅            |

### Final Dashboard Section Order (Operational View, top to bottom)

```
ModernSliverAppBar (admin tool hidden from normal users)
OperationalStatusStrip
CivilRegistryStatusBanner (conditional)
TaxonomyStatusBanner (admin only)
WelcomeBanner (normal users)
DashboardSummaryWidget
QuickActionsGrid (6 frozen: إضافة مستفيد / المستفيدون / زيارات اليوم / الكفالات / الجمعيات / المزامنة)
DashboardTodaysWorkCard
DashboardSyncHealthCard
SizedBox(24.h)
FilterChips + Advanced Filters button
── operational only ──
SectionTitle: 'تفاصيل المتابعة'
UrgentCasesSection
SectionTitle: 'الأنشطة الحديثة' + 'عرض الكل'
RecentActivitiesList
```

### Remaining Deferred Items

- Chart widgets in analytical view (mock data — not replaced with live queries)
- Post-sync auto-refresh wiring (`KNOWN GAP` documented in `dashboard_sync_invalidation_test.dart`)
- Full `flutter test` run (closure used targeted baseline verification only)
- `.withOpacity()` deprecations in non-dashboard files (pre-existing, out of scope)

### Tests Used for Closure (2026-05-28)

| Suite                                                    | Tests                     | Result        |
| -------------------------------------------------------- | ------------------------- | ------------- |
| `test/features/dashboard/`                               | 190                       | ✅ All passed |
| `test/core/utils/log_sanitizer_test.dart`                | —                         | ✅            |
| `test/core/security/security_logging_test.dart`          | —                         | ✅            |
| `test/core/auth/role_provider_test.dart`                 | —                         | ✅            |
| `test/core/auth/role_permissions_test.dart`              | —                         | ✅            |
| `test/features/security/admin_tool_visibility_test.dart` | —                         | ✅            |
| `test/features/sync/sync_safety_test.dart`               | —                         | ✅            |
| Security + Auth total                                    | 101                       | ✅ All passed |
| `dashboard_sync_invalidation_test.dart`                  | 6                         | ✅ All passed |
| **Analyzer**                                             | 0 errors in changed files | ✅            |

### Preservation Guarantees

- Quick Actions: 6 items frozen, tests unchanged
- No new providers added to Dashboard load path
- No sync/security/state logic changed
- No admin/seed tools exposed to normal users
- Targeted baseline verification only (full `flutter test` not run)

---

## 1. Current Dashboard UX Snapshot

### 1.1 Current Page Structure (top to bottom)

```
DashboardPage (Scaffold)
├── ModernSliverAppBar
│   ├── Title: "منظومة بناء" (or "منظومة بناء (غير متصل)" when offline)
│   ├── SearchButton          — all users
│   ├── NotificationsButton   — badge: pendingTasksCount
│   └── _DashboardAdminPopupMenu
│       ├── تصدير التقرير     — admin + kDebugMode
│       ├── إدارة التصنيفات  — admin + kDebugMode
│       └── لوحة المراقبة    — kDebugMode only
│
├── [Content: _DashboardHome]
│   ├── OfflineBanner                    ← conditional: when offline
│   ├── _CivilRegistryBanner             ← conditional: when civil DB not loaded
│   ├── _TaxonomySyncHealthBanner        ← conditional: taxonomy sync issues
│   ├── WelcomeBanner                    ← conditional: first-time only
│   ├── _buildHomeModeSwitcher           ← "تشغيلي" / "تحليلي" chips
│   ├── DashboardSummaryWidget           ← overview card: total/pending/synced
│   ├── SectionTitle: "إجراءات سريعة"
│   ├── QuickActionsGrid (6 cards)
│   │   1. إضافة مستفيد  (emphasized)
│   │   2. المستفيدون
│   │   3. زيارات اليوم
│   │   4. الكفالات
│   │   5. الجمعيات
│   │   6. المزامنة       (badge: pendingSync count)
│   ├── FilterChipGroup (4 chips: الكل / اليوم / هذا الأسبوع / تحتاج متابعة)
│   │   + Refresh IconButton + Advanced Filters IconButton
│   ├── [Operational mode]:
│   │   ├── SectionTitle: "حالات تحتاج متابعة"
│   │   ├── UrgentCasesSection
│   │   ├── SectionTitle: "الأنشطة الحديثة"
│   │   └── RecentActivitiesList (max 5)
│   └── [Analytical mode]:
│       ├── TrendLineChart (6-month growth)
│       ├── UrgentCasesSection
│       ├── DailyPerformanceSection
│       ├── RecentActivitiesList (max 5)
│       ├── CollapsibleSection: "إحصائيات النمو" (GrowthChart + CategoryDistributionChart)
│       └── CollapsibleSection: "التوزيع الجغرافي" (GeographicDistributionSection)
│
├── FAB: FloatingActionButton.extended — "إضافة مستفيد" (index=0 only)
│
└── NavigationBar (3 destinations)
    ├── الرئيسية (index=0) ← Dashboard
    ├── المزامنة (index=1) ← MobileSyncPage
    └── الإعدادات (index=2) ← CleanSettingsPage
```

### 1.2 Current AppBar Behavior

- SliverAppBar — collapses on scroll (pinned behavior).
- Title changes to "(غير متصل)" suffix when connectivity is lost.
- Search → `showSearch()` with `DashboardSearchDelegate`.
- Notifications → Snackbar showing pending task count (no actual notification list).
- Admin popup → Export, Taxonomy management, Monitoring (guarded by `isAdmin || kDebugMode`).
- No visible sync status in AppBar.
- No user avatar or user identity visible.

### 1.3 Current Quick Actions (Frozen)

| #   | Label        | Icon               | Color     | Badge             |
| --- | ------------ | ------------------ | --------- | ----------------- |
| 1   | إضافة مستفيد | person_add         | blue      | —                 |
| 2   | المستفيدون   | people             | green     | —                 |
| 3   | زيارات اليوم | event_note         | grey-blue | —                 |
| 4   | الكفالات     | volunteer_activism | accent    | —                 |
| 5   | الجمعيات     | business           | purple    | —                 |
| 6   | المزامنة     | sync               | teal      | pendingSync count |

### 1.4 Current Overview / Stat Cards

`DashboardSummaryWidget` (single card):

- إجمالي المستفيدين (total count)
- البيانات المتزامنة (synced count)
- الحالات الطارئة (orphans + poor health)
- بانتظار الرفع (pending sync count)
- Delta label: sync percentage

Stat cards are displayed in a 2×2 `GridView.count(shrinkWrap: true)` inside the summary card.

### 1.5 Current Sync Status Display

- AppBar title suffix "(غير متصل)" when offline.
- `OfflineBanner` at top of content when offline.
- `المزامنة` Quick Action card with `syncBadge` count.
- No dedicated sync health card.
- No "last synced" timestamp on Dashboard.
- No visual indicator of upload queue size in the main content.

### 1.6 Current Filters / Chips

Four chips in a horizontal scrolling row:

- الكل, اليوم, هذا الأسبوع, تحتاج متابعة
- Advanced filters (bottom sheet): category, governorate, syncedOnly
- Mode switcher chips: تشغيلي / تحليلي (feature-flagged)

### 1.7 Current Urgent / Today Sections

- `UrgentCasesSection`: queries DB for no-visits count + poor-health count + disabilities count.
- Shows total count with colored counters per category.
- Has "عرض الكل" / "تسجيل زيارة" tap handlers.
- No maximum item count enforced on home screen — shows full count, not a preview list.

### 1.8 Current Admin / Debug Visibility

- `_DashboardAdminPopupMenu`: visible when `isAdmin == true` OR `kDebugMode == true`.
- In debug builds, Monitoring Dashboard appears even for normal users.
- No seed tools visible on Dashboard (correct — moved to Settings/Admin area).
- `DashboardAppBar` widget exists in codebase but is **dead code** — never rendered.

### 1.9 Current Empty / Loading / Error States

- **Loading**: `SkeletonCard` placeholders (3 cards) shown when `isLoadingStats && statistics == null`.
- **Error**: `RetryWidget` with message and retry button.
- **Empty urgent cases**: `_buildEmptyState()` — shows "لا توجد حالات طارئة حالياً" with a green check icon.
- **Empty activities**: `RecentActivitiesList` shows empty state message.
- No dedicated "no beneficiaries yet" onboarding state.
- No "all data synced — nothing pending" celebratory state.

### 1.10 Current Bottom Navigation

Three items: الرئيسية / المزامنة / الإعدادات.
Uses Material 3 `NavigationBar` with haptic feedback on tap.
FAB is present only on index=0 (Rئيسية).

### 1.11 Current Accessibility / RTL Status

- `QuickActionCard` has `Semantics` wrapper with label and button hint.
- `ChoiceChip` mode switcher has Semantics labels.
- `TrailingIcon` for `ActivityItem` uses `Icons.chevron_right` — NOT RTL-aware (should be `Icons.chevron_left` in RTL or use `Directionality`).
- `ActivityItem` swipe actions assume LTR direction (swipeRight = view, swipeLeft = delete).
- No explicit `TextScaler` test coverage.
- Card padding uses `ScreenUtil` scaling but no max-width constraint for tablets.
- `OfflineBanner` uses only color (orange/warning) to communicate status — no additional icon-only fallback for color-blind users.

---

### What Is Already Good and Must Be Preserved

- **6 Quick Actions** — clean, intuitive, well-labeled in Arabic, consistent with field worker mental model.
- **FAB "إضافة مستفيد"** — correctly positioned, always accessible on home screen.
- **Admin popup menu** — admin tools correctly hidden from normal users.
- **Offline banner** — simple, non-blocking, communicates state clearly.
- **UrgentCasesSection** — real data from DB, actionable (تسجيل زيارة link).
- **Pull-to-refresh** — standard, works correctly.
- **3-tab bottom nav** — correct scope (Home / Sync / Settings), minimal.
- **Haptic feedback** on navigation and Quick Actions.
- **Connectivity listener** — automatically refreshes on reconnect.
- **RecentActivitiesList** — scoped to 5 items with "عرض الكل" link.
- **Role-based isAdminProvider** — fail-closed, tested, derived from Firebase claims.

### What Is Still Confusing

1. **Mode switcher (تشغيلي / تحليلي)** — appears only when feature flag is on, but the "تشغيلي" chip alone looks orphaned and purposeless.
2. **Notifications button** — shows a snackbar with count, not a real notification panel. Users expect a notification list.
3. **Up to 4 simultaneous banners** can stack at the top (offline + civil registry + taxonomy + welcome) — overwhelming.
4. **Filter chips below Quick Actions** — purpose unclear to first-time users; "التصنيفات السريعة" label doesn't explain the filter scope.
5. **Civil Registry banner** — technical label, field workers don't understand what "السجل المدني" download means in context.
6. **Taxonomy health banner** — too technical for field workers.
7. **No "last synced" time** on main Dashboard — users don't know if data is fresh.
8. **Sync badge on Quick Action card** — shows count but doesn't differentiate "pending uploads" from "failed uploads".
9. **ActivityItem swipe** — swipe-to-delete on recent activity is unexpected and potentially destructive.

### What Is Visually Weak

1. `DashboardSummaryWidget` header row has icon + "لوحة المعلومات" text + contextLabel badge + assessment icon — too many competing elements.
2. Stat value text at 28.sp — unnecessarily large, dominates the card.
3. No visual separation between the mode switcher and the summary card below.
4. Quick Actions grid and filter chips look the same weight — no visual hierarchy.
5. `UrgentCasesSection` uses a card-within-page that looks isolated rather than integrated.
6. `RecentActivitiesList` items use generic icon colors (green/blue/red/purple) with no system meaning.
7. `OfflineBanner` uses `.withOpacity` deprecated API (color-precision issue in Flutter 3.x).

### What Slows Down Daily Workflow

1. No "Today's Work" summary — field worker must derive: today's count from DashboardSummary + check UrgentCases separately.
2. No quick path to "register a visit for urgent case" from the summary view.
3. No compact sync health summary without navigating to the full Sync page.
4. Mode switcher adds an extra mental choice before the user can focus.
5. Filter chips require a second action (Advanced Filters) to use meaningful filters like governorate.
6. `SkeletonCard` blocks all content during load — no progressive disclosure.

---

## 2. User Types and Daily Tasks

### 2.1 Field Worker (عامل ميداني)

**Profile:** Primary data collector. Visits beneficiaries, registers visits, creates new beneficiary records, captures photos and attachments. Works on-site in Gaza governorates with intermittent connectivity.

**Top 3 Daily Goals:**

1. Add new beneficiaries or register today's field visits.
2. Check which cases need urgent follow-up.
3. Confirm that yesterday's data was uploaded successfully.

**Most-Used Actions:**

- إضافة مستفيد (multiple times per day)
- تسجيل زيارة (for each visit)
- مزامنة البيانات (at end of day or when back online)

**Information Needed at First Glance:**

- How many visits are planned / completed today
- Any overdue follow-ups waiting
- Whether last sync was successful
- How many records are waiting to upload (so nothing is lost)
- Whether app is offline (safe to continue working?)

**Actions That Should Be Hidden:**

- Export report
- Taxonomy management
- Monitoring dashboard
- Civil registry download tool
- Any seed or reset tool
- Analytical charts and geographic distribution

**Confusion Risks:**

- Technical error messages ("Firestore exception", "composite index required")
- Multiple stacked banners without clear priority
- Analytical mode adding confusing charts to a simple workflow
- Sync badge showing a count without explaining if it's safe or problematic

---

### 2.2 Reviewer / Supervisor (مشرف)

**Profile:** Reviews submitted beneficiary records, validates field worker data quality, oversees visit completion rates. Less frequent data entry; more oversight.

**Top 3 Daily Goals:**

1. Review pending or flagged beneficiary records.
2. Track visit completion rates for the team.
3. Monitor overall sync health across devices.

**Most-Used Actions:**

- البحث عن مستفيد
- عرض قائمة المستفيدين (with filters)
- عرض الأنشطة الحديثة

**Information Needed at First Glance:**

- Total beneficiaries and new additions this week
- Cases flagged as urgent or needing follow-up
- Visit coverage (visited vs not visited)
- Overall sync status (is data coming in from field workers?)

**Actions That Should Be Hidden:**

- Seed tools, export tools
- Admin configuration
- Taxonomy management

**Confusion Risks:**

- Can't distinguish their own activity from other team members' on the Activity feed.
- No team-level visit overview (not needed in Phase 1 but useful later).

---

### 2.3 Admin (مدير النظام)

**Profile:** System administrator. Manages taxonomy data, exports reports, monitors system health, reviews diagnostics.

**Top 3 Daily Goals:**

1. Monitor system health (sync errors, pending queue, failed uploads).
2. Export reports for management.
3. Manage taxonomy categories (add/edit/delete groups).

**Most-Used Actions:**

- Admin popup: تصدير التقرير, إدارة التصنيفات
- Monitoring Dashboard
- Sync page (check pending counts, run forced sync)

**Information Needed at First Glance:**

- System-level sync health (all devices, all collections)
- Error counts
- Total beneficiaries added this period

**Actions That Should Be Hidden:**
Nothing specific — admin can see everything.

**Confusion Risks:**

- Admin tools in a popup menu in AppBar are buried — admin needs a dedicated Admin Panel page.
- No way to see per-device sync status from Dashboard.

---

### 2.4 Read-Only User (مستخدم للاطلاع فقط)

**Profile:** Can view beneficiary data but cannot create or modify records. Typically a coordinator or partner organization representative.

**Top 3 Daily Goals:**

1. View beneficiary statistics.
2. Search for a specific beneficiary.
3. View recent activity feed.

**Most-Used Actions:**

- البحث
- عرض القائمة

**Actions That Should Be Hidden:**

- إضافة مستفيد
- تسجيل زيارة
- المزامنة (upload operations)
- Export (unless explicitly granted)

**Confusion Risks:**

- Seeing Quick Actions they can't use (إضافة مستفيد, زيارات اليوم) without understanding they'll get an error.
- FAB "إضافة مستفيد" is visible — could cause confusion.

> **Note for implementation:** Quick Actions are currently never hidden by role. Role-based action gating is a future phase concern. For now, read-only users will receive appropriate error responses when they attempt write operations.

---

## 3. Information Architecture Proposal

The following is the **target** Dashboard section order. It does not describe the current implementation.

---

### Section 1 — Header / AppBar

**Purpose:** Brand identity, global utilities, user identity.

**What it shows:**

- App name "منظومة بناء"
- Current user name or role indicator (field worker / admin)
- Search (universal access)
- Notifications icon (future: real notification list)
- More (⋮) menu — admin-only items inside

**What actions it enables:**

- Search anywhere in the app
- Access admin tools without cluttering main screen
- Quick user context (who am I logged in as?)

**Why it belongs here:** AppBar is the persistent navigation anchor. It must not change per-scroll or per-content.

**What should NOT appear here:**

- TaxonomyStatusBadge (technical, confusing)
- Export button (non-primary action)
- Seed/debug tools
- Multiple competing icon buttons without hierarchy

**Expected states:** Always visible. Offline: title changes to include "(غير متصل)".

**Accessibility:** All icons must have tooltips. Touch targets ≥ 48dp. No icon-only items without semantics label.

---

### Section 2 — Operational Status Strip

**Purpose:** Single, compact row communicating app status at-a-glance without blocking content.

**What it shows:**

- Connectivity: متصل / غير متصل (with icon)
- Last sync time: "آخر مزامنة: منذ 5 دقائق"
- Pending count: "15 سجل بانتظار الرفع" (only if > 0)
- Warning indicator: red dot if last sync failed

**What actions it enables:**

- Tap to open Sync Center (navigate to sync page)

**Why it belongs here:** Field workers need to know if their data is safe BEFORE they do anything else. A compact strip replaces 3–4 stacked banners.

**What should NOT appear here:**

- Technical error codes
- Taxonomy sync details
- Civil registry status

**Expected states:**

- Online + synced: subtle green strip, minimal text
- Online + pending: amber strip, count visible
- Offline: amber strip, offline icon, "وضع عدم الاتصال — بياناتك محفوظة محلياً"
- Sync failed: red strip, "فشلت المزامنة — اضغط لإعادة المحاولة"

**Accessibility:** Status must not be communicated by color alone. Always include an icon and text.

---

### Section 3 — Priority Overview Cards

**Purpose:** High-level numbers the user needs to make decisions.

**What it shows (proposed 2×2 or 1×4 scroll):**

- إجمالي المستفيدين (total beneficiaries)
- زيارات اليوم (today visited / planned)
- بانتظار الرفع (pending upload count)
- حالات عاجلة (urgent cases count — clickable)

**What actions it enables:**

- Tap on each card → navigate to relevant list
- Tap "حالات عاجلة" → jump to urgent cases section or list

**Why it belongs here:** Overview cards give the user a "morning briefing" before they start acting.

**What should NOT appear here:**

- Analytical charts or trends
- Technical sync metrics
- Geographic distribution
- Category percentages

**Expected states:**

- Loading: 4 skeleton cards (same size)
- Error: error card with retry
- Loaded: real numbers, no animation lag

**Accessibility:** Numbers must have semantic labels (not just "15" — "15 مستفيداً").

---

### Section 4 — Quick Actions

**Purpose:** One-tap access to most-used workflows.

**What it shows:** Exactly 6 cards (frozen spec):

1. إضافة مستفيد
2. المستفيدون
3. زيارات اليوم
4. الكفالات
5. الجمعيات
6. المزامنة

**What actions it enables:** Navigate to each feature.

**Why it belongs here:** After understanding the overview, the user's next step is to act. Quick Actions are the "action layer."

**What should NOT appear here:**

- Export, Reports, Civil Registry, Seed tools, Admin tools
- More than 6 items (frozen)
- Role-gated items (all 6 always visible)

**Expected states:** Always fully rendered (no loading state). Badge on المزامنة if pendingSync > 0.

**Accessibility:** Each card has Semantics(button: true, label: ...). Touch target ≥ 48×48dp.

---

### Section 5 — Today's Work

**Purpose:** Show the field worker exactly what needs to be done today, without searching.

**What it shows (proposed):**

- زيارات اليوم: X completed / Y planned
- متابعة عاجلة: Z overdue cases (max 3 previewed)
- حالات بدون زيارة: N beneficiaries with no visits this month
- "عرض الكل" link for each category

**What actions it enables:**

- Tap individual case → navigate to beneficiary detail
- "تسجيل زيارة" shortcut per case

**Why it belongs here:** Field workers' primary daily concern. Shows up BELOW Quick Actions because actions come first, context comes second.

**What should NOT appear here:**

- Charts or trends
- Sync metrics
- Analytical breakdowns
- Admin alerts

**Expected states:**

- Loading: 2–3 skeleton list items
- Empty: "أحسنت! لا توجد حالات طارئة اليوم" — positive reinforcement
- Has data: max 3 items per category, "عرض الكل" always visible

**Accessibility:** Each item has a meaningful label. Urgent items have a colored indicator AND a text label (not color-only).

---

### Section 6 — Sync & Offline Health

**Purpose:** Dedicated but compact sync status area. Replaces the current large "navigate to sync page" pattern with a glanceable summary.

**What it shows:**

- آخر مزامنة ناجحة: تاريخ ووقت
- سجلات بانتظار الرفع: N
- رفع فاشل: N (if > 0, shown in red)
- زر: "فتح مركز المزامنة"

**What actions it enables:**

- Navigate to MobileSyncPage for full control
- Visual indicator if anything requires attention

**Why it belongs here:** Below Today's Work — users check sync status after completing daily work tasks.

**What should NOT appear here:**

- Raw Firestore logs or technical messages
- Civil registry download tool
- Taxonomy sync health (admin concern)

**Expected states:**

- All synced: green summary, "تم تزامن جميع البيانات"
- Pending: amber, count visible
- Failed: red, "يوجد X سجل فشل رفعه — اضغط للتفاصيل"
- Offline: amber, "وضع عدم الاتصال — بياناتك محفوظة"

---

### Section 7 — Recent Activity / Alerts

**Purpose:** Audit trail — what happened recently. Secondary information.

**What it shows:**

- Last 3–5 activities from `RecentActivitiesList`
- Each: action type, beneficiary name (or masked), timestamp
- "عرض الكل" link

**What actions it enables:**

- Tap activity → navigate to relevant record
- "عرض الكل" → AllActivitiesPage

**Why it belongs here:** Recent activity is reference information, not primary workflow. It belongs near the bottom.

**What should NOT appear here:**

- Swipe-to-delete on activity items (destructive, unexpected)
- Technical sync log entries
- System events (taxonomy synced, app started)

**Expected states:**

- Loading: skeleton list
- Empty: "لا توجد أنشطة حديثة"
- Error: inline error with retry

---

### Section 8 — Optional Insights (Admin / Analytical Mode)

**Purpose:** Charts and analytics — ONLY in analytical mode, ONLY behind feature flag.

**What it shows:**

- Growth trend (TrendLineChart)
- Category distribution (CategoryDistributionChart)
- Geographic distribution (GeographicDistributionSection)
- Daily performance (DailyPerformanceSection)

**Why it belongs here:** Analytical mode is an opt-in power feature. It must not clutter the default operational view.

**What should NOT appear here:**

- Debug tools
- Raw Firestore data
- Seed results

---

### Section 9 — Admin / Maintenance (Hidden)

**Purpose:** Admin-only tools — fully hidden from normal users.

**Location:** In `More (⋮)` popup in AppBar **or** dedicated Admin Panel page.

**Contents:**

- تصدير التقرير
- إدارة التصنيفات
- لوحة المراقبة
- أدوات التشخيص
- Firestore diagnostics (debug only)
- Civil registry download tool

**Visibility rule:** `isAdmin == true` only. `kDebugMode` does NOT grant admin access in production.

**Recommended future:** Dedicated Admin Panel page accessible from Settings, not from Dashboard popup.

---

## 4. Items to Remove, Hide, or Move

### Classification

| Item                                                                                   | Classification                     | Reason                                                                                   | Where It Should Go                                                                 |
| -------------------------------------------------------------------------------------- | ---------------------------------- | ---------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| Mode switcher (تشغيلي/تحليلي) chips                                                    | **B — Move to More menu**          | Confusing when feature flag is off; one chip alone is purposeless                        | Dropdown in More menu for power users                                              |
| `_CivilRegistryBanner`                                                                 | **C — Move to Admin/Maintenance**  | Technical concept; field workers don't understand it; blocks content                     | Admin panel or Settings → System status                                            |
| `_TaxonomySyncHealthBanner`                                                            | **C — Move to Admin/Maintenance**  | Technical taxonomy status; irrelevant to daily field work                                | Admin panel or status section in Settings                                          |
| WelcomeBanner                                                                          | **E — Keep but simplify**          | Useful for onboarding; currently shows generic text                                      | Show only once, use user's actual name, add "start now" CTA                        |
| `DashboardAppBar` widget (dead code)                                                   | **A — Remove from codebase**       | Never rendered, creates maintenance confusion                                            | Delete file                                                                        |
| Advanced Filters button (tune icon)                                                    | **E — Keep but simplify**          | Useful but buried; "فلاتر متقدمة" as icon-only is not discoverable                       | Move to a visible "تصفية" labeled button or chip                                   |
| Analytical charts (TrendLineChart, GrowthChart, CategoryChart, GeographicDistribution) | **B — Move to More menu / opt-in** | Heavy, slow to load, not daily field work tools                                          | Optional Insights section behind feature flag, accessible from More menu           |
| `DailyPerformanceSection`                                                              | **D — Move to Reports/Analytics**  | Performance analytics belong in Reports, not Dashboard                                   | Reports page                                                                       |
| Swipe-to-delete on ActivityItem                                                        | **A — Remove from Dashboard**      | Destructive, accidental, unexpected on recent activity feed                              | Keep in dedicated AllActivitiesPage with explicit delete button + confirmation     |
| `DashboardExportDialog` (in AppBar)                                                    | **C — Move to Admin/Maintenance**  | Not a daily field worker action                                                          | Admin popup / Settings → Export                                                    |
| Monitoring Dashboard (kDebugMode)                                                      | **C — Move to Admin/Maintenance**  | Technical diagnostic; should require admin claim, not just debug mode                    | Admin panel, admin-only                                                            |
| FilterChipGroup label "التصنيفات السريعة"                                              | **E — Keep but rename**            | Label doesn't match what filters do ("التصنيفات السريعة" sounds like taxonomy filtering) | Rename to "عرض البيانات" or "فلترة"                                                |
| Refresh IconButton next to filter chips                                                | **E — Keep but move**              | Redundant with pull-to-refresh; clutters filter row                                      | Remove from filter row; pull-to-refresh is sufficient                              |
| `geographicDistributionProvider` (non-autoDispose)                                     | **D — Move to Reports**            | Loads full province map even when not shown; performance risk                            | Load on-demand in Reports/Analytics page                                           |
| Notifications icon → snackbar                                                          | **E — Keep but improve**           | Showing a snackbar for notifications is misleading                                       | Future: open a notification panel; For now: navigate to pending tasks or sync page |
| Duplicate data: `dashboardSummaryProvider` + `dashboardProvider`                       | **E — Consolidate**                | Two providers serving overlapping data; causes duplicate DB queries                      | Consolidate into single source in future provider refactor phase                   |
| `urgentCasesProvider` (non-autoDispose)                                                | **E — Make autoDispose**           | Stays alive indefinitely in memory                                                       | Add `.autoDispose` modifier                                                        |

---

### Summary Table

| Category                             | Items                                                                                           |
| ------------------------------------ | ----------------------------------------------------------------------------------------------- |
| **A — Remove from normal Dashboard** | Mode switcher lone chip, DashboardAppBar dead code, swipe-to-delete on activity feed            |
| **B — Move to More menu**            | Full analytical mode toggle, advanced filter discovery                                          |
| **C — Move to Admin/Maintenance**    | Civil registry banner, taxonomy health banner, export dialog, monitoring dashboard              |
| **D — Move to Reports/Analytics**    | Daily performance section, geographic distribution, category charts                             |
| **E — Keep but simplify/improve**    | Welcome banner, filter chips, notifications icon, overview card typography, OfflineBanner color |

---

## 5. Missing UX Features / Recommended Additions

### Feature 1 — Smart "Today's Work" Card

**User Value:** Field workers instantly see what to do today without hunting through the Dashboard.

**What it shows:**

- زيارات اليوم: N completed (tap → Visits page filtered to today)
- متابعة عاجلة: N overdue (tap → filtered urgent list)
- حالات بدون زيارة: N (tap → beneficiaries with no recent visit)
- Max 3 items per category with "عرض الكل" link

**Priority:** P0 — Core field worker daily tool  
**Complexity:** Medium (needs today-scoped queries; reuse existing DB queries from UrgentCasesSection)  
**Dependencies:** `urgentCasesProvider`, `todayStats` in `DashboardState`  
**Risk:** Low — display-only, no new write operations  
**Phase:** Phase 3

---

### Feature 2 — Compact Sync Health Card

**User Value:** Field workers confirm data safety without opening Sync Center.

**What it shows:**

- آخر مزامنة: وقت + تاريخ OR "لم تتم مزامنة بعد"
- بانتظار الرفع: N (or "لا شيء")
- فشل: N (red, only if > 0)
- زر: "فتح مركز المزامنة"

**Priority:** P1 — Highly useful, reduces sync anxiety  
**Complexity:** Low (data already available from `dashboardSummaryProvider`)  
**Dependencies:** `dashboardSummaryProvider.pending`, last sync time from `syncMetadataDao`  
**Risk:** Low — read-only display  
**Phase:** Phase 3

---

### Feature 3 — Priority Alerts Strip

**User Value:** Proactive alerts before user starts their day. Not stackable banners — a single priority strip.

**Logic:**

- Only ONE alert shown at a time (highest priority wins)
- Priority order:
  1. Sync failed (P0 — red)
  2. Offline for > 24 hours (P1 — amber)
  3. Unsynced changes > N records (P1 — amber)
  4. Low file numbers available (P2 — amber)
  5. Urgent follow-up overdue (P2 — contextual)
- Alert is dismissible (per session)
- Tap → action relevant to the alert

**Priority:** P1 — Replaces 3–4 stacked banners  
**Complexity:** Medium (needs alert priority logic; replaces current banner pattern)  
**Dependencies:** Sync status, file number pool count, offline duration tracking  
**Risk:** Medium — replaces existing banner components; needs tests  
**Phase:** Phase 2

---

### Feature 4 — Quick Add Pattern (FAB + Speed Dial)

**User Value:** Field workers add beneficiaries faster. Current: one FAB tap → Add Beneficiary form. Future: speed dial shows 2–3 options.

**Proposed options:**

- إضافة مستفيد (primary — same as current FAB)
- تسجيل زيارة (secondary — if supported)
- إضافة متابعة (tertiary — if supported)

**Priority:** P2 — Useful but current FAB is already correct  
**Complexity:** Medium (FAB → SpeedDial; needs role check for options)  
**Dependencies:** Visit and follow-up create flows exist  
**Risk:** Low — additive change, current behavior preserved as default  
**Phase:** Phase 4

---

### Feature 5 — Global Search / Command Entry

**User Value:** Find a beneficiary by name, phone, or file number in one step from AppBar.

**Current state:** `DashboardSearchDelegate` is implemented and functional via `showSearch()`.

**Improvements needed:**

- Add placeholder text: "ابحث باسم المستفيد أو رقم الملف..."
- Add recent searches list (local only, no cloud)
- Return to previous position after search closes
- Ensure results are not paginated too aggressively

**Priority:** P1 — Search is already there; improvements make it discoverable  
**Complexity:** Low–Medium  
**Dependencies:** `DashboardSearchDelegate` (existing)  
**Risk:** Low  
**Phase:** Phase 2

---

### Feature 6 — "Continue Where You Left Off"

**User Value:** After app restart or return from another page, user sees their last context.

**Proposed:**

- Show last opened beneficiary as a chip under Search bar: "آخر مستفيد: محمد أحمد ←"
- Clear on logout

**Priority:** P3 — Nice-to-have  
**Complexity:** Low (SharedPreferences cache of last beneficiary ID + name)  
**Dependencies:** Navigation service, SharedPreferences  
**Risk:** Low  
**Phase:** Phase 5

---

### Feature 7 — Role-Personalized Dashboard Header

**User Value:** Users see content relevant to their role without confusion.

**Proposed:**

- Field worker: "اليوم: X زيارات مكتملة • Y حالة طارئة"
- Reviewer: "هذا الأسبوع: X سجل جديد • Y بانتظار المراجعة"
- Admin: "حالة النظام: سليم / تحذير / خطأ"

**Priority:** P2  
**Complexity:** Medium (needs role-aware provider + per-role widget)  
**Dependencies:** `userRoleProvider` (existing, tested)  
**Risk:** Low — additive, role provider is stable  
**Phase:** Phase 5

---

### Feature 8 — Meaningful Empty States

**User Value:** Users know what to do when there's nothing to show.

**Current gaps:**

- No "no beneficiaries yet" state with onboarding CTA
- No "all synced — nothing pending" positive state
- No "no visits today" contextual state

**Proposed states:**

| Scenario          | Message                             | CTA            |
| ----------------- | ----------------------------------- | -------------- |
| No beneficiaries  | "لم يتم إضافة أي مستفيد بعد"        | إضافة مستفيد   |
| No urgent cases   | "أحسنت! لا توجد حالات طارئة"        | — (positive)   |
| All synced        | "تم تزامن جميع البيانات ✓"          | — (positive)   |
| No visits today   | "لم تُسجَّل زيارات اليوم"           | تسجيل زيارة    |
| Offline + no data | "لا تتوفر بيانات — تحقق من الاتصال" | إعادة المحاولة |

**Priority:** P1 — Empty states reduce confusion significantly  
**Complexity:** Low (text + icon changes)  
**Risk:** Low  
**Phase:** Phase 2

---

### Feature 9 — Microcopy Improvements

**User Value:** Clear labels reduce learning time and errors.

**Current weak labels:**

| Current Label                              | Issue                               | Proposed Label                     |
| ------------------------------------------ | ----------------------------------- | ---------------------------------- |
| "التصنيفات السريعة"                        | Sounds like taxonomy browsing       | "فلترة البيانات"                   |
| "وضع تشغيلي / تحليلي"                      | Technical, no explanation           | "عرض مبسط / عرض تفصيلي"            |
| "تصدير التقرير"                            | Vague in popup                      | "تصدير ملف Excel"                  |
| "السجل المدني"                             | Technical, unknown to field workers | "قاعدة بيانات المواطنين" or hide   |
| "لوحة المراقبة"                            | Admin jargon                        | "مراقبة النظام" or keep admin-only |
| Notifications snackbar "لديك X مهمة معلقة" | "مهمة معلقة" is ambiguous           | "X سجل بانتظار الرفع"              |

**Priority:** P1 — Language improvements are low-risk, high-impact  
**Complexity:** Low  
**Phase:** Phase 2

---

### Feature 10 — Accessibility Improvements

**User Value:** All users can use the app regardless of font size, visual ability, or motor skills.

| Issue                     | Current State                                                                                                                                             | Proposed Fix                                                                |
| ------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------- |
| Minimum touch target      | QuickActionCard: 50×50 icon inside full card — OK. ListTile items may be < 48dp.                                                                          | Audit all tappable items; ensure ≥ 48dp height                              |
| Tooltip / semantic labels | QuickActionCard has Semantics. AppBar icons have tooltips. ActivityItem chevron has NO semantic label.                                                    | Add semantics to all interactive elements                                   |
| Text scaling              | No TextScaler test. Stat values at 28.sp may overflow at scale 1.5.                                                                                       | Clamp font sizes; test at scale 1.3 and 1.5                                 |
| Color-only status         | OfflineBanner uses color without additional text cue for color-blind users — text IS present, OK. ActivityItem uses color for type with NO text fallback. | Add text labels to activity type indicators                                 |
| RTL-safe icons            | `Icons.chevron_right` in ActivityItem and `Icons.arrow_forward` in "عرض الكل" are LTR-directional                                                         | Replace with `Icons.arrow_forward_ios` or use `Directionality`-aware widget |
| High contrast             | App uses AppColors theme — not audited for WCAG AA contrast ratios                                                                                        | Audit primary action colors vs background                                   |
| Focus order               | Not audited for keyboard/focus traversal                                                                                                                  | Verify logical focus order in RTL                                           |

**Priority:** P1 (touch targets, semantics), P2 (text scale, contrast), P3 (focus order)  
**Phase:** Phase 4

---

## 6. Visual Design Recommendations

### 6.1 Layout

- **Page padding:** `ResponsiveUtils.getResponsivePadding()` is used — keep. Add explicit `maxWidth: 600` constraint for tablets via `ConstrainedBox` or `Center` wrapper.
- **Card spacing:** Current `SizedBox(height: 24.h)` between sections — consistent. Reduce to 16.h between closely related items.
- **Section separation:** Add a subtle `Divider` or extra vertical space between major sections (overview / quick actions / today's work).
- **Nested scrolling:** Current `SingleChildScrollView` inside `SliverToBoxAdapter` is a known anti-pattern. Target: move to full `SliverList` architecture with `SliverPadding`. Do NOT change during planning phase.
- **No nested `GridView.count` inside `SingleChildScrollView`** — DashboardSummaryWidget has this. Target: replace with `Row` of stat chips.

### 6.2 Typography

Recommended scale (harmonized with existing `DashboardTextStyles`):

| Element                   | Current   | Recommended                          |
| ------------------------- | --------- | ------------------------------------ |
| Screen/AppBar title       | 20sp (ok) | 20sp — keep                          |
| Section title             | 18sp (ok) | 16–18sp — keep                       |
| Card title / stat label   | 12sp      | 13–14sp                              |
| Stat value (large number) | 28sp      | 20–22sp (reduce to prevent overflow) |
| Card subtitle             | 11.5sp    | 12sp                                 |
| Caption / timestamp       | 11sp      | 11–12sp                              |

**Rule:** Stat values must never clip or overflow. Use `FittedBox` or `AutoSizeText` for large numbers.

### 6.3 Cards

- **Consistent radius:** 16.r — already used. Keep.
- **Consistent padding:** 16.w all sides for cards. 12.w for compact items.
- **Icon + label hierarchy:** Icon container → Icon (24dp max) → label below. Avoid icon > 26dp on mobile.
- **Badge placement:** Top-right corner of icon container (current implementation is correct).
- **Tap feedback:** Use `InkWell` or `MicroInteractions.bounceButton` consistently. Do not mix.

### 6.4 Color (Status Encoding)

Use the existing `AppColors` theme. Do NOT introduce arbitrary new colors.

| Status                  | Color                          |
| ----------------------- | ------------------------------ |
| Success / synced        | AppColors.success (green)      |
| Warning / pending       | AppColors.warning (amber)      |
| Danger / error / urgent | AppColors.error (red)          |
| Neutral / information   | AppColors.primary (blue)       |
| Disabled / inactive     | AppColors.textSecondary (grey) |

**Rule:** Color must encode meaning consistently across the entire Dashboard. "Urgent" is always `AppColors.error`. "Pending" is always `AppColors.warning`. No random new colors per feature.

### 6.5 Icons

- Use `Icons.*_rounded` variants consistently (existing Quick Actions use `_rounded` — keep).
- No icon without a semantic meaning.
- RTL-aware: `Icons.arrow_forward` / `Icons.chevron_right` must be replaced with `TextDirection`-aware or explicitly mirrored icons.
- Recommended RTL-safe pattern: `Icon(Icons.arrow_forward_ios)` wrapped in `Directionality.of(context) == TextDirection.rtl ? Transform.flip(flipX: true) : child`.

### 6.6 Banners

**Current problem:** Up to 4 banners can stack simultaneously.

**Rule for target state:**

- Maximum 1 high-priority banner visible at a time.
- Priority order: sync error > offline > welcome > taxonomy.
- Low-priority status (taxonomy health, civil registry) → collapsed into the Operational Status Strip (Section 2).
- Welcome Banner → max 1 session, auto-dismiss after 5 seconds or first action.

### 6.7 Loading

- **Skeleton cards:** Keep for initial load. Do NOT show skeleton on refresh (pull-to-refresh — keep old data visible).
- **Progressive disclosure:** Show Quick Actions and AppBar immediately (no wait). Show data cards as they load with skeleton placeholders.
- **No full-screen spinner:** `CircularProgressIndicator` on full screen should only appear during SharedPreferences initialization (< 100ms), not during data load.

---

## 7. Accessibility and RTL Checklist

> This is a target checklist for future implementation phases. Not verified as complete today.

### RTL Layout

- [ ] All `Row` children are RTL-aware (leading/trailing text correctly mirrored)
- [ ] `Icons.arrow_forward` replaced with RTL-aware equivalent in `RecentActivitiesList`, `UrgentCasesSection`, filter row
- [ ] `Icons.chevron_right` in `ActivityItem` trailing — replace with `Icons.chevron_left` in RTL or use `Transform.flip`
- [ ] `SwipeableCard` swipe directions verified in RTL (swipeRight = view in LTR = delete equivalent in RTL?)
- [ ] Gradient direction in `QuickActionCard` (`Alignment.topRight → bottomLeft`) — correct in RTL
- [ ] `FloatingActionButton` location: `FloatingActionButtonLocation.endFloat` — correct in RTL (renders on left)
- [ ] `NavigationBar` destination order: RTL renders left-to-right, but conceptually first item is rightmost in Arabic — verify visual order

### Arabic Label Clarity

- [ ] "التصنيفات السريعة" → rename (see Feature 9)
- [ ] "وضع تشغيلي / تحليلي" → rename (see Feature 9)
- [ ] "لديك X مهمة معلقة" → clarify (see Feature 9)
- [ ] All section titles use Arabic natively (no English words in visible text)
- [ ] No numeric-only badges without accessible `Semantics` label

### Semantic Labels

- [ ] All `IconButton` have `tooltip` set
- [ ] All `QuickActionCard` have `Semantics(button: true, label: ...)` — currently implemented ✅
- [ ] `ChoiceChip` mode switcher has `Semantics(label: ...)` — currently implemented ✅
- [ ] `ActivityItem` trailing `Icon(Icons.chevron_right)` has semantic label
- [ ] Badge numbers have semantic labels: "15 سجل بانتظار الرفع" not just "15"
- [ ] Loading skeletons have `ExcludeSemantics` wrapper (screen reader skips them)
- [ ] Error states have semantic role "alert"

### Touch Targets

- [ ] All `QuickActionCard` instances: full card is tappable, minimum 48×48dp effective area ✅
- [ ] `IconButton` default size is 48×48 in Material 3 ✅
- [ ] `FilterChipGroup` chips: minimum 32dp height (Material spec for chips); verify at small font sizes
- [ ] `ActivityItem` `ListTile`: minimum 48dp height ✅ (Material ListTile default)
- [ ] `SectionTitle` "عرض الكل" `TextButton`: minimum 48dp ✅

### Text Scale

- [ ] Test at `TextScaleFactor` 1.0 (baseline), 1.3 (large text), 1.5 (accessibility)
- [ ] `DashboardSummaryWidget` stat values at 28.sp → may clip at scale 1.5; add `FittedBox` or cap
- [ ] Quick Action card labels: `maxLines: 2, overflow: TextOverflow.ellipsis` — already set ✅
- [ ] Badge numbers: font size 10sp → at scale 1.5 = 15sp — verify badge container doesn't overflow

### No Overflow

- [ ] `DashboardSummaryWidget` grid with 28.sp values — audit at scale 1.5 and small screen (360dp)
- [ ] `QuickActionCard` compact mode at 360dp width — tested in compact var ✅
- [ ] Stat card values with large numbers (100,000+): add number formatting (`NumberFormat.compact()`)

### High Contrast

- [ ] `AppColors.warning` amber text on white background — verify ≥ 4.5:1 WCAG AA ratio
- [ ] `AppColors.error` red text on white background — verify ≥ 4.5:1
- [ ] Card gradient background + text — ensure text is still readable on gradient

### Offline Status

- [ ] Offline communicated with icon (wifi_off) ✅ + text ✅ — not color-only ✅
- [ ] Sync error communicated with icon + text (proposed in Status Strip)
- [ ] Screen reader announces connectivity change

---

## 8. UX Success Metrics

These are measurable acceptance criteria for future implementation phases.

### Core Workflow Metrics

| Metric                                    | Target                                                         |
| ----------------------------------------- | -------------------------------------------------------------- |
| Add beneficiary from Dashboard in one tap | ≤ 1 tap (FAB or Quick Action)                                  |
| Understand sync status                    | ≤ 3 seconds glance (Status Strip must be immediately readable) |
| Reach today's visits                      | ≤ 1 tap (Quick Action "زيارات اليوم")                          |
| Reach urgent cases                        | ≤ 1 tap (tap on urgent count card)                             |
| Identify offline status                   | Immediate — strip visible without scrolling                    |
| First usable UI visible                   | ≤ 500ms — AppBar + Quick Actions render before data loads      |
| Dashboard full load time                  | ≤ 2s on typical device (Drift queries < 200ms target)          |

### Content Metrics

| Metric                                  | Target                                     |
| --------------------------------------- | ------------------------------------------ |
| Normal user sees admin/debug/seed tools | Never — 0 visible tools                    |
| Banners shown simultaneously            | Maximum 1 priority banner                  |
| Quick Actions count                     | Always exactly 6 (enforced by widget test) |
| Today's Work preview items              | Maximum 3 per category                     |
| Recent Activities shown                 | Maximum 5 on Dashboard                     |

### Accessibility Metrics

| Metric                                        | Target                               |
| --------------------------------------------- | ------------------------------------ |
| All dashboard cards survive text scale 1.5    | No overflow, no clipping             |
| RTL layout has no overflow                    | Zero overflow on any screen > 320dp  |
| All interactive elements have semantic labels | 100%                                 |
| Touch targets ≥ 48×48dp                       | All tappable elements                |
| Status communicated without color alone       | All status items include icon + text |

### Regression Guards

| Metric                                    | Target                                             |
| ----------------------------------------- | -------------------------------------------------- |
| Quick Actions changed without test update | Not allowed — widget test blocks regression        |
| Admin tools exposed to normal user        | Not allowed — security visibility test blocks this |
| Dashboard test baseline                   | 150/150 must remain PASS after any implementation  |
| Security test baseline                    | 101/101 must remain PASS after any implementation  |

---

## 9. Proposed Implementation Phases

### Phase 1 — UX Audit and Wireframe (Current Phase)

**Scope:** Document-only. No code.
**Deliverable:** This document (`DASHBOARD_UX_NEXT_LEVEL_PLAN.md`)
**Files Touched:** Docs only
**Tests Needed:** None
**Risk:** Zero
**Rollback:** N/A

---

### Phase 2 — Visual Cleanup and Microcopy

**Scope:** Typography, spacing, card consistency, banner simplification, label improvements. No logic changes.

**Changes:**

- Reduce stat value font size from 28.sp to 20–22.sp
- Rename "التصنيفات السريعة" → "فلترة البيانات"
- Rename mode switcher labels
- Cap banner stacking to 1 visible at a time (priority logic)
- Remove `Refresh IconButton` from filter row (pull-to-refresh is sufficient)
- Fix `Icons.chevron_right` → RTL-aware icon in ActivityItem
- Fix `Icons.arrow_forward` → RTL-aware in "عرض الكل" links
- Apply `ExcludeSemantics` to skeleton loaders
- Add number formatting to large stat values

**Files Likely Touched:**

- `dashboard_page.dart` — banner priority logic, label changes
- `activities_section.dart` — icon fix
- `dashboard_summary_widget.dart` — font size
- `urgent_cases_section.dart` — minor copy changes

**Tests Needed:**

- Widget test: Quick Actions labels unchanged (existing test ✅)
- Widget test: No overflow at 360dp width
- Widget test: Max 1 banner visible

**Risk:** Low — UI-only, no logic changes
**Rollback:** Revert changed lines

---

### Phase 3 — Information Architecture

**Scope:** Add Today's Work card, Compact Sync Health card, Priority Alerts strip. Remove dead code (`DashboardAppBar`).

**Changes:**

- Add `TodaysWorkCard` widget (display-only, reads from existing DB queries)
- Add `SyncHealthCard` widget (reads from `dashboardSummaryProvider`)
- Add `PriorityAlertStrip` widget replacing multiple banners
- Remove `DashboardAppBar` dead code file
- Move Civil Registry and Taxonomy banners to admin-only section
- Move mode switcher to More menu

**Files Likely Touched:**

- `dashboard_page.dart` — layout order, new sections
- New: `widgets/todays_work_card.dart`
- New: `widgets/sync_health_card.dart`
- New: `widgets/priority_alert_strip.dart`
- Delete: `widgets/dashboard_app_bar.dart` (dead code)

**Tests Needed:**

- Widget test: `TodaysWorkCard` empty state
- Widget test: `TodaysWorkCard` list state (max 3 items)
- Widget test: `SyncHealthCard` states (synced / pending / failed / offline)
- Widget test: `PriorityAlertStrip` shows at most 1 alert
- Widget test: Civil Registry banner NOT visible to normal user

**Risk:** Medium — restructures page content; must not change Quick Actions
**Rollback:** Feature flag gate new sections

---

## Phase 4 Consolidation & UX Polish Status ✅ COMPLETE

**Completed 2026-05-28**

- Section heading "حالات تحتاج متابعة" → "تفاصيل المتابعة" in both operational and analytical views of `dashboard_page.dart`
- Redundant `SizedBox(height: 8.h)` before 24h gap removed (spacing cleanup after Sync Health card)
- Empty-state copy in `activities_section.dart`: "ابدأ بإضافة مستفيدين لرؤية الإحصائيات" → "لا توجد أنشطة حديثة حتى الآن"
- Empty-state copy in `urgent_cases_section.dart`: "لا توجد حالات طارئة" → "أحسنت! لا توجد حالات تحتاج متابعة اليوم"
- Deprecated `.withOpacity(0.3)` → `.withValues(alpha: 0.3)` in `activities_section.dart`
- Quick Actions unchanged (6 frozen); no new providers/queries/sync/security changes
- 25/25 focused tests PASS; 0 analyzer issues on all changed files

---

## Phase 3 Today's Work + Sync Health Status ✅ COMPLETE

**Completed 2026-05-28**

- `DashboardTodaysWorkCard` implemented — uses `TodayStats` from `DashboardStatistics` (cheap, already loaded)
- `DashboardSyncHealthCard` implemented — uses `pendingSync`, `isOnline`, `lastSyncTime` (cheap, already loaded)
- Both cards shown in operational view only (after Quick Actions)
- `UrgentCasesSection` and `RecentActivitiesList` kept untouched (Phase 4 will consolidate)
- Quick Actions unchanged (6 frozen)
- Security/State/Sync baselines preserved
- No new providers added, no heavy queries added
- 25/25 focused tests PASS (5 card tests × 2 + 15 quick actions)
- 0 analyzer errors/warnings in new files

**Deferred to Phase 4:**

- Consolidate UrgentCasesSection into TodaysWorkCard
- Add 3-item urgent case preview
- Add overdue follow-ups row (needs new `TodayStats` field)
- `hasSyncFailure` wiring in sync card
- DashboardAppBar dead code removal

---

### Phase 4 — Accessibility Pass

**Scope:** RTL fixes, touch targets, semantic labels, text scale audit.

**Changes:**

- Replace all LTR directional icons with RTL-aware variants
- Add `Semantics` to ActivityItem trailing icon
- Add `FittedBox` or size clamp to stat values
- Test and fix text scale 1.5 overflow
- Verify WCAG AA contrast for key color pairs
- Add `ExcludeSemantics` to decorative icons

**Files Likely Touched:**

- `activities_section.dart`
- `dashboard_summary_widget.dart`
- `urgent_cases_section.dart`
- `quick_actions.dart` (minor: semantic label improvements)

**Tests Needed:**

- Widget test: RTL layout no overflow (golden test or explicit size test)
- Widget test: Stat values at textScaleFactor 1.5

**Risk:** Low — no logic changes
**Rollback:** Revert icon changes

---

### Phase 5 — Role-Aware Dashboard and Personalization

**Scope:** Role-personalized header, "Continue where you left off", Quick Add speed dial.

**Changes:**

- Add role-aware header section using `userRoleProvider`
- Add `lastOpenedBeneficiaryProvider` (SharedPreferences-backed)
- Replace FAB with `SpeedDial` if additional quick-add actions are supported
- Read-only users: disable write-action taps with friendly message

**Files Likely Touched:**

- `dashboard_page.dart` — header section
- New: `providers/last_opened_beneficiary_provider.dart`
- `quick_actions.dart` — if role-based tap handling added

**Tests Needed:**

- Widget test: read-only user sees disabled quick actions (if implemented)
- Widget test: field worker header shows today's visit count
- Unit test: `lastOpenedBeneficiaryProvider` reads and writes correctly

**Risk:** Medium — role-based behavior is security-sensitive; must use existing `userRoleProvider`
**Rollback:** Feature flag

---

### Phase 6 — Optional Analytics / Reporting

**Scope:** Move analytical charts to a dedicated Reports/Analytics page. Clean up analytical mode in Dashboard.

**Changes:**

- Create `/reports` route with full Analytics page
- Move `TrendLineChart`, `GrowthChart`, `CategoryDistributionChart`, `GeographicDistributionSection`, `DailyPerformanceSection` to Reports page
- Remove analytical mode from Dashboard entirely OR keep as a simple toggle to the Reports page

**Files Likely Touched:**

- New: `lib/features/reports/presentation/pages/analytics_page.dart`
- `dashboard_page.dart` — remove analytical mode content

**Tests Needed:**

- Widget test: Dashboard in operational mode has no charts
- Widget test: Analytics page renders charts correctly

**Risk:** Medium — removes existing analytical mode; must not break existing navigation
**Rollback:** Keep analytical mode behind feature flag until Reports page is verified

---

## 10. Recommended Dashboard Wireframe

Target state (after Phase 3 implementation). Arabic / RTL / Mobile 390dp width.

```
┌─────────────────────────────────────────────────┐
│  [AppBar — pinned, collapses on scroll]          │
│  🏠  منظومة بناء              🔍  🔔  ⋮(admin)  │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│  [Operational Status Strip — single row]         │
│  🟢 متصل  │  آخر مزامنة: منذ 5 دقائق  │  ↗ مزامنة│
│  (amber if pending, red if failed, grey offline) │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│  [Priority Alert — max 1, dismissible]           │
│  ⚠  15 سجل بانتظار الرفع — اضغط للمزامنة     ✕ │
│  (hidden when no alerts)                         │
└─────────────────────────────────────────────────┘

┌──────────────┬──────────────┬──────────────────┐
│ 👥 المستفيدون │ 🗓 زيارات اليوم │ ⚡ حالات عاجلة  │
│    1,247      │    8 / 12    │       3          │
│               │   مكتملة    │   اضغط للعرض    │
├──────────────┴──────────────┴──────────────────┤
│ 📤 بانتظار الرفع: 15   |  ✅ آخر رفع: أمس     │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│  ⚡ إجراءات سريعة                                │
│  ┌────────┐ ┌────────┐ ┌────────┐               │
│  │ ➕ إضافة│ │👥المستف │ │🗓زيارات│               │
│  │  مستفيد│ │  يدون  │ │ اليوم │               │
│  └────────┘ └────────┘ └────────┘               │
│  ┌────────┐ ┌────────┐ ┌────────┐               │
│  │💛الكفا │ │🏢الجمع │ │🔄 15  │               │
│  │  لات   │ │  يات   │ │مزامنة │               │
│  └────────┘ └────────┘ └────────┘               │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│  📋 عمل اليوم                                   │
│  ─────────────────────────────────────────────  │
│  🗓 زيارات: 8 مكتملة • 4 متبقية        عرض الكل│
│  ⚠  متابعة عاجلة: أحمد علي — منذ 3 أيام    ↗  │
│  ⚠  متابعة عاجلة: فاطمة محمد — منذ يومين   ↗  │
│  ⚠  متابعة عاجلة: خالد حسن — منذ 5 أيام   ↗  │
│                              + 2 أخرى  عرض الكل│
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│  🔄 حالة المزامنة                               │
│  ─────────────────────────────────────────────  │
│  آخر مزامنة ناجحة: اليوم 09:30                  │
│  📤 بانتظار الرفع: 15 سجل                       │
│  ✅ رفع فاشل: لا شيء                            │
│  ──────────────────────────────────             │
│  [       فتح مركز المزامنة       ]              │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│  🕐 الأنشطة الحديثة              عرض الكل ←    │
│  ─────────────────────────────────────────────  │
│  ➕  أُضيف مستفيد جديد           منذ ساعة      │
│  📝  تم تعديل بيانات محمد أحمد   منذ ساعتين    │
│  🔄  تم رفع 12 سجل               منذ 3 ساعات   │
└─────────────────────────────────────────────────┘

[                  ➕ إضافة مستفيد               ]
         ← FAB Extended, bottom-right

┌─────────────────────────────────────────────────┐
│  [NavigationBar — always visible]               │
│  🏠 الرئيسية  │  🔄 المزامنة  │  ⚙ الإعدادات  │
└─────────────────────────────────────────────────┘

────────────────────────────────────────────────────
ADMIN POPUP (More ⋮) — admin only:
  • تصدير التقرير
  • إدارة التصنيفات
  • مراقبة النظام (admin + debug only)
  • [عرض تحليلي] ← move mode switcher here
────────────────────────────────────────────────────
```

---

## 11. Future Testing Plan

> Tests must be written when implementation starts — NOT during planning.

### Widget Tests to Add

| Test                                                            | Purpose                               |
| --------------------------------------------------------------- | ------------------------------------- |
| Dashboard renders without overflow at 360dp                     | Catch layout issues on small phones   |
| Dashboard renders without overflow at text scale 1.5            | Accessibility regression guard        |
| Quick Actions always exactly 6                                  | Existing test ✅ — must not be broken |
| AppBar tooltips present on all action icons                     | Accessibility                         |
| Admin tools hidden for normal user                              | Existing test ✅ — must not be broken |
| Status Strip shows correct state for each connectivity scenario | New widget                            |
| `SyncHealthCard` renders all 3 states: synced, pending, failed  | New widget                            |
| `TodaysWorkCard` empty state renders "أحسنت!" message           | New widget                            |
| `TodaysWorkCard` shows max 3 items + "عرض الكل" when more       | New widget                            |
| `PriorityAlertStrip` shows at most 1 alert                      | New widget                            |
| Priority Alerts: sync error takes priority over offline warning | Priority logic                        |
| RTL layout: no icons are incorrectly mirrored                   | RTL regression                        |
| Welcome Banner auto-dismisses after first action                | Behavior test                         |
| Max 1 banner visible at a time                                  | Banner priority test                  |

### Unit Tests to Add

| Test                                                                   | Purpose        |
| ---------------------------------------------------------------------- | -------------- |
| Alert priority ordering: sync_error > offline > pending > file_numbers | Priority logic |
| Today's Work preview: returns max 3 items                              | Data slicing   |
| `lastOpenedBeneficiaryProvider` reads/writes correctly                 | Feature 6      |
| Role-aware header: field worker vs reviewer vs admin labels            | Feature 7      |
| `SyncHealthCard` data model: last sync time formatting                 | Display model  |
| Number formatting: 1,247 → "1٬247" or "1.2k" compact format            | Utility        |

### Performance Tests

| Test                                                             | Purpose               |
| ---------------------------------------------------------------- | --------------------- |
| Dashboard open does NOT trigger full beneficiary collection load | Guard expensive query |
| Dashboard open does NOT trigger taxonomy sync (unless stale)     | Guard background sync |
| `dashboardSummaryProvider` cache hit: < 50ms on second read      | Cache effectiveness   |
| Drift stat query: < 200ms on typical dataset (1,000 records)     | DB performance        |

---

## 12. Final Output Summary

### Document Created

- `docs/DASHBOARD_UX_NEXT_LEVEL_PLAN.md` — this document

### Current UX Issues Identified

1. Up to 4 stacked banners overwhelming content area
2. Mode switcher (تشغيلي/تحليلي) confusing when feature flag is partially on
3. No dedicated Today's Work surface for field worker daily workflow
4. No compact Sync Health card — users must navigate to full Sync page
5. No Priority Alert system — all alerts treated equal weight
6. Civil Registry and Taxonomy banners shown to field workers who don't understand them
7. "Notifications" button shows a snackbar — not a real notification list
8. RTL-unsafe icons in ActivityItem and "عرض الكل" links
9. Stat values at 28sp — risk of overflow at text scale 1.5
10. Filter chip section label "التصنيفات السريعة" is misleading
11. `DashboardAppBar` is dead code — should be deleted
12. Swipe-to-delete on activity items is unexpected and dangerous

### Proposed Ideal Structure

1. AppBar — persistent, minimal, search + notifications + admin-only popup
2. Operational Status Strip — single compact row, connectivity + last sync + pending count
3. Priority Alert — max 1 banner at a time, dismissible, highest-priority-wins
4. Overview Cards — total / today visits / urgent / pending sync
5. Quick Actions — exactly 6, frozen spec
6. Today's Work — max 3 urgent items + "عرض الكل", empty state positive message
7. Sync Health Card — compact, link to Sync Center
8. Recent Activity — last 3–5 items, "عرض الكل"
9. Admin / Insights — hidden in More menu or Analytics page

### Items to Remove / Hide / Move

- **Remove:** dead `DashboardAppBar` widget, swipe-to-delete on activity feed, lone mode-switcher chip
- **Move to More menu:** analytical mode toggle, export tool
- **Move to Admin:** Civil Registry banner, Taxonomy health banner, Monitoring Dashboard (require admin claim, not just kDebugMode)
- **Move to Reports/Analytics:** Charts, geographic distribution, daily performance
- **Keep + simplify:** Welcome banner, filter chips (rename), OfflineBanner (keep as part of Status Strip)

### Missing Features (Priority Order)

| Priority | Feature                                            |
| -------- | -------------------------------------------------- |
| P0       | Today's Work card                                  |
| P1       | Priority Alerts strip (replaces stacked banners)   |
| P1       | Compact Sync Health card                           |
| P1       | Search improvements (placeholder, recent searches) |
| P1       | Meaningful empty states                            |
| P1       | Microcopy improvements                             |
| P2       | Quick Add speed dial (FAB improvement)             |
| P2       | Role-personalized header                           |
| P3       | "Continue where you left off"                      |
| P3       | Read-only user gating                              |

### Accessibility Improvements

- Replace LTR directional icons in RTL context
- Add semantic labels to all interactive elements
- Clamp stat value font sizes at text scale 1.5
- Audit WCAG AA contrast for key color pairs
- Remove swipe-to-delete as accidental destructive action on main feed
- Add `ExcludeSemantics` to skeleton/decorative elements

### Proposed Phases

| Phase | Name                             | Risk   |
| ----- | -------------------------------- | ------ |
| 1     | UX Audit and Wireframe (current) | Zero   |
| 2     | Visual Cleanup and Microcopy     | Low    |
| 3     | Information Architecture         | Medium |
| 4     | Accessibility Pass               | Low    |
| 5     | Role-Aware Dashboard             | Medium |
| 6     | Analytics / Reports Page         | Medium |

### Confirmation

- ✅ No production code changed in this phase
- ✅ No tests changed in this phase
- ✅ Dashboard baseline (150/150) not touched
- ✅ Quick Actions (6 frozen cards) not touched
- ✅ Security hardening not weakened
- ✅ State Management improvements preserved
- ✅ Sync pipeline improvements preserved
- ✅ Flutter analyzer: 0 errors, 0 warnings (no code changes)

---

## Phase 1 Visual Cleanup Status

**Completed:** 2026-05-28 | **Risk:** Low | **Files changed:** 2

### Changes Applied

| #   | Change                                                                                           | File                    |
| --- | ------------------------------------------------------------------------------------------------ | ----------------------- |
| 1   | Notification snackbar: `'لديك $count مهمة معلقة'` → `'$count سجل بانتظار الرفع'`                 | dashboard_page.dart     |
| 2   | Section title: `'التصنيفات السريعة'` → `'عرض البيانات'`                                          | dashboard_page.dart     |
| 3   | Mode switcher: hidden when `!enableAnalyticalMode`; chips renamed to `'عرض مبسط'`/`'عرض تفصيلي'` | dashboard_page.dart     |
| 4   | `_CivilRegistryBanner`: hides when `isReady=true` (no green "all good" noise)                    | dashboard_page.dart     |
| 5   | "عرض الكل" arrow icon: RTL-safe (2 instances)                                                    | dashboard_page.dart     |
| 6   | `ActivityItem` trailing chevron: RTL-safe                                                        | activities_section.dart |

### Deferred Items

- `DashboardAppBar` dead code removal → Phase 3 (has active test)
- Full Priority Alert engine (replaces banner stacking) → Phase 3
- kDebugMode admin bypass documentation → Phase 3

### Test Results (post-implementation)

- Dashboard suite: **150/150 PASS**
- Security baseline: **101/101 PASS**
- Flutter analyzer: **0 errors, 0 warnings**
