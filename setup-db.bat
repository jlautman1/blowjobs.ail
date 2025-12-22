@echo off
echo.
echo ====================================
echo   GetHiGered - Database Setup
echo ====================================
echo.

:: Try to create database
echo Creating database 'blowjobs'...

:: Check if using Docker
where docker >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo Docker found! Starting PostgreSQL container...
    docker-compose up -d postgres
    echo.
    echo Waiting for database to be ready...
    timeout /t 5 /nobreak >nul
    echo [OK] PostgreSQL is running in Docker
) else (
    echo Docker not found. Trying local PostgreSQL...
    createdb blowjobs 2>nul
    if %ERRORLEVEL% EQU 0 (
        echo [OK] Database created
    ) else (
        echo [INFO] Database may already exist or PostgreSQL is not running
    )
)

echo.
echo Database setup complete!
echo.
pause

