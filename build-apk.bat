@echo off
setlocal enabledelayedexpansion

echo ============================================================
echo   Building Signed Android APK - MetallCalc
echo ============================================================
echo.

cd /d "%~dp0"

:: 1. Check JAVA_HOME
if not defined JAVA_HOME (
    if exist "C:\Program Files\Android\Android Studio\jbr" (
        set "JAVA_HOME=C:\Program Files\Android\Android Studio\jbr"
    )
)
if not defined JAVA_HOME (
    if exist "C:\Program Files\Java\jdk-17" (
        set "JAVA_HOME=C:\Program Files\Java\jdk-17"
    )
)
if not defined JAVA_HOME (
    if exist "C:\Program Files\Java\jdk-21" (
        set "JAVA_HOME=C:\Program Files\Java\jdk-21"
    )
)

if defined JAVA_HOME (
    echo [INFO] JAVA_HOME is !JAVA_HOME!
    set "PATH=!JAVA_HOME!\bin;!PATH!"
) else (
    echo [WARNING] JAVA_HOME is not set. Using system java.
)

:: 2. Check ANDROID_HOME
if not defined ANDROID_HOME (
    if exist "%LOCALAPPDATA%\Android\Sdk" (
        set "ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk"
        set "ANDROID_SDK_ROOT=%LOCALAPPDATA%\Android\Sdk"
    )
)
if defined ANDROID_HOME (
    echo [INFO] ANDROID_HOME is !ANDROID_HOME!
)

:: 3. Check npm
where npm.cmd >nul 2>&1
if %ERRORLEVEL% equ 0 (
    set "NPM_CMD=npm.cmd"
    goto :npm_ok
)
where npm >nul 2>&1
if %ERRORLEVEL% equ 0 (
    set "NPM_CMD=npm"
    goto :npm_ok
)
echo [ERROR] Node.js or npm not found in PATH!
pause
exit /b 1

:npm_ok

:: 4. Select Target Architecture
set "TARGET_OPT=%~1"
if /i "%TARGET_OPT%"=="--no-pause" set "TARGET_OPT="
if /i "%TARGET_OPT%"=="arm64" set "TARGET_OPT=arm64"
if /i "%TARGET_OPT%"=="aarch64" set "TARGET_OPT=arm64"
if /i "%TARGET_OPT%"=="armv7" set "TARGET_OPT=armv7"
if /i "%TARGET_OPT%"=="arm" set "TARGET_OPT=armv7"
if /i "%TARGET_OPT%"=="amr" set "TARGET_OPT=armv7"
if /i "%TARGET_OPT%"=="amr86" set "TARGET_OPT=all_32"
if /i "%TARGET_OPT%"=="x86" set "TARGET_OPT=x86"
if /i "%TARGET_OPT%"=="i686" set "TARGET_OPT=x86"
if /i "%TARGET_OPT%"=="all" set "TARGET_OPT=all"

if "%TARGET_OPT%"=="" (
    echo Выберите целевую архитектуру для Android APK:
    echo   [1] arm64-v8a   - 64-битные ARM смартфоны (по умолчанию)
    echo   [2] armeabi-v7a - 32-битные ARM устройства (ARMv7 / AMR)
    echo   [3] x86         - 32-битные Intel устройства / эмуляторы
    echo   [4] Все 32-бит  - Собрать ARMv7 + x86
    echo   [5] Все         - Собрать все (arm64 + armv7 + x86)
    echo.
    set /p "USER_CHOICE=Ваш выбор [1-5] (Enter = 1): "
    if "!USER_CHOICE!"=="2" set "TARGET_OPT=armv7"
    if "!USER_CHOICE!"=="3" set "TARGET_OPT=x86"
    if "!USER_CHOICE!"=="4" set "TARGET_OPT=all_32"
    if "!USER_CHOICE!"=="5" set "TARGET_OPT=all"
    if "!TARGET_OPT!"=="" set "TARGET_OPT=arm64"
)

:: 5. Check Keystore
set "KEYSTORE_FILE=src-tauri\gen\android\release.keystore"
set "KEYSTORE_PROPS=src-tauri\gen\android\keystore.properties"

if not exist "%KEYSTORE_FILE%" (
    echo [INFO] release.keystore not found. Generating new keystore...
    keytool -genkeypair -v -keystore "%KEYSTORE_FILE%" -alias metallcalc -keyalg RSA -keysize 2048 -validity 10000 -storepass metallcalc -keypass metallcalc -dname "CN=MetallCalc, OU=Dev, O=MetallCalc, L=City, ST=State, C=RU"
    if %ERRORLEVEL% neq 0 (
        echo [ERROR] Failed to generate release.keystore!
        pause
        exit /b 1
    )
    echo [OK] release.keystore generated successfully.
)

if not exist "%KEYSTORE_PROPS%" (
    echo [INFO] Creating keystore.properties...
    echo storeFile=release.keystore> "%KEYSTORE_PROPS%"
    echo storePassword=metallcalc>> "%KEYSTORE_PROPS%"
    echo keyAlias=metallcalc>> "%KEYSTORE_PROPS%"
    echo keyPassword=metallcalc>> "%KEYSTORE_PROPS%"
)

:: 6. Run tests
echo.
echo [1/3] Running Vitest tests...
call %NPM_CMD% test
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Unit tests failed. Build aborted.
    pause
    exit /b 1
)

:: 7. Build APKs
echo.
if /i "%TARGET_OPT%"=="arm64" (
    echo [2/3] Building signed arm64-v8a APK...
    call %NPM_CMD% run tauri android build -- --target aarch64 --split-per-abi --apk
) else if /i "%TARGET_OPT%"=="armv7" (
    echo [2/3] Building signed armeabi-v7a (ARMv7) APK...
    call %NPM_CMD% run tauri android build -- --target armv7 --split-per-abi --apk
) else if /i "%TARGET_OPT%"=="x86" (
    echo [2/3] Building signed x86 APK...
    call %NPM_CMD% run tauri android build -- --target i686 --split-per-abi --apk
) else if /i "%TARGET_OPT%"=="all_32" (
    echo [2/3] Building signed ARMv7 + x86 APKs...
    call %NPM_CMD% run tauri android build -- --target armv7 i686 --split-per-abi --apk
) else (
    echo [2/3] Building signed APKs for all targets (arm64, armv7, x86)...
    call %NPM_CMD% run tauri android build -- --target aarch64 armv7 i686 --split-per-abi --apk
)

if %ERRORLEVEL% neq 0 (
    echo [ERROR] Android build failed!
    pause
    exit /b 1
)

:: 8. Copy to releases
echo.
echo [3/3] Copying APK(s) to releases\...
if not exist "releases" mkdir "releases"

set "APK_BASE=src-tauri\gen\android\app\build\outputs\apk"

:: Copy ARM64
if exist "%APK_BASE%\arm64\release\app-arm64-release.apk" (
    copy /y "%APK_BASE%\arm64\release\app-arm64-release.apk" "releases\metallcalc-arm64-release.apk" >nul
    echo   [OK] releases\metallcalc-arm64-release.apk
) else if exist "%APK_BASE%\arm64-v8a\release\app-arm64-v8a-release.apk" (
    copy /y "%APK_BASE%\arm64-v8a\release\app-arm64-v8a-release.apk" "releases\metallcalc-arm64-release.apk" >nul
    echo   [OK] releases\metallcalc-arm64-release.apk
)

:: Copy ARMv7
if exist "%APK_BASE%\arm\release\app-arm-release.apk" (
    copy /y "%APK_BASE%\arm\release\app-arm-release.apk" "releases\metallcalc-armv7-release.apk" >nul
    echo   [OK] releases\metallcalc-armv7-release.apk
) else if exist "%APK_BASE%\armeabi-v7a\release\app-armeabi-v7a-release.apk" (
    copy /y "%APK_BASE%\armeabi-v7a\release\app-armeabi-v7a-release.apk" "releases\metallcalc-armv7-release.apk" >nul
    echo   [OK] releases\metallcalc-armv7-release.apk
)

:: Copy x86
if exist "%APK_BASE%\x86\release\app-x86-release.apk" (
    copy /y "%APK_BASE%\x86\release\app-x86-release.apk" "releases\metallcalc-x86-release.apk" >nul
    echo   [OK] releases\metallcalc-x86-release.apk
)

:: Fallback / Universal
if exist "%APK_BASE%\universal\release\app-universal-release.apk" (
    copy /y "%APK_BASE%\universal\release\app-universal-release.apk" "releases\metallcalc-universal-release.apk" >nul
    echo   [OK] releases\metallcalc-universal-release.apk
)

echo.
echo ============================================================
echo   Signed Android APK build finished!
echo ============================================================
echo.
echo Output files in releases\:
dir "releases\*.apk" 2>nul
echo.
if not "%~1"=="--no-pause" if not "%~2"=="--no-pause" pause
