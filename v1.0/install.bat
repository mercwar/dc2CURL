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
title InstallShield (R) Setup Launcher v1.0 :: dc2url Deployment Matrix
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
echo %Y2%                InstallShield (R) Setup Engine Deployment Block%RESET%%BG_GLASS%
echo %O2%    =====================================================================================%RESET%%BG_GLASS%
echo.

:: 1. DYNAMIC CONTEXT FOLDER PARSING RESOLUTION
set "BASE_DIR=%~dp0"
if "%BASE_DIR:~-1%"=="\" set "BASE_DIR=%BASE_DIR:~0,-1%"

:: Detect if installer is executing inside root or v1.0 folder context
echo "%BASE_DIR%" | find /i "\v1.0" >nul 2>&1
if %errorlevel% equ 0 (
    set "FINAL_EXEC_DIR=%BASE_DIR%\exec"
) else (
    if exist "%BASE_DIR%\v1.0\exec\" (
        set "FINAL_EXEC_DIR=%BASE_DIR%\v1.0\exec"
    ) else (
        set "FINAL_EXEC_DIR=%BASE_DIR%\exec"
    )
)
set "FINAL_EXE_PATH=%FINAL_EXEC_DIR%\dc2url.exe"
set "ROOT_UNINSTALL_PATH=%BASE_DIR%\uninstall.bat"

:: 2. VERIFY CORE ENGINE ARCHITECTURE
if not exist "%FINAL_EXE_PATH%" (
    echo %O1%        [CRITICAL ERROR] Core binary assets missing inside location: %FINAL_EXEC_DIR%%RESET%%BG_GLASS%
    goto :finish
)

:: 3. COM SUBSYSTEM SELF-REGISTRATION PIPELINE (InstallShield Style)
echo %O2%        [*] Initiating COM Server Layer Registrations...%RESET%%BG_GLASS%
if exist "%FINAL_EXEC_DIR%\DarkComHeadless.dll" (
    regsvr32.exe /s "%FINAL_EXEC_DIR%\DarkComHeadless.dll"
    echo                [SUCCESS] DarkComHeadless.dll mapped into target OLE registry.
)
if exist "%FINAL_EXEC_DIR%\WebView2Loader.dll" (
    echo                [INFO] WebView2Loader.dll located.
)

:: 4. GENERATE CLEAN SYSTEM EXECUTABLE WRAPPER
echo @echo off > "%FINAL_EXEC_DIR%\dc2url.bat"
echo "%FINAL_EXEC_DIR%\dc2url.exe" %%* >> "%FINAL_EXEC_DIR%\dc2url.bat"
echo                [SUCCESS] Execution wrapper 'dc2url.bat' successfully initialized targeting dc2url.exe.

:: 5. EXPLICIT WINDOWS EXECUTABLE PATH REGISTRATION (Forces tracking visibility)
echo %O2%        [*] Registering Executable Binaries in System Context...%RESET%%BG_GLASS%

:: Write to App Paths layer explicitly for structural safety
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f /ve /t REG_SZ /d "%FINAL_EXE_PATH%" >nul 2>&1
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f /v "Path" /t REG_SZ /d "%FINAL_EXEC_DIR%" >nul 2>&1

:: Use SETX to permanently bind the executable's folder to the Master System Variable array
setx /M dc2url_path "%FINAL_EXEC_DIR%" >nul 2>&1
echo                [REGISTERED] dc2url_path to: 
echo                 %FINAL_EXEC_DIR%

:: Non-destructive user environment path integration
powershell -Command "$p=[System.Environment]::GetEnvironmentVariable('PATH','User'); if($p -split ';' -notcontains '%FINAL_EXEC_DIR%'){[System.Environment]::SetEnvironmentVariable('PATH',('%FINAL_EXEC_DIR%;'+$p),'User')}" >nul 2>&1
echo                [REGISTERED] Executable path successfully written to User Environment block.

:: 6. CALCULATE INSTALLATION SIZE (KB) FOR WINDOWS APPS REGISTRY
for /f "tokens=1" %%s in ('powershell -Command "$sum = (Get-ChildItem '%FINAL_EXEC_DIR%' -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum; if($sum){[Math]::Round($sum / 1KB)}else{0}"') do set "EST_SIZE=%%s"
if "%EST_SIZE%"=="" set "EST_SIZE=1024"

:: 7. REGISTER IN WINDOWS INSTALLED PROGRAMS MATRIX (POINTING TO ROOT UNINSTALLER)
echo %O2%        [*] Copying Uninstallation Entries into Windows Apps Database...%RESET%%BG_GLASS%
set "UNINSTALL_KEY=HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\dc2url"

:: Generate structural metadata fields for Windows Apps & Features list
reg add "%UNINSTALL_KEY%" /f /v "DisplayName" /t REG_SZ /d "dc2url Utility Suite" >nul 2>&1
reg add "%UNINSTALL_KEY%" /f /v "DisplayVersion" /t REG_SZ /d "5.1" >nul 2>&1
reg add "%UNINSTALL_KEY%" /f /v "Publisher" /t REG_SZ /d "CVBGOD" >nul 2>&1
reg add "%UNINSTALL_KEY%" /f /v "InstallLocation" /t REG_SZ /d "%FINAL_EXEC_DIR%" >nul 2>&1
reg add "%UNINSTALL_KEY%" /f /v "DisplayIcon" /t REG_SZ /d "%FINAL_EXE_PATH%,0" >nul 2>&1
reg add "%UNINSTALL_KEY%" /f /v "UninstallString" /t REG_SZ /d "\"%ROOT_UNINSTALL_PATH%\"" >nul 2>&1
reg add "%UNINSTALL_KEY%" /f /v "EstimatedSize" /t REG_DWORD /d %EST_SIZE% >nul 2>&1
reg add "%UNINSTALL_KEY%" /f /v "NoModify" /t REG_DWORD /d 1 >nul 2>&1
reg add "%UNINSTALL_KEY%" /f /v "NoRepair" /t REG_DWORD /d 1 >nul 2>&1
echo                [REGISTERED] Uninstall entry written pointing to root uninstaller ^(Size: %EST_SIZE% KB^).

:: Broadcast WM_SETTINGCHANGE message globally to refresh terminal caches instantly
powershell -Command "$type = [String]; $member = [System.Runtime.InteropServices.Marshal]; $advapi = '[DllImport(\"user32.dll\",SetLastError=true)]public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, IntPtr wParam, String lParam, uint fuFlags, uint uTimeout, out IntPtr lpdwResult);'; $type = Add-Type -MemberDefinition $advapi -Name 'Win32' -Namespace 'Win32Functions' -PassThru; $result = [IntPtr]::Zero; [Win32Functions.Win32]::SendMessageTimeout([IntPtr]0xffff, 0x001A, [IntPtr]::Zero, 'Environment', 2, 5000, [out]$result)" >nul 2>&1

:: Force synchronization onto the running batch terminal instance context immediately
set "PATH=%FINAL_EXEC_DIR%;%PATH%"
echo                [BROADCAST] System environment update complete. All lookups refreshed.
echo.
echo %Y2%        [INSTALLATION COMPLETED DEVICE VERIFIED]%RESET%
echo.

:finish
echo %TXT%        Press any key to close installer suite...%RESET%
pause >nul
exit /b 0