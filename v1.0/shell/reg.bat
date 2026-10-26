@echo off
set "TARGET_DIR=%~1"
set "FINAL_EXE_PATH=!TARGET_DIR!\exec\darkcom2.exe"
set "FINAL_EXEC_DIR=!TARGET_DIR!\exec"

:: 1. Programmatically construct the dc2url command shortcut alias wrapper file natively
echo @@"%%~dp0darkcom2.exe" %%* > "!FINAL_EXEC_DIR!\dc2url.bat"

:: 2. Custom System Protocol Handler Routing Configuration (dc2URL://)
echo [INFO] Mapping custom protocol context handlers...
reg add "HKLM\Software\Classes\dc2URL" /f /ve /t REG_SZ /d "URL:dc2URL Protocol" >nul 2>&1
if %errorlevel% equ 0 (
    reg add "HKLM\Software\Classes\dc2URL" /f /v "URL Protocol" /t REG_SZ /d "" >nul
    reg add "HKLM\Software\Classes\dc2URL\shell\open\command" /f /ve /t REG_SZ /d "\"!FINAL_EXE_PATH!\" \"%%1\"" >nul
    echo [SUCCESS] Protocol handler mapped successfully under System Machine context.
) else (
    reg add "HKCU\Software\Classes\dc2URL" /f /ve /t REG_SZ /d "URL:dc2URL Protocol" >nul
    reg add "HKCU\Software\Classes\dc2URL\URL Protocol" /f /ve /t REG_SZ /d "" >nul
    reg add "HKCU\Software\Classes\dc2URL\shell\open\command" /f /ve /t REG_SZ /d "\"!FINAL_EXE_PATH!\" \"%%1\"" >nul
    echo [SUCCESS] Protocol handler mapped successfully under Current User context.
)

:: 3. Persistent User PATH Configuration (SAFE: Direct registry transaction bypasses loop and character length issues)
echo [INFO] Injecting binary directories to local environment context...
reg add "HKCU\Environment" /v "dc2url_path" /t REG_SZ /d "!FINAL_EXEC_DIR!" /f >nul 2>&1
for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v PATH 2^>nul') do set "CURRENT_USER_PATH=%%B"

if "!CURRENT_USER_PATH!"=="" (
    reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "%%dc2url_path%%" /f >nul 2>&1
) else (
    echo "!CURRENT_USER_PATH!" | find /I "dc2url_path" >nul 2>&1
    if !errorlevel! neq 0 (
        reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "%%dc2url_path%%;!CURRENT_USER_PATH!" /f >nul 2>&1
    )
)

:: 4. Programmatic environment broadcast forces the Windows 11 shell to refresh environment cache instantly
echo [INFO] Broadcasting environment variable change to Windows 11 Kernel...
powershell -Command "[System.Environment]::SetEnvironmentVariable('PATH', [System.Environment]::GetEnvironmentVariable('PATH', 'User'), 'User')" >nul 2>&1
echo [SUCCESS] Path integration completed successfully.
