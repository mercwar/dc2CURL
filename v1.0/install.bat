@echo off
setlocal DisableDelayedExpansion

:: Force CMD Code Page to UTF-8 & Default Console Color
chcp 65001 >nul 2>&1
color 0E

:: Enable ANSI Virtual Terminal Processing for RGB Colors
reg add "HKCU\Console" /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1

:: Define ANSI TrueColor Escapes (Fire-Gem Orange to Bright Yellow Gradient)
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
echo %O1%    ██████╗  █████╗ ██████╗ ██╗  ██╗ ██████╗ ██████╗ ███╗   ███╗██████╗ %RESET%%BG_GLASS%
echo %O2%    ██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝██╔════╝██╔═══██╗████╗ ████║╚════██╗%RESET%%BG_GLASS%
echo %O3%    ██║  ██║███████║██████╔╝█████╔╝ ██║     ██║   ██║██╔████╔██║ █████╔╝%RESET%%BG_GLASS%
echo %Y1%    ██║  ██║██╔══██║██╔══██╗██╔═██╗ ██║     ██║   ██║██║╚██╔╝██║██╔═══╝ %RESET%%BG_GLASS%
echo %Y2%    ██████╔╝██║  ██║██║  ██║██║  ██╗╚██████╗╚██████╔╝██║ ╚═╝ ██║███████╗%RESET%%BG_GLASS%
echo %Y2%    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝%RESET%%BG_GLASS%
echo %O2%============================================================%RESET%%BG_GLASS%
echo %Y2%              dc2URL :: INSTALLATION SUITE%RESET%%BG_GLASS%
echo %O2%============================================================%RESET%%BG_GLASS%
echo.

:: 1. CAPTURE ACTIVE DEPLOYMENT DIRECTORY CONTEXT
set "TARGET_DIR=%~dp0"
if "%TARGET_DIR:~-1%"=="\" set "TARGET_DIR=%TARGET_DIR:~0,-1%"
set "FINAL_EXEC_DIR=%TARGET_DIR%\exec"
set "FINAL_EXE_PATH=%FINAL_EXEC_DIR%\darkcom2.exe"

:: 2. DETECT EXISTING ENVIRONMENT VARIABLE & PURGE DIRECTLY
set "EXISTING_PATH="
for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v dc2url_path 2^>nul') do set "EXISTING_PATH=%%B"

if not "%EXISTING_PATH%"=="" (
    echo %Y1%[Notice]%TXT% Previous installation detected. Updating configuration...%RESET%%BG_GLASS%
    reg delete "HKCU\Environment" /v dc2url_path /f >nul 2>&1
    echo          Old settings cleaned up successfully.
    echo %O2%============================================================%RESET%%BG_GLASS%
    echo.
)

:: 3. WORKSPACE LAYOUT VERIFICATION WITH PROGRESS BAR
<nul set /p "=%Y1%    [....................]    0% - Checking installation files...%RESET%%BG_GLASS%"
if not exist "%FINAL_EXE_PATH%" (
    echo.
    echo %O1%[Error] Required program files are missing from the 'exec' folder.%RESET%%BG_GLASS%
    echo          Please ensure the installation package is complete.
    goto :finish
)
powershell -Command "$steps = 20; for($i=1; $i -le $steps; $i++){$p=[math]::Floor(($i/$steps)*100); $b='#'*$i + '.'*($steps-$i); Write-Host -NoNewline \"`r    [ $b ] $p%% - Checking installation files...      \"; Start-Sleep -Milliseconds 15}"
echo.
echo          Program files verified and ready.

:: 4. CLI WRAPPER GENERATION WITH PROGRESS BAR
<nul set /p "=%Y1%    [....................]    0% - Creating command shortcuts...%RESET%%BG_GLASS%"
echo @"%%~dp0darkcom2.exe" %%* > "%FINAL_EXEC_DIR%\dc2url.bat"
powershell -Command "$steps = 20; for($i=1; $i -le $steps; $i++){$p=[math]::Floor(($i/$steps)*100); $b='#'*$i + '.'*($steps-$i); Write-Host -NoNewline \"`r    [ $b ] $p%% - Creating command shortcuts...    \"; Start-Sleep -Milliseconds 15}"
echo.
echo          Command shortcuts created.

:: 5. PROTOCOL HANDLER REGISTRATION WITH PROGRESS BAR
<nul set /p "=%Y1%    [....................]    0% - Registering web link handler...%RESET%%BG_GLASS%"
reg add "HKLM\Software\Classes\dc2URL" /f /ve /t REG_SZ /d "URL:dc2URL Protocol" >nul 2>&1
if %errorlevel% equ 0 (
    reg add "HKLM\Software\Classes\dc2URL" /f /v "URL Protocol" /t REG_SZ /d "" >nul 2>&1
    reg add "HKLM\Software\Classes\dc2URL\shell\open\command" /f /ve /t REG_SZ /d "\"%FINAL_EXE_PATH%\" \"%%1\"" >nul 2>&1
) else (
    reg add "HKCU\Software\Classes\dc2URL" /f /ve /t REG_SZ /d "URL:dc2URL Protocol" >nul 2>&1
    reg add "HKCU\Software\Classes\dc2URL\URL Protocol" /f /ve /t REG_SZ /d "" >nul 2>&1
    reg add "HKCU\Software\Classes\dc2URL\shell\open\command" /f /ve /t REG_SZ /d "\"%FINAL_EXE_PATH%\" \"%%1\"" >nul 2>&1
)
powershell -Command "$steps = 20; for($i=1; $i -le $steps; $i++){$p=[math]::Floor(($i/$steps)*100); $b='#'*$i + '.'*($steps-$i); Write-Host -NoNewline \"`r    [ $b ] $p%% - Registering web link handler...    \"; Start-Sleep -Milliseconds 15}"
echo.
echo          Web link (dc2URL://) successfully registered.

:: 6. PATH INJECTION WITH PROGRESS BAR
<nul set /p "=%Y1%    [....................]    0% - Setting up system environment...%RESET%%BG_GLASS%"
reg add "HKCU\Environment" /v "dc2url_path" /t REG_SZ /d "%FINAL_EXEC_DIR%" /f >nul 2>&1

:: Retrieve user PATH safely
set "CURRENT_USER_PATH="
for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v PATH 2^>nul') do set "CURRENT_USER_PATH=%%B"

if "%CURRENT_USER_PATH%"=="" (
    reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "%%dc2url_path%%" /f >nul 2>&1
) else (
    echo "%CURRENT_USER_PATH%" | find /I "dc2url_path" >nul 2>&1
    if %errorlevel% neq 0 (
        reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "%%dc2url_path%%;%CURRENT_USER_PATH%" /f >nul 2>&1
    )
)
powershell -Command "$steps = 20; for($i=1; $i -le $steps; $i++){$p=[math]::Floor(($i/$steps)*100); $b='#'*$i + '.'*($steps-$i); Write-Host -NoNewline \"`r    [ $b ] $p%% - Setting up system environment...   \"; Start-Sleep -Milliseconds 15}"
echo.
echo          System environment configured.

:: 7. ENVIRONMENT REFRESH WITH PROGRESS BAR
<nul set /p "=%Y1%    [....................]    0% - Applying system changes...%RESET%%BG_GLASS%"
powershell -Command "$path = [System.Environment]::GetEnvironmentVariable('PATH', 'User'); if ($path -notlike '*dc2url_path*') { [System.Environment]::SetEnvironmentVariable('PATH', '$path;%FINAL_EXEC_DIR%', 'User') }" >nul 2>&1
powershell -Command "$steps = 20; for($i=1; $i -le $steps; $i++){$p=[math]::Floor(($i/$steps)*100); $b='#'*$i + '.'*($steps-$i); Write-Host -NoNewline \"`r    [ $b ] $p%% - Applying system changes...       \"; Start-Sleep -Milliseconds 15}"
echo.
echo          System changes applied successfully.

echo.
echo %O2%============================================================%RESET%%BG_GLASS%
echo %Y2%          INSTALLATION COMPLETED SUCCESSFULLY%RESET%%BG_GLASS%
echo %O2%============================================================%RESET%%BG_GLASS%
echo %TXT%Location : %FINAL_EXEC_DIR%
echo Please close this window and open a NEW Command Prompt to use 'dc2url'.%RESET%%BG_GLASS%
echo.

:finish
echo Press any key to exit setup...
pause >nul
exit /b 0
