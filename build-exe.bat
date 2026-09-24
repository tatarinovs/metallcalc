@echo off
setlocal enabledelayedexpansion

echo ============================================================
echo   Building Windows EXE - MetallCalc (Tauri 2)
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
echo [ERROR] Node.js or npm not found in PATH. Please install Node.js.
pause
exit /b 1

:npm_ok

:: 2. Check cargo
where cargo >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Rust and Cargo not found in PATH. Please install Rust from https://rustup.rs
    pause
    exit /b 1
)

:: 3. Select Target Architecture
set "TARGET_OPT=%~1"
if /i "%TARGET_OPT%"=="--no-pause" set "TARGET_OPT="
if /i "%TARGET_OPT%"=="-x64" set "TARGET_OPT=x64"
if /i "%TARGET_OPT%"=="--x64" set "TARGET_OPT=x64"
if /i "%TARGET_OPT%"=="-x86" set "TARGET_OPT=x86"
if /i "%TARGET_OPT%"=="--x86" set "TARGET_OPT=x86"
if /i "%TARGET_OPT%"=="-all" set "TARGET_OPT=all"
if /i "%TARGET_OPT%"=="--all" set "TARGET_OPT=all"

if "%TARGET_OPT%"=="" (
    echo Выберите целевую архитектуру для сборки Windows EXE:
    echo   [1] x64  - 64-битная Windows (x86_64-pc-windows-msvc) [По умолчанию]
    echo   [2] x86  - 32-битная Windows (i686-pc-windows-msvc)
    echo   [3] Все  - Собрать обе архитектуры (x64 + x86)
    echo.
    set /p "USER_CHOICE=Ваш выбор [1-3] (Enter = 1): "
    if "!USER_CHOICE!"=="2" set "TARGET_OPT=x86"
    if "!USER_CHOICE!"=="3" set "TARGET_OPT=all"
    if "!TARGET_OPT!"=="" set "TARGET_OPT=x64"
)

:: 4. Run tests
echo.
echo [1/3] Running Vitest unit tests...
call %NPM_CMD% test
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Tests failed. Build aborted.
    pause
    exit /b 1
)
echo.

if not exist "releases" mkdir "releases"

:: 5. Build selected targets
if /i "%TARGET_OPT%"=="x64" goto :build_x64
if /i "%TARGET_OPT%"=="x86" goto :build_x86
if /i "%TARGET_OPT%"=="all" goto :build_all

:build_x64
echo [2/3] Building Tauri Windows release (x64)...
call %NPM_CMD% run tauri build -- --target x86_64-pc-windows-msvc
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Tauri x64 build failed.
    pause
    exit /b 1
)
goto :copy_x64

:build_x86
echo [2/3] Building Tauri Windows release (x86 / 32-bit)...
call %NPM_CMD% run tauri build -- --target i686-pc-windows-msvc
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Tauri x86 build failed.
    pause
    exit /b 1
)
goto :copy_x86

:build_all
echo [2/3] Building Tauri Windows release (x64 + x86)...
echo --- Building x64 ---
call %NPM_CMD% run tauri build -- --target x86_64-pc-windows-msvc
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Tauri x64 build failed.
    pause
    exit /b 1
)
echo --- Building x86 ---
call %NPM_CMD% run tauri build -- --target i686-pc-windows-msvc
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Tauri x86 build failed.
    pause
    exit /b 1
)
goto :copy_all

:copy_x64
echo [3/3] Copying x64 binaries to releases\...
if exist "src-tauri\target\x86_64-pc-windows-msvc\release\metallcalc.exe" (
    copy /y "src-tauri\target\x86_64-pc-windows-msvc\release\metallcalc.exe" "releases\metallcalc.exe" >nul
    copy /y "src-tauri\target\x86_64-pc-windows-msvc\release\metallcalc.exe" "releases\metallcalc-x64.exe" >nul
    echo   [OK] releases\metallcalc.exe
    echo   [OK] releases\metallcalc-x64.exe
) else if exist "src-tauri\target\release\metallcalc.exe" (
    copy /y "src-tauri\target\release\metallcalc.exe" "releases\metallcalc.exe" >nul
    copy /y "src-tauri\target\release\metallcalc.exe" "releases\metallcalc-x64.exe" >nul
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
) else if exist "src-tauri\target\release\bundle\nsis" (
    for %%F in (src-tauri\target\release\bundle\nsis\*setup.exe) do (
        copy /y "%%F" "releases\metallcalc-setup.exe" >nul
        copy /y "%%F" "releases\metallcalc-x64-setup.exe" >nul
        echo   [OK] releases\metallcalc-setup.exe
        echo   [OK] releases\metallcalc-x64-setup.exe
    )
)
goto :done

:copy_x86
echo [3/3] Copying x86 binaries to releases\...
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
goto :done

:copy_all
echo [3/3] Copying all binaries to releases\...
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
    )
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
goto :done

:done
echo.
echo ============================================================
echo   Build finished successfully!
echo ============================================================
echo.
echo Output files in releases\:
dir "releases\*.exe" 2>nul
echo.
if not "%~1"=="--no-pause" if not "%~2"=="--no-pause" pause
