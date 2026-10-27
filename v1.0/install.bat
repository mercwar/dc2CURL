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

:: Force the working directory to match the actual folder location of this script file (e.g., Program Files\dc2url\v1.0).
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
echo %O2%    ====================================================================================_%RESET%%BG_GLASS%
echo %Y2%                dc2url Core Cyborg Ecosystem Installer%RESET%%BG_GLASS%
echo %O2%    ====================================================================================_%RESET%%BG_GLASS%
echo.

:: 1. VERSIONED PATH TARGETING SETUP (%~dp0 points directly to C:\Program Files\dc2url\v1.0\)
set "VERSION_DIR=%~dp0"
rem Strip trailing backslash if present
if "%VERSION_DIR:~-1%"=="\" set "VERSION_DIR=%VERSION_DIR:~0,-1%"

for %%I in ("%VERSION_DIR%") do set "VERSION_NAME=%%~nxI"
for %%I in ("%VERSION_DIR%\..") do set "BASE_DIR=%%~fI"

set "FINAL_EXEC_DIR=%VERSION_DIR%\exec"
set "FINAL_EXE_PATH=%FINAL_EXEC_DIR%\dc2url.exe"

:: 2. VERIFY DISCOVERED FILE ASSETS IN VERSION DIRECTORY
if not exist "%FINAL_EXE_PATH%" (
    echo %O1%        [AVIS FAILED] Installation files are missing in: %FINAL_EXEC_DIR%%RESET%%BG_GLASS%
    goto :finish
)

:: 3. COM SUBSYSTEM SELF-REGISTRATION PIPELINE
echo %O2%        [*] Processing OLE/COM Registrations...%RESET%%BG_GLASS%
if exist "%FINAL_EXEC_DIR%\DarkComHeadless.dll" (
    regsvr32.exe /s "%FINAL_EXEC_DIR%\DarkComHeadless.dll"
                [SUCCESS] DarkComHeadless.dll registration.
)
if exist "%FINAL_EXEC_DIR%\WebView2Loader.dll" (
    regsvr32.exe /s "%FINAL_EXEC_DIR%\WebView2Loader.dll"
                [SUCCESS] WebView2Loader.dll registration.
)

:: 4. GENERATE CLEAN COMMAND ROUTER ABSTRACTION WRAPPER
echo @echo off > "%FINAL_EXEC_DIR%\dc2url.bat"
echo "%FINAL_EXEC_DIR%\dc2url.exe" %%* >> "%FINAL_EXEC_DIR%\dc2url.bat"
                [SUCCESS] installed 'dc2url.bat' successfully.

:: 5. MULTI-ARCHITECTURE CROSS-REGISTRY LAYER MAPS
echo %O2%        [*] Auto Configuring dc2url for windows...%RESET%%BG_GLASS%

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

:: 6. REGISTRATION IN WINDOWS PROGRAMS SCREEN (POINTS TO VERSION UNINSTALLER)
echo %O2%        [*] Auto Registering dc2url into Windows...%RESET%%BG_GLASS%

set "UNINSTALL_KEY=HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\dc2url"
reg add "%UNINSTALL_KEY%" /f /v "DisplayName" /t REG_SZ /d "dc2url (%VERSION_NAME%)" >nul 2>&1
reg add "%UNINSTALL_KEY%" /f /v "UninstallString" /t REG_SZ /d "\"%VERSION_DIR%\uninstall.bat\"" >nul 2>&1
reg add "%UNINSTALL_KEY%" /f /v "DisplayIcon" /t REG_SZ /d "%VERSION_DIR%\favi-con.ico" >nul 2>&1
reg add "%UNINSTALL_KEY%" /f /v "DisplayVersion" /t REG_SZ /d "%VERSION_NAME%" >nul 2>&1
reg add "%UNINSTALL_KEY%" /f /v "Publisher" /t REG_SZ /d "Mercwar AI" >nul 2>&1
reg add "%UNINSTALL_KEY%" /f /v "EstimatedSize" /t REG_DWORD /d 1024 >nul 2>&1
reg add "%UNINSTALL_KEY%" /f /v "NoModify" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "%UNINSTALL_KEY%" /f /v "NoRepair" /t REG_DWORD /d 1 /f >nul 2>&1

:: Double mirror registry visibility configuration to WoW6432Node space
set "UNINSTALL_KEY_32=HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\dc2url"
reg add "%UNINSTALL_KEY_32%" /f /v "DisplayName" /t REG_SZ /d "dc2url (%VERSION_NAME%)" >nul 2>&1
reg add "%UNINSTALL_KEY_32%" /f /v "UninstallString" /t REG_SZ /d "\"%VERSION_DIR%\uninstall.bat\"" >nul 2>&1
reg add "%UNINSTALL_KEY_32%" /f /v "DisplayIcon" /t REG_SZ /d "%VERSION_DIR%\favi-con.ico" >nul 2>&1
reg add "%UNINSTALL_KEY_32%" /f /v "DisplayVersion" /t REG_SZ /d "%VERSION_NAME%" >nul 2>&1
reg add "%UNINSTALL_KEY_32%" /f /v "Publisher" /t REG_SZ /d "Mercwar AI" >nul 2>&1
reg add "%UNINSTALL_KEY_32%" /f /v "EstimatedSize" /t REG_DWORD /d 1024 >nul 2>&1
reg add "%UNINSTALL_KEY_32%" /v "NoModify" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "%UNINSTALL_KEY_32%" /v "NoRepair" /t REG_DWORD /d 1 /f >nul 2>&1

:: 7. MASTER SYSTEM ENVIRONMENT VARIABLE & MACHINE PATH INJECTION
echo %O2%        [AVIS] Saving config and completing registration...%RESET%%BG_GLASS%

:: Set persistent machine environment variable pointer
setx /M dc2url_path "%FINAL_EXEC_DIR%" >nul 2>&1

:: Forcefully prepend target directory to the Machine (System) PATH registry safely without duplicates
powershell -Command "$m=[System.Environment]::GetEnvironmentVariable('PATH','Machine'); if($m -split ';' -notcontains '%FINAL_EXEC_DIR%'){[System.Environment]::SetEnvironmentVariable('PATH',('%FINAL_EXEC_DIR%;'+$m),'Machine')}" >nul 2>&1

:: Prepend to User PATH block as a fallback layer
powershell -Command "$p=[System.Environment]::GetEnvironmentVariable('PATH','User'); if($p -split ';' -notcontains '%FINAL_EXEC_DIR%'){[System.Environment]::SetEnvironmentVariable('PATH',('%FINAL_EXEC_DIR%;'+$p),'User')}" >nul 2>&1

:: Broadcast environment changes globally to invalidate stale Win32 process caches
powershell -Command "$advapi = '[DllImport(\"user32.dll\",SetLastError=true)]public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, IntPtr wParam, String lParam, uint fuFlags, uint uTimeout, out IntPtr lpdwResult);'; $type = Add-Type -MemberDefinition $advapi -Name 'Win32' -Namespace 'Win32Functions' -PassThru; $res = [IntPtr]::Zero; [Win32Functions.Win32]::SendMessageTimeout([IntPtr]0xffff, 0x001A, [IntPtr]::Zero, 'Environment', 2, 5000, [out]$res)" >nul 2>&1

:: Synchronize path variables onto the running terminal session instance context immediately
set "PATH=%FINAL_EXEC_DIR%;%PATH%"

echo                 [SUCCESS] dc2url is now fully installed and at your command!
echo.
echo %Y2%        [To uninstall, goto add/remove programs]%RESET%%BG_GLASS%
echo.

:finish
echo %TXT%        Please Restart your command window to begin to use dc2url...%RESET%
pause >nul

exit /b 0