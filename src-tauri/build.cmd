@echo off
setlocal enabledelayedexpansion

:: Check if running with sudo privileges
whoami /groups | find "S-1-16-12288" > nul
if %errorLevel% neq 0 (
    echo Requesting elevated privileges...
    sudo "%~f0"
    exit /b
)

echo ====================================
echo Development Environment Setup Script
echo ====================================

:: Set paths
set "VCPKG_ROOT=M:\vcpkg"
set "VS_PATH=C:\Program Files\Microsoft Visual Studio\2022\Community"
set "VS_INSTALLER=C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe"

:: Check for Visual Studio Installation
if not exist "%VS_PATH%" (
    echo Visual Studio 2022 not found
    
    :: Check if VS Installer exists
    if exist "%VS_INSTALLER%" (
        echo Running Visual Studio Installer...
        sudo start "" "%VS_INSTALLER%" modify --add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended
    ) else (
        echo Please install Visual Studio 2022 with C++ development tools
        start https://visualstudio.microsoft.com/vs/community/
        pause
        exit /b 1
    )
)

:: Set environment variables
set "VCINSTALLDIR=%VS_PATH%\VC"
set "VS160COMNTOOLS=%VS_PATH%\Common7\Tools"

:: Check/Install vcpkg
if not exist "%VCPKG_ROOT%" (
    echo Installing vcpkg...
    sudo git clone https://github.com/Microsoft/vcpkg.git "%VCPKG_ROOT%"
    cd /d "%VCPKG_ROOT%"
    sudo call bootstrap-vcpkg.bat
) else (
    echo Updating vcpkg...
    cd /d "%VCPKG_ROOT%"
    sudo git pull
    sudo call bootstrap-vcpkg.bat
)

:: Install required packages
echo Installing required packages...
sudo vcpkg install ffmpeg:x64-windows
sudo vcpkg integrate install

:: Set up build environment
echo Setting up build environment...
call "%VS_PATH%\VC\Auxiliary\Build\vcvarsall.bat" x64

:: Return to project directory
cd /d %~dp0

:: Clean and rebuild
echo Cleaning previous build...
sudo cargo clean

echo Building project...
sudo cargo vcpkg build

if %errorLevel% neq 0 (
    echo Build failed!
    pause
    exit /b 1
)

echo ====================================
echo Setup completed successfully!
echo ====================================
pause