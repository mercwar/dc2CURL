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

:: Force working directory to script location
cd /d "%~dp0"

:: InstallShield Configuration Properties: Title Block & Bounds
title InstallShield (R) Setup Launcher v1.0 :: dc2url Uninstaller Matrix
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
echo %O2%    =====================================================================================%RESET%%BG_GLASS%
echo %Y2%                InstallShield (R) Setup Engine Uninstaller Block%RESET%%BG_GLASS%
echo %O2%    =====================================================================================%RESET%%BG_GLASS%
echo.

:: 1. TARGET ONLY THE EXEC FOLDER Safely
set "BASE_DIR=%~dp0"
if "%BASE_DIR:~-1%"=="\" set "BASE_DIR=%BASE_DIR:~0,-1%"

if exist "%BASE_DIR%\exec\" (
    set "TARGET_EXEC=%BASE_DIR%\exec"
) else (
    echo "%BASE_DIR%" | find /i "\exec" >nul 2>&1
    if %errorlevel% equ 0 (
        set "TARGET_EXEC=%BASE_DIR%"
    ) else (
        set "TARGET_EXEC=%BASE_DIR%\exec"
    )
)

echo %O2%        [*] Target Exec Directory: %TARGET_EXEC%%RESET%%BG_GLASS%

:: 2. TERMINATE RUNNING PROCESSES AND FLUSH PIPELINE HANDLES
echo %O2%        [*] Terminating active background processes...%RESET%%BG_GLASS%
taskkill /f /im dc2url.exe >nul 2>&1
taskkill /f /im darkcom2.exe >nul 2>&1
echo                 [CLEANED] Running application processes terminated.

:: 3. UNREGISTER COM OBJECTS FROM REGISTRY PIPELINE
echo %O2%        [*] Unregistering COM components from System OLE Registry...%RESET%%BG_GLASS%
if exist "%TARGET_EXEC%\DarkComHeadless.dll" (
    regsvr32.exe /u /s "%TARGET_EXEC%\DarkComHeadless.dll" >nul 2>&1
    echo                 [UNREGISTERED] DarkComHeadless.dll removed from system registry.
)

:: 4. SCRUB REGISTRY ENTRIES, MULTI-ARCH APP PATHS, & ENVIRONMENT KEYS
echo %O2%        [*] Scrubbing Windows Registry and Environment Blocks...%RESET%%BG_GLASS%

:: Wipe protocol context registration handlers across standard character casings
reg delete "HKLM\Software\Classes\dc2url" /f >nul 2>&1
reg delete "HKCU\Software\Classes\dc2url" /f >nul 2>&1
reg delete "HKLM\Software\Classes\dc2URL" /f >nul 2>&1
reg delete "HKCU\Software\Classes\dc2URL" /f >nul 2>&1

:: --- Native 64-bit App Paths Scrub ---
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f >nul 2>&1
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\App Paths\darkcom2.exe" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\App Paths\darkcom2.exe" /f >nul 2>&1

:: --- 32-bit WoW6432Node Redirector App Paths Scrub ---
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f >nul 2>&1
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\darkcom2.exe" /f >nul 2>&1
reg delete "HKCU\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f >nul 2>&1
reg delete "HKCU\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\darkcom2.exe" /f >nul 2>&1

:: Drop environment variable mappings
reg delete "HKCU\Environment" /v "dc2url_path" /f >nul 2>&1
reg delete "HKCU\Environment" /v "dc2URL_path" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "dc2url_path" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "dc2URL_path" /f >nul 2>&1
reg delete "HKCU\Volatile Environment" /v "PATH" /f >nul 2>&1

:: Clean environment paths safely matching context patterns case-insensitively
powershell -Command "$p=[System.Environment]::GetEnvironmentVariable('PATH','User'); if($p){$arr=($p -split ';') | Where-Object {$_ -and $_ -notlike '*dc2url*' -and $_ -notlike '*MERCWA*' -and $_ -ne '%TARGET_EXEC%'}; [System.Environment]::SetEnvironmentVariable('PATH',($arr -join ';'),'User')}" >nul 2>&1
powershell -Command "$p=[System.Environment]::GetEnvironmentVariable('PATH','Machine'); if($p){$arr=($p -split ';') | Where-Object {$_ -and $_ -notlike '*dc2url*' -and $_ -notlike '*MERCWA*' -and $_ -ne '%TARGET_EXEC%'}; [System.Environment]::SetEnvironmentVariable('PATH',($arr -join ';'),'Machine')}" >nul 2>&1

:: Broadcast WM_SETTINGCHANGE message globally to refresh environment variables instantly
powershell -Command "$advapi = '[DllImport(''user32.dll'',SetLastError=true)]public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, IntPtr wParam, String lParam, uint fuFlags, uint uTimeout, out IntPtr lpdwResult);'; $type = Add-Type -MemberDefinition $advapi -Name 'Win32' -Namespace 'Win32Functions' -PassThru; $result = [IntPtr]::Zero; [Win32Functions.Win32]::SendMessageTimeout([IntPtr]0xffff, 0x001A, [IntPtr]::Zero, 'Environment', 2, 5000, [out]$result)" >nul 2>&1

:: Delete the native windows suite application panel uninstall keys
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\dc2url" /f >nul 2>&1
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\dc2URL" /f >nul 2>&1

echo                 [SUCCESS] All multi-architecture registry keys and environment variables scrubbed.

:: 5. PURGE ONLY THE TARGET EXEC FOLDER CONTENTS safely
if not exist "%TARGET_EXEC%" goto :finish_uninstall

echo %O2%        [*] Removing exec folder and contents...%RESET%%BG_GLASS%

:: Wipe hidden system attributes to prevent removal locks
attrib -r -h -s "%TARGET_EXEC%\*.*" /s /d >nul 2>&1

:: Remove files inside target exec folder
del /f /q /a "%TARGET_EXEC%\*.*" >nul 2>&1

:: Remove subdirectories inside target exec folder if any exist
for /d %%p in ("%TARGET_EXEC%\*") do rmdir /s /q "%%p" >nul 2>&1

:: Remove target exec directory itself
rmdir /s /q "%TARGET_EXEC%" >nul 2>&1

if exist "%TARGET_EXEC%" (
    powershell -Command "Remove-Item -Path '%TARGET_EXEC%' -Recurse -Force" >nul 2>&1
)

if not exist "%TARGET_EXEC%" (
    echo                 [PURGED] %TARGET_EXEC% successfully deleted.
) else (
    echo                 [WARNING] Could not fully remove %TARGET_EXEC%.
)

:finish_uninstall
echo.
echo %Y2%        [UNINSTALLATION COMPLETED SYSTEM CLEANED]%RESET%
echo.

echo %TXT%        Press any key to close uninstaller suite...%RESET%
pause >nul
exit /b 0
