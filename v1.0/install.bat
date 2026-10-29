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
set "MIDI_OUTPUT=%TEMP%\transformers.mid"
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
echo %O1%        ██████╗  █████╗ ██████╗ ██╗  ██╗ ██████╗ ██████╗ ███╗   ███╗██████╗ %RESET%%BG_GLASS%
echo %O2%        ██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝██╔════╝██╔═══██╗████╗ ████║╚════██╗%RESET%%BG_GLASS%
echo %O3%        ██║  ██║███████║██████╔╝█████╔╝ ██║     ██║   ██║██╔████╔██║ █████╔╝%RESET%%BG_GLASS%
echo %Y1%        ██║  ██║██╔══██║██╔══██║██╔═██╗ ██║     ██║   ██║██║╚██╔╝██║██╔═══╝ %RESET%%BG_GLASS%
echo %Y2%        ██████╔╝██║  ██║██║  ██║██║  ██║╚██████╗╚██████╔╝██║ ╚═╝ ██║███████╗%RESET%%BG_GLASS%
echo %Y2%        ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝%RESET%%BG_GLASS%
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

echo %O2%        [*] Processing OLE/COM Registrations...%RESET%%BG_GLASS%
if exist "%FINAL_EXEC_DIR%\DarkComHeadless.dll" (
    regsvr32.exe /s "%FINAL_EXEC_DIR%\DarkComHeadless.dll"
    echo                     [SUCCESS] DarkComHeadless.dll registration.
)
if exist "%FINAL_EXEC_DIR%\WebView2Loader.dll" (
    regsvr32.exe /s "%FINAL_EXEC_DIR%\WebView2Loader.dll"
    echo                     [SUCCESS] WebView2Loader.dll registration.
)

echo @echo off > "%FINAL_EXEC_DIR%\dc2url.bat"
echo "%FINAL_EXEC_DIR%\dc2url.exe" %%* >> "%FINAL_EXEC_DIR%\dc2url.bat"
echo                     [SUCCESS] installed 'dc2url.bat' successfully.

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

set "PATH=%FINAL_EXEC_DIR%;%PATH%"

echo                     [SUCCESS] dc2url is now fully installed and at your command!
echo.

:: =========================================================================
:: SOUND ARGUMENT REGISTRY CHECK & AUDIO PLAYBACK ROUTINE
:: =========================================================================
echo %O2%        [*] Detecting sound settings ...%RESET%%BG_GLASS%
@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"



set "GET_URL=http://httpbin.org/get?test=winhttp_fastpath"
set "POST_URL=http://httpbin.org/post"
set "BINARY_URL=http://httpbin.org/bytes/1024"
set "BINARY_OUTPUT=httpbin_binary.bin"

echo ============================================================
echo DARK-COM-2 :: WINHTTP FAST-PATH (-nojs) VERIFICATION SUITE
echo ============================================================
echo.

if exist "%BINARY_OUTPUT%" del /f /q "%BINARY_OUTPUT%"

echo [TEST 1] GET Request (WinHTTP Fast-Path)
echo ------------------------------------------------------------
dc2url.exe "%GET_URL%" -v -nojs

echo.
echo ============================================================
echo [TEST 2] POST Request with JSON Payload (WinHTTP Fast-Path)
echo ============================================================
dc2url.exe "%POST_URL%" -X POST -d "{\"action\":\"winhttp_test\",\"status\":\"active\"}" -v --nojs

echo.
echo ============================================================
echo [TEST 3] Binary Stream Download (WinHTTP Fast-Path)
echo ============================================================
echo Downloading 1024 raw bytes directly to disk...
dc2url.exe -o "%BINARY_OUTPUT%" "%BINARY_URL%" -v -nojs

echo.
if exist "%BINARY_OUTPUT%" (
    for %%I in ("%BINARY_OUTPUT%") do set "FILESIZE=%%~zI"
    echo [SUCCESS] Binary download completed successfully!
    echo [FILE] Target: %BINARY_OUTPUT%
    echo [SIZE] Bytes transferred: !FILESIZE! bytes
    
    if !FILESIZE! EQU 1024 (
        echo [VERIFICATION] Byte count matches exact expected payload size.
    ) else (
        echo [WARNING] Size mismatch. Expected 1024 bytes, got !FILESIZE! bytes.
    )
) else (
    echo [ERROR] Binary download failed. Output file was not created.
)

echo.
echo ============================================================
echo ALL WINHTTP FAST-PATH TESTS COMPLETED
echo ============================================================


set "TARGET_URL=https://mercwar01.byethost3.com/darkcom2/echo.php"
set "MIDI_OUTPUT=transformers.mid"
set "MIDI_URL=https://raw.githubusercontent.com/mercwar/dc2url/main/sound/%MIDI_OUTPUT%"

echo ============================================================
echo DARK-COM-2 :: FULL CURL-COMPATIBLE VERIFICATION SUITE
echo ============================================================
echo.

if exist "%MIDI_OUTPUT%" del /f /q "%MIDI_OUTPUT%"

echo [TEST 1] URL First (Standard Curl Style)
echo ------------------------------------------------------------
dc2url.exe "%TARGET_URL%" -X POST -d "{\"action\":\"test_url_first\"}" -v

echo.
echo ============================================================
echo [TEST 2] Flags First (Alternative Curl Style)
echo ============================================================
dc2url.exe -X POST -d "{\"action\":\"test_flags_first\"}" "%TARGET_URL%" --verbose

echo.
echo ============================================================
echo [TEST 3] Long Flags Style
echo ============================================================
dc2url.exe --request POST --data "{\"action\":\"test_long_flags\"}" "%TARGET_URL%" --verbose

echo.
echo ============================================================
echo SEQUENTIAL VERIFICATION: PERSISTENCE TRACKING BLOCK
echo ============================================================
echo.
echo Iteration #1: Sending payload...
dc2url.exe --request POST --data "{\"iteration\":1}" "%TARGET_URL%" -v
echo.

echo Iteration #2: Testing value increment updates...
dc2url.exe --request POST --data "{\"iteration\":2}" "%TARGET_URL%" -v
echo.

echo ============================================================
echo BINARY DOWNLOAD TEST: WINHTTP FAST-PATH (-nojs)
echo ============================================================
echo Downloading canonical MIDI asset via dc2url.exe -o flag...
dc2url.exe  -o "%MIDI_OUTPUT%" "%MIDI_URL%" 

echo.
if exist "%MIDI_OUTPUT%" (
    for %%I in ("%MIDI_OUTPUT%") do set "FILESIZE=%%~zI"
    echo [SUCCESS] Binary download completed successfully!
    echo [FILE] Target: %MIDI_OUTPUT%
    echo [SIZE] Bytes transferred: !FILESIZE! bytes
    
    if !FILESIZE! GTR 1000 (
        echo [VERIFICATION] File size is valid. Launching audio playback test...
        :: Passing the file directly to start triggers the system's default MIDI player
        start "" "%MIDI_OUTPUT%"
    ) else (
        echo [WARNING] File size is suspiciously small. Verify redirect response stream.
    )
) else (
    echo [ERROR] Binary download failed. Output file was not created.
)

@echo off
:: Enable delayed expansion so !FILESIZE! works inside IF statements
setlocal EnableDelayedExpansion

set "SOUND_SETTING=off"
for /f "tokens=2*" %%A in ('reg query "HKCU\Software\Eclipse\Launcher" /v "SoundArg" 2^>nul') do (
    set "SOUND_SETTING=%%B"
)

if /i "%SOUND_SETTING%"=="on" (
    if exist "%MIDI_OUTPUT%" del /f /q "%MIDI_OUTPUT%" >nul 2>&1
    dc2url -o "%MIDI_URL%" "%MIDI_OUTPUT%"

    if exist "%MIDI_OUTPUT%" (
        for %%I in ("%MIDI_OUTPUT%") do set "FILESIZE=%%~zI"
        
        if !FILESIZE! GTR 1000 (
            echo [Transformation] TRANSFORM!
            start "" "%MIDI_OUTPUT%"
        ) else (
            echo [AVIS FAILURE] File size is too small (!FILESIZE! bytes). Check network or proxy.
        )
    ) else (
        echo [AVIS ERROR] Binary download failed.
    )
) else (
    echo %TXT%        [INFO] Skipping audio playback.%RESET%%BG_GLASS%
)

echo.
echo %Y2%        [To uninstall, go to Add/Remove Programs or run uninstall.bat]%RESET%%BG_GLASS%
echo.

:finish
echo %TXT%        Your copy of dc2url in now installed cmd:\ dc2url -nojs [curl compat]...%RESET%
echo.

:: =========================================================================
:: EXECUTE EXISTING LOCAL SETUP SCRIPT DIRECTLY
:: =========================================================================
if exist "%ROOT_DIR%\setup.bat" (
    echo %O2%        [?] Install Eclipse for MS Windows 11 ? (Y/N)%RESET%%BG_GLASS%
    choice /c YN /n /m "        Press Y to run setup, or N to skip: "
    
    if errorlevel 2 (
        echo %TXT%        [INFO] Exiting...%RESET%%BG_GLASS%
    ) else if errorlevel 1 (
        echo %O2%        [*] Launching local setup...%RESET%%BG_GLASS%
        cd /d "%FINAL_EXEC_DIR%"
        timeout /t 2 >nul
        
        :: Bypassed the %TEMP% check to run the local file directly
        call "%ROOT_DIR%\setup.bat"
    )
) else (
    echo %TXT%        [error] Check Installation %FINAL_EXEC_DIR%.%RESET%%BG_GLASS%
)

echo.
echo.
endlocal
exit /b 0


echo.
echo ============================================================
echo ALL API DIAGNOSTICS AND BINARY TESTS COMPLETED
echo ============================================================
pause

