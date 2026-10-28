@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1

:: ============================================================
:: FIREGEM // DARK-COM-2 (PROGRESS BAR STREAMING KERNEL)
:: ============================================================

for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

set "GRAD1=%ESC%[38;2;255;90;0m"
set "GRAD2=%ESC%[38;2;255;125;0m"
set "GRAD3=%ESC%[38;2;255;160;0m"
set "GRAD4=%ESC%[38;2;255;195;0m"
set "GRAD5=%ESC%[38;2;255;225;0m"
set "GRAD6=%ESC%[38;2;255;255;0m"

set "GOLD=%ESC%[38;2;255;210;0m"
set "BLUE=%ESC%[38;2;255;140;0m"
set "ICE=%ESC%[38;2;255;230;0m"
set "GREEN=%ESC%[38;2;255;190;0m"
set "MUTED=%ESC%[38;2;115;125;145m"
set "WHITE=%ESC%[38;2;240;240;250m"
set "RST=%ESC%[0m"
set "LINE_COLOR=%ESC%[38;2;255;90;0m"

mode con cols=100 lines=50
color 00
title DC2URL STARGATE v1.0 QUASAR 2

cd /d "%~dp0"

:: ============================================================
:: SELF-ELEVATION PIPELINE
:: ============================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList '/c', 'cd /d ""%~dp0"" && ""%~f0""' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"


:: Clear the screen and request ANSI escape sequence support for classic Windows Console
cls
reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1

:: Visual Anchors / Escape Codes
for /F %%A in ('echo prompt $E ^| cmd') do set ESC=%%A
set "CYAN=%ESC%[96m"
set "WHITE=%ESC%[97m"
set "GREEN=%ESC%[92m"
set "GRAY=%ESC%[90m"
set "RESET=%ESC%[0m"

:: BIOS Post Header Simulation
echo %CYAN%================================================================================%RESET%
echo %WHITE%  DC2URL AMIBIOS(C)2026 Core Execution Pipeline v2.40                          %RESET%
echo %WHITE%  BIOS Date: 10/27/26 23:46:11 Ver: 08.00.16                                    %RESET%
echo %CYAN%================================================================================%RESET%
echo.
echo  CPU: Intel(R) Core(TM) i7-10700K CPU @ 3.80GHz
echo  Speed: 3800MHz  Count: 16
echo.
echo  %GRAY%Entering Pipeline Verification...%RESET%

:: Hardware Check / Software Component Validation Emulation
timeout /t 1 >nul
echo  Checking Memory NVRAM... %GREEN%OK%RESET%
timeout /t 1 >nul

:: Detect dc2url application path registration
where dc2url >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo  Detecting Network Layer Executable... %GREEN%[FOUND]%RESET%
) else (
    echo  Detecting Network Layer Executable... %ESC%[91m[NOT FOUND]%RESET%
)

:: Emulate Initializing State Broker Panels
timeout /t 3 >nul
echo  Initializing Gateway Control... %GREEN%ALIVE%RESET%
echo.
echo %GRAY%--------------------------------------------------------------------------------%RESET%
echo  %GREEN%POST Complete. Booting dc2url Software Environment Engine...%RESET%
echo %GRAY%--------------------------------------------------------------------------------%RESET%
echo.

:: Check for the switch parameter (case-insensitive) or missing arguments
if "%~1"=="" goto :sound_off
if /i "%~1"=="on" goto :sound_on
if /i "%~1"=="off" goto :sound_off


:sound_on
echo %CYAN%[SYSTEM]%RESET% Turning network subsystem stream sound ON...
set "MIDI_URL=https://github.com/mercwar/dc2url/raw/refs/heads/main/sound/transformers.mid"


:: Download the file using dc2url case-sensitive pipeline
curl -sL "%MIDI_URL%" -o "%TEMP%\transformers.mid"

:: Play the file using Windows Media Player engine
start "" wmplayer "%TEMP%\transformers.mid"

:sound_off
timeout /t 3 >nul

goto :START_EXECUTION

:: ============================================================
:: FRAME BUFFER SUBROUTINE
:: ============================================================
:RENDER_FRAME
cls
echo.
echo %LINE_COLOR%  ────────────────────────────────────────────────────────────────────────────────────%RST%
echo    %GOLD%// %WHITE%F I R E G E M   %MUTED%■   %BLUE%D A R K - C O M - 2   %MUTED%//   %ICE%M O D E R N   K E R N E L%RST%
echo %LINE_COLOR%  ────────────────────────────────────────────────────────────────────────────────────%RST%
echo %GRAD1%        ██████╗  █████╗ ██████╗ ██╗  ██╗ ██████╗ ██████╗ ███╗   ███╗██████╗ %RST%
echo %GRAD2%        ██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝██╔════╝██╔═══██╗████╗ ████║╚════██╗%RST%
echo %GRAD3%        ██║  ██║███████║██████╔╝█████╔╝ ██║     ██║   ██║██╔████╔██║ █████╔╝%RST%
echo %GRAD4%        ██║  ██║██╔══██║██╔══██╗██╔═██╗ ██║     ██║   ██║██║╚██╔╝██║██╔═══╝ %RST%
echo %GRAD5%        ██████╔╝██║  ██║██║  ██║██║  ██║╚██████╗╚██████╔╝██║ ╚═╝ ██║███████╗%RST%
echo %GRAD6%        ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝%RST%
echo %LINE_COLOR%  ────────────────────────────────────────────────────────────────────────────────────%RST%
echo.
echo %MUTED%  MERCWAR SYSTEMS%RST% %GRAD3% %RST% %GOLD%ECLIPSE TECHNOLOGY%RST%
echo %MUTED%  STATUS: %RST% %GOLD%%FRAME_STATUS%%RST%
echo %LINE_COLOR%  ────────────────────────────────────────────────────────────────────────────────────%RST%
echo.
echo %WHITE%%FRAME_BODY_1%%RST%
echo %WHITE%%FRAME_BODY_2%%RST%
echo %WHITE%%FRAME_BODY_3%%RST%
echo.
echo %MUTED%  📊 STAGE:%RST%
echo    %MUTED%[%RST%%FRAME_BAR_COL%%FRAME_BAR_FILL%%MUTED%%FRAME_BAR_EMPTY%%MUTED%]%RST% %GOLD%%FRAME_PCT%%%%%%RST%
echo.
echo    %MUTED%» %BLUE%PHASE: %FRAME_PHASE%%RST%
echo %LINE_COLOR%  ────────────────────────────────────────────────────────────────────────────────────%RST%
goto :eof

:DRAW_PROGRESS
set /a "NUM_BLOCKS=%1 / 5"
set "FRAME_BAR_FILL="
set "FRAME_BAR_EMPTY="
for /l %%B in (1,1,20) do (
    if %%B leq !NUM_BLOCKS! (
        set "FRAME_BAR_FILL=!FRAME_BAR_FILL!█"
    ) else (
        set "FRAME_BAR_EMPTY=!FRAME_BAR_EMPTY!░"
    )
)
set "FRAME_PCT=%1"
if %1 lss 10 set "FRAME_PCT=  %1"
if %1 geq 10 if %1 lss 100 set "FRAME_PCT= %1"
goto :eof

:: ============================================================
:: START_EXECUTION
:: ============================================================
:START_EXECUTION
set "FRAME_PHASE=[AVIS] SCANNER"
set "FRAME_STATUS=[AVIS] Scanning system ..."
set "FRAME_BODY_1=[AVIS] Scanning windows for installation methods..."
set "FRAME_BODY_2=[AVIS] Validating connection..."
set "FRAME_BODY_3=[AVIS] Launcher alive."
call :DRAW_PROGRESS 10
set "FRAME_BAR_COL=%BLUE%"
call :RENDER_FRAME

set "found_tools="
set "count=0"
for %%T in (dc2url python curl mshta powershell certutil cscript bitsadmin wget node winget) do (
    where %%T >nul 2>&1
    if not errorlevel 1 (
        set /a count+=1
        set "tool_!count!=%%T"
        set "found_tools=!found_tools! %%T"
    )
)

set "FRAME_PHASE=[AVIS] DEVICE SELECTOR"
set "FRAME_STATUS=[AVIS] Device detection complete."
set "FRAME_BODY_1=[AVIS] Devices detected: %count% available."
set "FRAME_BODY_2=[AVIS] Select your preferred device engine."
set "FRAME_BODY_3=[AVIS] Follow the interactive steps below."
call :DRAW_PROGRESS 35
set "FRAME_BAR_COL=%GOLD%"
call :RENDER_FRAME

echo.
for /l %%i in (1,1,!count!) do (
    echo %GRAD2%     ╔═[%GOLD% %%i %GRAD2%]══%RST% %WHITE%!tool_%%i!%RST%
)
echo.

set /p "TOOL_NUM=%GOLD%    >>> SELECT ENGINE [1-%count%]: %RST%"
if "!TOOL_NUM!"=="" (
    set "SELECTED_TOOL=curl"
) else (
    for /l %%i in (1,1,!count!) do (
        if "!TOOL_NUM!"=="%%i" set "SELECTED_TOOL=!tool_%%i!"
    )
)
if "!SELECTED_TOOL!"=="" set "SELECTED_TOOL=curl"

:: Target Installation Path Selection
set "DEFAULT_INSTALL=%ProgramFiles%\dc2url"
if "%DEFAULT_INSTALL%"=="" set "DEFAULT_INSTALL=%SystemDrive%\Program Files\dc2url"

set "FRAME_PHASE=[AVIS] SELECT INSTALL PATH"
set "FRAME_STATUS=[AVIS] Configuring target directories..."
set "FRAME_BODY_1=  Default: %DEFAULT_INSTALL%"
set "FRAME_BODY_2=  Engine:  %SELECTED_TOOL%"
set "FRAME_BODY_3=        [AVIS] Ready for configuration."
call :DRAW_PROGRESS 55
set "FRAME_BAR_COL=%BLUE%"
call :RENDER_FRAME

echo.
set /p "INSTALL_PATH=%GOLD%    >>> ENTER INSTALL PATH (PRESS ENTER FOR DEFAULT): %RST%"
if "!INSTALL_PATH!"=="" set "INSTALL_PATH=!DEFAULT_INSTALL!"

if not exist "!INSTALL_PATH!" (
    mkdir "!INSTALL_PATH!" >nul 2>&1
)

set "CONFIG_URL=https://raw.githubusercontent.com/mercwar/dc2url/refs/heads/main/config.json"
set "CONFIG_FILE=!INSTALL_PATH!\config.json"

set "FRAME_PHASE=[AVIS] FETCHING MANIFEST"
set "FRAME_STATUS=[AVIS] Downlinking configuration manifest..."
set "FRAME_BODY_1=  Source: %CONFIG_URL%"
set "FRAME_BODY_2=  Target: %CONFIG_FILE%"
set "FRAME_BODY_3=        [AVIS] Executing download..."
call :DRAW_PROGRESS 75
set "FRAME_BAR_COL=%GOLD%"
call :RENDER_FRAME

if /i "!SELECTED_TOOL!"=="curl" (
    curl -s -L -f "!CONFIG_URL!" -o "!CONFIG_FILE!"
) else if /i "!SELECTED_TOOL!"=="wget" (
    wget -q "!CONFIG_URL!" -O "!CONFIG_FILE!"
) else if /i "!SELECTED_TOOL!"=="certutil" (
    certutil -urlcache -split -f "!CONFIG_URL!" "!CONFIG_FILE!" >nul 2>&1
    certutil -urlcache * delete >nul 2>&1
) else if /i "!SELECTED_TOOL!"=="powershell" (
    powershell -NoProfile -Command "Invoke-WebRequest -Uri '!CONFIG_URL!' -OutFile '!CONFIG_FILE!' -UseBasicParsing"
) else if /i "!SELECTED_TOOL!"=="bitsadmin" (
    bitsadmin /transfer dc2url_job /download /priority normal "!CONFIG_URL!" "!CONFIG_FILE!" >nul 2>&1
) else if /i "!SELECTED_TOOL!"=="python" (
    python -c "import urllib.request; urllib.request.urlretrieve('!CONFIG_URL!', '!CONFIG_FILE!')"
) else if /i "!SELECTED_TOOL!"=="node" (
    node -e "const fs=require('fs');const https=require('https');https.get('!CONFIG_URL!',res=>{const stream=fs.createWriteStream('!CONFIG_FILE!');res.pipe(stream);});"
) else if /i "!SELECTED_TOOL!"=="mshta" (
    mshta "javascript:var xhr=new ActiveXObject('MSXML2.XMLHTTP');xhr.open('GET','!CONFIG_URL!',false);xhr.send();var s=new ActiveXObject('ADODB.Stream');s.Type=1;s.Open();s.Write(xhr.ResponseBody);s.SaveToFile('!CONFIG_FILE!',2);window.close();"
) else if /i "!SELECTED_TOOL!"=="cscript" (
    cscript //nologo //e:jscript "%~f0" download_js "!CONFIG_URL!" "!CONFIG_FILE!"
) else if /i "!SELECTED_TOOL!"=="dc2url" (
    dc2url "!CONFIG_URL!" "!CONFIG_FILE!"
) else if /i "!SELECTED_TOOL!"=="winget" (
    powershell -NoProfile -Command "Invoke-WebRequest -Uri '!CONFIG_URL!' -OutFile '!CONFIG_FILE!' -UseBasicParsing"
)

if exist "!CONFIG_FILE!" (
    set "FRAME_PHASE=[AVIS] PAYLOAD DEPLOYMENT"
    set "FRAME_STATUS=[AVIS] Manifest locked. Streaming via progress bar..."
    set "FRAME_BODY_1=  Config: Success"
    set "FRAME_BODY_2=  Path:   !INSTALL_PATH!"
    set "FRAME_BODY_3=        [AVIS] Executing non-blocking payload deployment..."
    call :DRAW_PROGRESS 90
    set "FRAME_BAR_COL=%GREEN%"
    call :RENDER_FRAME

    set "PS_SCRIPT=!INSTALL_PATH!\parse_manifest.ps1"
    set "VER_FILE=!INSTALL_PATH!\detected_version.tmp"
    
    (
        echo param([string]$ConfigPath, [string]$InstallPath, [string]$VersionFile^)
        echo $cfg = Get-Content $ConfigPath -Raw ^| ConvertFrom-Json
        echo $owner = if ($cfg.repo_owner^) { $cfg.repo_owner } else { 'mercwar' }
        echo $repo = if ($cfg.repo_name^) { $cfg.repo_name } else { 'dc2url' }
        echo $ver = if ($cfg.version^) { $cfg.version } else { 'v1.0' }
        echo Set-Content -Path $VersionFile -Value $ver -Encoding ascii
        echo $baseUrl = "https://raw.githubusercontent.com/$owner/$repo/refs/heads/main/"
        echo $allFiles = @^(^)
        echo if ($cfg.manifest_layout^) {
        echo     $catIdx = 0
        echo     foreach ($prop in $cfg.manifest_layout.psobject.properties^) {
        echo         $catIdx++
        echo         foreach ($item in $prop.Value^) {
        echo             $source = $item.source
        echo             $target = if ($item.target^) { $item.target } else { $source }
        echo             if ($catIdx -eq 1^) {
        echo                 $relPath = $target
        echo                 $remotePath = $source
        echo             } else {
        echo                 $relPath = Join-Path $ver $target
        echo                 $remotePath = Join-Path $ver $source
        echo             }
        echo             $fileUrl = $baseUrl + ($remotePath -replace '\\', '/'^)
        echo             $dest = Join-Path $InstallPath $relPath
        echo             $allFiles += [PSCustomObject]@{ Url = $fileUrl; Dest = $dest; Source = $source }
        echo         }
        echo     }
        echo }
        echo $total = $allFiles.Count
        echo $curr = 0
        echo foreach ($file in $allFiles^) {
        echo     $curr++
        echo     $pct = [int^](($curr / $total^) * 100^)
        echo     Write-Progress -Activity "AVIS PAYLOAD STREAM" -Status "Downloading [$curr/$total]: $($file.Source^)" -PercentComplete $pct
        echo     $parent = Split-Path $file.Dest -Parent
        echo     if (-not (Test-Path $parent^)^) { New-Item -ItemType Directory -Force -Path $parent ^| Out-Null }
        echo     try {
        echo         Invoke-WebRequest -Uri $file.Url -OutFile $file.Dest -UseBasicParsing
        echo     } catch {
        echo         Write-Warning "Failed to download $($file.Source^): $_"
        echo     }
        echo }
        echo Write-Progress -Activity "AVIS PAYLOAD STREAM" -Completed
    ) > "!PS_SCRIPT!"

    powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Normal -File "!PS_SCRIPT!" -ConfigPath "!CONFIG_FILE!" -InstallPath "!INSTALL_PATH!" -VersionFile "!VER_FILE!"
    del "!PS_SCRIPT!" >nul 2>&1

    set "VER_DIR=v1.0"
    if exist "!VER_FILE!" (
        set /p VER_DIR=<"!VER_FILE!"
        del "!VER_FILE!" >nul 2>&1
    )

    set "FRAME_PHASE=[AVIS] SEQUENCE COMPLETE"
    set "FRAME_STATUS=[AVIS] Handoff verified."
    call :DRAW_PROGRESS 100
    set "FRAME_BAR_COL=%GREEN%"
    call :RENDER_FRAME

    echo.
    echo Installation sequence complete.
    echo ====================================================================================
    call "!INSTALL_PATH!\!VER_DIR!\install.bat"
    endlocal
) else (
    echo [-] Failed to download config.json. Exiting.
    pause
    endlocal
)

exit /b 0

:: JScript helper routine for cscript execution if invoked
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
