@echo off
setlocal EnabledelayedExpansion

:: Force CMD Code Page to UTF-8 & Default Console to High-Intensity Yellow
chcp 65001 >nul 2>&1
color 0E

:: Enable ANSI Virtual Terminal Processing for RGB Colors
reg add "HKCU\Console" /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1

:: Define ANSI TrueColor Escapes (Fire-Gem Orange to Bright Yellow Gradient)
for /f %%a in ('echo prompt $E^|cmd') do set "E=%%a"
set "RESET=!E![0m"
set "BG_GLASS=!E![48;2;10;10;12m"
set "O1=!E![38;2;255;68;0m"
set "O2=!E![38;2;255;110;0m"
set "O3=!E![38;2;255;153;0m"
set "Y1=!E![38;2;255;200;0m"
set "Y2=!E![38;2;255;235;0m"
set "TXT=!E![38;2;240;240;240m"

cls
echo !BG_GLASS!
cls

:: =========================================================================
:: DARKCOM2 FIRE-GEM BANNER (UNINSTALLER)
:: =========================================================================
echo.
echo %O1%    ██████╗  █████╗ ██████╗ ██╗  ██╗ ██████╗ ██████╗ ███╗   ███╗██████╗ %RESET%%BG_GLASS%
echo %O2%    ██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝██╔════╝██╔═══██╗████╗ ████║╚════██╗%RESET%%BG_GLASS%
echo %O3%    ██║  ██║███████║██████╔╝█████╔╝ ██║     ██║   ██║██╔████╔██║ █████╔╝%RESET%%BG_GLASS%
echo %Y1%    ██║  ██║██╔══██║██╔══██╗██╔═██╗ ██║     ██║   ██║██║╚██╔╝██║██╔═══╝ %RESET%%BG_GLASS%
echo %Y2%    ██████╔╝██║  ██║██║  ██║██║  ██╗╚██████╗╚██████╔╝██║ ╚═╝ ██║███████╗%RESET%%BG_GLASS%
echo %Y2%    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝%RESET%%BG_GLASS%
echo %O2%============================================================%RESET%%BG_GLASS%
echo %Y2%              dc2URL :: UNINSTALLATION SUITE%RESET%%BG_GLASS%
echo %O2%============================================================%RESET%%BG_GLASS%
echo.

:: 1. CAPTURE ACTIVE DEPLOYMENT DIRECTORY CONTEXT
set "TARGET_DIR=%~dp0"
if "!TARGET_DIR:~-1!"=="\" set "TARGET_DIR=!TARGET_DIR:~0,-1!"
set "FINAL_EXEC_DIR=!TARGET_DIR!\exec"

:: 2. UNREGISTER PROTOCOL HANDLER WITH PROGRESS BAR
<nul set /p "=%Y1%   [....................]   0% - Removing web link handler...%RESET%%BG_GLASS%"
reg delete "HKCU\Software\Classes\dc2URL" /f >nul 2>&1
reg delete "HKLM\Software\Classes\dc2URL" /f >nul 2>&1
powershell -Command "$steps = 20; for($i=1; $i -le $steps; $i++){$p=[math]::Floor(($i/$steps)*100); $b='#'*$i + '.'*($steps-$i); Write-Host -NoNewline \"`r   [ $b ] $p%% - Removing web link handler...     \"; Start-Sleep -Milliseconds 15}"
echo.
echo          Web link registration removed.

:: 3. REMOVE REGISTRY PATH ENTRY WITH PROGRESS BAR
<nul set /p "=%Y1%   [....................]   0% - Cleaning environment variables...%RESET%%BG_GLASS%"
reg delete "HKCU\Environment" /v dc2url_path /f >nul 2>&1
powershell -Command "$steps = 20; for($i=1; $i -le $steps; $i++){$p=[math]::Floor(($i/$steps)*100); $b='#'*$i + '.'*($steps-$i); Write-Host -NoNewline \"`r   [ $b ] $p%% - Cleaning environment variables...  \"; Start-Sleep -Milliseconds 15}"
echo.
echo          Environment variables cleaned.

:: 4. CLEAN UP WRAPPER SHORTCUT WITH PROGRESS BAR
<nul set /p "=%Y1%   [....................]   0% - Removing command shortcuts...%RESET%%BG_GLASS%"
if exist "!FINAL_EXEC_DIR!\dc2url.bat" del /f /q "!FINAL_EXEC_DIR!\dc2url.bat" >nul 2>&1
powershell -Command "$steps = 20; for($i=1; $i -le $steps; $i++){$p=[math]::Floor(($i/$steps)*100); $b='#'*$i + '.'*($steps-$i); Write-Host -NoNewline \"`r   [ $b ] $p%% - Removing command shortcuts...    \"; Start-Sleep -Milliseconds 15}"
echo.
echo          Command shortcuts removed.

:: 5. REFRESH ENVIRONMENT CACHE WITH PROGRESS BAR
<nul set /p "=%Y1%   [....................]   0% - Refreshing system cache...%RESET%%BG_GLASS%"
powershell -Command "[System.Environment]::SetEnvironmentVariable('PATH', [System.Environment]::GetEnvironmentVariable('PATH', 'User'), 'User')" >nul 2>&1
powershell -Command "$steps = 20; for($i=1; $i -le $steps; $i++){$p=[math]::Floor(($i/$steps)*100); $b='#'*$i + '.'*($steps-$i); Write-Host -NoNewline \"`r   [ $b ] $p%% - Refreshing system cache...       \"; Start-Sleep -Milliseconds 15}"
echo.
echo          System cache refreshed.

echo.
echo %O2%============================================================%RESET%%BG_GLASS%
echo %Y2%          UNINSTALLATION COMPLETED SUCCESSFULLY%RESET%%BG_GLASS%
echo %O2%============================================================%RESET%%BG_GLASS%
echo %TXT%dc2URL has been cleanly unregistered from your system.
echo Note: Core binary files in 'exec\' were left untouched.%RESET%%BG_GLASS%
echo.

:finish
echo Press any key to exit uninstaller...
pause >nul
exit /b 0