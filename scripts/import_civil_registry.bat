@echo off
REM ===================================================================
REM سكريبت لتحويل persons.sql إلى civil_registry.db
REM ===================================================================

echo.
echo ========================================
echo تحويل persons.sql الى قاعدة بيانات
echo ========================================
echo.

REM التحقق من وجود sqlite3
where sqlite3 >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ sqlite3 غير مثبت!
    echo.
    echo الرجاء تحميله من: https://www.sqlite.org/download.html
    echo او تثبيته عبر: winget install SQLite.SQLite
    echo.
    pause
    exit /b 1
)

echo ✅ sqlite3 موجود
echo.

REM الحصول على مسار persons.sql
set SQL_FILE=%1
if "%SQL_FILE%"=="" set SQL_FILE=F:\new and clean\persons.sql

if not exist "%SQL_FILE%" (
    echo ❌ الملف غير موجود: %SQL_FILE%
    echo.
    echo الاستخدام: import_civil_registry.bat "المسار_الكامل_للملف.sql"
    echo مثال: import_civil_registry.bat "F:\new and clean\persons.sql"
    echo.
    pause
    exit /b 1
)

REM الحصول على مجلد الملف
for %%F in ("%SQL_FILE%") do set SQL_DIR=%%~dpF
for %%F in ("%SQL_FILE%") do set SQL_NAME=%%~nF

REM مسار قاعدة البيانات الناتجة
set DB_FILE=%SQL_DIR%civil_registry.db

echo 📂 الملف: %SQL_FILE%
echo 💾 القاعدة: %DB_FILE%
echo.

REM حذف القاعدة القديمة
if exist "%DB_FILE%" (
    echo 🗑️  حذف القاعدة القديمة...
    del "%DB_FILE%"
)

echo 📋 إنشاء قاعدة البيانات...
echo.

REM إنشاء قاعدة بيانات جديدة وتنفيذ SQL
echo 🚀 بدء الاستيراد...
echo ⏳ هذه العملية قد تستغرق 5-10 دقائق...
echo.

sqlite3 "%DB_FILE%" < "%SQL_FILE%"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo ✅ تم الاستيراد بنجاح!
    echo ========================================
    echo.
    
    REM عرض معلومات القاعدة
    echo 📊 معلومات قاعدة البيانات:
    echo.
    
    REM حساب عدد السجلات
    for /f %%i in ('sqlite3 "%DB_FILE%" "SELECT COUNT(*) FROM persons;"') do set RECORD_COUNT=%%i
    echo 📝 عدد السجلات: %RECORD_COUNT%
    
    REM حساب حجم الملف
    for %%A in ("%DB_FILE%") do set DB_SIZE=%%~zA
    set /a DB_SIZE_MB=%DB_SIZE% / 1048576
    echo 💾 حجم القاعدة: %DB_SIZE_MB% MB
    
    echo.
    echo 🔍 إنشاء Indexes للأداء...
    
    sqlite3 "%DB_FILE%" "CREATE INDEX IF NOT EXISTS idx_national_id ON persons(national_id);"
    sqlite3 "%DB_FILE%" "CREATE INDEX IF NOT EXISTS idx_full_name ON persons(full_name);"
    sqlite3 "%DB_FILE%" "CREATE INDEX IF NOT EXISTS idx_governorate ON persons(governorate);"
    
    echo ✅ تم إنشاء Indexes
    
    echo.
    echo ========================================
    echo ✨ العملية مكتملة!
    echo ========================================
    echo.
    echo 📂 المسار: %DB_FILE%
    echo.
    echo الخطوة التالية:
    echo 1. انسخ الملف الى: assets\databases\civil_registry.db
    echo 2. او استخدم ADB: adb push "%DB_FILE%" /sdcard/Download/
    echo.
) else (
    echo.
    echo ❌ فشل الاستيراد!
    echo الرجاء التحقق من صيغة ملف SQL
    echo.
)

pause
