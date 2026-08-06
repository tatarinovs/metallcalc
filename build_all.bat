@echo off
setlocal EnableExtensions

set "PROJECT_ROOT=%~dp0"
if "%PROJECT_ROOT:~-1%"=="\" set "PROJECT_ROOT=%PROJECT_ROOT:~0,-1%"

where flutter >nul 2>nul
if not errorlevel 1 (
    set "FLUTTER_CMD=flutter"
) else if exist "%USERPROFILE%\flutter\bin\flutter.bat" (
    set "FLUTTER_CMD=%USERPROFILE%\flutter\bin\flutter.bat"
) else (
    echo ERROR: Flutter SDK was not found.
    exit /b 1
)

pushd "%PROJECT_ROOT%" || exit /b 1
if not exist "releases" mkdir "releases"

del /q "releases\MetallCalc.exe" "releases\Metallcalc_arm64.apk" "releases\Metallcalc_arm32.apk" "releases\Metallcalc_x86_64.apk" 2>nul
if exist "releases\windows" rmdir /s /q "releases\windows"
if exist "releases\web" rmdir /s /q "releases\web"

echo =======================================
echo Running quality checks...
echo =======================================
call "%FLUTTER_CMD%" pub get
if errorlevel 1 goto :fail
call "%FLUTTER_CMD%" analyze
if errorlevel 1 goto :fail
call "%FLUTTER_CMD%" test
if errorlevel 1 goto :fail

echo =======================================
if exist "android\key.properties" (
    echo Building Android APKs with the configured release key...
) else (
    echo Building Android APKs with the debug key...
    echo WARNING: Configure android\key.properties before publishing an update.
)
echo =======================================
call "%FLUTTER_CMD%" build apk --split-per-abi --obfuscate --split-debug-info="build\debug_info" --tree-shake-icons
if errorlevel 1 goto :fail

copy /y "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" "releases\Metallcalc_arm64.apk" >nul
if errorlevel 1 goto :fail
copy /y "build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk" "releases\Metallcalc_arm32.apk" >nul
if errorlevel 1 goto :fail
copy /y "build\app\outputs\flutter-apk\app-x86_64-release.apk" "releases\Metallcalc_x86_64.apk" >nul
if errorlevel 1 goto :fail

echo.
echo =======================================
echo Building Windows application...
echo =======================================
call "%FLUTTER_CMD%" build windows --obfuscate --split-debug-info="build\debug_info" --tree-shake-icons
if errorlevel 1 goto :fail

xcopy "build\windows\x64\runner\Release\*" "releases\windows\" /E /I /Y >nul
if errorlevel 1 goto :fail

set "EVB_CONSOLE=C:\Program Files (x86)\Enigma Virtual Box\enigmavbconsole.exe"
set "EVB_TEMPLATE=%PROJECT_ROOT%\metallcalc.evb"
set "EVB_GENERATED=%PROJECT_ROOT%\build\metallcalc.generated.evb"
if exist "%EVB_CONSOLE%" if exist "%EVB_TEMPLATE%" (
    echo Packing optional single-file Windows executable...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$template = Get-Content -LiteralPath $env:EVB_TEMPLATE -Raw; $template.Replace('__PROJECT_ROOT__', $env:PROJECT_ROOT) | Set-Content -LiteralPath $env:EVB_GENERATED -Encoding ASCII"
    if errorlevel 1 goto :fail
    "%EVB_CONSOLE%" "%EVB_GENERATED%"
    if errorlevel 1 goto :fail
    if not exist "releases\MetallCalc.exe" goto :fail
) else (
    echo Enigma Virtual Box is unavailable; portable bundle remains in releases\windows.
)

echo.
echo =======================================
echo Building Web application...
echo =======================================
call "%FLUTTER_CMD%" build web --wasm --base-href "/calc/"
if errorlevel 1 goto :fail
xcopy "build\web\*" "releases\web\" /E /I /Y >nul
if errorlevel 1 goto :fail

echo.
echo =======================================
echo Build completed successfully.
echo Artifacts are in the releases directory.
echo =======================================
popd
exit /b 0

:fail
set "BUILD_EXIT_CODE=%errorlevel%"
if "%BUILD_EXIT_CODE%"=="0" set "BUILD_EXIT_CODE=1"
echo.
echo ERROR: Build failed with exit code %BUILD_EXIT_CODE%.
popd
exit /b %BUILD_EXIT_CODE%
