# DASHBOARD UX/UI NEXT-LEVEL — PHASE 4: CONSOLIDATION & UX POLISH

**Date:** 2026-05-28
**Phase:** Consolidation — Low-risk polish only, no new logic
**App:** منظومة بناء — Gaza/Cedar beneficiary management
**Precondition:** Phase 3 complete (25/25 focused tests, 0 analyzer issues)

---

## 1. Scope

Minor UX polish after Phase 3 introduced Today's Work + Sync Health cards:

1. **Heading rename**: Section "حالات تحتاج متابعة" → "تفاصيل المتابعة" to distinguish summary (Today's Work) from detail (UrgentCasesSection).
2. **Spacing consolidation**: Remove redundant `SizedBox(height: 8.h)` + `SizedBox(height: 24.h)` double-spacing after Sync Health card.
3. **Empty-state copy polish**: More human Arabic copy in `RecentActivitiesList` and `UrgentCasesSection`.
4. **Deprecated API fix**: `.withOpacity()` → `.withValues(alpha:)` in `activities_section.dart`.

---

## 2. Duplication After Phase 3

| Section              | Shows                                                   |
| -------------------- | ------------------------------------------------------- |
| Today's Work card    | `pendingTasks` count (summary from `TodayStats`)        |
| `UrgentCasesSection` | Real DB counts: no-visit 30d, poor health, disabilities |

**Assessment:** Not truly duplicate — different data sources, different granularity. Today's Work is a summary; UrgentCasesSection is actionable detail. Keep both. Only rename section heading to clarify relationship.

---

## 3. Selected Low-Risk Changes

| Change                           | File                                                   | Risk                                  |
| -------------------------------- | ------------------------------------------------------ | ------------------------------------- |
| Rename SectionTitle × 2          | `dashboard_page.dart`                                  | None — no test depends on this string |
| Remove extra `SizedBox(8.h)`     | `dashboard_page.dart`                                  | None — visual only                    |
| Update empty-state copy          | `activities_section.dart`, `urgent_cases_section.dart` | None — text only                      |
| Fix `.withOpacity()` deprecation | `activities_section.dart`                              | None — same visual result             |

---

## 4. Deferred Items

| Item                                               | Reason                            |
| -------------------------------------------------- | --------------------------------- |
| 3-item urgent case preview in Today's Work         | Needs new query; deferred Phase 5 |
| `overdue` field in `TodayStats`                    | Not in entity; Phase 5            |
| Role-personalized dashboard                        | Phase 5                           |
| Full accessibility audit                           | Phase 5                           |
| Reports/analytics relocation                       | Phase 5                           |
| Real notification center                           | Phase 5                           |
| Consolidating UrgentCasesSection into Today's Work | Phase 5 — different data sources  |

---

## 5. Tests to Run

```
flutter test test/features/dashboard/dashboard_todays_work_card_test.dart
flutter test test/features/dashboard/dashboard_sync_health_card_test.dart
flutter test test/features/dashboard/dashboard_quick_actions_test.dart
flutter analyze --no-fatal-infos
```

---

## 6. Implementation Results

### Changes Made

| File                        | Change                                                           |
| --------------------------- | ---------------------------------------------------------------- |
| `dashboard_page.dart`       | Renamed 2× SectionTitle "حالات تحتاج متابعة" → "تفاصيل المتابعة" |
| `dashboard_page.dart`       | Removed redundant SizedBox(8.h) before SizedBox(24.h)            |
| `activities_section.dart`   | Polished empty-state copy + fixed `.withOpacity()`               |
| `urgent_cases_section.dart` | Polished empty-state copy                                        |

### Tests Run

- `dashboard_todays_work_card_test.dart` — ✅ **5/5 PASS**
- `dashboard_sync_health_card_test.dart` — ✅ **5/5 PASS**
- `dashboard_quick_actions_test.dart` — ✅ **15/15 PASS**

### Analyzer

- Changed files: **No issues found**

---

## 7. Rollback Notes

All changes are text/visual only:

- SectionTitle rename: revert the 2 strings.
- Spacing: revert the removed SizedBox.
- Empty state: revert text.
- `.withValues(alpha:)`: identical visual result to `.withOpacity()`.
