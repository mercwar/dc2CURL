@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1

:: ============================================================
:: SELF-ELEVATION PIPELINE (REQUIRES ADMIN FOR PROGRAM FILES)
:: ============================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList '/c', 'cd /d ""%~dp0"" && ""%~f0""' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"

title InstallShield (R) Uninstaller v1.0 :: dc2url Master Removal Engine
mode con: cols=120 lines=30
color 0C

cls
echo.
echo     ====================================================================================
echo                         dc2url Core Cyborg Ecosystem Uninstaller
echo     ====================================================================================
echo.

:: Terminate running processes to release file locks
echo     [*] Terminating any active eclipse or dc2url processes...
taskkill /f /im eclipse.exe >nul 2>&1
taskkill /f /im dc2url.exe >nul 2>&1
echo     [+] Processes cleared.
echo.

:: Detect target installation directory (defaults to ProgramFiles\dc2url or script directory parent)
set "DEFAULT_INSTALL=%ProgramFiles%\dc2url"
if "%DEFAULT_INSTALL%"=="" set "DEFAULT_INSTALL=%SystemDrive%\Program Files\dc2url"

echo     ------------------------------------------------------------------------------------
echo     [AVIS] UNINSTALLER DIRECTORY CONFIGURATION
echo     Default system path: !DEFAULT_INSTALL!
echo.
set /p "INSTALL_PATH=    >>> ENTER FULL PATH OR PRESS ENTER FOR DEFAULT (!DEFAULT_INSTALL!): "
if "!INSTALL_PATH!"=="" set "INSTALL_PATH=!DEFAULT_INSTALL!"

if not exist "!INSTALL_PATH!" (
    echo     [-] Specified path does not exist: !INSTALL_PATH!
    goto :cleanup_registry
)

echo     [*] Unregistering OLE/COM Components...
for /R "!INSTALL_PATH!" %%F in (DarkComHeadless.dll WebView2Loader.dll) do (
    if exist "%%F" (
        regsvr32.exe /u /s "%%F"
        echo                     [SUCCESS] Unregistered "%%~nxF".
    )
)

echo     [*] Removing targeted headless and exe files...
for /R "!INSTALL_PATH!" %%F in (*headless*.dll *headless*.exe *.exe) do (
    if exist "%%F" (
        del /f /q "%%F" >nul 2>&1
        echo                     [REMOVED] "%%~nxF"
    )
)

:: Alternative explicit check for the execution subfolder if used
set "FINAL_EXEC_DIR=!INSTALL_PATH!\exec"
if exist "!FINAL_EXEC_DIR!" (
    if exist "!FINAL_EXEC_DIR!\DarkComHeadless.dll" (
        del /f /q "!FINAL_EXEC_DIR!\DarkComHeadless.dll" >nul 2>&1
        echo                     [REMOVED] exec\DarkComHeadless.dll
    )
    if exist "!FINAL_EXEC_DIR!\dc2url.exe" (
        del /f /q "!FINAL_EXEC_DIR!\dc2url.exe" >nul 2>&1
        echo                     [REMOVED] exec\dc2url.exe
    )
)

:cleanup_registry
echo     [*] Cleaning up registry configurations and uninstall entries...
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

:: Optionally remove the installation directory if empty or completely
if exist "!INSTALL_PATH!" (
    echo     [*] Removing empty installation directories...
    rmdir /s /q "!INSTALL_PATH!" >nul 2>&1
)

echo.
echo                     [SUCCESS] Headless and executable files successfully removed!
echo.
pause
exit /b 0
