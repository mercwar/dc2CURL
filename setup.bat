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
:: DIRECTORY RESOLUTION MAPPING & CONFIG.JSON VERSION DISCOVERY
:: =========================================================================
set "ROOT_DIR=%~dp0"
set "CONFIG_URL=https://githubusercontent.com"
set "TEMP_CONFIG=%TEMP%\dc2url_config.json"

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
echo. 
echo  %O2%  [Eclipse] Downloading current version, please wait..%RESET%%BG_GLASS%

if exist "%TEMP_CONFIG%" del /f /q "%TEMP_CONFIG%" >nul 2>&1
dc2url -l "%CONFIG_URL%" -nojs -o "%TEMP_CONFIG%"

set "VERSION_TAG=v1.0"
if exist "%TEMP_CONFIG%" (
    for /f "delims=" %%v in ('powershell -Command "$json = Get-Content '%TEMP_CONFIG%' -Raw | ConvertFrom-Json; if($json.version) { Write-Output $json.version }" 2^>nul') do (
        set "VERSION_TAG=%%v"
    )
    del /f /q "%TEMP_CONFIG%" >nul 2>&1
)

echo [+] Discovered Version Path Mapping: %VERSION_TAG% 

set "TARGET=%ProgramFiles%\dc2url"
set "TARGET_BASE=%TARGET%\%VERSION_TAG%"
set "FINAL_EXEC_DIR=%TARGET_BASE%\exec"
set "FINAL_EXE_PATH=%FINAL_EXEC_DIR%\eclipse.exe"
set "DOWNLOAD_URL=https://byethost3.com"
set "MENU_URL=https://byethost3.com"

if not exist "%TARGET%" mkdir "%TARGET%"
if not exist "%TARGET_BASE%" mkdir "%TARGET_BASE%"
if not exist "%FINAL_EXEC_DIR%" mkdir "%FINAL_EXEC_DIR%"

cd /d "%FINAL_EXEC_DIR%"

title InstallShield (R) Setup Launcher :: Eclipse Master Deployment Engine (%VERSION_TAG%)
mode con: cols=120 lines=36

chcp 65001 >nul 2>&1
color 0E

reg add "HKCU\Console" /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1

cls
echo %BG_GLASS%
cls

echo.
echo %O2%    ====================================================================================%RESET%%BG_GLASS%
echo %Y2%                        Eclipse Ecosystem Installer :: Version %VERSION_TAG%%RESET%%BG_GLASS%
echo %O2%    ====================================================================================%RESET%%BG_GLASS%
echo.

:: --- Ensure Full Write Permissions ---
echo %O2%    [*] Granting write permissions to target directories...%RESET%
icacls "%TARGET%" /grant Users:(OI)(CI)F /t >nul 2>&1

:: =========================================================================
:: DOWNLINK ACQUISITION VIA DC2URL (-nojs Fast Path)
:: =========================================================================
echo %O2%    [*] Checking for active instances of eclipse.exe...%RESET%
taskkill /f /im eclipse.exe >nul 2>&1

echo %O2%    [*] Acquiring eclipse.exe and menu.json via dc2url downlink engine...%RESET%
if exist "%FINAL_EXE_PATH%" del /f /q "%FINAL_EXE_PATH%" >nul 2>&1

dc2url -l "%DOWNLOAD_URL%" -o "%FINAL_EXE_PATH%"

if not exist "%FINAL_EXEC_DIR%\menu.json" (
    dc2url -l "%MENU_URL%"  -o "%FINAL_EXEC_DIR%\menu.json"
)

:: =========================================================================
:: ICON DETECTION AND HANDLING
:: =========================================================================
if exist "%TARGET%\eclipse.ico" (
    echo %O2%    [*] Copying eclipse.ico resources into exec tree...%RESET%
    copy /y "%TARGET%\eclipse.ico" "%FINAL_EXEC_DIR%\eclipse.ico" >nul 2>&1
) else if exist "%ROOT_DIR%\eclipse.ico" (
    echo %O2%    [*] Staging eclipse.ico resources from working archive...%RESET%
    copy /y "%ROOT_DIR%\eclipse.ico" "%TARGET%\eclipse.ico" >nul 2>&1
    copy /y "%ROOT_DIR%\eclipse.ico" "%FINAL_EXEC_DIR%\eclipse.ico" >nul 2>&1
)

:: =========================================================================
:: WINDOWS REGISTRATION & ADD/REMOVE PROGRAMS SEEDING
:: =========================================================================
echo %O2%    [*] Injecting uninstaller context tokens to system tree...%RESET%
for %%U in (
    "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\Eclipse"
    "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Eclipse"
) do (
    reg add %%U /f /v "DisplayName" /t REG_SZ /d "Eclipse %VERSION_TAG%" >nul 2>&1
    reg add %%U /f /v "UninstallString" /t REG_SZ /d "\"%TARGET%\uninstall.bat\"" >nul 2>&1
    reg add %%U /f /v "DisplayVersion" /t REG_SZ /d "%VERSION_TAG%" >nul 2>&1
    reg add %%U /f /v "Publisher" /t REG_SZ /d "Mercwar AI" >nul 2>&1
    if exist "%FINAL_EXEC_DIR%\eclipse.ico" reg add %%U /f /v "DisplayIcon" /t REG_SZ /d "\"%FINAL_EXEC_DIR%\eclipse.ico\"" >nul 2>&1
)

setx /M eclipse_path "%FINAL_EXEC_DIR%" >nul 2>&1

echo.
echo %Y2%    [SUCCESS] Eclipse %VERSION_TAG% successfully deployed and configured!%RESET%
pause
exit /b 0
