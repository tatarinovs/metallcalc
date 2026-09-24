@echo off
setlocal enabledelayedexpansion

echo ============================================================
echo   Building ALL Artifacts - MetallCalc (Web, Win, Android)
echo ============================================================
echo.

cd /d "%~dp0"

:: 1. Check npm
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

:: 2. Check Cargo (Rust)
where cargo >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Rust and Cargo not found in PATH!
    pause
    exit /b 1
)

:: 3. Check Java for Android
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

:: 4. Check Android SDK
if not defined ANDROID_HOME (
    if exist "%LOCALAPPDATA%\Android\Sdk" (
        set "ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk"
        set "ANDROID_SDK_ROOT=%LOCALAPPDATA%\Android\Sdk"
    )
)
if defined ANDROID_HOME (
    echo [INFO] ANDROID_HOME is !ANDROID_HOME!
)

if not exist "releases" mkdir "releases"

:: 5. Step 1/4: Run Unit Tests
echo.
echo ============================================================
echo [1/4] Running Unit Tests (Vitest)...
echo ============================================================
call %NPM_CMD% test
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Unit tests failed! Build aborted.
    pause
    exit /b 1
)

:: 6. Step 2/4: Build and Package Web Version
echo.
echo ============================================================
echo [2/4] Building and packaging Web version...
echo ============================================================
call %NPM_CMD% run build
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Web build failed!
    pause
    exit /b 1
)

echo Packaging dist\ into releases\metallcalc-web.zip...
if exist "releases\metallcalc-web.zip" del /f /q "releases\metallcalc-web.zip" >nul 2>&1
where tar >nul 2>&1
if %ERRORLEVEL% equ 0 (
    tar -a -c -f "releases\metallcalc-web.zip" -C dist .
) else (
    powershell -NoProfile -Command "Compress-Archive -Path 'dist\*' -DestinationPath 'releases\metallcalc-web.zip' -Force"
)

if exist "releases\metallcalc-web.zip" (
    echo   [OK] releases\metallcalc-web.zip
) else (
    echo   [WARNING] Could not create releases\metallcalc-web.zip
)

:: 7. Step 3/4: Build Windows Binaries (x64 and x86)
echo.
echo ============================================================
echo [3/4] Building Windows Binaries (x64 and x86)...
echo ============================================================

echo --- Building Windows x64 ---
call %NPM_CMD% run tauri build -- --target x86_64-pc-windows-msvc
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Windows x64 build failed!
    pause
    exit /b 1
)

if exist "src-tauri\target\x86_64-pc-windows-msvc\release\metallcalc.exe" (
    copy /y "src-tauri\target\x86_64-pc-windows-msvc\release\metallcalc.exe" "releases\metallcalc.exe" >nul
    copy /y "src-tauri\target\x86_64-pc-windows-msvc\release\metallcalc.exe" "releases\metallcalc-x64.exe" >nul
    echo   [OK] releases\metallcalc.exe
    echo   [OK] releases\metallcalc-x64.exe
)
if exist "src-tauri\target\x86_64-pc-windows-msvc\release\bundle\nsis" (
    for %%F in (src-tauri\target\x86_64-pc-windows-msvc\release\bundle\nsis\*setup.exe) do (
        copy /y "%%F" "releases\metallcalc-setup.exe" >nul
        copy /y "%%F" "releases\metallcalc-x64-setup.exe" >nul
        echo   [OK] releases\metallcalc-setup.exe
        echo   [OK] releases\metallcalc-x64-setup.exe
    )
)

echo --- Building Windows x86 (32-bit) ---
call %NPM_CMD% run tauri build -- --target i686-pc-windows-msvc
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Windows x86 build failed!
    pause
    exit /b 1
)

if exist "src-tauri\target\i686-pc-windows-msvc\release\metallcalc.exe" (
    copy /y "src-tauri\target\i686-pc-windows-msvc\release\metallcalc.exe" "releases\metallcalc-x86.exe" >nul
    echo   [OK] releases\metallcalc-x86.exe
)
if exist "src-tauri\target\i686-pc-windows-msvc\release\bundle\nsis" (
    for %%F in (src-tauri\target\i686-pc-windows-msvc\release\bundle\nsis\*setup.exe) do (
        copy /y "%%F" "releases\metallcalc-x86-setup.exe" >nul
        echo   [OK] releases\metallcalc-x86-setup.exe
    )
)

:: 8. Step 4/4: Build Android APKs
echo.
echo ============================================================
echo [4/4] Building Signed Android APKs (arm64, armv7, x86)...
echo ============================================================

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

call %NPM_CMD% run tauri android build -- --target aarch64 armv7 i686 --split-per-abi --apk
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Android build failed!
    pause
    exit /b 1
)

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
echo   ALL Builds completed successfully!
echo ============================================================
echo.
echo All output artifacts in releases\:
dir "releases\*" 2>nul
echo.
if not "%~1"=="--no-pause" pause
