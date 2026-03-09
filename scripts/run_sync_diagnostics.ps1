param(
  [switch]$SkipPubGet,
  [switch]$SkipAnalyze,
  [switch]$SkipTests,
  [switch]$ShowAdbOnly
)

$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $PSScriptRoot)

Write-Host '=== BENAA Sync Diagnostics Runner ===' -ForegroundColor Cyan

if (-not $ShowAdbOnly) {
  if (-not $SkipPubGet) {
    Write-Host '-> Running flutter pub get' -ForegroundColor Yellow
    flutter pub get
  }

  if (-not $SkipAnalyze) {
    Write-Host '-> Running focused analyze for sync modules' -ForegroundColor Yellow
    dart analyze lib/core/sync lib/features/sync lib/features/attachments lib/data/db
  }

  if (-not $SkipTests) {
    Write-Host '-> Running focused sync tests (if present)' -ForegroundColor Yellow
    flutter test test/features/sync test/features/auth/presentation/state/auth_notifier_post_login_sync_test.dart
  }
}

Write-Host ''
Write-Host '=== Runtime Upload Verification (Android) ===' -ForegroundColor Cyan
Write-Host '1) Clear old logs:' -ForegroundColor Green
Write-Host '   adb logcat -c'
Write-Host '2) Start live filter:' -ForegroundColor Green
Write-Host '   adb logcat | Select-String -Pattern "SyncRelatedEntitiesUpUseCase|database is locked|sync-state distribution|Error uploading attachment|status="'
Write-Host '3) In app: run Sync Down then Sync Up once only.' -ForegroundColor Green
Write-Host '4) Expected success indicators:' -ForegroundColor Green
Write-Host '   - No repeated "database is locked"'
Write-Host '   - Attachment logs show pending>0 then uploaded/synced OR clear reason for skip'

Write-Host ''
Write-Host 'Done.' -ForegroundColor Cyan
