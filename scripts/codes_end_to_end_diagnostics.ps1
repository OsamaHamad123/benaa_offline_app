param(
    [string]$BaseUrl = 'https://disabled-api.example.com',
    [string]$Email = 'admin@gmail.com',
    [securestring]$Password,
    [string]$DeviceId = 'copilot-e2e-device',
    [int]$RequestCount = 5000,
    [switch]$CreateBatchIfMissing,
    [int]$BatchSize = 5000
)

$ErrorActionPreference = 'Stop'

function Read-ErrorBody {
    param($Exception)
    if ($null -eq $Exception.Response) { return $null }
    $stream = $Exception.Response.GetResponseStream()
    if ($null -eq $stream) { return $null }
    $reader = New-Object System.IO.StreamReader($stream)
    return $reader.ReadToEnd()
}

function ConvertTo-PlainText {
    param([securestring]$Secret)

    if ($null -eq $Secret) {
        return ''
    }

    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Secret)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
    }
    finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    }
}

function Invoke-ApiCall {
    param(
        [string]$Name,
        [string]$Method,
        [string]$Url,
        $Headers,
        $Body = $null
    )

    try {
        if ($null -ne $Body) {
            $resp = Invoke-WebRequest -Uri $Url -Method $Method -Headers $Headers -Body $Body -UseBasicParsing
        }
        else {
            $resp = Invoke-WebRequest -Uri $Url -Method $Method -Headers $Headers -UseBasicParsing
        }

        $json = $null
        try { $json = $resp.Content | ConvertFrom-Json } catch {}

        return [PSCustomObject]@{
            Name       = $Name
            StatusCode = [int]$resp.StatusCode
            Json       = $json
            Raw        = $resp.Content
        }
    }
    catch {
        $status = 0
        if ($null -ne $_.Exception.Response) {
            $status = [int]$_.Exception.Response.StatusCode
        }

        $body = Read-ErrorBody -Exception $_.Exception
        $json = $null
        try { $json = $body | ConvertFrom-Json } catch {}

        return [PSCustomObject]@{
            Name       = $Name
            StatusCode = $status
            Json       = $json
            Raw        = $body
        }
    }
}

Write-Host '=== CODES E2E DIAGNOSTICS ===' -ForegroundColor Cyan
Write-Host "BaseUrl=$BaseUrl" -ForegroundColor DarkGray
Write-Host "DeviceId=$DeviceId" -ForegroundColor DarkGray

if ($null -eq $Password) {
    $Password = ConvertTo-SecureString 'password' -AsPlainText -Force
}

$plainPassword = ConvertTo-PlainText -Secret $Password

$loginBody = @{
    email           = $Email
    password        = $plainPassword
    device_id       = $DeviceId
    device_name     = 'Codes E2E Diagnostics'
    device_platform = 'android'
} | ConvertTo-Json

$login = Invoke-RestMethod -Uri "$BaseUrl/api/mobile/auth/login" -Method Post -ContentType 'application/json' -Body $loginBody
$token = $login.data.token.access_token
if ([string]::IsNullOrWhiteSpace($token)) {
    throw 'Login failed: no token returned'
}

$headers = @{
    Authorization  = "Bearer $token"
    Accept         = 'application/json'
    'Content-Type' = 'application/json'
}

$results = @()
$results += Invoke-ApiCall -Name 'BATCH_ACTIVE' -Method 'GET' -Url "$BaseUrl/api/mobile/codes/batch/active" -Headers $headers
$results += Invoke-ApiCall -Name 'CODES_STATS' -Method 'GET' -Url "$BaseUrl/api/mobile/codes/stats" -Headers $headers
$results += Invoke-ApiCall -Name 'DEVICE_STATS' -Method 'GET' -Url "$BaseUrl/api/mobile/codes/device-stats?device_id=$DeviceId" -Headers $headers

$loginSyncBody = @{ device_id = $DeviceId; device_codes = @() } | ConvertTo-Json -Depth 10
$results += Invoke-ApiCall -Name 'LOGIN_SYNC' -Method 'POST' -Url "$BaseUrl/api/mobile/codes/login-sync" -Headers $headers -Body $loginSyncBody

$requestBody = @{ device_id = $DeviceId; count = $RequestCount } | ConvertTo-Json
$request = Invoke-ApiCall -Name 'REQUEST_CODES' -Method 'POST' -Url "$BaseUrl/api/mobile/codes/request-codes" -Headers $headers -Body $requestBody
$results += $request

$activeBatch = $results | Where-Object { $_.Name -eq 'BATCH_ACTIVE' } | Select-Object -First 1
$needBatch = $false
if ($activeBatch.StatusCode -eq 404) { $needBatch = $true }
if ($request.StatusCode -eq 404 -and $request.Json -and $request.Json.error -eq 'no_codes_available') { $needBatch = $true }

if ($needBatch -and $CreateBatchIfMissing) {
    Write-Host 'No active/available codes detected. Creating new batch...' -ForegroundColor Yellow
    $createBody = @{ batch_size = $BatchSize } | ConvertTo-Json
    $create = Invoke-ApiCall -Name 'CREATE_BATCH' -Method 'POST' -Url "$BaseUrl/api/mobile/codes/batch/create" -Headers $headers -Body $createBody
    $results += $create

    $results += Invoke-ApiCall -Name 'BATCH_ACTIVE_AFTER_CREATE' -Method 'GET' -Url "$BaseUrl/api/mobile/codes/batch/active" -Headers $headers
    $results += Invoke-ApiCall -Name 'REQUEST_CODES_AFTER_CREATE' -Method 'POST' -Url "$BaseUrl/api/mobile/codes/request-codes" -Headers $headers -Body $requestBody
    $results += Invoke-ApiCall -Name 'DEVICE_STATS_AFTER_CREATE' -Method 'GET' -Url "$BaseUrl/api/mobile/codes/device-stats?device_id=$DeviceId" -Headers $headers
}

Write-Host ''
Write-Host '=== SUMMARY ===' -ForegroundColor Cyan
foreach ($item in $results) {
    $errorCode = $null
    if ($item.Json -and $item.Json.PSObject.Properties.Name -contains 'error') {
        $errorCode = $item.Json.error
    }

    if ([string]::IsNullOrWhiteSpace($errorCode)) {
        Write-Host ("{0} => {1}" -f $item.Name, $item.StatusCode)
    }
    else {
        Write-Host ("{0} => {1} | error={2}" -f $item.Name, $item.StatusCode, $errorCode)
    }
}

Write-Host ''
$codesStats = $results | Where-Object { $_.Name -eq 'CODES_STATS' } | Select-Object -First 1
if ($codesStats.Json -and $codesStats.Json.data -and $codesStats.Json.data.codes) {
    $c = $codesStats.Json.data.codes
    Write-Host ("Server Codes: total={0}, available={1}, used={2}" -f $c.total, $c.available, $c.used) -ForegroundColor DarkCyan
}

$deviceStats = $results | Where-Object { $_.Name -like 'DEVICE_STATS*' } | Select-Object -Last 1
if ($deviceStats.Json -and $deviceStats.Json.data) {
    $d = $deviceStats.Json.data
    Write-Host ("Device Stats: assigned={0}, unused={1}, can_request_more={2}, slots={3}" -f $d.total_assigned, $d.unused_count, $d.can_request_more, $d.available_slots) -ForegroundColor DarkCyan
}

$report = [PSCustomObject]@{
    generated_at            = (Get-Date).ToUniversalTime().ToString('o')
    base_url                = $BaseUrl
    device_id               = $DeviceId
    create_batch_if_missing = [bool]$CreateBatchIfMissing
    request_count           = $RequestCount
    results                 = $results
}

$reportPath = Join-Path $PSScriptRoot ("codes_e2e_report_{0}.json" -f ([DateTimeOffset]::UtcNow.ToUnixTimeSeconds()))
$report | ConvertTo-Json -Depth 12 | Out-File -FilePath $reportPath -Encoding utf8
Write-Host ("Report saved: {0}" -f $reportPath) -ForegroundColor Green
