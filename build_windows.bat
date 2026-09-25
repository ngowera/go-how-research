@echo off
REM =========================================================================
REM Go-How RS - Windows Automated Build Script
REM =========================================================================
echo.
echo =========================================================================
echo    Go-How RS - All-in-One University Research Software
echo =========================================================================
echo.

REM 1. Check Flutter
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Flutter SDK not found in PATH!
    echo Please install Flutter or add it to your Windows PATH environment variable.
    pause
    exit /b 1
)

echo [1/4] Enabling Windows desktop support...
call flutter config --enable-windows-desktop

echo [2/4] Getting packages...
call flutter pub get

echo [3/4] Generating Drift database code...
call dart run build_runner build --delete-conflicting-outputs

echo [4/4] Building Windows Release Executable (.exe)...
call flutter build windows --release

echo.
echo =========================================================================
echo [SUCCESS] Build completed!
echo Executable location:
echo build\windows\x64\runner\Release\gohow_research.exe
echo =========================================================================
pause
