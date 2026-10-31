@echo off

:: InstallShield Subsystem: Force Elevated Administrative Token Context
:: -----------------------------------------------------------------------------
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' neq '0' ( goto :RequestUAC ) else ( goto :ExecuteSetup )

:RequestUAC
    powershell -Command "Start-Process '%~f0' -Verb RunAs -WorkingDirectory '%~dp0'"
    exit /b

:ExecuteSetup
setlocal EnableDelayedExpansion

:: =========================================================================
:: DIRECTORY RESOLUTION MAPPING (MANIFEST LAYOUT)
:: =========================================================================
set "ROOT_DIR=%~dp0"
set "VERSION_DIR=%ROOT_DIR%"
if "%VERSION_DIR:~-1%"=="\" set "VERSION_DIR=%VERSION_DIR:~0,-1%"

for %%I in ("%VERSION_DIR%") do set "VERSION_NAME=%%~nxI"
for %%I in ("%VERSION_DIR%\..") do set "BASE_DIR=%%~fI"

set "FINAL_EXEC_DIR=%VERSION_DIR%\exec"
set "FINAL_EXE_PATH=%FINAL_EXEC_DIR%\dc2url.exe"

set "MIDI_URL=https://raw.githubusercontent.com/mercwar/dc2url/main/sound/transformers.mid"

cd /d "%FINAL_EXEC_DIR%"

title InstallShield (R) Setup Launcher v1.0 :: dc2url Master Deployment Engine
mode con: cols=120 lines=34

chcp 65001 >nul 2>&1
color 0E

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
echo %O1%      ######   #####  ######  ##  ##  #####  ######  ###   ### ###### %RESET%%BG_GLASS%
echo %O2%      ##   ## ##   ## ##   ## ## ##   ##     ##   ## #### ####     ## %RESET%%BG_GLASS%
echo %O3%      ##   ## ####### ######  #####   ##     ##   ## ## ### ##  ##### %RESET%%BG_GLASS%
echo %Y1%      ##   ## ##   ## ##   ## ##  ##  ##     ##   ## ##     ##      ## %RESET%%BG_GLASS%
echo %Y2%      ######  ##   ## ##   ## ##  ##   #####  #####  ##     ## ####### %RESET%%BG_GLASS%
echo %O2%    ====================================================================================%RESET%%BG_GLASS%
echo %Y2%                        dc2url Core Cyborg Ecosystem Installer%RESET%%BG_GLASS%
echo %O2%    ====================================================================================%RESET%%BG_GLASS%
echo.

echo %O2%        [*] Granting full write access permissions to %VERSION_DIR%...%RESET%%BG_GLASS%
icacls "%VERSION_DIR%" /grant Users:(OI)(CI)F /t >nul 2>&1

if not exist "%FINAL_EXE_PATH%" (
    echo %O1%        [AVIS FAILED] Execution binaries are missing in: %FINAL_EXEC_DIR%%RESET%%BG_GLASS%
    goto :finish
)

echo %O2%        [*] Processing OLE/COM & System DLL Registrations...%RESET%%BG_GLASS%
if exist "%FINAL_EXEC_DIR%\dc2ws2.dll" (
    regsvr32.exe /s "%FINAL_EXEC_DIR%\dc2ws2.dll"
    echo                      [SUCCESS] dc2ws2.dll network subsystem registered.
)
if exist "%FINAL_EXEC_DIR%\DarkComHeadless.dll" (
    regsvr32.exe /s "%FINAL_EXEC_DIR%\DarkComHeadless.dll"
    echo                      [SUCCESS] DarkComHeadless.dll registration.
)
if exist "%FINAL_EXEC_DIR%\WebView2Loader.dll" (
    regsvr32.exe /s "%FINAL_EXEC_DIR%\WebView2Loader.dll"
    echo                      [SUCCESS] WebView2Loader.dll registration.
)

echo @echo off > "%FINAL_EXEC_DIR%\dc2url.bat"
echo "%FINAL_EXEC_DIR%\dc2url.exe" %%* >> "%FINAL_EXEC_DIR%\dc2url.bat"
echo                      [SUCCESS] installed 'dc2url.bat' successfully.

echo %O2%        [*] Auto Configuring dc2url for Windows App Paths...%RESET%%BG_GLASS%

reg add "HKCU\Software\dc2url\Launcher" /f /v "InstallPath" /t REG_SZ /d "%FINAL_EXEC_DIR%" >nul 2>&1

reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f /ve /t REG_SZ /d "%FINAL_EXE_PATH%" >nul 2>&1
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f /v "Path" /t REG_SZ /d "%FINAL_EXEC_DIR%" >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f /ve /t REG_SZ /d "%FINAL_EXE_PATH%" >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f /v "Path" /t REG_SZ /d "%FINAL_EXEC_DIR%" >nul 2>&1

reg add "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f /ve /t REG_SZ /d "%FINAL_EXE_PATH%" >nul 2>&1
reg add "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f /v "Path" /t REG_SZ /d "%FINAL_EXEC_DIR%" >nul 2>&1
reg add "HKCU\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f /ve /t REG_SZ /d "%FINAL_EXE_PATH%" >nul 2>&1
reg add "HKCU\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\dc2url.exe" /f /v "Path" /t REG_SZ /d "%FINAL_EXEC_DIR%" >nul 2>&1

echo %O2%        [*] Auto Registering dc2url into Windows Installed Apps...%RESET%%BG_GLASS%

for %%H in (HKLM HKCU) do (
    for %%N in ("" "\Wow6432Node") do (
        reg add "%%H%%~N\Software\Microsoft\Windows\CurrentVersion\Uninstall\dc2url" /f /v "DisplayName" /t REG_SZ /d "dc2url" >nul 2>&1
        reg add "%%H%%~N\Software\Microsoft\Windows\CurrentVersion\Uninstall\dc2url" /f /v "UninstallString" /t REG_SZ /d "\"%VERSION_DIR%\uninstall.bat\"" >nul 2>&1
        reg add "%%H%%~N\Software\Microsoft\Windows\CurrentVersion\Uninstall\dc2url" /f /v "InstallLocation" /t REG_SZ /d "%VERSION_DIR%\" >nul 2>&1
        reg add "%%H%%~N\Software\Microsoft\Windows\CurrentVersion\Uninstall\dc2url" /f /v "DisplayIcon" /t REG_SZ /d "%BASE_DIR%\favi-con.ico" >nul 2>&1
        reg add "%%H%%~N\Software\Microsoft\Windows\CurrentVersion\Uninstall\dc2url" /f /v "DisplayVersion" /t REG_SZ /d "%VERSION_NAME%" >nul 2>&1
        reg add "%%H%%~N\Software\Microsoft\Windows\CurrentVersion\Uninstall\dc2url" /f /v "Publisher" /t REG_SZ /d "Mercwar AI" >nul 2>&1
        reg add "%%H%%~N\Software\Microsoft\Windows\CurrentVersion\Uninstall\dc2url" /f /v "EstimatedSize" /t REG_DWORD /d 1024 >nul 2>&1
        reg add "%%H%%~N\Software\Microsoft\Windows\CurrentVersion\Uninstall\dc2url" /f /v "NoModify" /t REG_DWORD /d 1 /f >nul 2>&1
        reg add "%%H%%~N\Software\Microsoft\Windows\CurrentVersion\Uninstall\dc2url" /f /v "NoRepair" /t REG_DWORD /d 1 /f >nul 2>&1
    )
)

echo %O2%        [AVIS] Saving config and completing registration...%RESET%%BG_GLASS%

setx /M dc2url_path "%FINAL_EXEC_DIR%" >nul 2>&1

powershell -Command "$m=[System.Environment]::GetEnvironmentVariable('PATH','Machine'); if($m -split ';' -notcontains '%FINAL_EXEC_DIR%'){[System.Environment]::SetEnvironmentVariable('PATH',('%FINAL_EXEC_DIR%;'+$m),'Machine')}" >nul 2>&1
powershell -Command "$p=[System.Environment]::GetEnvironmentVariable('PATH','User'); if($p -split ';' -notcontains '%FINAL_EXEC_DIR%'){[System.Environment]::SetEnvironmentVariable('PATH',('%FINAL_EXEC_DIR%;'+$p),'User')}" >nul 2>&1

powershell -Command "$advapi = '[DllImport(\"user32.dll\",SetLastError=true)]public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, IntPtr wParam, String lParam, uint fuFlags, uint uTimeout, out IntPtr lpdwResult);'; $type = Add-Type -MemberDefinition $advapi -Name 'Win32' -Namespace 'Win32Functions' -PassThru; $res = [IntPtr]::Zero; [Win32Functions.Win32]::SendMessageTimeout([IntPtr]0xffff, 0x001A, [IntPtr]::Zero, 'Environment', 2, 5000, [out]$res)" >nul 2>&1

echo                     [SUCCESS] dc2url is now fully installed and at your command!
echo.

set "MIDI_OUTPUT=%BASE_DIR%\sound\transformers.mid"
if not exist "%BASE_DIR%\sound" mkdir "%BASE_DIR%\sound"

echo.
echo %O2%        [*] Detecting sound settings ...%RESET%%BG_GLASS%

set "SOUND_SETTING=off"
for /f "tokens=2*" %%A in ('reg query "HKCU\Software\Eclipse\Launcher" /v "SoundArg" 2^>nul') do (
    set "SOUND_SETTING=%%B"
)

if /i "%SOUND_SETTING%"=="on" (
    if exist "%MIDI_OUTPUT%" del /f /q "%MIDI_OUTPUT%" >nul 2>&1
    
    dc2url -o "%MIDI_OUTPUT%" "%MIDI_URL%"
    
    echo.
    if exist "%MIDI_OUTPUT%" (
        for %%I in ("%MIDI_OUTPUT%") do set "FILESIZE=%%~zI"
        
        if !FILESIZE! LSS 1000 goto bad_file
        echo.
        echo %Y2%        [Transformation] TRANSFORM... %RESET%%BG_GLASS%
        start "" "%MIDI_OUTPUT%"
        
    ) else (
        echo [AVIS ERROR] Binary download failed.
    )
) else (
    echo %TXT%        [INFO] Skipping audio playback.%RESET%%BG_GLASS%
)
goto finish

:bad_file
echo [AVIS FAILURE] File size is too small (!FILESIZE! bytes). Check network or proxy.

:finish
echo.
echo %Y2%        [To uninstall, go to Add/Remove Programs or run uninstall.bat]%RESET%%BG_GLASS%
echo.
echo %TXT%        Your copy of dc2url in now installed cmd:\ dc2url -nojs [curl compat]...%RESET%
echo.

if not exist "%BASE_DIR%\setup.bat" goto :no_setup

choice /c YN /n /m "%O2%        [?] Install Eclipse for MS Windows 11 ? (Y/N)%RESET%%BG_GLASS%"

if errorlevel 2 goto :skip_setup
if errorlevel 1 goto :run_setup

:run_setup
echo %O2%        [*] Launching local setup...%RESET%%BG_GLASS%
cd /d "%BASE_DIR%"
timeout /t 2 >nul
call "%BASE_DIR%\setup.bat"
goto :setup_end

:skip_setup
echo %Y2%        [INFO] Exiting...%RESET%%BG_GLASS%
goto :setup_end

:no_setup
echo %TXT%        [error] Check Installation %FINAL_EXEC_DIR%.%RESET%%BG_GLASS%

:setup_end
echo.
echo.
endlocal
exit /b 0
