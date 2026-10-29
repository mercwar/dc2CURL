@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1

:: ============================================================
:: SELF-ELEVATION PIPELINE (REQUIRES ADMIN FOR PROGRAM FILES)
:: ============================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList '/c', 'cd /d ""%~dp0"" && ""%~f0""' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"

:: InstallShield Setup Configuration Properties: Title Block & Bounds
title InstallShield (R) Setup Launcher v1.0 :: dc2url Master Deployment Engine
mode con: cols=120 lines=34
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
set "GRAY=%E%[38;2;115;125;145m"
set "GREEN=%E%[38;2;90;255;120m"

cls
echo %BG_GLASS%
cls

echo.
echo %O1%        ██████╗  █████╗ ██████╗ ██╗  ██╗ ██████╗ ██████╗ ███╗   ███╗██████╗ %RESET%%BG_GLASS%
echo %O2%        ██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝██╔════╝██╔═══██╗████╗ ████║╚════██╗%RESET%%BG_GLASS%
echo %O3%        ██║  ██║███████║██████╔╝█████╔╝ ██║     ██║   ██║██╔████╔██║ █████╔╝%RESET%%BG_GLASS%
echo %Y1%        ██║  ██║██╔══██║██╔══██╗██╔═██╗ ██║     ██║   ██║██║╚██╔╝██║██╔═══╝ %RESET%%BG_GLASS%
echo %Y2%        ██████╔╝██║  ██║██║  ██║██║  ██║╚██████╗╚██████╔╝██║ ╚═╝ ██║███████╗%RESET%%BG_GLASS%
echo %Y2%        ╚═════╝ ╚═╝  ╚═╝╚_╝  ╚_╝╚_╝  ╚_╝ ╚═════╝ ╚═════╝ ╚_╝     ╚_╝╚══════╝%RESET%%BG_GLASS%
echo %O2%    ====================================================================================%RESET%%BG_GLASS%
echo %Y2%                    dc2url Core Cyborg Ecosystem Installer%RESET%%BG_GLASS%
echo %O2%    ====================================================================================%RESET%%BG_GLASS%
echo.

:: ============================================================
:: TASKKILL RUNNING ECLIPSE INSTANCES TO PREVENT WRITE LOCKS
:: ============================================================
echo %O2%    [*] Terminating any active eclipse.exe processes...%RESET%
taskkill /f /im eclipse.exe >nul 2>&1
echo %GREEN%    [+] Eclipse processes cleared.%RESET%
echo.

:: ============================================================
:: TOOL DETECTION & SELECTION
:: ============================================================
set "count=0"
for %%T in (dc2url python curl mshta powershell certutil cscript bitsadmin wget node winget) do (
    where %%T >nul 2>&1
    if not errorlevel 1 (
        if /i "%%T"=="python" (
            python --version >nul 2>&1
            if not errorlevel 1 (
                set /a count+=1
                set "tool_!count!=%%T"
            )
        ) else (
            set /a count+=1
            set "tool_!count!=%%T"
        )
    )
)

if !count! equ 0 (
    echo %O1%    [-] No download engines found. Exiting.%RESET%
    pause
    exit /b
)

echo %O2%    [AVIS] Scanning system engines...%RESET%
echo.
for /l %%i in (1,1,!count!) do (
    echo     %GRAY%[%Y1%%%i%GRAY%]%TXT% !tool_%%i!%RESET%
)
echo.

set /p "TOOL_NUM=%Y2%    >>> SELECT ENGINE [1-!count!]: %RESET%"
if "!TOOL_NUM!"=="" (
    set "SELECTED_TOOL=curl"
) else (
    set "SELECTED_TOOL="
    for /l %%i in (1,1,!count!) do (
        if "!TOOL_NUM!"=="%%i" set "SELECTED_TOOL=!tool_%%i!"
    )
)
if "!SELECTED_TOOL!"=="" set "SELECTED_TOOL=curl"

:: ============================================================
:: DIRECTORY CONFIGURATION
:: ============================================================
set "DEFAULT_INSTALL=%ProgramFiles%\dc2url"
if "%DEFAULT_INSTALL%"=="" set "DEFAULT_INSTALL=%SystemDrive%\Program Files\dc2url"

echo.
echo %O2%    ------------------------------------------------------------------------------------%RESET%
echo %Y2%    [AVIS] DIRECTORY CONFIGURATION%RESET%
echo %GRAY%    Default system path: !DEFAULT_INSTALL!%RESET%
echo.

set /p "INSTALL_PATH=%Y2%    >>> ENTER FULL PATH OR PRESS ENTER FOR DEFAULT: %RESET%"
if "!INSTALL_PATH!"=="" set "INSTALL_PATH=!DEFAULT_INSTALL!"

if not exist "!INSTALL_PATH!" (
    mkdir "!INSTALL_PATH!" >nul 2>&1
)

:: ============================================================
:: DOWNLOAD CONFIG.JSON FIRST
:: ============================================================
set "CONFIG_URL=https://raw.githubusercontent.com/mercwar/dc2url/refs/heads/main/config.json"
set "CONFIG_FILE=!INSTALL_PATH!\config.json"

echo.
echo %O2%    [*] Downloading config.json using !SELECTED_TOOL!...%RESET%
call :download_!SELECTED_TOOL! "!CONFIG_URL!" "!CONFIG_FILE!" 2>error_config.log

if not exist "!CONFIG_FILE!" (
    echo %O1%    [-] Failed to download config.json.%RESET%
    if exist error_config.log type error_config.log
    del error_config.log >nul 2>&1
    pause
    exit /b
)
del error_config.log >nul 2>&1
echo %GREEN%    [+] config.json downloaded successfully.%RESET%

:: ============================================================
:: PARSE MANIFEST & LOOP NODES (RESPECTING do_not_version)
:: ============================================================
echo %O2%    [*] Parsing manifest layout and streaming payload nodes...%RESET%

set "PS_CMD=$cfg = Get-Content '!CONFIG_FILE!' -Raw | ConvertFrom-Json; $ver = $cfg.version; $skipNode = $cfg.do_not_version; foreach ($node in $cfg.manifest_layout.psobject.properties.Name) { $noVer = ($node -eq $skipNode); foreach ($item in $cfg.manifest_layout.$node) { $src = $item.source; $tgt = if ($item.target) { $item.target } else { $src }; $remoteSub = if ($noVer) { $src } else { $ver + '/' + $src }; $localSub = if ($noVer) { $tgt } else { $ver + '\' + $tgt }; [Console]::WriteLine($node + '|' + $remoteSub + '|' + $localSub) } }"

for /f "delims=" %%i in ('powershell -NoProfile -Command "try { !PS_CMD! } catch { $_.Exception.Message | Out-File error_manifest.log }"') do (
    set "LINE=%%i"
    
    if exist error_manifest.log (
        echo.
        echo %O1%    === CRITICAL MANIFEST PARSING ERROR DETECTED ===%RESET%
        type error_manifest.log
        echo ================================================
        pause
        exit /b 1
    )

    for /f "tokens=1,2,3 delims=|" %%a in ("!LINE!") do (
        set "NODE_NAME=%%a"
        set "REMOTE_REL=%%b"
        set "LOCAL_REL=%%c"
        
        set "FILE_URL=https://raw.githubusercontent.com/mercwar/dc2url/refs/heads/main/!REMOTE_REL!"
        set "DEST_FILE=!INSTALL_PATH!\!LOCAL_REL!"
        
        for %%p in ("!DEST_FILE!") do (
            set "TARGET_DIR=%%~dpp"
            if not exist "!TARGET_DIR!" mkdir "!TARGET_DIR!" >nul 2>&1
        )
        
        echo     %GRAY%[NODE: !NODE_NAME!]%TXT% Downloading !REMOTE_REL! ...%RESET%
        call :download_!SELECTED_TOOL! "!FILE_URL!" "!DEST_FILE!" 2>error_download.log
        
        if errorlevel 1 (
            echo %O1%    [!] Error occurred while attempting download tool handling.%RESET%
            if exist error_download.log type error_download.log
        )
        del error_download.log >nul 2>&1
    )
)

echo.
echo %GREEN%    [+] Processing completed to destination target path: !INSTALL_PATH!%RESET%

:: ============================================================
:: POST-DOWNLOAD AUTOMATIC EXECUTION OF INSTALL.BAT
:: ============================================================
set "EXPECTED_INSTALL_BAT=!INSTALL_PATH!\v1.0\install.bat"

echo %O2%    [*] Validating and executing install.bat automatically...%RESET%
if exist "!EXPECTED_INSTALL_BAT!" (
    echo %GREEN%    [+] Success: Running install.bat...%RESET%
    echo.
    call "!EXPECTED_INSTALL_BAT!"
) else (
    echo %O1%    [-] Warning: install.bat could not be verified at expected location.%RESET%
)

:: ============================================================
:: ECLIPSE & ROOT SETUP PROMPT
:: ============================================================
echo.
set /p "RUN_ECLIPSE=%Y2%    >>> DO YOU WANT TO RUN THE ECLIPSE INSTALLER? (Y/N): %RESET%"
if /i "!RUN_ECLIPSE!"=="y" (
    echo.
    echo %O2%    [*] Running root setup.bat...%RESET%
    if exist "!INSTALL_PATH!\setup.bat" (
        call "!INSTALL_PATH!\setup.bat"
    ) else (
        echo %O1%    [-] Warning: setup.bat could not be found at !INSTALL_PATH!\setup.bat.%RESET%
    )
) else (
    echo.
    echo %GRAY%    [!] Root setup.bat skipped by user.%RESET%
)
goto :eof

:: ============================================================
:: INDIVIDUAL TOOL DOWNLOAD FUNCTIONS
:: ============================================================
:download_curl
if exist "%~2" del /f /q "%~2" >nul 2>&1
curl -s -S -L -f "%~1" -o "%~2"
goto :eof

:download_wget
if exist "%~2" del /f /q "%~2" >nul 2>&1
wget -q "%~1" -O "%~2"
goto :eof

:download_certutil
if exist "%~2" del /f /q "%~2" >nul 2>&1
certutil -urlcache -split -f "%~1" "%~2" >nul 2>&1
certutil -urlcache * delete >nul 2>&1
goto :eof

:download_powershell
if exist "%~2" del /f /q "%~2" >nul 2>&1
powershell -NoProfile -Command "Invoke-WebRequest -Uri '%~1' -OutFile '%~2' -UseBasicParsing"
goto :eof

:download_bitsadmin
if exist "%~2" del /f /q "%~2" >nul 2>&1
bitsadmin /transfer dc2url_job /download /priority normal "%~1" "%~2" >nul 2>&1
goto :eof

:download_python
if exist "%~2" del /f /q "%~2" >nul 2>&1
python -c "import urllib.request; urllib.request.urlretrieve('%~1', '%~2')"
goto :eof

:download_node
if exist "%~2" del /f /q "%~2" >nul 2>&1
node -e "const fs=require('fs');const https=require('https');https.get('%~1',res=>{const stream=fs.createWriteStream('%~2');res.pipe(stream);});"
goto :eof

:download_mshta
if exist "%~2" del /f /q "%~2" >nul 2>&1
mshta "javascript:var xhr=new ActiveXObject('MSXML2.XMLHTTP');xhr.open('GET','%~1',false);xhr.send();var s=new ActiveXObject('ADODB.Stream');s.Type=1;s.Open();s.Write(xhr.ResponseBody);s.SaveToFile('%~2',2);window.close();"
goto :eof

:download_cscript
if exist "%~2" del /f /q "%~2" >nul 2>&1
cscript //nologo //e:jscript "%~f0" download_js "%~1" "%~2"
goto :eof

:download_dc2url
if exist "%~2" del /f /q "%~2" >nul 2>&1
dc2url "%~1" "%~2"
goto :eof

:download_winget
if exist "%~2" del /f /q "%~2" >nul 2>&1
powershell -NoProfile -Command "Invoke-WebRequest -Uri '%~1' -OutFile '%~2' -UseBasicParsing"
goto :eof

<job>
<script language="JScript">
var args = WScript.Arguments;
if (args.length >= 3 && args(0) == "download_js") {
    var url = args(1);
    var dest = args(2);
    try {
        var xhr = new ActiveXObject("MSXML2.XMLHTTP");
        xhr.open("GET", url, false);
        xhr.send();
        if (xhr.status == 200) {
            var stream = new ActiveXObject("ADODB.Stream");
            stream.Type = 1;
            stream.Open();
            stream.Write(xhr.ResponseBody);
            stream.SaveToFile(dest, 2);
            stream.Close();
        }
    } catch(e) {}
}
</script>
</job>
