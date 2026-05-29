# Dashboard/Home — Production QA Checklist

**Version:** 1.0  
**Frozen Date:** 2026-05-28  
**Phase:** Production QA Freeze (after Phase 1 + Phase 2 audit)  
**App:** منظومة بناء — Gaza/Cedar beneficiary management

---

## How to use this checklist

Run through all items on a real device or emulator **before** any release that touches Dashboard, AppBar, QuickActions, or Riverpod providers. Check each item manually. Document the tester name, device, and date.

| Tester | Device | OS  | Date |
| ------ | ------ | --- | ---- |
|        |        |     |      |

---

## 1. Normal User Dashboard

### 1.1 Startup and Layout

- [ ] Dashboard opens without freezing or ANR
- [ ] Dashboard first paint completes within 2 seconds on mid-range device
- [ ] AppBar spacing is correct — no overflow, no clipping
- [ ] AppBar shows Search icon, Notifications icon, and More (⋮) menu only
- [ ] More menu contains only appropriate options for normal users
- [ ] No seed/debug/test/admin tools are visible anywhere on Dashboard
- [ ] Dashboard does not start a full sync on open
- [ ] Dashboard does not run taxonomy seed on open
- [ ] Dashboard does not run associations seed on open

### 1.2 Quick Actions (CRITICAL — do not change spec)

The Quick Actions grid must show **exactly these 6 cards**, in order, always:

- [ ] إضافة مستفيد ✓
- [ ] المستفيدون ✓
- [ ] زيارات اليوم ✓
- [ ] الكفالات ✓
- [ ] الجمعيات ✓
- [ ] المزامنة ✓

Verify:

- [ ] All 6 cards render without overflow
- [ ] All 6 cards are tappable and navigate to the correct destination
- [ ] No 7th card appears
- [ ] No seed/sync-diagnostic/debug card appears
- [ ] "زيارات اليوم" label is correct (not "زيارات الميدانية" or any old label)

### 1.3 Statistics and Previews

- [ ] Dashboard statistics section loads within 3 seconds
- [ ] Statistics show real counts (not zeros unless DB is empty)
- [ ] Recent activity preview shows max 3–5 items only
- [ ] Beneficiary previews load max 3–5 items only
- [ ] No full collection is loaded on Dashboard open (check logs)

### 1.4 Filter Chips

- [ ] Filter chips row shows: الكل، اليوم، هذا الأسبوع، تحتاج متابعة
- [ ] Selecting a filter updates the displayed data
- [ ] Filters do not crash or freeze

---

## 2. Admin / Privileged User

### 2.1 Admin Tools Visibility

- [ ] Admin tools appear **only** when user has admin role (Firebase claim `admin: true`)
- [ ] Export/diagnostics/maintenance actions are not visible to normal field workers
- [ ] Admin-only menu items in the More (⋮) menu appear only for admins
- [ ] Dangerous/destructive actions (delete, clear cache, seed, reset) require confirmation dialog before executing

### 2.2 Role Isolation

- [ ] Log out admin user, log in as field worker — admin tools must disappear immediately
- [ ] Provider `isAdminProvider` returns false for non-admin users
- [ ] Role is resolved from Firebase Auth custom claims only — no local overrides

---

## 3. RTL and Arabic Layout

- [ ] All text is displayed right-to-left
- [ ] Quick Actions grid aligns correctly in RTL
- [ ] No text overflow on any card label
- [ ] Arabic labels are fully readable (not truncated)
- [ ] At 150% text scale (accessibility), cards do not overflow or clip labels
- [ ] At 200% text scale, app does not crash (some overflow is acceptable but no crash)
- [ ] Filter chip labels do not overflow in RTL
- [ ] AppBar title/icons align correctly in RTL

---

## 4. Performance

- [ ] Dashboard opens in < 2 seconds on first launch after app restart
- [ ] Dashboard opens in < 1 second on subsequent navigations (warm start)
- [ ] No full sync is triggered on Dashboard open (check DevTools or logs)
- [ ] No taxonomy seed is triggered on Dashboard open
- [ ] No associations seed is triggered on Dashboard open
- [ ] Dashboard preview sections load max 3–5 items (check `getRecentActivities` limit)
- [ ] No `StateError: Bad state: Stream has already been listened to` in logs
- [ ] No Riverpod `ProviderException` in logs during normal navigation
- [ ] Memory does not spike significantly when navigating to/from Dashboard repeatedly

---

## 5. Sync Visibility

- [ ] Pending uploads count badge appears when there are unsynced records
- [ ] Pending uploads count disappears after successful sync
- [ ] Tapping المزامنة Quick Action navigates to Sync page
- [ ] Sync page opens without Firebase errors in offline mode
- [ ] After a successful sync completes, Dashboard metrics update (or pull-to-refresh shows updated data)

> **Known gap (intentionally deferred):** Automatic post-sync Dashboard invalidation is not yet wired. The sync page does not automatically trigger `dashboardProvider.refresh()` after sync completes. This is documented and tracked separately.

---

## 6. Security and Privacy

- [ ] Open logs during normal usage and verify:
  - [ ] National IDs are masked (e.g., `123****789` not full ID)
  - [ ] Phone numbers are masked (e.g., `05***1234` not full number)
  - [ ] Full beneficiary names are not logged in production builds
  - [ ] Firebase tokens are not logged anywhere
  - [ ] No secret keys or passwords appear in logs
- [ ] LogSanitizer is active — verify `[Security] sensitive log masking enabled` appears at startup
- [ ] In release/profile build: `debugPrint` calls are suppressed (they compile to no-ops in release)
- [ ] No `print()` calls in production code (run `flutter analyze` to confirm)

---

## 7. Pagination

- [ ] Beneficiaries list loads first page only on open (pageSize = 20 records)
- [ ] Scrolling to 80% of list triggers prefetch of next page
- [ ] Scrolling to bottom loads next page and appends without duplicates
- [ ] Total record count does not jump or reset when loading more pages
- [ ] Entering a search term resets pagination to page 1
- [ ] Applying a filter resets pagination to page 1
- [ ] "No more items" indicator appears after last page is loaded
- [ ] Rapid scroll does not cause duplicate network/DB requests

---

## Sign-off

| Category                 | Status            | Notes |
| ------------------------ | ----------------- | ----- |
| 1. Normal User Dashboard | ⬜ Pass / ⬜ Fail |       |
| 2. Admin Visibility      | ⬜ Pass / ⬜ Fail |       |
| 3. RTL Layout            | ⬜ Pass / ⬜ Fail |       |
| 4. Performance           | ⬜ Pass / ⬜ Fail |       |
| 5. Sync Visibility       | ⬜ Pass / ⬜ Fail |       |
| 6. Security/Privacy      | ⬜ Pass / ⬜ Fail |       |
| 7. Pagination            | ⬜ Pass / ⬜ Fail |       |

**Overall result:** ⬜ PASS — ready for release / ⬜ FAIL — see notes above

**Signed off by:** ******\_\_\_****** **Date:** ******\_\_\_******
