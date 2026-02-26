param(
  [Parameter(Mandatory = $true)]
  [string]$FileId,

  [string]$BaseUrl = 'https://palestine.benaadev.org',

  [string]$Token,

  [string]$DeviceId = 'desktop-roundtrip-probe',

  [switch]$ApplyUpdate,

  [string]$UpdateField = 'data_description_needs'
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

function Write-Step {
  param([string]$Text)
  Write-Host "`n=== $Text ===" -ForegroundColor Cyan
}

function Get-HeaderMap {
  param([string]$Bearer)

  if ([string]::IsNullOrWhiteSpace($Bearer)) {
    return @{ Accept = 'application/json' }
  }

  return @{
    Accept        = 'application/json'
    Authorization = "Bearer $Bearer"
  }
}

function Invoke-Json {
  param(
    [string]$Method,
    [string]$Url,
    [hashtable]$Headers,
    $Body = $null
  )

  if ($null -ne $Body) {
    $json = $Body | ConvertTo-Json -Depth 20
    return Invoke-RestMethod -Method $Method -Uri $Url -Headers $Headers -ContentType 'application/json' -Body $json -TimeoutSec 60
  }

  return Invoke-RestMethod -Method $Method -Uri $Url -Headers $Headers -TimeoutSec 60
}

function Resolve-Token {
  param([string]$FromArg)

  if (-not [string]::IsNullOrWhiteSpace($FromArg)) {
    return $FromArg
  }

  if (-not [string]::IsNullOrWhiteSpace($env:BENAA_TOKEN)) {
    return $env:BENAA_TOKEN
  }

  return $null
}

function Get-RecordShape {
  param($Record)

  if ($null -eq $Record) {
    return [ordered]@{}
  }

  return [ordered]@{
    id                   = $Record.id
    file_id_number       = $Record.file_id_number
    data_first_name      = $Record.data_first_name
    data_father_name     = $Record.data_father_name
    data_family_name     = $Record.data_family_name
    data_id_number       = $Record.data_id_number
    data_phone_number    = $Record.data_phone_number
    data_current_address = $Record.data_current_address
    data_description_needs = $Record.data_description_needs
    updated_at           = $Record.updated_at
  }
}

$tokenValue = Resolve-Token -FromArg $Token
$headers = Get-HeaderMap -Bearer $tokenValue
$base = $BaseUrl.TrimEnd('/')
$detailUrl = "$base/api/mobile/database/data/$FileId"

Write-Step "Fetch baseline record"

try {
  $beforeResponse = Invoke-Json -Method 'GET' -Url $detailUrl -Headers $headers
} catch {
  Write-Host "Request failed at baseline fetch." -ForegroundColor Red
  if ($_.Exception.Response) {
    $status = [int]$_.Exception.Response.StatusCode.value__
    Write-Host "HTTP Status: $status" -ForegroundColor Yellow
    if ($status -eq 401 -or $status -eq 403) {
      Write-Host "Auth token is missing/invalid. Pass -Token or set BENAA_TOKEN." -ForegroundColor Yellow
    }
  }
  throw
}

$beforeRecord = $beforeResponse.data.record
if ($null -eq $beforeRecord) {
  throw "API response did not include data.record for file_id_number=$FileId"
}

$beforeShape = Get-RecordShape -Record $beforeRecord

Write-Host ("Record loaded: id={0}, file_id={1}" -f $beforeRecord.id, $beforeRecord.file_id_number) -ForegroundColor Green

$familyCount = @($beforeRecord.family_members).Count
$attachmentsCount = @($beforeRecord.attachments).Count
$fatherExists = $null -ne $beforeRecord.deceased_parents.father
$motherExists = $null -ne $beforeRecord.deceased_parents.mother

Write-Host ("Related snapshot => family_members={0}, attachments={1}, father={2}, mother={3}" -f $familyCount, $attachmentsCount, $fatherExists, $motherExists)

if (-not $ApplyUpdate.IsPresent) {
  Write-Step "Dry-run complete"
  [PSCustomObject]@{
    mode              = 'dry-run'
    file_id_number    = $beforeRecord.file_id_number
    beneficiary_id    = $beforeRecord.id
    family_members    = $familyCount
    attachments       = $attachmentsCount
    father_present    = $fatherExists
    mother_present    = $motherExists
    checked_fields    = ($beforeShape.Keys -join ',')
    note              = 'Use -ApplyUpdate for reversible round-trip update verification'
  } | Format-List
  return
}

Write-Step "Run reversible update"

$originalValue = $beforeRecord.$UpdateField
if ($null -eq $originalValue) { $originalValue = '' }

$marker = "[roundtrip-probe $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')]"
$newValue = "$originalValue $marker".Trim()

$updatePayload = @{
  file_id_number = $beforeRecord.file_id_number
  device_id = $DeviceId
  $UpdateField = $newValue
}

try {
  $null = Invoke-Json -Method 'PUT' -Url $detailUrl -Headers $headers -Body $updatePayload
  Write-Host "Update sent successfully." -ForegroundColor Green
} catch {
  Write-Host "Update failed. Check validation/payload contract for PUT endpoint." -ForegroundColor Red
  throw
}

Start-Sleep -Seconds 1

Write-Step "Fetch after update"
$afterResponse = Invoke-Json -Method 'GET' -Url $detailUrl -Headers $headers
$afterRecord = $afterResponse.data.record
$afterValue = $afterRecord.$UpdateField

$updatedOk = "$afterValue" -like "*$marker*"
$statusText = if ($updatedOk) { 'OK' } else { 'NOT_CONFIRMED' }
$statusColor = if ($updatedOk) { 'Green' } else { 'Yellow' }
Write-Host ("Field '{0}' round-trip status: {1}" -f $UpdateField, $statusText) -ForegroundColor $statusColor

Write-Step "Rollback"
$rollbackPayload = @{
  file_id_number = $beforeRecord.file_id_number
  device_id = $DeviceId
  $UpdateField = $originalValue
}

try {
  $null = Invoke-Json -Method 'PUT' -Url $detailUrl -Headers $headers -Body $rollbackPayload
  Write-Host "Rollback sent successfully." -ForegroundColor Green
} catch {
  Write-Host "Rollback failed. Please restore manually." -ForegroundColor Red
  throw
}

Start-Sleep -Seconds 1
$finalResponse = Invoke-Json -Method 'GET' -Url $detailUrl -Headers $headers
$finalRecord = $finalResponse.data.record
$rollbackOk = "$($finalRecord.$UpdateField)" -eq "$originalValue"

Write-Step "Round-trip result"
[PSCustomObject]@{
  mode                = 'apply-update'
  file_id_number      = $beforeRecord.file_id_number
  beneficiary_id      = $beforeRecord.id
  updated_field       = $UpdateField
  update_verified     = $updatedOk
  rollback_verified   = $rollbackOk
  family_members      = @($afterRecord.family_members).Count
  attachments         = @($afterRecord.attachments).Count
  father_present      = $null -ne $afterRecord.deceased_parents.father
  mother_present      = $null -ne $afterRecord.deceased_parents.mother
} | Format-List
