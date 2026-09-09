@echo off
setlocal enabledelayedexpansion

echo ============================================================
echo   Building Signed Android APK (arm64-v8a) - MetallCalc
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

:: 4. Check Keystore
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

:: 5. Run tests
echo.
echo [1/3] Running Vitest tests...
call %NPM_CMD% test
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Unit tests failed. Build aborted.
    pause
    exit /b 1
)

:: 6. Build arm64 APK
echo.
echo [2/3] Building signed arm64-v8a APK...
call %NPM_CMD% run tauri android build -- --target aarch64 --split-per-abi --apk
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Android build failed!
    pause
    exit /b 1
)

:: 7. Copy to dist
echo.
echo [3/3] Copying APK to releases\...
if not exist "releases" mkdir "releases"

set "APK_SRC=src-tauri\gen\android\app\build\outputs\apk\arm64\release\app-arm64-release.apk"
if not exist "%APK_SRC%" set "APK_SRC=src-tauri\gen\android\app\build\outputs\apk\universal\release\app-universal-release.apk"

if exist "%APK_SRC%" (
    copy /y "%APK_SRC%" "releases\metallcalc-arm64-release.apk" >nul
    echo   [OK] releases\metallcalc-arm64-release.apk
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
