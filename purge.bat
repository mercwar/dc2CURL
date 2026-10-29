@echo off
:: InstallShield Subsystem: Force Elevated Administrative Token Context
:: -----------------------------------------------------------------------------
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' neq '0' ( goto :RequestUAC ) else ( goto :ExecuteRemotePurge )

:RequestUAC
    powershell -Command "Start-Process '%~f0' -Verb RunAs -WorkingDirectory '%~dp0'"
    exit /b

:ExecuteRemotePurge
setlocal DisableDelayedExpansion

title InstallShield(R) Purge Engine :: Ecosystem Deconstruction
mode con: cols=120 lines=36
chcp 65001 >nul 2>&1
color 0C

reg add "HKCU\Console" /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1
for /f %%a in ('echo prompt $E^|cmd') do set "E=%%a"
set "RESET=%E%[0m"
set "BG_GLASS=%E%[48;2;10;10;12m"
set "R1=%E%[38;2;255;68;0m"
set "R2=%E%[38;2;255;110;0m"
set "R3=%E%[38;2;255;153;0m"
set "Y1=%E%[38;2;255;200;0m"
set "Y2=%E%[38;2;255;235;0m"
set "TXT=%E%[38;2;240;240;240m"

cls
echo %BG_GLASS%
cls

echo.
echo %R1%        ███████╗ ██████╗██╗     ██╗██████╗ ███████╗███████╗%RESET%%BG_GLASS%
echo %R2%        ██╔════╝██╔════╝██║     ██║██╔══██╗██╔════╝██╔════╝%RESET%%BG_GLASS%
echo %R1%        █████╗  ██║     ██║     ██║██████╔╝███████╗█████╗  %RESET%%BG_GLASS%
echo %Y1%        ██╔══╝  ██║     ██║     ██║██╔═══╝ ╚════██║██╔══╝  %RESET%%BG_GLASS%
echo %Y2%        ███████╗╚██████╗███████╗██║██║     ███████║███████╗%RESET%%BG_GLASS%
echo %Y2%        ╚══════╝ ╚═════╝╚══════╝╚═╝╚═╝     ╚══════╝╚══════╝%RESET%%BG_GLASS%

echo %R1%    ====================================================================================%RESET%%BG_GLASS%
echo %Y2%          REMOTE ECOSYSTEM PURGE :: Executing Official Uninstallers%RESET%%BG_GLASS%
echo %R1%    ====================================================================================%RESET%%BG_GLASS%
echo.

set "REPO_URL=https://raw.githubusercontent.com/mercwar/dc2url/main"
set "TEMP_DC2_UNINSTALL=%TEMP%\dc2url_uninstall_%RANDOM%.bat"
set "TEMP_ECLIPSE_UNINSTALL=%TEMP%\eclipse_uninstall_%RANDOM%.bat"


echo %R2%        [*] Dispatching download request for dc2URL uninstaller...%RESET%%BG_GLASS%

powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri '%REPO_URL%/v1.0/uninstall.bat' -OutFile '%TEMP_DC2_UNINSTALL%'" >nul 2>&1

if exist "%TEMP_DC2_UNINSTALL%" (
    echo                      [OK] dc2URL uninstaller payload secured.
    echo %R2%        [*] Executing dc2URL purge routine...%RESET%%BG_GLASS%
    echo.
    call "%TEMP_DC2_UNINSTALL%"
    del /f /q "%TEMP_DC2_UNINSTALL%" >nul 2>&1
) else (
    echo                      [ERROR] Failed to download dc2URL uninstaller.
)

echo.

:: =========================================================================
:: 2. FETCH EXECUTE ECLIPSE UNINSTALLER 
:: =========================================================================
echo %R2%        [*] Dispatching download request for Eclipse uninstaller...%RESET%%BG_GLASS%

powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri '%REPO_URL%/uninstall.bat' -OutFile '%TEMP_ECLIPSE_UNINSTALL%'" >nul 2>&1

if exist "%TEMP_ECLIPSE_UNINSTALL%" (
    echo                      [OK] Eclipse uninstaller payload secured.
    echo %R2%        [*] Executing Eclipse purge routine...%RESET%%BG_GLASS%
    echo.
    call "%TEMP_ECLIPSE_UNINSTALL%"
    del /f /q "%TEMP_ECLIPSE_UNINSTALL%" >nul 2>&1
) else (
    echo                      [ERROR] Failed to download Eclipse uninstaller.
)

echo.
echo %R3%    ====================================================================================%RESET%%BG_GLASS%
echo %Y1%                         REMOTE ECOSYSTEM PURGE COMPLETE%RESET%%BG_GLASS%
echo %R3%    ====================================================================================%RESET%%BG_GLASS%
echo.
echo %TXT%        All targeted application environments and registry trees have been flushed.%RESET%
echo.
pause
exit /b 0
