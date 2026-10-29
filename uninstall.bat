@echo off
:: InstallShield Subsystem: Force Elevated Administrative Token Context
:: -----------------------------------------------------------------------------
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' neq '0' ( goto :RequestUAC ) else ( goto :ExecuteUninstaller )

:RequestUAC
    powershell -Command "Start-Process '%~f0' -Verb RunAs -WorkingDirectory '%~dp0'"
    exit /b

:ExecuteUninstaller
setlocal DisableDelayedExpansion

:: Store original script directory immediately
set "SCRIPT_DIR=%~dp0"

:: 1. Define Target Paths matching the installer schema
set "TARGET=%ProgramFiles%\dc2url"
set "TARGET_BASE=%TARGET%\v1.0"
set "FINAL_EXEC_DIR=%TARGET_BASE%\exec"

title Eclipse Uninstaller

mode con: cols=120 lines=36
chcp 65001 >nul 2>&1
color 0E

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
echo %R1%        ███████╗ ██████╗██╗     ██║██████╗ ███████╗███████╗%RESET%%BG_GLASS%
echo %R2%        ██╔════╝██╔════╝██║     ██║██╔══██╗██╔════╝██╔════╝%RESET%%BG_GLASS%
echo %R1%        █████╗  ██║     ██║     ██║██████╔╝███████╗█████╗  %RESET%%BG_GLASS%
echo %Y1%        ██╔══╝  ██║     ██║     ██║██╔═══╝ ╚════██║██╔══╝  %RESET%%BG_GLASS%
echo %Y2%        ███████╗╚██████╗███████╗██║██║     ███████║███████╗%RESET%%BG_GLASS%
echo %Y2%        ╚══════╝ ╚═════╝╚══════╝╚═╝╚═╝     ╚══════╝╚══════╝%RESET%%BG_GLASS%
echo %R2%    ====================================================================================%RESET%%BG_GLASS%
echo %Y2%                              Eclipse Uninstaller%RESET%%BG_GLASS%
echo %R2%    ====================================================================================%RESET%%BG_GLASS%
echo.

:: =========================================================================
:: 1. PROCESS TERMINATION & DLL UNREGISTRATION
:: =========================================================================
echo %R2%        [*] Closing active Eclipse programs...%RESET%%BG_GLASS%
taskkill /f /im eclipse.exe >nul 2>&1

echo %R2%        [*] Unhooking system DLL components...%RESET%%BG_GLASS%
if exist "%FINAL_EXEC_DIR%\DarkComHeadless.dll" (
    regsvr32.exe /u /s "%FINAL_EXEC_DIR%\DarkComHeadless.dll" >nul 2>&1
    echo                     [OK] Removed DarkComHeadless.dll registration.
)
if exist "%FINAL_EXEC_DIR%\WebView2Loader.dll" (
    regsvr32.exe /u /s "%FINAL_EXEC_DIR%\WebView2Loader.dll" >nul 2>&1
    echo                     [OK] Removed WebView2Loader.dll registration.
)

:: =========================================================================
:: 2. REGISTRY CLEANUP
:: =========================================================================
echo %R2%        [*] Removing Windows Registry entries and shortcuts...%RESET%%BG_GLASS%

reg delete "HKCU\Software\Eclipse" /f >nul 2>&1

reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\App Paths\eclipse.exe" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\App Paths\eclipse.exe" /f >nul 2>&1
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\eclipse.exe" /f >nul 2>&1
reg delete "HKCU\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\eclipse.exe" /f >nul 2>&1

:: FIXED: Added User-scoped Uninstall keys (this is where Windows reads 'Programs and Features' for user installs)
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\Eclipse" /f >nul 2>&1
reg delete "HKCU\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Eclipse" /f >nul 2>&1

reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\Eclipse" /f >nul 2>&1
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Eclipse" /f >nul 2>&1

echo                     [OK] Windows Registry cleared.

:: =========================================================================
:: 3. ENVIRONMENT PATH PURGE & BROADCAST
:: =========================================================================
echo %R2%        [*] Removing Eclipse from system environment variables...%RESET%%BG_GLASS%

reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v eclipse_path /f >nul 2>&1

powershell -Command "$m=[System.Environment]::GetEnvironmentVariable('PATH','Machine'); if($m -split ';' -contains '%FINAL_EXEC_DIR%'){$new=($m -split ';' | Where-Object {$_ -neq '%FINAL_EXEC_DIR%'}) -join ';'; [System.Environment]::SetEnvironmentVariable('PATH',$new,'Machine')}" >nul 2>&1
powershell -Command "$p=[System.Environment]::GetEnvironmentVariable('PATH','User'); if($p -split ';' -contains '%FINAL_EXEC_DIR%'){$new=($p -split ';' | Where-Object {$_ -neq '%FINAL_EXEC_DIR%'}) -join ';'; [System.Environment]::SetEnvironmentVariable('PATH',$new,'User')}" >nul 2>&1

powershell -Command "$advapi = '[DllImport(\"user32.dll\",SetLastError=true)]public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, IntPtr wParam, String lParam, uint fuFlags, uint uTimeout, out IntPtr lpdwResult);'; $type = Add-Type -MemberDefinition $advapi -Name 'Win32' -Namespace 'Win32Functions' -PassThru; $res = [IntPtr]::Zero; [Win32Functions.Win32]::SendMessageTimeout([IntPtr]0xffff, 0x001A, [IntPtr]::Zero, 'Environment', 2, 5000, [out]$res)" >nul 2>&1

echo                     [OK] System environment updated.

:: =========================================================================
:: 4. FILESYSTEM CLEANUP (TARGETED FILE REMOVAL ONLY)
:: =========================================================================
echo %R2%        [*] Deleting Eclipse application files...%RESET%%BG_GLASS%

if exist "%FINAL_EXEC_DIR%\eclipse.exe" del /f /q "%FINAL_EXEC_DIR%\eclipse.exe" >nul 2>&1
if exist "%FINAL_EXEC_DIR%\menu.json" del /f /q "%FINAL_EXEC_DIR%\menu.json" >nul 2>&1


echo.
echo %R3%    ====================================================================================%RESET%%BG_GLASS%
echo %Y1%                        UNINSTALLATION COMPLETE%RESET%%BG_GLASS%
echo %R3%    ====================================================================================%RESET%%BG_GLASS%
echo.


echo %TXT%        Eclipse has been removed from your computer.%RESET%
echo.


set "REINSTALL="
set /p "REINSTALL=%Y2%        Would you like to reinstall Eclipse now? (Y/N): %RESET%"

if /i "%REINSTALL%"=="y" (
    call "%TARGET%\setup.bat"
)



exit /b 0
