@echo off
:: InstallShield Subsystem: Force Elevated Administrative Token Context
:: -----------------------------------------------------------------------------
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' neq '0' ( goto :RequestUAC ) else ( goto :ExecuteUninstaller )

:RequestUAC
    powershell -Command "Start-Process '%~f0' -Verb RunAs -WorkingDirectory '%~dp0'"
    exit

:ExecuteUninstaller
setlocal DisableDelayedExpansion

:: =========================================================================
:: DIRECTORY RESOLUTION MAPPING
:: =========================================================================
set "VERSION_DIR=%~dp0"
if "%VERSION_DIR:~-1%"=="\" set "VERSION_DIR=%VERSION_DIR:~0,-1%"

for %%I in ("%VERSION_DIR%") do set "VERSION_NAME=%%~nxI"
for %%I in ("%VERSION_DIR%\..") do set "BASE_DIR=%%~fI"

set "FINAL_EXEC_DIR=%VERSION_DIR%\exec"

title InstallShield Uninstaller :: dc2url Master Deployment Engine

mode con: cols=120 lines=36
chcp 65001 >nul 2>&1
color 0E

reg add "HKCU\Console" /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1
for /f %%a in ('echo prompt $E^|cmd') do set "E=%%a"
set "RESET=%E%[0m"
set "BG_GLASS=%E%[48;2;10;10;12m"
set "R1=%E%[38;2;255;68;0m"
set "R2=%E%[38;2;255;110;0m"
set "R3=%E%[38;2;255;153;0m"
set "Y1=%E%[38;2;255;200;0m"
set "Y2=%E%[38;2;255;235;0m"
set "TXT=%E%[38;2;240;240;240m"

cls
echo %BG_GLASS%
cls

echo.
echo %R1%        ███████╗ ██████╗██╗     ██╗██████╗ ███████╗███████╗%RESET%%BG_GLASS%
echo %R2%        ██╔════╝██╔════╝██║     ██║██╔══██╗██╔════╝██╔════╝%RESET%%BG_GLASS%
echo %R1%        █████╗  ██║     ██║     ██║██████╔╝███████╗█████╗  %RESET%%BG_GLASS%
echo %Y1%        ██╔══╝  ██║     ██║     ██║██╔═══╝ ╚════██║██╔══╝  %RESET%%BG_GLASS%
echo %Y2%        ███████╗╚██████╗███████╗██║██║     ███████║███████╗%RESET%%BG_GLASS%
echo %Y2%        ╚══════╝ ╚═════╝╚══════╝╚═╝╚═╝     ╚══════╝╚══════╝%RESET%%BG_GLASS%
echo %R2%    ====================================================================================%RESET%%BG_GLASS%
echo %Y2%                             dc2url Master Uninstaller Engine%RESET%%BG_GLASS%
echo %R2%    ====================================================================================%RESET%%BG_GLASS%
echo.

:: =========================================================================
:: 1. PROCESS TERMINATION & DLL UNREGISTRATION
:: =========================================================================
echo %R2%        [*] Closing active dc2url processes...%RESET%%BG_GLASS%
taskkill /f /im dc2url.exe >nul 2>&1

echo %R2%        [*] Unhooking system DLL components...%RESET%%BG_GLASS%
if exist "%FINAL_EXEC_DIR%\DarkComHeadless.dll" (
    regsvr32.exe /u /s "%FINAL_EXEC_DIR%\DarkComHeadless.dll" >nul 2>&1
    echo                      [OK] Removed DarkComHeadless.dll registration.
)
if exist "%FINAL_EXEC_DIR%\WebView2Loader.dll" (
    regsvr32.exe /u /s "%FINAL_EXEC_DIR%\WebView2Loader.dll" >nul 2>&1
    echo                      [OK] Removed WebView2Loader.dll registration.
)
echo.

:: =========================================================================
:: 2. REGISTRY & DOS COMMAND REGISTRATION CLEANUP
:: =========================================================================
echo %R2%        [*] Removing Windows Registry, App Paths, and DOS command registrations...%RESET%%BG_GLASS%

reg delete "HKCU\Software\Eclipse" /f >nul 2>&1

reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f >nul 2>&1
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f >nul 2>&1
reg delete "HKCU\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f >nul 2>&1

reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\dc2url" /f >nul 2>&1
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\dc2url" /f >nul 2>&1

:: Remove Command Processor AutoRun hooks and DOS command stubs
reg delete "HKCU\Software\Microsoft\Command Processor" /v AutoRun /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Command Processor" /v AutoRun /f >nul 2>&1

if exist "%LocalAppData%\Microsoft\WindowsApps\dc2url.exe" del /f /q "%LocalAppData%\Microsoft\WindowsApps\dc2url.exe" >nul 2>&1
if exist "%LocalAppData%\Microsoft\WindowsApps\dc2url.bat" del /f /q "%LocalAppData%\Microsoft\WindowsApps\dc2url.bat" >nul 2>&1
if exist "%SYSTEMROOT%\system32\dc2url.bat" del /f /q "%SYSTEMROOT%\system32\dc2url.bat" >nul 2>&1
if exist "%SYSTEMROOT%\dc2url.bat" del /f /q "%SYSTEMROOT%\dc2url.bat" >nul 2>&1

echo                      [OK] Windows Registry and DOS command linkages cleared.
echo.

:: =========================================================================
:: 3. ENVIRONMENT PATH PURGE & BROADCAST
:: =========================================================================
echo %R2%        [*] Removing dc2url from system environment variables...%RESET%%BG_GLASS%

reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v dc2url_path /f >nul 2>&1
reg delete "HKCU\Environment" /v dc2url_path /f >nul 2>&1
setx /M dc2url_path "" >nul 2>&1

powershell -Command "$m=[System.Environment]::GetEnvironmentVariable('PATH','Machine'); if($m -split ';' -contains '%FINAL_EXEC_DIR%'){$new=($m -split ';' | Where-Object {$_ -neq '%FINAL_EXEC_DIR%'}) -join ';'; [System.Environment]::SetEnvironmentVariable('PATH',$new,'Machine')}" >nul 2>&1
powershell -Command "$p=[System.Environment]::GetEnvironmentVariable('PATH','User'); if($p -split ';' -contains '%FINAL_EXEC_DIR%'){$new=($p -split ';' | Where-Object {$_ -neq '%FINAL_EXEC_DIR%'}) -join ';'; [System.Environment]::SetEnvironmentVariable('PATH',$new,'User')}" >nul 2>&1

powershell -Command "$advapi = '[DllImport(\"user32.dll\",SetLastError=true)]public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, IntPtr wParam, String lParam, uint fuFlags, uint uTimeout, out IntPtr lpdwResult);'; $type = Add-Type -MemberDefinition $advapi -Name 'Win32' -Namespace 'Win32Functions' -PassThru; $res = [IntPtr]::Zero; [Win32Functions.Win32]::SendMessageTimeout([IntPtr]0xffff, 0x001A, [IntPtr]::Zero, 'Environment', 2, 5000, [out]$res)" >nul 2>&1

echo                      [OK] System environment updated.
echo.

:: =========================================================================
:: 4. FILESYSTEM CLEANUP (FULL DIRECTORY WIPE)
:: =========================================================================
echo %R2%        [*] Deleting dc2url application files and folders...%RESET%%BG_GLASS%

cd /d "%TEMP%"

if exist "%BASE_DIR%" (
    start /b "" cmd /c "ping 127.0.0.1 -n 3 > nul & rmdir /s /q "%BASE_DIR%"" >nul 2>&1
    echo                      [OK] Deletion scheduled for base directory.
)

echo.
echo %R3%    ====================================================================================%RESET%%BG_GLASS%
echo %Y1%                             UNINSTALLATION COMPLETE%RESET%%BG_GLASS%
echo %R3%    ====================================================================================%RESET%%BG_GLASS%
echo.
echo %TXT%        dc2url and all associated DOS command stubs have been completely purged.%RESET%
echo.
pause
exit /b 0
