@echo off

:: InstallShield Subsystem: Force Elevated Administrative Token Context
:: -----------------------------------------------------------------------------
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' neq '0' ( goto :RequestUAC ) else ( goto :ExecuteUninstall )

:RequestUAC
    powershell -Command "Start-Process '%~f0' -Verb RunAs -WorkingDirectory '%~dp0'"
    exit /b

:ExecuteUninstall
setlocal EnableDelayedExpansion

:: =========================================================================
:: DIRECTORY RESOLUTION MAPPING (MANIFEST LAYOUT)
:: =========================================================================
set "ROOT_DIR=%~dp0"
set "VERSION_DIR=%ROOT_DIR%"
if "%VERSION_DIR:~-1%"=="\" set "VERSION_DIR=%VERSION_DIR:~0,-1%"

for %%I in ("%VERSION_DIR%") do set "VERSION_NAME=%%~nxI"
for %%I in ("%VERSION_DIR%\..") do set "BASE_DIR=%%~fI"

set "FINAL_EXEC_DIR=%VERSION_DIR%\exec"

title InstallShield (R) Uninstaller v1.0 :: dc2url Master Deployment Engine
mode con: cols=120 lines=34

chcp 65001 >nul 2>&1
color 0E

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
echo %O1%      ######   #####  ######  ##  ##  #####  ######  ###   ### ###### %RESET%%BG_GLASS%
echo %O2%      ##   ## ##   ## ##   ## ## ##   ##     ##   ## #### ####     ## %RESET%%BG_GLASS%
echo %O3%      ##   ## ####### ######  #####   ##     ##   ## ## ### ##  ##### %RESET%%BG_GLASS%
echo %Y1%      ##   ## ##   ## ##   ## ##  ##  ##     ##   ## ##     ##      ## %RESET%%BG_GLASS%
echo %Y2%      ######  ##   ## ##   ## ##  ##   #####  #####  ##     ## ####### %RESET%%BG_GLASS%
echo %O2%    ====================================================================================%RESET%%BG_GLASS%
echo %Y2%                        dc2url Core Cyborg Ecosystem Uninstaller%RESET%%BG_GLASS%
echo %O2%    ====================================================================================%RESET%%BG_GLASS%
echo.

echo %O2%        [*] Terminating active dc2url execution processes...%RESET%%BG_GLASS%
taskkill /f /im dc2url.exe >nul 2>&1

echo %O2%        [*] Removing Windows Registry App Paths and Uninstaller Keys...%RESET%%BG_GLASS%

for %%H in (HKLM HKCU) do (
    for %%N in ("" "\Wow6432Node") do (
        reg delete "%%H%%~N\Software\Microsoft\Windows\CurrentVersion\Uninstall\dc2url" /f >nul 2>&1
        reg delete "%%H%%~N\Software\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f >nul 2>&1
    )
)
reg delete "HKCU\Software\dc2url\Launcher" /f >nul 2>&1

echo %O2%        [*] Purging Environment Variable PATH entries...%RESET%%BG_GLASS%

reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "dc2url_path" /f >nul 2>&1

powershell -Command "$m=[System.Environment]::GetEnvironmentVariable('PATH','Machine'); $arr = $m -split ';' | Where-Object {$_ -ne '%FINAL_EXEC_DIR%'}; [System.Environment]::SetEnvironmentVariable('PATH', ($arr -join ';'), 'Machine')" >nul 2>&1
powershell -Command "$p=[System.Environment]::GetEnvironmentVariable('PATH','User'); $arr = $p -split ';' | Where-Object {$_ -ne '%FINAL_EXEC_DIR%'}; [System.Environment]::SetEnvironmentVariable('PATH', ($arr -join ';'), 'User')" >nul 2>&1

powershell -Command "$advapi = '[DllImport(\"user32.dll\",SetLastError=true)]public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, IntPtr wParam, String lParam, uint fuFlags, uint uTimeout, out IntPtr lpdwResult);'; $type = Add-Type -MemberDefinition $advapi -Name 'Win32' -Namespace 'Win32Functions' -PassThru; $res = [IntPtr]::Zero; [Win32Functions.Win32]::SendMessageTimeout([IntPtr]0xffff, 0x001A, [IntPtr]::Zero, 'Environment', 2, 5000, [out]$res)" >nul 2>&1

echo %O2%        [*] Cleaning up execution binaries and temporary files...%RESET%%BG_GLASS%

if exist "%FINAL_EXEC_DIR%" (
    rmdir /s /q "%FINAL_EXEC_DIR%" >nul 2>&1
)

echo                     [SUCCESS] dc2url has been completely uninstalled.
echo.

:finish
echo %Y2%        [INFO] Uninstallation sequence finalized successfully.%RESET%%BG_GLASS%
echo.
timeout /t 3 >nul
endlocal
exit /b 0
