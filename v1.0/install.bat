@echo off
:: InstallShield Subsystem: Force Elevated Administrative Token Context
:: -----------------------------------------------------------------------------
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' neq '0' ( goto :RequestUAC ) else ( goto :ExecuteSetup )

:RequestUAC
    powershell -Command "Start-Process '%~f0' -Verb RunAs -WorkingDirectory '%~dp0'"
    exit /b

:ExecuteSetup
setlocal DisableDelayedExpansion

:: Force the working directory to match the actual folder location of this script file.
cd /d "%~dp0"

:: InstallShield Configuration Properties: Title Block & Bounds
title InstallShield (R) Setup Launcher v1.0 :: dc2url Multi-Arch Engine Fix
mode con: cols=120 lines=34

chcp 65001 >nul 2>&1
color 0E

:: Force TrueColor Console Canvas Context Allocation
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
echo %Y2%               Cross-Architecture Mirror Resolution Subsystem Deployment%RESET%%BG_GLASS%
echo %O2%    =====================================================================================%RESET%%BG_GLASS%
echo.

:: 1. RESOLVE FOLDER GEOMETRY AND DETECT BASE RUNTIME
set "BASE_DIR=%~dp0"
if "%BASE_DIR:~-1%"=="\" set "BASE_DIR=%BASE_DIR:~0,-1%"

echo "%BASE_DIR%" | find /i "\exec" >nul 2>&1
if %errorlevel% equ 0 (
    set "FINAL_EXEC_DIR=%BASE_DIR%"
) else (
    if exist "%BASE_DIR%\exec\" (
        set "FINAL_EXEC_DIR=%BASE_DIR%\exec"
    ) else (
        set "FINAL_EXEC_DIR=%BASE_DIR%"
    )
)
set "FINAL_EXE_PATH=%FINAL_EXEC_DIR%\dc2url.exe"

:: 2. INTEGRITY CHECK FOR CORE ENGINE COMPONENTS
if not exist "%FINAL_EXE_PATH%" (
    echo %O1%        [CRITICAL ERROR] Binary not discovered at target destination: %FINAL_EXEC_DIR%%RESET%%BG_GLASS%
    goto :finish
)

:: 3. COMMAND ROUTER ABSTRACTION LAYERS
echo @echo off > "%FINAL_EXEC_DIR%\dc2url.bat"
echo "%FINAL_EXEC_DIR%\dc2url.exe" %%* >> "%FINAL_EXEC_DIR%\dc2url.bat"

:: 4. ARREST REGISTRY REDIRECTION: POPULATE BOTH 32-BIT AND 64-BIT APP PATHS LAYERS
echo %O2%        [*] Writing Multi-Architecture Application Routing Nodes...%RESET%%BG_GLASS%

:: --- Standard Native 64-bit Registry Mappings ---
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f /ve /t REG_SZ /d "%FINAL_EXE_PATH%" >nul 2>&1
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f /v "Path" /t REG_SZ /d "%FINAL_EXEC_DIR%" >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f /ve /t REG_SZ /d "%FINAL_EXE_PATH%" >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f /v "Path" /t REG_SZ /d "%FINAL_EXEC_DIR%" >nul 2>&1

:: --- Explicit WoW6432Node Redirector Registry Mappings (For 32-bit execution layers) ---
reg add "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f /ve /t REG_SZ /d "%FINAL_EXE_PATH%" >nul 2>&1
reg add "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f /v "Path" /t REG_SZ /d "%FINAL_EXEC_DIR%" >nul 2>&1
reg add "HKCU\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f /ve /t REG_SZ /d "%FINAL_EXE_PATH%" >nul 2>&1
reg add "HKCU\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f /v "Path" /t REG_SZ /d "%FINAL_EXEC_DIR%" >nul 2>&1

:: 5. SYSTEM ENVIRONMENT SYNCHRONIZATION OVERRIDES
setx /M dc2URL_path "%FINAL_EXEC_DIR%" >nul 2>&1
powershell -Command "$p=[System.Environment]::GetEnvironmentVariable('PATH','User'); if($p -split ';' -notcontains '%FINAL_EXEC_DIR%'){[System.Environment]::SetEnvironmentVariable('PATH',('%FINAL_EXEC_DIR%;'+$p),'User')}" >nul 2>&1

for /f "tokens=2*" %%a in ('reg query "HKCU\Environment" /v PATH 2^>nul') do set "USER_PATH=%%b"
if defined USER_PATH (
    reg add "HKCU\Volatile Environment" /v PATH /t REG_SZ /d "%FINAL_EXEC_DIR%;%USER_PATH%" /f >nul 2>&1
)

:: Global system notification broadcast block
powershell -Command "$advapi = '[DllImport(\"user32.dll\",SetLastError=true)]public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, IntPtr wParam, String lParam, uint fuFlags, uint uTimeout, out IntPtr lpdwResult);'; $type = Add-Type -MemberDefinition $advapi -Name 'Win32' -Namespace 'Win32Functions' -PassThru; $res = [IntPtr]::Zero; [Win32Functions.Win32]::SendMessageTimeout([IntPtr]0xffff, 0x001A, [IntPtr]::Zero, 'Environment', 2, 5000, [out]$res)" >nul 2>&1

echo                [SUCCESS] Registry nodes mapped across native and virtualized subkeys.
echo.
echo %Y2%        [DEPLOYMENT PATCH ROUTINE ONLINE - MULTI-ARCH COMPLETED]%RESET%%BG_GLASS%
echo.

:finish
echo %TXT%        Press any key to complete installation...%RESET%
pause >nul
exit /b 0
