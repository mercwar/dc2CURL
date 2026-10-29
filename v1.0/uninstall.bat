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

for %%I in ("%VERSION_DIR%") do set "VERSION_NAME=%%~nxI"
for %%I in ("%VERSION_DIR%\..") do set "BASE_DIR=%%~fI"

if exist "%VERSION_DIR%\exec" (
    set "FINAL_EXEC_DIR=%VERSION_DIR%\exec"
) else if exist "%BASE_DIR%\exec" (
    set "FINAL_EXEC_DIR=%BASE_DIR%\exec"
) else (
    set "FINAL_EXEC_DIR=%VERSION_DIR%\exec"
)

title InstallShield (R) Setup Launcher v1.0 :: dc2url Master Removal Engine
mode con: cols=120 lines=34

chcp 65001 >nul 2>&1
color 0C

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
echo %O1%        ====================================================================================%RESET%%BG_GLASS%
echo %Y2%                            dc2url Core Cyborg Ecosystem Uninstaller%RESET%%BG_GLASS%
echo %O2%        ====================================================================================%RESET%%BG_GLASS%
echo.

:: Terminate running instances to release locks
taskkill /f /im dc2url.exe >nul 2>&1
taskkill /f /im eclipse.exe >nul 2>&1

echo %O2%        [*] Unregistering OLE/COM Components...%RESET%%BG_GLASS%
if exist "%FINAL_EXEC_DIR%\DarkComHeadless.dll" (
    regsvr32.exe /u /s "%FINAL_EXEC_DIR%\DarkComHeadless.dll"
    echo                      [SUCCESS] Unregistered DarkComHeadless.dll.
)
if exist "%FINAL_EXEC_DIR%\WebView2Loader.dll" (
    regsvr32.exe /u /s "%FINAL_EXEC_DIR%\WebView2Loader.dll"
    echo                      [SUCCESS] Unregistered WebView2Loader.dll.
)

echo %O2%        [*] Deleting executable and headless binaries...%RESET%%BG_GLASS%
if exist "%FINAL_EXEC_DIR%\DarkComHeadless.dll" (
    del /f /q "%FINAL_EXEC_DIR%\DarkComHeadless.dll" >nul 2>&1
    echo                      [REMOVED] DarkComHeadless.dll
)
if exist "%FINAL_EXEC_DIR%\dc2url.exe" (
    del /f /q "%FINAL_EXEC_DIR%\dc2url.exe" >nul 2>&1
    echo                      [REMOVED] dc2url.exe
)
if exist "%FINAL_EXEC_DIR%\dc2url.bat" (
    del /f /q "%FINAL_EXEC_DIR%\dc2url.bat" >nul 2>&1
    echo                      [REMOVED] dc2url.bat
)

echo %O2%        [*] Purging Registry configurations and App Paths...%RESET%%BG_GLASS%

reg delete "HKCU\Software\dc2url" /f >nul 2>&1

reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f >nul 2>&1
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f >nul 2>&1
reg delete "HKCU\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f >nul 2>&1

for %%H in (HKLM HKCU) do (
    for %%N in ("" "\Wow6432Node") do (
        reg delete "%%H%%~N\Software\Microsoft\Windows\CurrentVersion\Uninstall\dc2url" /f >nul 2>&1
    )
)

REG delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "dc2url_path" /f >nul 2>&1
REG delete "HKCU\Environment" /v "dc2url_path" /f >nul 2>&1

echo %O2%        [*] Cleaning Environment PATH Variables...%RESET%%BG_GLASS%

powershell -Command "$m=[System.Environment]::GetEnvironmentVariable('PATH','Machine'); if($m -split ';' -contains '%FINAL_EXEC_DIR%'){ $filtered = ($m -split ';' | Where-Object { $_ -ne '%FINAL_EXEC_DIR%' }) -join ';'; [System.Environment]::SetEnvironmentVariable('PATH',$filtered,'Machine')}" >nul 2>&1
powershell -Command "$p=[System.Environment]::GetEnvironmentVariable('PATH','User'); if($p -split ';' -contains '%FINAL_EXEC_DIR%'){ $filtered = ($p -split ';' | Where-Object { $_ -ne '%FINAL_EXEC_DIR%' }) -join ';'; [System.Environment]::SetEnvironmentVariable('PATH',$filtered,'User')}" >nul 2>&1

powershell -Command "$advapi = '[DllImport(\"user32.dll\",SetLastError=true)]public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, IntPtr wParam, String lParam, uint fuFlags, uint uTimeout, out IntPtr lpdwResult);'; $type = Add-Type -MemberDefinition $advapi -Name 'Win32' -Namespace 'Win32Functions' -PassThru; $res = [IntPtr]::Zero; [Win32Functions.Win32]::SendMessageTimeout([IntPtr]0xffff, 0x001A, [IntPtr]::Zero, 'Environment', 2, 5000, [out]$res)" >nul 2>&1

echo.
echo                      [SUCCESS] Headless and executable files completely removed!
echo.
pause
exit /b 0
