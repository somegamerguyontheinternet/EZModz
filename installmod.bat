@echo off
setlocal enabledelayedexpansion
title EZModz - Minecraft Mod Installer

echo ============================================
echo              EZModz Installer
echo        The Easy Minecraft Mod Manager
echo ============================================
echo.

echo Would you like your mod source to be Modrinth or CurseForge?
set /p SOURCE="Type modrinth or curseforge: "

if /i "%SOURCE%"=="modrinth" (
    goto continue_flow
) else (
    echo.
    echo EZModz currently supports only Modrinth.
    goto endpause
)

:continue_flow
set "DEFAULTDIR=%APPDATA%\.minecraft\mods"
echo.
echo What is your Minecraft mods directory?
echo Press ENTER for default: %DEFAULTDIR%
set /p MCDIR="Directory: "

if "%MCDIR%"=="" set "MCDIR=%DEFAULTDIR%"

if not exist "%MCDIR%" mkdir "%MCDIR%"

echo.
set /p MODNAME="Enter the mod name (search term): "

echo.
set /p MCVERSION="Enter Minecraft version (example: 1.21.1): "

echo.
echo Searching Modrinth...

powershell -ExecutionPolicy Bypass -File "%~dp0api.ps1" modrinth "%MODNAME%" "%MCVERSION%" "" "%MCDIR%" > "%temp%\ezmodz_loaders.txt"

set /p LOADERLIST=<"%temp%\ezmodz_loaders.txt"

echo.
echo Loaders available:
for %%L in (%LOADERLIST%) do echo - %%L

echo.
set /p LOADER="Choose loader: "

echo.
echo Downloading mod...

powershell -ExecutionPolicy Bypass -File "%~dp0api.ps1" modrinth "%MODNAME%" "%MCVERSION%" "%LOADER%" "%MCDIR%" > "%temp%\ezmodz_result.txt"

set /p RESULT=<"%temp%\ezmodz_result.txt"

echo.
echo %RESULT%
echo.

echo Checking for required dependencies...
powershell -ExecutionPolicy Bypass -File "%~dp0search.ps1" "%MODNAME%" "%MCVERSION%" "%LOADER%" "%MCDIR%"

:endpause
echo.
echo Press any key to close EZModz...
pause >nul
exit /b