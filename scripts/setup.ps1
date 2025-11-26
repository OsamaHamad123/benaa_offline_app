# Quick Setup Script for Benaa App Testing System

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Benaa App - Testing System Setup" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

# Check Ruby installation
Write-Host "1️⃣  Checking Ruby installation..." -ForegroundColor Yellow
$rubyInstalled = Get-Command ruby -ErrorAction SilentlyContinue

if ($rubyInstalled) {
    $rubyVersion = ruby --version
    Write-Host "   ✅ Ruby is installed: $rubyVersion" -ForegroundColor Green
} else {
    Write-Host "   ❌ Ruby is NOT installed" -ForegroundColor Red
    Write-Host "   📥 Please download from: https://rubyinstaller.org/" -ForegroundColor Yellow
    Write-Host "   📝 Choose: Ruby+Devkit 3.2.x (x64)`n" -ForegroundColor Yellow
    exit
}

# Check Bundler
Write-Host "`n2️⃣  Checking Bundler..." -ForegroundColor Yellow
$bundlerInstalled = Get-Command bundle -ErrorAction SilentlyContinue

if (-not $bundlerInstalled) {
    Write-Host "   📦 Installing Bundler..." -ForegroundColor Cyan
    gem install bundler
}

$bundlerVersion = bundle --version
Write-Host "   ✅ Bundler: $bundlerVersion" -ForegroundColor Green

# Install Fastlane
Write-Host "`n3️⃣  Installing Fastlane dependencies..." -ForegroundColor Yellow
Set-Location android

if (Test-Path "Gemfile") {
    bundle install
    Write-Host "   ✅ Fastlane installed successfully!" -ForegroundColor Green
} else {
    Write-Host "   ❌ Gemfile not found!" -ForegroundColor Red
}

Set-Location ..

# Check Flutter
Write-Host "`n4️⃣  Checking Flutter..." -ForegroundColor Yellow
$flutterInstalled = Get-Command flutter -ErrorAction SilentlyContinue

if ($flutterInstalled) {
    $flutterVersion = flutter --version | Select-String "Flutter" | Select-Object -First 1
    Write-Host "   ✅ $flutterVersion" -ForegroundColor Green
} else {
    Write-Host "   ❌ Flutter is NOT installed" -ForegroundColor Red
}

# Test Fastlane
Write-Host "`n5️⃣  Testing Fastlane..." -ForegroundColor Yellow
Set-Location android
$fastlaneTest = bundle exec fastlane --version 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Fastlane is working!" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Fastlane test failed" -ForegroundColor Yellow
}

Set-Location ..

# Summary
Write-Host "`n================================" -ForegroundColor Cyan
Write-Host "Setup Summary" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

Write-Host "`n✅ Setup complete!" -ForegroundColor Green
Write-Host "`n📚 Next Steps:" -ForegroundColor Yellow
Write-Host "   1. Read GIT_WORKFLOW_GUIDE.md" -ForegroundColor White
Write-Host "   2. Read TESTING_SETUP_GUIDE.md" -ForegroundColor White
Write-Host "   3. Setup GitHub Branch Protection Rules" -ForegroundColor White
Write-Host "   4. Load Git helpers: . .\scripts\git-helpers.ps1" -ForegroundColor White
Write-Host "`n🚀 Available Fastlane commands:" -ForegroundColor Yellow
Write-Host "   cd android" -ForegroundColor Gray
Write-Host "   bundle exec fastlane test" -ForegroundColor Gray
Write-Host "   bundle exec fastlane build_debug" -ForegroundColor Gray
Write-Host "   bundle exec fastlane beta" -ForegroundColor Gray
Write-Host ""
