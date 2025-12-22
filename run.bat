@echo off
echo.
echo ====================================
echo   GetHiGered - Starting App
echo ====================================
echo.

:: Check for Flutter
where flutter >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Flutter is not installed!
    echo.
    echo Please install Flutter:
    echo   1. Download from: https://docs.flutter.dev/get-started/install/windows
    echo   2. Extract to C:\flutter
    echo   3. Add C:\flutter\bin to your PATH
    echo   4. Restart this terminal and try again
    echo.
    pause
    exit /b 1
)

echo [OK] Flutter found
echo.

:: Start backend in new window
echo Starting backend server...
start "GetHiGered Backend" cmd /k "cd backend && go run cmd/server/main.go"

:: Wait a moment for backend to start
timeout /t 3 /nobreak >nul

:: Start frontend
echo Starting frontend in Chrome...
cd frontend
flutter run -d chrome --web-port=3000

pause

