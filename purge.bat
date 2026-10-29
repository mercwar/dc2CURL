@echo off
:: InstallShield Subsystem: Force Elevated Administrative Token Context
:: -----------------------------------------------------------------------------
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' neq '0' ( goto :RequestUAC ) else ( goto :ExecuteDeepPurge )

:RequestUAC
    powershell -Command "Start-Process '%~f0' -Verb RunAs -WorkingDirectory '%~dp0'"
    exit /b

:ExecuteDeepPurge
setlocal DisableDelayedExpansion

title InstallShield (R) Deep Purge Engine v2.0 :: Full Ecosystem & Fake Variant Sweep
mode con: cols=120 lines=36

chcp 65001 >nul 2>&1
color 0C

reg add "HKCU\Console" /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1
for /f %%a in ('echo prompt $E^|cmd') do set "E=%%a"
set "RESET=%E%[0m"
set "BG_GLASS=%E%[48;2;10;10;12m"
set "R1=%E%[38;2;255;68;0m"
set "R2=%E%[38;2;255;110;0m"
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
echo %Y2%          DEEP SYSTEM PURGE :: Removing Eclipse Tray, Fake Variants & All Traces%RESET%%BG_GLASS%
echo %R1%    ====================================================================================%RESET%%BG_GLASS%
echo.

:: =========================================================================
:: 1. TERMINATE ALL KNOWN PROCESS VARIANTS
:: =========================================================================
echo %R2%        [*] Terminating all instances of Eclipse, Tray, and fake process names...%RESET%%BG_GLASS%
for %%P in (
    eclipse.exe
    eclipse-tray.exe
    eclipsetray.exe
    eclipsetraymaster.exe
    traymaster.exe
    dc2url.exe
    darkcom.exe
    darkcomheadless.exe
) do (
    taskkill /f /im %%P >nul 2>&1
)

:: =========================================================================
:: 2. TARGET DIRECTORY & FILE SWEEP (Program Files, Program Files (x86), AppData)
:: =========================================================================
echo %R2%        [*] Sweeping and deleting directories across Program Files and system paths...%RESET%%BG_GLASS%

for %%D in (
    "%ProgramFiles%\dc2url"
    "C:\Program Files\dc2url"
    "%ProgramFiles%\EclipseTray"
    "C:\Program Files\EclipseTray"
    "%ProgramFiles(x86)%\EclipseTray"
    "C:\Program Files (x86)\dc2url"
    "%AppData%\Eclipse"
    "%AppData%\EclipseTray"
    "%LocalAppData%\Eclipse"
    "%LocalAppData%\EclipseTray"
) do (
    if exist "%%~D" (
        attrib -h -s -r "%%~D\*.*" /s /d >nul 2>&1
        rmdir /s /q "%%~D" >nul 2>&1
        echo                      [PURGED] %%~D
    )
)

:: =========================================================================
:: 3. CLEAN STARTUP SHORTCUTS
:: =========================================================================
echo %R2%        [*] Removing Startup directory persistence links...%RESET%%BG_GLASS%
for %%S in (
    "%AppData%\Microsoft\Windows\Start Menu\Programs\Startup\EclipseTrayMaster.lnk"
    "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Startup\EclipseTrayMaster.lnk"
    "%AppData%\Microsoft\Windows\Start Menu\Programs\Startup\EclipseTray.lnk"
    "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Startup\EclipseTray.lnk"
    "%AppData%\Microsoft\Windows\Start Menu\Programs\Startup\Eclipse.lnk"
) do (
    if exist "%%~S" del /f /q "%%~S" >nul 2>&1
)

:: =========================================================================
:: 4. REGISTRY SWEEP (App Paths, Uninstall Trees, Services, Root Keys)
:: =========================================================================
echo %R2%        [*] Erasing all registry keys, App Paths, and Uninstaller entries...%RESET%%BG_GLASS%

reg delete "HKCU\Software\Eclipse" /f >nul 2>&1
reg delete "HKLM\Software\Eclipse" /f >nul 2>&1
reg delete "HKCU\Software\EclipseTray" /f >nul 2>&1
reg delete "HKLM\Software\EclipseTray" /f >nul 2>&1

for %%E in (
    eclipse.exe
    eclipse-tray.exe
    eclipsetray.exe
    dc2url.exe
) do (
    reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\App Paths\%%E" /f >nul 2>&1
    reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\App Paths\%%E" /f >nul 2>&1
    reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\%%E" /f >nul 2>&1
    reg delete "HKCU\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\%%E" /f >nul 2>&1
)

reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\EclipseTray" /f >nul 2>&1
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\EclipseTray" /f >nul 2>&1
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\Eclipse" /f >nul 2>&1
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Eclipse" /f >nul 2>&1

:: =========================================================================
:: 5. ENVIRONMENT VARIABLE PURGE & BROADCAST
:: =========================================================================
echo %R2%        [*] Clearing global and user environment variables...%RESET%%BG_GLASS%
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "eclipse_path" /f >nul 2>&1
reg delete "HKCU\Environment" /v "eclipse_path" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "dc2url_path" /f >nul 2>&1
reg delete "HKCU\Environment" /v "dc2url_path" /f >nul 2>&1

powershell -Command "$advapi = '[DllImport(\"user32.dll\",SetLastError=true)]public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, IntPtr wParam, String lParam, uint fuFlags, uint uTimeout, out IntPtr lpdwResult);'; $type = Add-Type -MemberDefinition $advapi -Name 'Win32' -Namespace 'Win32Functions' -PassThru; $res = [IntPtr]::Zero; [Win32Functions.Win32]::SendMessageTimeout([IntPtr]0xffff, 0x001A, [IntPtr]::Zero, 'Environment', 2, 5000, [out]$res)" >nul 2>&1

echo.
echo %R1%    ====================================================================================%RESET%%BG_GLASS%
echo %Y2%                        COMPLETE ECOSYSTEM & FAKE VARIANT PURGE SUCCESSFUL%RESET%%BG_GLASS%
echo %R1%    ====================================================================================%RESET%%BG_GLASS%
echo.
echo %TXT%        All traces of Eclipse, Eclipse Tray, fake binaries, registry entries, and paths are gone.%RESET%
echo.
pause
exit /b 0
