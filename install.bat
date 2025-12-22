@echo off
echo.
echo ====================================
echo   GetHiGered - Installing Dependencies
echo ====================================
echo.

:: Check Go
echo Checking Go...
where go >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Go is not installed!
    echo Download from: https://go.dev/dl/
    pause
    exit /b 1
)
echo [OK] Go found

:: Check Flutter
echo Checking Flutter...
where flutter >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Flutter is not installed!
    echo.
    echo To install Flutter on Windows:
    echo   1. Download from: https://docs.flutter.dev/get-started/install/windows
    echo   2. Extract to C:\flutter
    echo   3. Add C:\flutter\bin to your PATH
    echo   4. Restart PowerShell and run this again
    echo.
    pause
    exit /b 1
)
echo [OK] Flutter found

echo.
echo Installing Go dependencies...
cd backend
go mod download
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to install Go dependencies
    pause
    exit /b 1
)
echo [OK] Go dependencies installed

echo.
echo Installing Flutter dependencies...
cd ..\frontend
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to install Flutter dependencies
    pause
    exit /b 1
)
echo [OK] Flutter dependencies installed

cd ..
echo.
echo ====================================
echo   Installation Complete!
echo ====================================
echo.
echo Next steps:
echo   1. Make sure PostgreSQL is running (or run: docker-compose up -d postgres)
echo   2. Run: run.bat
echo.
pause

