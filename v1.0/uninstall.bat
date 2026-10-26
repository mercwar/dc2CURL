@echo off
setlocal EnabledelayedExpansion
echo ============================================================
echo               dc2URL :: UNINSTALLATION SUITE
echo ============================================================
echo.

:: 1. Read Variable Extraction Paths directly from Environment Registry
for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v dc2url_path 2^>nul') do set "REMOVE_DIR_EXEC=%%B"

if "!REMOVE_DIR_EXEC!"=="" (
    echo [ERROR] No active environment registration path discovered for dc2URL.
    echo System appears to be clean or already wiped.
    goto open_installer
)

:: Extract base folder directory path out of nested exec context string maps
set "REMOVE_DIR_ROOT=!REMOVE_DIR_EXEC:\exec=!"

echo [INFO] Target components discovered for deletion:
echo   Execution Cores: !REMOVE_DIR_EXEC!
echo   Application Root: !REMOVE_DIR_ROOT!
echo.

:: 2. Purge System Custom Deep-Link URI Protocol Handlers (dc2URL://)
echo [INFO] Stripping system protocol URI handlers from the tracking keys...
reg delete "HKLM\Software\Classes\dc2URL" /f >nul 2>&1
reg delete "HKCU\Software\Classes\dc2URL" /f >nul 2>&1

:: 3. Purge Environment Path Tracking Entries
echo [INFO] Stripping path variables out of environment blocks...
reg delete "HKCU\Environment" /v "dc2url_path" /f >nul 2>&1

for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v PATH 2^>nul') do set "OLD_PATH=%%B"
if not "!OLD_PATH!"=="" (
    set "NEW_PATH=!OLD_PATH:%%dc2url_path%%;=!"
    set "NEW_PATH=!NEW_PATH:%%dc2url_path%%=!"
    
    if "!NEW_PATH!"=="" (
        reg delete "HKCU\Environment" /v PATH /f >nul 2>&1
    ) else (
        reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "!NEW_PATH!" /f >nul 2>&1
    )
)

:: Force the system shell to flush cached user parameters immediately
powershell -Command "[System.Environment]::SetEnvironmentVariable('PATH', [System.Environment]::GetEnvironmentVariable('PATH', 'User'), 'User')" >nul 2>&1

:: 4. Erase Application Installation Directory File Footprint
echo [INFO] Wiping deployed files...
start /b cmd /c "timeout /t 1 /nobreak >nul && del /f /q "!REMOVE_DIR_EXEC!\*.*" 2>nul && del /f /q "!REMOVE_DIR_ROOT!\images\*.*" 2>nul && del /f /q "!REMOVE_DIR_ROOT!\*.*" 2>nul && rd /s /q "!REMOVE_DIR_ROOT!\images" 2>nul && rd /s /q "!REMOVE_DIR_EXEC!" 2>nul && rd /s /q "!REMOVE_DIR_ROOT!" 2>nul"
echo [SUCCESS] System cleanup mappings completed.

:open_installer
echo.
echo ============================================================
echo  UNINSTALLATION COMPLETE
echo ============================================================
echo.

:: If uninstaller was initialized by the installer script loop, do not spawn a parallel loop clone
if "%~1"=="--from-installer" (
    echo [INFO] Returning back to master installation execution sequence track...
    echo.
    timeout /t 2 /nobreak >nul
    call "%~dp0install.bat"
    exit /b
)

:: If run standalone by the user clicking the file, loop back open the local installer manually
if exist "%~dp0install.bat" (
    echo [INFO] Automatically restarting Master Installation Suite...
    timeout /t 2 /nobreak >nul
    start "" "%~dp0install.bat"
)
