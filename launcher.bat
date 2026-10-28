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

:: ============================================================
:: TOOL DETECTION & SELECTION
:: ============================================================
set "count=0"
for %%T in (dc2url python curl mshta powershell certutil cscript bitsadmin wget node winget) do (
    where %%T >nul 2>&1
    if not errorlevel 1 (
        set /a count+=1
        set "tool_!count!=%%T"
    )
)

if !count! equ 0 (
    echo [-] No download engines found. Exiting.
    pause
    exit /b
)

echo === AVAILABLE TOOLS ===
echo.
for /l %%i in (1,1,!count!) do (
    echo [%%i] !tool_%%i!
)
echo.

set /p "TOOL_NUM=Select engine [1-!count!]: "
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
echo === DOWNLOAD DESTINATION CONFIGURATION ===
echo Default system path: !DEFAULT_INSTALL!
echo.

set /p "INSTALL_PATH=>>> ENTER FULL PATH OR PRESS ENTER FOR DEFAULT: "
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
echo [*] Downloading config.json using !SELECTED_TOOL!...
call :download_!SELECTED_TOOL! "!CONFIG_URL!" "!CONFIG_FILE!" 2>error_config.log

if not exist "!CONFIG_FILE!" (
    echo [-] Failed to download config.json.
    echo === ENGINE ERROR LOG ===
    if exist error_config.log type error_config.log
    del error_config.log >nul 2>&1
    pause
    exit /b
)
del error_config.log >nul 2>&1
echo [+] config.json downloaded successfully.

:: ============================================================
:: PARSE MANIFEST & LOOP NODES (RESPECTING do_not_version)
:: ============================================================
echo [*] Parsing manifest layout and downloading payload nodes...

set "PS_CMD=$cfg = Get-Content '!CONFIG_FILE!' -Raw | ConvertFrom-Json; $ver = $cfg.version; $skipNode = $cfg.do_not_version; foreach ($node in $cfg.manifest_layout.psobject.properties.Name) { $noVer = ($node -eq $skipNode); foreach ($item in $cfg.manifest_layout.$node) { $src = $item.source; $tgt = if ($item.target) { $item.target } else { $src }; $remoteSub = if ($noVer) { $src } else { $ver + '/' + $src }; $localSub = if ($noVer) { $tgt } else { $ver + '\' + $tgt }; [Console]::WriteLine($node + '|' + $remoteSub + '|' + $localSub) } }"

for /f "delims=" %%i in ('powershell -NoProfile -Command "try { !PS_CMD! } catch { $_.Exception.Message | Out-File error_manifest.log }"') do (
    set "LINE=%%i"
    
    :: Safe catch check to verify if the return payload is a PowerShell error trace
    if exist error_manifest.log (
        echo.
        echo === CRITICAL MANIFEST PARSING ERROR DETECTED ===
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
        
        echo    [NODE: !NODE_NAME!] Downloading !REMOTE_REL! ...
        call :download_!SELECTED_TOOL! "!FILE_URL!" "!DEST_FILE!" 2>error_download.log
        
        if errorlevel 1 (
            echo [!] Error occurred while attempting download tool handling.
            if exist error_download.log type error_download.log
            pause
        )
        del error_download.log >nul 2>&1
    )
)


echo.
echo [+] Processing completed to destination target path: !INSTALL_PATH!
:: ============================================================
:: POST-DOWNLOAD VALIDATION
:: ============================================================
set "EXPECTED_INSTALL_BAT=!INSTALL_PATH!\v1.0\install.bat"

echo [*] Validating installation components...
if exist "!EXPECTED_INSTALL_BAT!" (
    echo [+] Success: install.bat was found at !EXPECTED_INSTALL_BAT!
	call "!EXPECTED_INSTALL_BAT!"
) else (
    echo [-] Warning: install.bat could not be verified at the expected location.
)

endlocal
exit /b

:: ============================================================
:: INDIVIDUAL TOOL DOWNLOAD FUNCTIONS
:: ============================================================
:download_curl
curl -s -L -f "%~1" -o "%~2"
goto :eof

:download_wget
wget -q "%~1" -O "%~2"
goto :eof

:download_certutil
certutil -urlcache -split -f "%~1" "%~2" >nul 2>&1
certutil -urlcache * delete >nul 2>&1
goto :eof

:download_powershell
powershell -NoProfile -Command "Invoke-WebRequest -Uri '%~1' -OutFile '%~2' -UseBasicParsing"
goto :eof

:download_bitsadmin
bitsadmin /transfer dc2url_job /download /priority normal "%~1" "%~2" >nul 2>&1
goto :eof

:download_python
python -c "import urllib.request; urllib.request.urlretrieve('%~1', '%~2')"
goto :eof

:download_node
node -e "const fs=require('fs');const https=require('https');https.get('%~1',res=>{const stream=fs.createWriteStream('%~2');res.pipe(stream);});"
goto :eof

:download_mshta
mshta "javascript:var xhr=new ActiveXObject('MSXML2.XMLHTTP');xhr.open('GET','%~1',false);xhr.send();var s=new ActiveXObject('ADODB.Stream');s.Type=1;s.Open();s.Write(xhr.ResponseBody);s.SaveToFile('%~2',2);window.close();"
goto :eof

:download_cscript
cscript //nologo //e:jscript "%~f0" download_js "%~1" "%~2"
goto :eof

:download_dc2url
dc2url "%~1" "%~2"
goto :eof

:download_winget
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