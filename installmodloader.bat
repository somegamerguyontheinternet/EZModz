@echo off
setlocal enabledelayedexpansion
title EZModz - Modloader Installer

echo ============================================
echo          EZModz Modloader Installer
echo ============================================
echo.

set "DEFAULTDIR=%APPDATA%\.minecraft"
echo Minecraft directory? (Press ENTER for default)
echo Default: %DEFAULTDIR%
set /p MCDIR="Path: "
if "%MCDIR%"=="" set "MCDIR=%DEFAULTDIR%"

if not exist "%MCDIR%" (
    echo.
    echo Error: "%MCDIR%" does not exist.
    goto endpause
)

echo.
echo Which modloader would you like to install?
echo   1) Fabric
echo   2) Quilt
echo   3) NeoForge
echo   4) Forge
set /p CHOICE="Enter 1-4: "

if "%CHOICE%"=="1" set "LOADER=fabric"
if "%CHOICE%"=="2" set "LOADER=quilt"
if "%CHOICE%"=="3" set "LOADER=neoforge"
if "%CHOICE%"=="4" set "LOADER=forge"

if "%LOADER%"=="" (
    echo.
    echo Invalid choice.
    goto endpause
)

echo.
set /p MCVERSION="Enter Minecraft version (e.g. 1.21.1): "

if "%MCVERSION%"=="" (
    echo.
    echo Minecraft version is required.
    goto endpause
)

echo.
echo Installing %LOADER% for Minecraft %MCVERSION%...
powershell -ExecutionPolicy Bypass -File "%~dp0apimodloader.ps1" "%LOADER%" "%MCVERSION%" "%MCDIR%"
echo.
echo Done.

:endpause
echo.
echo Press any key to close...
pause >nul
endlocal
exit /b