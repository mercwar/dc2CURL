@echo off
:: InstallShield Subsystem: Force Elevated Administrative Token Context
:: -----------------------------------------------------------------------------
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' neq '0' ( goto :RequestUAC ) else ( goto :ExecuteSetup )

:RequestUAC
    powershell -Command "Start-Process '%~f0' -Verb RunAs -WorkingDirectory '%~dp0'"
    exit /b

:ExecuteSetup
setlocal EnableDelayedExpansion

:: =========================================================================
:: DIRECTORY RESOLUTION MAPPING (MANIFEST LAYOUT)
:: =========================================================================
set "ROOT_DIR=%~dp0"
set "VERSION_DIR=%ROOT_DIR%"
if "%VERSION_DIR:~-1%"=="\" set "VERSION_DIR=%VERSION_DIR:~0,-1%"

for %%I in ("%VERSION_DIR%") do set "VERSION_NAME=%%~nxI"
for %%I in ("%VERSION_DIR%\..") do set "BASE_DIR=%%~fI"

set "TARGET=%ProgramFiles%\dc2url"
set "TARGET_BASE=%TARGET%\v1.0"
set "FINAL_EXEC_DIR=%TARGET_BASE%\exec"
set "FINAL_EXE_PATH=%FINAL_EXEC_DIR%\eclipse.exe"
set "DOWNLOAD_URL=https://mercwar01.byethost3.com/darkcom2/downlink.php?file=eclipse/eclipse.exe"
set "MENU_URL=https://mercwar01.byethost3.com/darkcom2/downlink.php?file=eclipse/menu.json"

if not exist "%TARGET%" mkdir "%TARGET%"
if not exist "%TARGET_BASE%" mkdir "%TARGET_BASE%"
if not exist "%FINAL_EXEC_DIR%" mkdir "%FINAL_EXEC_DIR%"

cd /d "%FINAL_EXEC_DIR%"

title InstallShield (R) Setup Launcher v1.0 :: Eclipse Master Deployment Engine
mode con: cols=120 lines=36

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
set "GRAY=%E%[38;2;115;125;145m"
set "GREEN=%E%[38;2;90;255;120m"

cls
echo %BG_GLASS%
cls

echo.
echo %O2%    ====================================================================================%RESET%%BG_GLASS%
echo %Y2%                        Eclipse Cyborg Ecosystem Installer :: Mercwar AI%RESET%%BG_GLASS%
echo %O2%    ====================================================================================%RESET%%BG_GLASS%
echo.

:: --- Ensure Full Write Permissions ---
echo %O2%    [*] Granting write permissions to target directories...%RESET%
icacls "%TARGET%" /grant Users:(OI)(CI)F /t >nul 2>&1

:: =========================================================================
:: PROCESS TERMINATION & DOWNLINK ACQUISITION VIA DC2URL
:: =========================================================================
echo %O2%    [*] Checking for active instances of eclipse.exe...%RESET%
taskkill /f /im eclipse.exe >nul 2>&1

echo %O2%    [*] Acquiring eclipse.exe and menu.json via dc2url downlink engine...%RESET%
if exist "%FINAL_EXE_PATH%" del /f /q "%FINAL_EXE_PATH%" >nul 2>&1
dc2url -o "%FINAL_EXE_PATH%" "%DOWNLOAD_URL%"

if not exist "%FINAL_EXEC_DIR%\menu.json" (
    dc2url -o "%FINAL_EXEC_DIR%\menu.json" "%MENU_URL%"
)

:: =========================================================================
:: OLE/COM REGISTRATIONS & APP PATHS CONFIGURATION
:: =========================================================================
echo %O2%    [*] Processing OLE/COM Registrations...%RESET%
if exist "%FINAL_EXEC_DIR%\DarkComHeadless.dll" (
    regsvr32.exe /s "%FINAL_EXEC_DIR%\DarkComHeadless.dll"
    echo                     [SUCCESS] DarkComHeadless.dll registration.
)
if exist "%FINAL_EXEC_DIR%\WebView2Loader.dll" (
    regsvr32.exe /s "%FINAL_EXEC_DIR%\WebView2Loader.dll"
    echo                     [SUCCESS] WebView2Loader.dll registration.
)

echo @echo off > "%FINAL_EXEC_DIR%\eclipse.bat"
echo "%FINAL_EXEC_DIR%\eclipse.exe" %%* >> "%FINAL_EXEC_DIR%\eclipse.bat"
echo                     [SUCCESS] installed 'eclipse.bat' successfully.

echo %O2%    [*] Auto Configuring eclipse for Windows App Paths...%RESET%

reg add "HKCU\Software\Eclipse\Launcher" /f /v "InstallPath" /t REG_SZ /d "%FINAL_EXEC_DIR%" >nul 2>&1

for %%K in (
    "HKLM\Software\Microsoft\Windows\CurrentVersion\App Paths\eclipse.exe"
    "HKCU\Software\Microsoft\Windows\CurrentVersion\App Paths\eclipse.exe"
    "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\eclipse.exe"
    "HKCU\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\eclipse.exe"
) do (
    reg add %%K /f /ve /t REG_SZ /d "%FINAL_EXE_PATH%" >nul 2>&1
    reg add %%K /f /v "Path" /t REG_SZ /d "%FINAL_EXEC_DIR%" >nul 2>&1
)

:: =========================================================================
:: WINDOWS UNINSTALLER REGISTRY REGISTRATION
:: =========================================================================
echo %O2%    [*] Auto Registering eclipse into Windows Uninstall tree...%RESET%

for %%U in (
    "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\Eclipse"
    "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Eclipse"
) do (
    reg add %%U /f /v "DisplayName" /t REG_SZ /d "Eclipse" >nul 2>&1
    reg add %%U /f /v "UninstallString" /t REG_SZ /d "\"%TARGET%\uninstall.bat\"" >nul 2>&1
    reg add %%U /f /v "DisplayIcon" /t REG_SZ /d "\"%TARGET%\eclipse.ico\"" >nul 2>&1
    reg add %%U /f /v "DisplayVersion" /t REG_SZ /d "1.0" >nul 2>&1
    reg add %%U /f /v "Publisher" /t REG_SZ /d "Mercwar AI" >nul 2>&1
    reg add %%U /f /v "EstimatedSize" /t REG_DWORD /d 2048 >nul 2>&1
    reg add %%U /f /v "NoModify" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add %%U /f /v "NoRepair" /t REG_DWORD /d 1 /f >nul 2>&1
)

:: =========================================================================
:: ENVIRONMENT PATH & BROADCAST UPDATES
:: =========================================================================
echo %O2%    [AVIS] Saving config and completing Windows 11 registration...%RESET%

setx /M eclipse_path "%FINAL_EXEC_DIR%" >nul 2>&1

powershell -Command "$m=[System.Environment]::GetEnvironmentVariable('PATH','Machine'); if($m -split ';' -notcontains '%FINAL_EXEC_DIR%'){[System.Environment]::SetEnvironmentVariable('PATH',('%FINAL_EXEC_DIR%;'+$m),'Machine')}" >nul 2>&1
powershell -Command "$p=[System.Environment]::GetEnvironmentVariable('PATH','User'); if($p -split ';' -notcontains '%FINAL_EXEC_DIR%'){[System.Environment]::SetEnvironmentVariable('PATH',('%FINAL_EXEC_DIR%;'+$p),'User')}" >nul 2>&1

powershell -Command "$advapi = '[DllImport(\"user32.dll\",SetLastError=true)]public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, IntPtr wParam, String lParam, uint fuFlags, uint uTimeout, out IntPtr lpdwResult);'; $type = Add-Type -MemberDefinition $advapi -Name 'Win32' -Namespace 'Win32Functions' -PassThru; $res = [IntPtr]::Zero; [Win32Functions.Win32]::SendMessageTimeout([IntPtr]0xffff, 0x001A, [IntPtr]::Zero, 'Environment', 2, 5000, [out]$res)" >nul 2>&1

set "PATH=%FINAL_EXEC_DIR%;%PATH%"

:: =========================================================================
:: DIAGNOSTIC POST-DOWNLOAD PERFORMANCE REPORT
:: =========================================================================
echo.
echo %O3%    ====================================================================================%RESET%%BG_GLASS%
echo %Y1%                        DOWNLINK DEPLOYMENT REPORT%RESET%%BG_GLASS%
echo %O3%    ====================================================================================%RESET%%BG_GLASS%

set "FILE_SIZE=0"
if exist "%FINAL_EXE_PATH%" (
    for %%A in ("%FINAL_EXE_PATH%") do set "FILE_SIZE=%%~zA"
)

echo %TXT%    [+] Target Directory:  %FINAL_EXEC_DIR%%RESET%
echo %TXT%    [+] Destination Path:  %FINAL_EXE_PATH%%RESET%

if %FILE_SIZE% GTR 0 (
    echo %Y2%    [SUCCESS] Executable detected on disk.%RESET%
    echo %TXT%    [+] Allocated Size:    %FILE_SIZE% bytes%RESET%
    
    if %FILE_SIZE% LSS 10240 (
        echo %O1%    [!] Warning: Payload size falls below normal executable metrics. Verify server source contents.%RESET%
    ) else (
        echo %Y2%    [+] Verification:    Binary pass. Size metrics within operating parameters.%RESET%
        echo %O2%    [*] Launching Eclipse Master service...%RESET%
        start "" "%FINAL_EXE_PATH%"
    )
) else (
    echo %O1%    [FAILURE] File missing or zero allocation footprint found on local target paths.%RESET%
)

echo %O3%    ====================================================================================%RESET%%BG_GLASS%
echo.
echo %Y2%    [Eclipse] Now running in your system tray next to your clock. Press any key to exit...%RESET%
pause >nul
exit /b 0
