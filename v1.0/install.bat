@echo off
setlocal EnabledelayedExpansion

echo ============================================================
echo               dc2URL :: INSTALLATION SUITE
echo ============================================================
echo.

:: 1. CAPTURE ACTIVE DEPLOYMENT DIRECTORY CONTEXT
set "TARGET_DIR=%~dp0"
if "!TARGET_DIR:~-1!"=="\" set "TARGET_DIR=!TARGET_DIR:~0,-1!"
set "FINAL_EXEC_DIR=!TARGET_DIR!\exec"
set "FINAL_EXE_PATH=!FINAL_EXEC_DIR!\darkcom2.exe"

:: 2. DETECT EXISTING ENVIRONMENT VARIABLE & PURGE DIRECTLY
set "EXISTING_PATH="
for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v dc2url_path 2^>nul') do set "EXISTING_PATH=%%B"

if not "!EXISTING_PATH!"=="" (
    echo [DETECTED] Pre-existing dc2URL environment registration found:
    echo            !EXISTING_PATH!
    echo.
    echo [CLEANUP] Removing existing dc2url_path registry key...
    reg delete "HKCU\Environment" /v dc2url_path /f >nul 2>&1
    echo       - Old environment variable key removed.
    echo ============================================================
    echo.
)

:: 3. VERIFY WORKSPACE LAYOUT
echo [1/5] Verifying workspace layout...
if not exist "!FINAL_EXE_PATH!" (
    echo [ERROR] Target binary missing: !FINAL_EXE_PATH!
    echo [ERROR] Installation failed. Ensure files are staged in 'exec\'.
    goto :finish
)
echo       - Core binaries verified successfully.

:: 4. GENERATE CLI WRAPPER SHORTCUT
echo [2/5] Generating CLI wrapper shortcut...
echo @@"%%~dp0darkcom2.exe" %%* > "!FINAL_EXEC_DIR!\dc2url.bat"
echo       - Wrapper generated.

:: 5. REGISTER PROTOCOL HANDLER
echo [3/5] Registering custom dc2URL:// protocol handler...
reg add "HKLM\Software\Classes\dc2URL" /f /ve /t REG_SZ /d "URL:dc2URL Protocol" >nul 2>&1
if !errorlevel! equ 0 (
    reg add "HKLM\Software\Classes\dc2URL" /f /v "URL Protocol" /t REG_SZ /d "" >nul 2>&1
    reg add "HKLM\Software\Classes\dc2URL\shell\open\command" /f /ve /t REG_SZ /d "\"!FINAL_EXE_PATH!\" \"%%1\"" >nul 2>&1
    echo       - Protocol mapped under System Machine context.
) else (
    reg add "HKCU\Software\Classes\dc2URL" /f /ve /t REG_SZ /d "URL:dc2URL Protocol" >nul 2>&1
    reg add "HKCU\Software\Classes\dc2URL\URL Protocol" /f /ve /t REG_SZ /d "" >nul 2>&1
    reg add "HKCU\Software\Classes\dc2URL\shell\open\command" /f /ve /t REG_SZ /d "\"!FINAL_EXE_PATH!\" \"%%1\"" >nul 2>&1
    echo       - Protocol mapped under Current User context.
)

:: 6. PATH INJECTION
echo [4/5] Injecting execution directory into Environment PATH...
reg add "HKCU\Environment" /v "dc2url_path" /t REG_SZ /d "!FINAL_EXEC_DIR!" /f >nul 2>&1
set "CURRENT_USER_PATH="
for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v PATH 2^>nul') do set "CURRENT_USER_PATH=%%B"

if "!CURRENT_USER_PATH!"=="" (
    reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "%%dc2url_path%%" /f >nul 2>&1
) else (
    echo "!CURRENT_USER_PATH!" | find /I "dc2url_path" >nul 2>&1
    if !errorlevel! neq 0 (
        reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "%%dc2url_path%%;!CURRENT_USER_PATH!" /f >nul 2>&1
    )
)
echo       - PATH injection complete.

:: 7. REFRESH ENVIRONMENT CACHE
echo [5/5] Refreshing Windows environment cache...
powershell -Command "[System.Environment]::SetEnvironmentVariable('PATH', [System.Environment]::GetEnvironmentVariable('PATH', 'User'), 'User')" >nul 2>&1
echo       - Environment refreshed.

echo.
echo ============================================================
echo           INSTALLATION COMPLETED SUCCESSFULLY
echo ============================================================
echo Active Path : !FINAL_EXEC_DIR!
echo System command 'dc2url' is now registered and ready.
echo.

:finish
echo Press any key to end the command line session...
pause >nul
exit /b 0