@echo off
:: InstallShield Subsystem: Force Elevated Administrative Token Context
:: -----------------------------------------------------------------------------
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' neq '0' ( goto :RequestUAC ) else ( goto :ExecuteUninstall )

:RequestUAC
    powershell -Command "Start-Process '%~f0' -Verb RunAs -WorkingDirectory '%~dp0'"
    exit /b

:ExecuteUninstall
setlocal DisableDelayedExpansion

:: Force working directory context
cd /d "%~dp0"

:: InstallShield Configuration Properties: Title Block & Bounds
title InstallShield (R) Uninstaller v1.0 :: dc2url Master Deployment Engine
mode con: cols=120 lines=34

chcp 65001 >nul 2>&1
color 0E

:: Force TrueColor Console Canvas Context Allocation
reg add "HKCU\Console" /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1
for /f %%a in ('echo prompt $E^|cmd') do set "E=%%a"
set "RESET=%E%[0m"
set "BG_GLASS=%E%[48;2;10;10;12m"
set "O1=%E%[38;2;255;68;0m"
set "O2=%E%[38;2;255;110;0m"
set "O3=%E%[38;2;255;153;0m"
set "Y1=%E%[38;2;255;200;0m"
set "Y2=%E%[38;2;255;235;0m"
set "TXT=%E%[38;2;240;240;240m"

cls
echo %BG_GLASS%
cls

echo.
echo %O1%        ██████╗  █████╗ ██████╗ ██╗  ██╗ ██████╗ ██████╗ ███╗   ███╗██████╗ %RESET%%BG_GLASS%
echo %O2%        ██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝██╔════╝██╔═══██╗████╗ ████║╚════██╗%RESET%%BG_GLASS%
echo %O3%        ██║  ██║███████║██████╔╝█████╔╝ ██║     ██║   ██║██╔████╔██║ █████╔╝%RESET%%BG_GLASS%
echo %Y1%        ██║  ██║██╔══██║██╔══██╗██╔═██╗ ██║     ██║   ██║██║╚██╔╝██║██╔═══╝ %RESET%%BG_GLASS%
echo %Y2%        ██████╔╝██║  ██║██║  ██║██║  ██║╚██████╗╚██████╔╝██║ ╚═╝ ██║███████╗%RESET%%BG_GLASS%
echo %Y2%        ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝%RESET%%BG_GLASS%
echo %O2%    ====================================================================================%RESET%%BG_GLASS%
echo %Y2%                dc2url Core Cyborg Ecosystem Uninstaller%RESET%%BG_GLASS%
echo %O2%    ====================================================================================%RESET%%BG_GLASS%
echo.

:: 1. PATH RESOLUTION
set "VERSION_DIR=%~dp0"
if "%VERSION_DIR:~-1%"=="\" set "VERSION_DIR=%VERSION_DIR:~0,-1%"

for %%I in ("%VERSION_DIR%") do set "VERSION_NAME=%%~nxI"
for %%I in ("%VERSION_DIR%\..") do set "BASE_DIR=%%~fI"

set "FINAL_EXEC_DIR=%VERSION_DIR%\exec"

:: 2. OLE/COM UNREGISTRATION PIPELINE
echo %O2%        [*] Unregistering OLE/COM Components...%RESET%%BG_GLASS%
if exist "%FINAL_EXEC_DIR%\DarkComHeadless.dll" (
    regsvr32.exe /u /s "%FINAL_EXEC_DIR%\DarkComHeadless.dll"
    echo                  [SUCCESS] DarkComHeadless.dll unregistered.
)
if exist "%FINAL_EXEC_DIR%\WebView2Loader.dll" (
    regsvr32.exe /u /s "%FINAL_EXEC_DIR%\WebView2Loader.dll"
    echo                  [SUCCESS] WebView2Loader.dll unregistered.
)

:: 3. REMOVE REGISTRY APP PATHS & UNINSTALL ENTRIES
echo %O2%        [*] Cleaning Windows App Paths and Registries...%RESET%%BG_GLASS%
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f >nul 2>&1
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f >nul 2>&1
reg delete "HKCU\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f >nul 2>&1

reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\dc2url" /f >nul 2>&1
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\dc2url" /f >nul 2>&1

:: 4. CLEAN SYSTEM ENVIRONMENT VARIABLES & PATHS
echo %O2%        [*] Purging Environment Pointers and Machine PATH...%RESET%%BG_GLASS%
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "dc2url_path" /f >nul 2>&1

:: Safely remove entry from Machine and User PATH variables via single-line PowerShell commands
powershell -Command "$m = [System.Environment]::GetEnvironmentVariable('PATH', 'Machine'); if ($m) { $p = ($m -split ';' | Where-Object { $_ -and $_ -notlike '*dc2url*' }) -join ';'; [System.Environment]::SetEnvironmentVariable('PATH', $p, 'Machine') }" >nul 2>&1
powershell -Command "$u = [System.Environment]::GetEnvironmentVariable('PATH', 'User'); if ($u) { $p = ($u -split ';' | Where-Object { $_ -and $_ -notlike '*dc2url*' }) -join ';'; [System.Environment]::SetEnvironmentVariable('PATH', $p, 'User') }" >nul 2>&1

echo                  [SUCCESS] dc2url successfully uninstalled from system registers!
echo.
echo %Y2%        [Note: Installation directory files can be safely deleted from: %BASE_DIR%]%RESET%%BG_GLASS%
echo.

:finish
echo %TXT%        Uninstallation sequence complete. Press any key to exit...%RESET%
pause >nul

exit /b 0
