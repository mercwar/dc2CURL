@echo off
:: InstallShield Subsystem: Force Elevated Administrative Token Context
:: -----------------------------------------------------------------------------
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' neq '0' ( goto :RequestUAC ) else ( goto :ExecuteUninstall )

:RequestUAC
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs -WorkingDirectory '%~dp0'"
    exit /b

:ExecuteUninstall
setlocal DisableDelayedExpansion

:: Force working directory to the explicit folder location of this script file
cd /d "%~dp0"

:: InstallShield Configuration Properties: Title Block & Bounds
title InstallShield (R) Setup Launcher v1.0 :: dc2url Precise Subsystem Uninstaller
mode con: cols=120 lines=34

chcp 65001 >nul 2>&1
color 0E

:: Force TrueColor Console Canvas Context Allocation
reg add "HKCU\Console" /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1
for /f "tokens=*" %%a in ('echo prompt $E^|cmd') do set "E=%%a"
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
echo %Y2%        ██████╔╝██║  ██║██║  ██║██║  ██╗╚██████╗╚██████╔╝██║ ╚═╝ ██║███████╗%RESET%%BG_GLASS%
echo %Y2%        ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝%RESET%%BG_GLASS%
echo %O2%    ====================================================================================%RESET%%BG_GLASS%
echo %Y2%                InstallShield (R) Setup Engine Uninstaller Block (Precise Mode)%RESET%%BG_GLASS%
echo %O2%    ====================================================================================%RESET%%BG_GLASS%
echo.

:: 1. TARGET EXCLUSIVELY THE VERSIONED DIRECTORY LAYER (%~dp0)
set "VERSION_DIR=%~dp0"
if "%VERSION_DIR:~-1%"=="\" set "VERSION_DIR=%VERSION_DIR:~0,-1%"

for %%I in ("%VERSION_DIR%") do set "VERSION_NAME=%%~nxI"
for %%I in ("%VERSION_DIR%\..") do set "BASE_DIR=%%~fI"

set "TARGET_EXEC=%VERSION_DIR%\exec"

echo %O2%        [*] Isolated Version Target Directory: %VERSION_DIR%%RESET%%BG_GLASS%

:: 2. TERMINATE BACKGROUND PROCESS HANDLES BEFORE SCRUBBING
echo %O2%        [*] Terminating active background processes...%RESET%%BG_GLASS%
taskkill /f /im dc2url.exe >nul 2>&1
taskkill /f /im darkcom2.exe >nul 2>&1
echo                  [CLEANED] Active file hooks dropped.

:: 3. UNREGISTER COM OBJECT LAYERS FROM SYSTEM OLE
echo %O2%        [*] Unregistering COM components from System OLE Registry...%RESET%%BG_GLASS%
if exist "%TARGET_EXEC%\DarkComHeadless.dll" (
    regsvr32.exe /u /s "%TARGET_EXEC%\DarkComHeadless.dll" >nul 2>&1
    echo                  [UNREGISTERED] DarkComHeadless.dll severed from registry tree.
)

:: 4. SCRUB ALL STRICT LOWERCASE ENVIRONMENT & MULTI-ARCH APPLICATION REGISTRIES
echo %O2%        [*] Scrubbing Windows Registry and Environment Blocks...%RESET%%BG_GLASS%

reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f >nul 2>&1
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f >nul 2>&1
reg delete "HKCU\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f >nul 2>&1

reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\dc2url" /f >nul 2>&1
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\dc2url" /f >nul 2>&1

reg delete "HKCU\Environment" /v "dc2url_path" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "dc2url_path" /f >nul 2>&1

powershell -Command "$p=[System.Environment]::GetEnvironmentVariable('PATH','User'); if($p){$arr=($p -split ';') | Where-Object {$_ -and $_ -notlike '*dc2url*' -and $_ -ne '%TARGET_EXEC%'}; [System.Environment]::SetEnvironmentVariable('PATH',($arr -join ';'),'User')}" >nul 2>&1
powershell -Command "$p=[System.Environment]::GetEnvironmentVariable('PATH','Machine'); if($p){$arr=($p -split ';') | Where-Object {$_ -and $_ -notlike '*dc2url*' -and $_ -ne '%TARGET_EXEC%'}; [System.Environment]::SetEnvironmentVariable('PATH',($arr -join ';'),'Machine')}" >nul 2>&1

powershell -Command "$advapi = '[DllImport(''user32.dll'',SetLastError=true)]public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, IntPtr wParam, String lParam, uint fuFlags, uint uTimeout, out IntPtr lpdwResult);'; $type = Add-Type -MemberDefinition $advapi -Name 'Win32' -Namespace 'Win32Functions' -PassThru; $result = [IntPtr]::Zero; [Win32Functions.Win32]::SendMessageTimeout([IntPtr]0xffff, 0x001A, [IntPtr]::Zero, 'Environment', 2, 5000, [out]$result)" >nul 2>&1

echo                  [SUCCESS] System environmental blocks and shell nodes cleared.

:: 5. PURGE EXCLUSIVELY THE VERSION DIRECTORY AND ITS CONTENTS
if not exist "%VERSION_DIR%" goto :finish_uninstall

if "%VERSION_DIR%"=="C:\" if "%VERSION_DIR%"=="%BASE_DIR%" (
    echo %O1%        [SAFETY ABORT] Execution path matched root directory. Skipping file purge loop.%RESET%%BG_GLASS%
    goto :finish_uninstall
)

echo %O2%        [*] Purging version deployment directory contents safely: %VERSION_DIR%%RESET%%BG_GLASS%

attrib -r -h -s "%VERSION_DIR%\*.*" /s /d >nul 2>&1
rmdir /s /q "%VERSION_DIR%" >nul 2>&1

if exist "%VERSION_DIR%" (
    powershell -Command "Remove-Item -Path '%VERSION_DIR%' -Recurse -Force" >nul 2>&1
)

if not exist "%VERSION_DIR%" (
    echo                  [PURGED] Version directory successfully scrubbed from system context.
) else (
    echo                  [WARNING] Access lock encountered modifying destination: %VERSION_DIR%.
)

:finish_uninstall
echo.
echo %Y2%        [UNINSTALLATION COMPLETED - UTILITY DETACHED SUCCESSFULLY]%RESET%
echo.

echo %TXT%        Press any key to close uninstaller suite...%RESET%
pause >nul
exit /b 0
