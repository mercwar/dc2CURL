@echo off
:: InstallShield Subsystem: Force Elevated Administrative Token Context
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' neq '0' ( goto :RequestUAC ) else ( goto :ExecuteTeardown )

:RequestUAC
    powershell -Command "Start-Process '%~f0' -Verb RunAs -WorkingDirectory '%~dp0'"
    exit /b

:ExecuteTeardown
setlocal EnableDelayedExpansion

for /f %%a in ('echo prompt $E^|cmd') do set "E=%%a"
set "RESET=%E%[0m"
set "BG_GLASS=%E%[48;2;10;10;12m"
set "O2=%E%[38;2;255;110;0m"
set "Y2=%E%[38;2;255;235;0m"

title InstallShield (R) Setup Launcher :: Eclipse Clean Reversal Engine
mode con: cols=120 lines=34
chcp 65001 >nul 2>&1

cls
echo %BG_GLASS%
cls

echo.
echo %O2%    ====================================================================================%RESET%%BG_GLASS%
echo %Y2%                        Eclipse Reversal & Deregistration Pipeline%RESET%%BG_GLASS%
echo %O2%    ====================================================================================%RESET%%BG_GLASS%
echo.

echo %O2%    [*] Terminating run-time processes...%RESET%%BG_GLASS%
taskkill /f /im eclipse.exe >nul 2>&1

echo %O2%    [*] Stripping registration nodes for installer configuration...%RESET%%BG_GLASS%
:: Explicitly remove keys from both views to guarantee clean removal from Add/Remove Programs
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\Eclipse" /f /reg:64 >nul 2>&1
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\Eclipse" /f /reg:32 >nul 2>&1
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Eclipse" /f /reg:64 >nul 2>&1
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Eclipse" /f /reg:32 >nul 2>&1

echo %O2%    [*] Purging system environment configuration variable...%RESET%%BG_GLASS%
reg delete "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /v "eclipse_path" /f /reg:64 >nul 2>&1
reg delete "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /v "eclipse_path" /f /reg:32 >nul 2>&1

:: =========================================================================
:: TARGETED BINARY RETRIEVAL EXTINCTION (ICON ABSOLUTE PRESERVATION)
:: =========================================================================
echo %O2%    [*] Purging operational binary assets...%RESET%%BG_GLASS%
set "TARGET=%ProgramFiles%\dc2url"

:: Process version subdirectories dynamically to find the deployment layout
for /d %%V in ("%TARGET%\*") do (
    set "VERSION_DIR=%%V"
    set "EXEC_DIR=!VERSION_DIR!\exec"
    
    :: Remove exactly the deployed executable and layout files
    if exist "!EXEC_DIR!\eclipse.exe" del /f /q "!EXEC_DIR!\eclipse.exe" >nul 2>&1
    if exist "!EXEC_DIR!\menu.json" del /f /q "!EXEC_DIR!\menu.json" >nul 2>&1
 
    
    :: Clean up folder trees only if they contain no custom user files or icons
    rmdir "!EXEC_DIR!" >nul 2>&1
    rmdir "!VERSION_DIR!" >nul 2>&1
)

echo.
echo %Y2%    [SUCCESS] Registration paths cleaned. Binary runtime components removed.%RESET%%BG_GLASS%
pause
exit /b 0
