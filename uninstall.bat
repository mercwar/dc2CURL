@echo off
:: InstallShield Subsystem: Force Elevated Administrative Token Context
:: -----------------------------------------------------------------------------
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' neq '0' ( goto :RequestUAC ) else ( goto :ExecuteUninstaller )

:RequestUAC
    powershell -Command "Start-Process '%~f0' -Verb RunAs -WorkingDirectory '%~dp0'"
    exit /b

:ExecuteUninstaller
setlocal EnableDelayedExpansion

:: Dynamically discover version from config.json or fall back to scanning Program Files
set "TARGET=%ProgramFiles%\dc2url"
set "CONFIG_URL=https://raw.githubusercontent.com/mercwar/dc2url/main/config.json"
set "TEMP_CONFIG=%TEMP%\dc2url_config.json"

powershell -Command "try { Invoke-WebRequest -Uri '%CONFIG_URL%' -OutFile '%TEMP_CONFIG%' -UseBasicParsing } catch { }"

set "VERSION_TAG=v1.0"
if exist "%TEMP_CONFIG%" (
    for /f "delims=" %%v in ('powershell -Command "$json = Get-Content '%TEMP_CONFIG%' -Raw | ConvertFrom-Json; if($json.version) { output $json.version }" 2^>nul') do (
        set "VERSION_TAG=%%v"
    )
    del /f /q "%TEMP_CONFIG%" >nul 2>&1
)

set "TARGET_BASE=%TARGET%\%VERSION_TAG%"
set "FINAL_EXEC_DIR=%TARGET_BASE%\exec"

title Eclipse Uninstaller (%VERSION_TAG%)

mode con: cols=120 lines=36
chcp 65001 >nul 2>&1
color 0E

cls
echo ====================================================================================
echo                         Eclipse Uninstaller (%VERSION_TAG%)
echo ====================================================================================
echo.

echo [*] Terminating active Eclipse programs...
taskkill /f /im eclipse.exe >nul 2>&1

echo [*] Removing Windows Registry entries...
reg delete "HKCU\Software\Eclipse" /f >nul 2>&1
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\Eclipse" /f >nul 2>&1
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Eclipse" /f >nul 2>&1

echo [*] Deleting application files for version %VERSION_TAG%...
if exist "%TARGET_BASE%" (
    rmdir /s /q "%TARGET_BASE%" >nul 2>&1
)

echo [OK] Uninstallation complete.
pause
exit /b 0
