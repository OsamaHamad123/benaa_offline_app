param(
  [string]$BaseUrl = 'https://disabled-api.example.com',
  [string]$Email = 'admin@gmail.com',
  [securestring]$Password,
  [string]$DeviceId = 'copilot-smoke-device',
  [int]$RequestCount = 1
)

$ErrorActionPreference = 'Stop'

function Write-Step {
  param([string]$Name, [int]$Status, [string]$Note = '')
  if ([string]::IsNullOrWhiteSpace($Note)) {
    Write-Output ("$Name => $Status")
  } else {
    Write-Output ("$Name => $Status | $Note")
  }
}

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
  } finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
  }
}

$failed = $false

try {
  if ($null -eq $Password) {
    $Password = ConvertTo-SecureString 'password' -AsPlainText -Force
  }

  $plainPassword = ConvertTo-PlainText -Secret $Password

  $loginPayload = @{
    email = $Email
    password = $plainPassword
    device_id = $DeviceId
    device_name = 'Copilot Smoke Contract'
    device_platform = 'android'
  } | ConvertTo-Json

  $login = Invoke-RestMethod -Uri "$BaseUrl/api/mobile/auth/login" -Method Post -ContentType 'application/json' -Body $loginPayload
  $token = $login.data.token.access_token
  if ([string]::IsNullOrWhiteSpace($token)) {
    throw 'Login token is empty'
  }

  Write-Step -Name 'LOGIN' -Status 200

  $headers = @{
    Authorization = "Bearer $token"
    Accept = 'application/json'
    'Content-Type' = 'application/json'
  }

  $statsResp = Invoke-WebRequest -Uri "$BaseUrl/api/mobile/codes/device-stats?device_id=$DeviceId" -Method Get -Headers $headers -UseBasicParsing
  if ($statsResp.StatusCode -ne 200) { $failed = $true }
  Write-Step -Name 'DEVICE-STATS' -Status $statsResp.StatusCode

  $loginSyncBody = @{
    device_id = $DeviceId
    device_codes = @()
  } | ConvertTo-Json -Depth 10

  $loginSyncResp = Invoke-WebRequest -Uri "$BaseUrl/api/mobile/codes/login-sync" -Method Post -Headers $headers -Body $loginSyncBody -UseBasicParsing
  if ($loginSyncResp.StatusCode -ne 200) { $failed = $true }
  Write-Step -Name 'LOGIN-SYNC' -Status $loginSyncResp.StatusCode

  $confirmBody = @{
    device_id = $DeviceId
    codes = @(
      @{
        code = '999999'
        used_at = (Get-Date).ToUniversalTime().ToString('o')
        record_type = 'data'
        record_id = 1
      }
    )
  } | ConvertTo-Json -Depth 10

  $confirmResp = Invoke-WebRequest -Uri "$BaseUrl/api/mobile/codes/confirm-usage" -Method Post -Headers $headers -Body $confirmBody -UseBasicParsing
  if ($confirmResp.StatusCode -ne 200) { $failed = $true }
  Write-Step -Name 'CONFIRM-USAGE' -Status $confirmResp.StatusCode

  $requestBody = @{
    device_id = $DeviceId
    count = $RequestCount
  } | ConvertTo-Json

  try {
    $requestResp = Invoke-WebRequest -Uri "$BaseUrl/api/mobile/codes/request-codes" -Method Post -Headers $headers -Body $requestBody -UseBasicParsing
    $requestStatus = $requestResp.StatusCode
    if ($requestStatus -ne 200 -and $requestStatus -ne 201) {
      $failed = $true
    }
    Write-Step -Name 'REQUEST-CODES' -Status $requestStatus
  } catch {
    $ex = $_.Exception
    $status = if ($null -ne $ex.Response) { [int]$ex.Response.StatusCode } else { 0 }
    $body = Read-ErrorBody -Exception $ex
    $allowed = $status -eq 400 -or $status -eq 404
    if (-not $allowed) {
      $failed = $true
    }

    $errorCode = ''
    if (-not [string]::IsNullOrWhiteSpace($body)) {
      try {
        $json = $body | ConvertFrom-Json
        $errorCode = $json.error
      } catch {
      }
    }

    Write-Step -Name 'REQUEST-CODES' -Status $status -Note "error=$errorCode"
  }

  if ($failed) {
    Write-Output 'SMOKE RESULT => FAIL'
    exit 1
  }

  Write-Output 'SMOKE RESULT => PASS'
  exit 0
} catch {
  Write-Output ("SMOKE RESULT => FAIL | " + $_.Exception.Message)
  exit 1
}
