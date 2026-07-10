@echo off
echo =======================================
echo Building Android APK (Split per ABI)...
echo =======================================
call c:\Users\Serg\flutter\bin\flutter.bat build apk --split-per-abi --obfuscate --split-debug-info=build\debug_info --tree-shake-icons

mkdir releases 2>nul
copy build\app\outputs\flutter-apk\app-arm64-v8a-release.apk releases\Metallcalc_arm64.apk >nul
copy build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk releases\Metallcalc_arm32.apk >nul
copy build\app\outputs\flutter-apk\app-x86_64-release.apk releases\Metallcalc_x86_64.apk >nul

echo.
echo =======================================
echo Building Windows EXE...
echo =======================================
call c:\Users\Serg\flutter\bin\flutter.bat build windows --obfuscate --split-debug-info=build\debug_info --tree-shake-icons

copy build\app\intermediates\flutter\release\flutter_assets\fonts\MaterialIcons-Regular.otf build\windows\x64\runner\Release\data\flutter_assets\fonts\ >nul
echo.
echo Packing Windows portable executable with Enigma Virtual Box...
"C:\Program Files (x86)\Enigma Virtual Box\enigmavbconsole.exe" "metallcalc.evb"
echo Windows portable executable created!

echo.
echo =======================================
echo Build complete! Check the 'releases' folder:
echo - releases\Metallcalc_arm64.apk (Main Android version)
echo - releases\Metallcalc.exe
echo =======================================
pause
