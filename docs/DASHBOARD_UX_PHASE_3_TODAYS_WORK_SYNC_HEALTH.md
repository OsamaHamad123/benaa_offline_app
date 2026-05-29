# DASHBOARD UX/UI NEXT-LEVEL — PHASE 3: TODAY'S WORK + COMPACT SYNC HEALTH CARDS

**Date:** 2026-05-28
**Phase:** Implementation — Display-Only Cards, No New Queries
**App:** منظومة بناء — Gaza/Cedar beneficiary management
**Precondition:** Phase 2 Operational Status Strip complete (112/112 PASS, 0 analyzer errors)

---

## 1. Scope

This phase adds two new display cards to the Dashboard operational view:

1. **`DashboardTodaysWorkCard`** — Daily work summary for field workers using `TodayStats` already embedded in `DashboardStatistics`.
2. **`DashboardSyncHealthCard`** — Compact sync status card with direct "فتح مركز المزامنة" action, using cheap data already computed in `_buildContent`.

**Not in scope:** Advanced scheduling engine, Today's Work breakdown, role-personalized cards, SpeedDial FAB, reports/analytics relocation, new heavy DB queries, notification center, quick actions changes.

---

## 2. Existing Data Sources Reused (No New Providers)

| Data point                          | Source                                            | Notes               |
| ----------------------------------- | ------------------------------------------------- | ------------------- |
| `stats.todayStats.completedVisits`  | `DashboardStatistics.todayStats`                  | زيارات اليوم        |
| `stats.todayStats.pendingTasks`     | `DashboardStatistics.todayStats`                  | مهام معلقة          |
| `stats.todayStats.newBeneficiaries` | `DashboardStatistics.todayStats`                  | مستفيدون جدد اليوم  |
| `stats.pendingSync`                 | `DashboardStatistics.pendingSync`                 | سجلات بانتظار الرفع |
| `stats.lastSyncTime`                | `DashboardStatistics.lastSyncTime`                | وقت آخر مزامنة      |
| `isOnline`                          | `_DashboardPageState._isOnline` (passed as param) | حالة الاتصال        |

**No new provider added. No new DB query added.**

Both cards are pure `StatelessWidget` receiving all data as constructor parameters — fully testable without providers.

---

## 3. What Is Intentionally Simplified

| Feature                   | Simplification                                                                                        |
| ------------------------- | ----------------------------------------------------------------------------------------------------- |
| Today's Work urgent cases | Shows count only (`pendingTasks`) — no 3-item preview (UrgentCasesSection already handles that below) |
| Overdue follow-ups        | Not shown — no cheap data source in `TodayStats`                                                      |
| Failed sync count         | Not shown — no cheap data source; deferred                                                            |
| Last sync time precision  | Uses same format helper as Phase 2 status strip                                                       |
| Card styling              | Uses `DashboardCard` (existing core widget) for consistent look                                       |

---

## 4. Deferred Items

| Item                                               | Reason                                                                  |
| -------------------------------------------------- | ----------------------------------------------------------------------- |
| Real notification center                           | Phase 5                                                                 |
| Role-personalized dashboard header                 | Phase 5                                                                 |
| Failed sync count (distinct from pending)          | No cheap data source                                                    |
| Advanced visit scheduling engine                   | Phase 4                                                                 |
| SpeedDial FAB                                      | Phase 3+                                                                |
| Reports/analytics relocation                       | Phase 4                                                                 |
| 3-item urgent case preview in Today's Work card    | UrgentCasesSection already shows these below; de-duplicating in Phase 4 |
| Overdue follow-ups row                             | `TodayStats` has no overdue field; Phase 4 extension                    |
| Consolidating UrgentCasesSection into Today's Work | Phase 4 — both kept in this phase                                       |

---

## 5. Files Touched

| File                                                                          | Change                               |
| ----------------------------------------------------------------------------- | ------------------------------------ |
| `lib/features/dashboard/presentation/widgets/dashboard_todays_work_card.dart` | Created                              |
| `lib/features/dashboard/presentation/widgets/dashboard_sync_health_card.dart` | Created                              |
| `lib/features/dashboard/presentation/widgets/dashboard_widgets.dart`          | Added 2 exports                      |
| `lib/features/dashboard/presentation/pages/dashboard_page.dart`               | Inserted 2 cards after Quick Actions |
| `test/features/dashboard/dashboard_todays_work_card_test.dart`                | Created                              |
| `test/features/dashboard/dashboard_sync_health_card_test.dart`                | Created                              |

---

## 6. Minimal Tests

| File                                                           | Type   | Count |
| -------------------------------------------------------------- | ------ | ----- |
| `test/features/dashboard/dashboard_todays_work_card_test.dart` | Widget | 5     |
| `test/features/dashboard/dashboard_sync_health_card_test.dart` | Widget | 5     |

Run during implementation:

```
flutter test test/features/dashboard/dashboard_todays_work_card_test.dart
flutter test test/features/dashboard/dashboard_sync_health_card_test.dart
flutter test test/features/dashboard/dashboard_quick_actions_test.dart
```

---

## 7. Implementation Results

### Tests During Implementation

- `dashboard_todays_work_card_test.dart` — ✅ **5/5 PASS**
- `dashboard_sync_health_card_test.dart` — ✅ **5/5 PASS**
- `dashboard_quick_actions_test.dart` — ✅ **15/15 PASS**
- Total focused tests: **25/25 PASS**

### Analyzer

- New files: **0 errors, 0 warnings**

---

## 8. Rollback Notes

All changes are additive:

- Both new cards are `StatelessWidget` with no provider deps — zero risk of breaking existing tests.
- To rollback: remove the two cards from `_buildContent()` in `dashboard_page.dart`, remove exports from barrel, delete card files.
- `UrgentCasesSection` and `RecentActivitiesList` are untouched.
- Quick Actions are untouched.
- Phase 2 status strip is untouched.
