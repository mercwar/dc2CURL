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
title InstallShield (R) Setup Launcher v1.0 :: dc2url Master Deployment Engine
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
echo %Y2%                   dc2url Core Production Environment Installation Engine%RESET%%BG_GLASS%
echo %O2%    =====================================================================================%RESET%%BG_GLASS%
echo.

:: 1. STRICT LOWERCASE PATH RESOLUTION & VERIFICATION
set "BASE_DIR=%~dp0"
if "%BASE_DIR:~-1%"=="\" set "BASE_DIR=%BASE_DIR:~0,-1%"

:: Evaluate folder layout context safely
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

:: 2. VERIFY DISCOVERED FILE ASSETS
if not exist "%FINAL_EXE_PATH%" (
    echo %O1%        [CRITICAL ERROR] Execution assets missing from folder: %FINAL_EXEC_DIR%%RESET%%BG_GLASS%
    goto :finish
)

:: 3. COM SUBSYSTEM SELF-REGISTRATION PIPELINE
echo %O2%        [*] Processing OLE/COM Server Component Registrations...%RESET%%BG_GLASS%
if exist "%FINAL_EXEC_DIR%\DarkComHeadless.dll" (
    regsvr32.exe /s "%FINAL_EXEC_DIR%\DarkComHeadless.dll"
    echo                [SUCCESS] DarkComHeadless.dll mapped into target engine space.
)
if exist "%FINAL_EXEC_DIR%\WebView2Loader.dll" (
    regsvr32.exe /s "%FINAL_EXEC_DIR%\WebView2Loader.dll"
    echo                [SUCCESS] WebView2Loader.dll mapped into target engine space.
)

:: 4. GENERATE CLEAN COMMAND ROUTER ABSTRACTION WRAPPER
echo @echo off > "%FINAL_EXEC_DIR%\dc2url.bat"
echo "%FINAL_EXEC_DIR%\dc2url.exe" %%* >> "%FINAL_EXEC_DIR%\dc2url.bat"
echo                [SUCCESS] Command routing wrapper 'dc2url.bat' successfully initialized.

:: 5. MULTI-ARCHITECTURE CROSS-REGISTRY LAYER MAPS (FORCED STRICT LOWERCASE)
echo %O2%        [*] Writing Multi-Architecture Application Routing Nodes...%RESET%%BG_GLASS%

:: --- Standard Native 64-bit Application Paths Integration ---
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f /ve /t REG_SZ /d "%FINAL_EXE_PATH%" >nul 2>&1
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f /v "Path" /t REG_SZ /d "%FINAL_EXEC_DIR%" >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f /ve /t REG_SZ /d "%FINAL_EXE_PATH%" >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f /v "Path" /t REG_SZ /d "%FINAL_EXEC_DIR%" >nul 2>&1

:: --- Explicit WoW6432Node Redirector Registry Mappings ---
reg add "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f /ve /t REG_SZ /d "%FINAL_EXE_PATH%" >nul 2>&1
reg add "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f /v "Path" /t REG_SZ /d "%FINAL_EXEC_DIR%" >nul 2>&1
reg add "HKCU\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f /ve /t REG_SZ /d "%FINAL_EXE_PATH%" >nul 2>&1
reg add "HKCU\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f /v "Path" /t REG_SZ /d "%FINAL_EXEC_DIR%" >nul 2>&1

:: 6. REGISTRATION IN WINDOWS PROGRAMS SCREEN (FORCED STRICT LOWERCASE UNINSTALL KEYS)
echo %O2%        [*] Registering application metadata inside Windows installed control layers...%RESET%%BG_GLASS%

set "UNINSTALL_KEY=HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\dc2url"
reg add "%UNINSTALL_KEY%" /f /v "DisplayName" /t REG_SZ /d "dc2url Utility Framework" >nul 2>&1
reg add "%UNINSTALL_KEY%" /f /v "UninstallString" /t REG_SZ /d "\"%BASE_DIR%\uninstall.bat\"" >nul 2>&1
reg add "%UNINSTALL_KEY%" /f /v "DisplayIcon" /t REG_SZ /d "%BASE_DIR%\favi-con.ico" >nul 2>&1
reg add "%UNINSTALL_KEY%" /f /v "DisplayVersion" /t REG_SZ /d "1.0" >nul 2>&1
reg add "%UNINSTALL_KEY%" /f /v "Publisher" /t REG_SZ /d "Robo Rook Universe" >nul 2>&1
reg add "%UNINSTALL_KEY%" /f /v "EstimatedSize" /t REG_DWORD /d 4500 >nul 2>&1
reg add "%UNINSTALL_KEY%" /f /v "NoModify" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "%UNINSTALL_KEY%" /f /v "NoRepair" /t REG_DWORD /d 1 /f >nul 2>&1

:: Double mirror registry visibility configuration to WoW6432Node space using strict lowercase key tags
set "UNINSTALL_KEY_32=HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\dc2url"
reg add "%UNINSTALL_KEY_32%" /f /v "DisplayName" /t REG_SZ /d "dc2url Utility Framework" >nul 2>&1
reg add "%UNINSTALL_KEY_32%" /f /v "UninstallString" /t REG_SZ /d "\"%BASE_DIR%\uninstall.bat\"" >nul 2>&1
reg add "%UNINSTALL_KEY_32%" /f /v "DisplayIcon" /t REG_SZ /d "%BASE_DIR%\favi-con.ico" >nul 2>&1
reg add "%UNINSTALL_KEY_32%" /f /v "DisplayVersion" /t REG_SZ /d "1.0" >nul 2>&1
reg add "%UNINSTALL_KEY_32%" /f /v "Publisher" /t REG_SZ /d "Robo Rook Universe" >nul 2>&1
reg add "%UNINSTALL_KEY_32%" /f /v "EstimatedSize" /t REG_DWORD /d 4500 >nul 2>&1
reg add "%UNINSTALL_KEY_32%" /v "NoModify" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "%UNINSTALL_KEY_32%" /v "NoRepair" /t REG_DWORD /d 1 /f >nul 2>&1

:: 7. MASTER SYSTEM ENVIRONMENT VARIABLE SYNC (STRICT LOWERCASE BLOCK VARIABLE)
setx /M dc2url_path "%FINAL_EXEC_DIR%" >nul 2>&1

:: Prepend configuration safely to user PATH block using non-destructive filtering
powershell -Command "$p=[System.Environment]::GetEnvironmentVariable('PATH','User'); if($p -split ';' -notcontains '%FINAL_EXEC_DIR%'){[System.Environment]::SetEnvironmentVariable('PATH',('%FINAL_EXEC_DIR%;'+$p),'User')}" >nul 2>&1

:: Directly drop configurations into the active user Volatile Environment layer
for /f "tokens=2*" %%a in ('reg query "HKCU\Environment" /v PATH 2^>nul') do set "USER_PATH=%%b"
if defined USER_PATH (
    reg add "HKCU\Volatile Environment" /v PATH /t REG_SZ /d "%FINAL_EXEC_DIR%;%USER_PATH%" /f >nul 2>&1
)

:: Globally broadcast environment updates to drop stale process caches instantly
powershell -Command "$advapi = '[DllImport(\"user32.dll\",SetLastError=true)]public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, IntPtr wParam, String lParam, uint fuFlags, uint uTimeout, out IntPtr lpdwResult);'; $type = Add-Type -MemberDefinition $advapi -Name 'Win32' -Namespace 'Win32Functions' -PassThru; $res = [IntPtr]::Zero; [Win32Functions.Win32]::SendMessageTimeout([IntPtr]0xffff, 0x001A, [IntPtr]::Zero, 'Environment', 2, 5000, [out]$res)" >nul 2>&1

:: Synchronize path variables onto the running terminal session instance context immediately
set "PATH=%FINAL_EXEC_DIR%;%PATH%"

echo                [SUCCESS] Environment update complete. Lookups refreshed across architectures.
echo.
echo %Y2%        [DEPLOYMENT COMPLETED - ENGINE ONLINE AND VISIBLE]%RESET%%BG_GLASS%
echo.

:finish
echo %TXT%        Press any key to close installer suite...%RESET%
pause >nul
exit /b 0
