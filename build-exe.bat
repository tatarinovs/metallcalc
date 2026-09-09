@echo off
setlocal enabledelayedexpansion

echo ============================================================
echo   Building Windows EXE - MetallCalc (Tauri 2)
echo ============================================================
echo.

cd /d "%~dp0"

:: Check npm
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

:: Check cargo
where cargo >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Rust and Cargo not found in PATH. Please install Rust from https://rustup.rs
    pause
    exit /b 1
)

:: Run tests
echo [1/3] Running Vitest unit tests...
call %NPM_CMD% test
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Tests failed. Build aborted.
    pause
    exit /b 1
)
echo.

:: Build Tauri release
echo [2/3] Building Tauri Windows release (without UPX)...
call %NPM_CMD% run tauri build
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Tauri build failed.
    pause
    exit /b 1
)
echo.

:: Copy to releases
echo [3/3] Copying binaries to releases\...
if not exist "releases" mkdir "releases"

if exist "src-tauri\target\release\app.exe" (
    copy /y "src-tauri\target\release\app.exe" "releases\metall-calc.exe" >nul
    echo   [OK] releases\metall-calc.exe
) else if exist "src-tauri\target\release\metall-calc.exe" (
    copy /y "src-tauri\target\release\metall-calc.exe" "releases\metall-calc.exe" >nul
    echo   [OK] releases\metall-calc.exe
)

if exist "src-tauri\target\release\bundle\nsis" (
    for %%F in (src-tauri\target\release\bundle\nsis\*setup.exe) do (
        copy /y "%%F" "releases\metall-calc-setup.exe" >nul
        echo   [OK] releases\metall-calc-setup.exe
    )
)

echo.
echo ============================================================
echo   Build finished successfully!
echo ============================================================
echo.
echo Output files in releases\:
dir "releases\*.exe" 2>nul
echo.
if not "%~1"=="--no-pause" pause
