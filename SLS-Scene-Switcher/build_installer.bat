@echo off
REM Build Script for OBS Stream Switcher Installer
REM This script creates the installer using Inno Setup

echo ========================================
echo OBS Stream Switcher - Build Installer
echo ========================================
echo.

REM Check if Inno Setup is installed
set INNO_PATH=C:\Program Files (x86)\Inno Setup 6\ISCC.exe
if not exist "%INNO_PATH%" (
    echo [ERROR] Inno Setup not found!
    echo.
    echo Please download and install Inno Setup 6 from:
    echo https://jrsoftware.org/isdl.php
    echo.
    echo Default installation path: C:\Program Files (x86)\Inno Setup 6\
    pause
    exit /b 1
)

echo [OK] Inno Setup found
echo.

REM Check if all required files exist
echo Checking required files...
if not exist "obs_stream_switcher.py" (
    echo [ERROR] obs_stream_switcher.py not found!
    pause
    exit /b 1
)
echo [OK] obs_stream_switcher.py

if not exist "setup_dependencies.bat" (
    echo [ERROR] setup_dependencies.bat not found!
    pause
    exit /b 1
)
echo [OK] setup_dependencies.bat

if not exist "check_python.ps1" (
    echo [ERROR] check_python.ps1 not found!
    pause
    exit /b 1
)
echo [OK] check_python.ps1

if not exist "installer_setup.iss" (
    echo [ERROR] installer_setup.iss not found!
    pause
    exit /b 1
)
echo [OK] installer_setup.iss

echo.
echo All required files found!
echo.

REM Compile the installer
echo Building installer...
"%INNO_PATH%" "installer_setup.iss"

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Build failed!
    pause
    exit /b 1
)

echo.
echo ========================================
echo [SUCCESS] Installer built successfully!
echo ========================================
echo.
echo Output: OBS_Stream_Switcher_Setup.exe
echo.
pause
