# Git Helper Scripts for Benaa App
# استخدم هذه السكريبتات لتسهيل العمليات اليومية

# ====================
# بدء ميزة جديدة
# ====================
function Start-NewFeature {
    param(
        [Parameter(Mandatory=$true)]
        [string]$FeatureName
    )
    
    Write-Host "🚀 Starting new feature: $FeatureName" -ForegroundColor Green
    
    # تحديث develop
    git checkout develop
    git pull origin develop
    
    # إنشاء branch جديد
    $branchName = "feature/$FeatureName"
    git checkout -b $branchName
    
    Write-Host "✅ Created branch: $branchName" -ForegroundColor Green
    Write-Host "📝 You can now start working on your feature!" -ForegroundColor Cyan
}

# ====================
# تحديث branch من develop
# ====================
function Update-FromDevelop {
    Write-Host "🔄 Updating current branch from develop..." -ForegroundColor Yellow
    
    $currentBranch = git rev-parse --abbrev-ref HEAD
    
    # حفظ التغييرات الحالية
    git add .
    git stash
    
    # جلب develop
    git checkout develop
    git pull origin develop
    
    # العودة والدمج
    git checkout $currentBranch
    git merge develop
    
    # استرجاع التغييرات
    git stash pop
    
    Write-Host "✅ Updated from develop!" -ForegroundColor Green
}

# ====================
# فحص الكود قبل الـ commit
# ====================
function Test-BeforeCommit {
    Write-Host "🧪 Running checks before commit..." -ForegroundColor Yellow
    
    # Format check
    Write-Host "`n📋 Checking formatting..." -ForegroundColor Cyan
    dart format .
    
    # Analyze
    Write-Host "`n🔍 Analyzing code..." -ForegroundColor Cyan
    flutter analyze
    
    # Tests
    Write-Host "`n🧪 Running tests..." -ForegroundColor Cyan
    flutter test
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ All checks passed! Ready to commit." -ForegroundColor Green
    } else {
        Write-Host "`n❌ Some checks failed. Please fix before committing." -ForegroundColor Red
    }
}

# ====================
# Commit سريع
# ====================
function Quick-Commit {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    
    git add .
    git commit -m $Message
    
    $currentBranch = git rev-parse --abbrev-ref HEAD
    git push origin $currentBranch
    
    Write-Host "✅ Committed and pushed!" -ForegroundColor Green
}

# ====================
# بناء APK للاختبار
# ====================
function Build-TestAPK {
    Write-Host "🔨 Building test APK..." -ForegroundColor Yellow
    
    Set-Location android
    bundle exec fastlane build_debug
    Set-Location ..
    
    Write-Host "✅ APK built successfully!" -ForegroundColor Green
}

# ====================
# تنظيف الـ branches القديمة
# ====================
function Clean-MergedBranches {
    Write-Host "🧹 Cleaning merged branches..." -ForegroundColor Yellow
    
    git checkout develop
    git pull origin develop
    
    # حذف الـ branches المدمجة محلياً
    git branch --merged | Where-Object { $_ -notmatch "^\*|main|develop" } | ForEach-Object {
        $branch = $_.Trim()
        Write-Host "Deleting: $branch" -ForegroundColor Gray
        git branch -d $branch
    }
    
    # تنظيف الـ remote tracking branches
    git remote prune origin
    
    Write-Host "✅ Cleanup complete!" -ForegroundColor Green
}

# ====================
# عرض حالة جميع الـ branches
# ====================
function Show-BranchStatus {
    Write-Host "`n📊 Branch Status:" -ForegroundColor Cyan
    Write-Host "=================" -ForegroundColor Cyan
    
    Write-Host "`nLocal branches:" -ForegroundColor Yellow
    git branch -v
    
    Write-Host "`nRemote branches:" -ForegroundColor Yellow
    git branch -r
    
    Write-Host "`nCurrent status:" -ForegroundColor Yellow
    git status
}

# ====================
# فحص الـ conflicts المحتملة
# ====================
function Check-Conflicts {
    param(
        [string]$TargetBranch = "develop"
    )
    
    Write-Host "🔍 Checking for potential conflicts with $TargetBranch..." -ForegroundColor Yellow
    
    $currentBranch = git rev-parse --abbrev-ref HEAD
    
    # Fetch latest
    git fetch origin $TargetBranch
    
    # Check if merge would cause conflicts
    $mergeBase = git merge-base HEAD origin/$TargetBranch
    $conflicts = git diff --name-only $mergeBase..origin/$TargetBranch | Where-Object {
        $file = $_
        $localChanges = git diff --name-only $mergeBase..HEAD | Where-Object { $_ -eq $file }
        return $localChanges
    }
    
    if ($conflicts) {
        Write-Host "`n⚠️  Potential conflicts in these files:" -ForegroundColor Red
        $conflicts | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    } else {
        Write-Host "`n✅ No conflicts detected!" -ForegroundColor Green
    }
}

# ====================
# عرض الأوامر المتاحة
# ====================
function Show-GitHelp {
    Write-Host "`n" -NoNewline
    Write-Host "🔧 Git Helper Commands" -ForegroundColor Cyan
    Write-Host "======================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Start-NewFeature <name>" -ForegroundColor Green -NoNewline
    Write-Host "     - بدء ميزة جديدة"
    Write-Host "Update-FromDevelop" -ForegroundColor Green -NoNewline
    Write-Host "           - تحديث من develop"
    Write-Host "Test-BeforeCommit" -ForegroundColor Green -NoNewline
    Write-Host "            - فحص الكود"
    Write-Host "Quick-Commit <message>" -ForegroundColor Green -NoNewline
    Write-Host "        - commit سريع"
    Write-Host "Build-TestAPK" -ForegroundColor Green -NoNewline
    Write-Host "                 - بناء APK"
    Write-Host "Clean-MergedBranches" -ForegroundColor Green -NoNewline
    Write-Host "          - تنظيف branches"
    Write-Host "Show-BranchStatus" -ForegroundColor Green -NoNewline
    Write-Host "             - عرض الحالة"
    Write-Host "Check-Conflicts [branch]" -ForegroundColor Green -NoNewline
    Write-Host "      - فحص conflicts"
    Write-Host ""
    Write-Host "Example:" -ForegroundColor Yellow
    Write-Host "  Start-NewFeature 'add-login-screen'" -ForegroundColor Gray
    Write-Host "  Test-BeforeCommit" -ForegroundColor Gray
    Write-Host "  Quick-Commit 'Add login screen UI'" -ForegroundColor Gray
    Write-Host ""
}

# عرض المساعدة عند التحميل
Write-Host "`n✅ Git Helper Scripts loaded!" -ForegroundColor Green
Write-Host "Run " -NoNewline
Write-Host "Show-GitHelp" -ForegroundColor Yellow -NoNewline
Write-Host " to see available commands`n"

# Aliases للأوامر الشائعة
Set-Alias -Name new-feature -Value Start-NewFeature
Set-Alias -Name update-branch -Value Update-FromDevelop
Set-Alias -Name check-code -Value Test-BeforeCommit
Set-Alias -Name qcommit -Value Quick-Commit
