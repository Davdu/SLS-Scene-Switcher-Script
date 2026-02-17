@echo off
REM OBS Stream Switcher - Dependency Setup
REM This script installs Python dependencies required for the OBS script

echo ========================================
echo OBS Stream Switcher - Dependency Setup
echo ========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python is not installed or not in PATH
    echo.
    echo Please install Python 3.11.9 from:
    echo https://www.python.org/downloads/
    echo.
    echo Make sure to check "Add Python to PATH" during installation
    pause
    exit /b 1
)

echo [OK] Python is installed
python --version
echo.

REM Upgrade pip
echo Upgrading pip...
python -m pip install --upgrade pip
if %errorlevel% neq 0 (
    echo [WARNING] Failed to upgrade pip, but continuing...
)
echo.

REM Install requests library
echo Installing requests library...
python -m pip install requests
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install requests library
    echo.
    echo Please try manually:
    echo   pip install requests
    pause
    exit /b 1
)

echo.
echo ========================================
echo [SUCCESS] All dependencies installed!
echo ========================================
echo.
echo The OBS Stream Switcher script is ready to use.
echo.
echo To use it in OBS:
echo 1. Open OBS Studio
echo 2. Go to Tools ^> Scripts
echo 3. Click the + button
echo 4. Navigate to: %APPDATA%\obs-studio\scripts
echo 5. Select obs_stream_switcher.py
echo.
pause
