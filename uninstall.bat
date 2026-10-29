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

:: =========================================================================
:: DIRECTORY RESOLUTION MAPPING
:: =========================================================================
set "VERSION_DIR=%~dp0"
if "%VERSION_DIR:~-1%"=="\" set "VERSION_DIR=%VERSION_DIR:~0,-1%"

if exist "%ProgramFiles%" (
    set "TARGET_BASE=%ProgramFiles%\dc2url\v1.0"
) else (
    set "TARGET_BASE=C:\Program Files\dc2url\v1.0"
)

set "FINAL_EXEC_DIR=%TARGET_BASE%\exec"
set "FINAL_EXE_PATH=%FINAL_EXEC_DIR%\eclipse.exe"
set "MENU_JSON_PATH=%FINAL_EXEC_DIR%\menu.json"
set "BATCH_PATH=%FINAL_EXEC_DIR%\eclipse.bat"

title InstallShield (R) Uninstaller v1.0 :: Eclipse Tray Master Removal Engine
mode con: cols=120 lines=34

chcp 65001 >nul 2>&1
color 0C

reg add "HKCU\Console" /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1
for /f %%a in ('echo prompt $E^|cmd') do set "E=%%a"
set "RESET=%E%[0m"
set "BG_GLASS=%E%[48;2;10;10;12m"
set "R1=%E%[38;2;255,68,0m"
set "R2=%E%[38;2;255,110,0m"
set "Y1=%E%[38;2;255,200,0m"
set "Y2=%E%[38;2;255,235,0m"
set "TXT=%E%[38;2;240,240,240m"

cls
echo %BG_GLASS%
cls

echo.
echo %R1%        ███████╗ ██████╗██╗    ██╗██████╗ ███████╗███████╗%RESET%%BG_GLASS%
echo %R2%        ██╔════╝██╔════╝██║    ██║██╔══██╗██╔════╝██╔════╝%RESET%%BG_GLASS%
echo %R1%        █████╗  ██║     ██║    ██║██████╔╝███████╗███████╗%RESET%%BG_GLASS%
echo %Y1%        ██╔══╝  ██║     ██║    ██║██╔═══╝ ╚════██║╚════██║%RESET%%BG_GLASS%
echo %Y2%        ███████╗╚██████╗███████╗██║██║     ███████║███████║%RESET%%BG_GLASS%
echo %Y2%        ╚══════╝ ╚═════╝╚══════╝╚═╝╚═╝     ╚══════╝╚══════╝%RESET%%BG_GLASS%
echo %R1%    ====================================================================================%RESET%%BG_GLASS%
echo %Y2%               Eclipse Tray Master :: Ecosystem Removal & Cleanup%RESET%%BG_GLASS%
echo %R1%    ====================================================================================%RESET%%BG_GLASS%
echo.

:: =========================================================================
:: TERMINATE ACTIVE PROCESSES
:: =========================================================================
echo %R2%        [*] Terminating active instances of eclipse.exe...%RESET%%BG_GLASS%
taskkill /f /im eclipse.exe >nul 2>&1

:: =========================================================================
:: PURGE DEPLOYED FILES & DIRECTORIES
:: =========================================================================
echo %R2%        [*] Purging binaries, configs, and application assets...%RESET%%BG_GLASS%
if exist "%FINAL_EXE_PATH%" del /f /q "%FINAL_EXE_PATH%" >nul 2>&1
if exist "%MENU_JSON_PATH%" del /f /q "%MENU_JSON_PATH%" >nul 2>&1
if exist "%BATCH_PATH%" del /f /q "%BATCH_PATH%" >nul 2>&1

if exist "%FINAL_EXEC_DIR%" rmdir /s /q "%FINAL_EXEC_DIR%" >nul 2>&1
if exist "%TARGET_BASE%" rmdir /s /q "%TARGET_BASE%" >nul 2>&1

:: =========================================================================
:: CLEANUP WINDOWS REGISTRY APP PATHS & UNINSTALL KEYS
:: =========================================================================
echo %R2%        [*] Cleaning up Windows registry entries and App Paths...%RESET%%BG_GLASS%

reg delete "HKCU\Software\Eclipse\Launcher" /f >nul 2>&1
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\App Paths\eclipse.exe" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\App Paths\eclipse.exe" /f >nul 2>&1
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\eclipse.exe" /f >nul 2>&1
reg delete "HKCU\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\eclipse.exe" /f >nul 2>&1

reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\EclipseTray" /f >nul 2>&1
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\EclipseTray" /f >nul 2>&1

:: =========================================================================
:: REMOVE ENVIRONMENT VARIABLES
:: =========================================================================
echo %R2%        [*] Removing environment variables and refreshing shell paths...%RESET%%BG_GLASS%
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "eclipse_path" /f >nul 2>&1
reg delete "HKCU\Environment" /v "eclipse_path" /f >nul 2>&1

:: Broadcast environment change to system
powershell -Command "$advapi = '[DllImport(\"user32.dll\",SetLastError=true)]public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, IntPtr wParam, String lParam, uint fuFlags, uint uTimeout, out IntPtr lpdwResult);'; $type = Add-Type -MemberDefinition $advapi -Name 'Win32' -Namespace 'Win32Functions' -PassThru; $res = [IntPtr]::Zero; [Win32Functions.Win32]::SendMessageTimeout([IntPtr]0xffff, 0x001A, [IntPtr]::Zero, 'Environment', 2, 5000, [out]$res)" >nul 2>&1

echo.
echo %R1%    ====================================================================================%RESET%%BG_GLASS%
echo %Y2%                       UNINSTALLATION & CLEANUP SUCCESSFUL%RESET%%BG_GLASS%
echo %R1%    ====================================================================================%RESET%%BG_GLASS%
echo.
echo %TXT%        Eclipse Tray Master has been completely removed from your system.%RESET%
echo.
pause
exit /b 0
