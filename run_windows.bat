@echo off
setlocal EnableExtensions

where flutter >nul 2>nul
if not errorlevel 1 (
    set "FLUTTER_CMD=flutter"
) else if exist "%USERPROFILE%\flutter\bin\flutter.bat" (
    set "FLUTTER_CMD=%USERPROFILE%\flutter\bin\flutter.bat"
) else (
    echo ERROR: Flutter SDK was not found.
    exit /b 1
)

pushd "%~dp0" || exit /b 1
call "%FLUTTER_CMD%" run -d windows
set "RUN_EXIT_CODE=%errorlevel%"
popd
exit /b %RUN_EXIT_CODE%
