@echo off

:: Get script directory
set "PROJECT_ROOT=%~dp0"
set "PROJECT_ROOT=%PROJECT_ROOT:~0,-1%"

:: Set backend path
set "BACKEND_PATH=%PROJECT_ROOT%\backend"

:: Show info
echo Starting XiangXiu Project...
echo Project Root: %PROJECT_ROOT%
echo Backend Path: %BACKEND_PATH%
echo.

:: Check MySQL installation
echo ==============================================
echo Checking MySQL installation...
echo ==============================================

:: Check if mysql command is available
mysql --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: MySQL is not installed or not in system PATH
    echo Please install MySQL and add it to system PATH
    echo Press any key to exit...
    pause
    exit /b 1
)

:: Get MySQL version
echo MySQL is installed. Checking version...
for /f "tokens=1,2,3 delims=, " %%a in ('mysql --version') do (
    if "%%a"=="mysql" (
        set "MYSQL_VERSION=%%b"
        goto :mysql_version_found
    )
)

:mysql_version_found
echo MySQL Version: %MYSQL_VERSION%
echo MySQL installation check passed!
echo ==============================================
echo.

:: Start backend
echo Starting backend service...
start "Backend Service" cmd /c "cd "%BACKEND_PATH%" && python app.py"
echo Backend service started

:: Start frontend
echo Starting frontend service...
start "Frontend Service" cmd /c "npm run dev"
echo Frontend service started

:: Wait for services to start
echo Waiting for services to start...
ping 127.0.0.1 -n 4 >nul

:: Open browser
echo Opening browser...
start http://localhost:5173
start http://localhost:5000
echo Browser opened

echo.
echo Project started successfully!
echo Frontend: http://localhost:5173
echo Backend: http://localhost:5000
echo.
echo Press any key to exit...
pause
