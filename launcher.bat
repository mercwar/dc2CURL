@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1

:: ============================================================
:: FIREGEM // DARK-COM-2 (OPTIMIZED & STABLE CURL PIPELINE)
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
title DARK-COM-2 DYNAMIC dc2url KERNEL v1.0

cd /d "%~dp0"

:: ============================================================
:: SELF-ELEVATION PIPELINE
:: ============================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList '/c', 'cd /d ""%~dp0"" && ""%~f0""' -Verb RunAs"
    exit /b
)

set "REPO_OWNER=mercwar"
set "REPO_NAME=dc2url"
set "GLOBAL_CONFIG_URL=https://raw.githubusercontent.com/%REPO_OWNER%/%REPO_NAME%/main/config.json"
set "OUTPUT_FILE=config.json"

goto :START_EXECUTION

:: ============================================================
:: FRAME BUFFER SUBROUTINE
:: ============================================================
:RENDER_FRAME
cls
echo.
echo %LINE_COLOR%  ────────────────────────────────────────────────────────────────────────────────────%RST%
echo   %GOLD%// %WHITE%F I R E G E M   %MUTED%■   %BLUE%D A R K - C O M - 2   %MUTED%//   %ICE%M O D E R N   K E R N E L%RST%
echo %LINE_COLOR%  ────────────────────────────────────────────────────────────────────────────────────%RST%
echo %GRAD1%        ██████╗  █████╗ ██████╗ ██╗  ██╗ ██████╗ ██████╗ ███╗   ███╗██████╗ %RST%
echo %GRAD2%        ██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝██╔════╝██╔═══██╗████╗ ████║╚════██╗%RST%
echo %GRAD3%        ██║  ██║███████║██████╔╝█████╔╝ ██║     ██║   ██║██╔████╔██║ █████╔╝%RST%
echo %GRAD4%        ██║  ██║██╔══██║██╔══██╗██╔═██╗ ██║     ██║   ██║██║╚██╔╝██║██╔═══╝ %RST%
echo %GRAD5%        ██████╔╝██║  ██║██║  ██║██║  ██╗╚██████╗╚██████╔╝██║ ╚═╝ ██║███████╗%RST%
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
echo   %MUTED%[%RST%%FRAME_BAR_COL%%FRAME_BAR_FILL%%MUTED%%FRAME_BAR_EMPTY%%MUTED%]%RST% %GOLD%%FRAME_PCT%%%%%%RST%
echo.
echo   %MUTED%» %BLUE%PHASE: %FRAME_PHASE%%RST%
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

set "MENU_COUNT=0"
for %%T in (curl powershell bitsadmin certutil python wget node cscript mshta dc2url) do (
    where %%T >nul 2>nul
    if not errorlevel 1 (
        set /a MENU_COUNT+=1
        set "MENU_NAME_!MENU_COUNT!=%%T"
        set "MENU_CMD_!MENU_COUNT!=%%T"
        for /f "delims=" %%P in ('where %%T 2^>nul') do set "MENU_PATH_!MENU_COUNT!=%%P"
    )
)

set /a MENU_COUNT+=1
set "MENU_NAME_!MENU_COUNT!=Manual Download GitHub"
set "MENU_CMD_!MENU_COUNT!=MANUAL_BROWSER"

set "FRAME_PHASE=[AVIS]  DEVICE SELECTOR"
set "FRAME_STATUS=[AVIS] Device detection complete."
set "FRAME_BODY_1=[AVIS] Devices detected: %MENU_COUNT% available."
set "FRAME_BODY_2=[AVIS] Select your preferred device."
set "FRAME_BODY_3=[AVIS] Follow the steps below to open datalink"
call :DRAW_PROGRESS 35
set "FRAME_BAR_COL=%GOLD%"
call :RENDER_FRAME

echo.
for /l %%I in (1,1,%MENU_COUNT%) do (
    echo %GRAD2%        ╔═[%GOLD% %%I %GRAD2%]══%RST% %WHITE%!MENU_NAME_%%I!%RST%
)
echo.

set /p "DL_CHOICE=%GOLD%   >>> SELECT ENGINE [1-%MENU_COUNT%]: %RST%"
if "%DL_CHOICE%"=="" set "DL_CHOICE=1"
if %DL_CHOICE% gtr %MENU_COUNT% set "DL_CHOICE=1"
if %DL_CHOICE% lss 1 set "DL_CHOICE=1"

set "SELECTED_DL="
for /l %%I in (1,1,%MENU_COUNT%) do (
    if "%DL_CHOICE%"=="%%I" set "SELECTED_DL=!MENU_CMD_%%I!"
)
if not defined SELECTED_DL set "SELECTED_DL=curl"

if /i "%SELECTED_DL%"=="MANUAL_BROWSER" (
    start https://github.com/%REPO_OWNER%/%REPO_NAME%
    pause
    exit /b 0
)

:: ============================================================
:: TARGET INSTALLATION PATH SELECTION
:: ============================================================
set "FRAME_PHASE=[AVIS] SELECT INSTALL PATH"
set "FRAME_STATUS=[AVIS] Configuring folders..."
set "FRAME_BODY_1=  [ 1 ] System Path (%SystemDrive%\Program Files\dc2url)"
set "FRAME_BODY_2=  [ 2 ] Custom Path (your custom drive path)"
set "FRAME_BODY_3=        [AVIS]  Choose your path."
call :DRAW_PROGRESS 55
set "FRAME_BAR_COL=%BLUE%"
call :RENDER_FRAME

echo.
set /p "PATH_CHOICE=%GOLD%   >>> SELECT DESTINATION [1-2, DEFAULT 1]: %RST%"

if "%PATH_CHOICE%"=="2" (
    for /f "delims=" %%D in ('powershell -Command "Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.FolderBrowserDialog; $f.Description = 'Select dc2url Installation Directory'; if ($f.ShowDialog() -eq 'OK') { $f.SelectedPath }"') do (
        set "CUSTOM_DIR=%%D"
    )
    if defined CUSTOM_DIR (
        set "TARGET_DIR=!CUSTOM_DIR!"
    ) else (
        set "TARGET_DIR=%SystemDrive%\Program Files\dc2url"
    )
) else (
    set "TARGET_DIR=%SystemDrive%\Program Files\dc2url"
)

if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"

:: ============================================================
:: PHASE 1: DOWNLOAD MANIFEST
:: ============================================================
set "FRAME_PHASE=[AVIS] Searching for installer files"
set "FRAME_STATUS=[AVIS] Downlinking installer files..."
set "FRAME_BODY_1=  Source: %GLOBAL_CONFIG_URL%"
set "FRAME_BODY_2=  Engine: %SELECTED_DL%"
set "FRAME_BODY_3=        [AVIS] Downloading..."
call :DRAW_PROGRESS 70
set "FRAME_BAR_COL=%GOLD%"
call :RENDER_FRAME

if exist "%OUTPUT_FILE%" del /f /q "%OUTPUT_FILE%" >nul 2>&1

if /i "%SELECTED_DL%"=="powershell" (
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%GLOBAL_CONFIG_URL%' -OutFile '%OUTPUT_FILE%'" >nul 2>&1
) else (
    curl -f -s -L -k "%GLOBAL_CONFIG_URL%" -o "%OUTPUT_FILE%"
)

if not exist "%OUTPUT_FILE%" (
    set "FRAME_STATUS=[AVIS FAILURE] Configuration manifest unavailable."
    call :RENDER_FRAME
    echo.
    echo [ERROR] Could not download manifest from %GLOBAL_CONFIG_URL%
    pause
    exit /b 1
)

:: ============================================================
:: PHASE 2: VERSION RESOLUTION
:: ============================================================
set "FRAME_PHASE=[AVIS] Auto detecting version"
set "FRAME_STATUS=[AVIS] Reading version definitions..."
call :DRAW_PROGRESS 85
set "FRAME_BAR_COL=%GOLD%"
call :RENDER_FRAME

set "VERSION="
for /f "usebackq delims=" %%V in ('powershell -Command "(Get-Content %OUTPUT_FILE% | ConvertFrom-Json).version" 2^>nul') do (
    set "VERSION=%%V"
)

if not defined VERSION (
    set "FRAME_STATUS=[AVIS FAILURE] Could not resolve target version."
    call :RENDER_FRAME
    pause
    exit /b 1
)

:: ============================================================
:: PHASE 3: PAYLOAD STREAMING
:: ============================================================
set "FRAME_PHASE=[AVIS] Collecting files..."
set "FRAME_STATUS=[AVIS] Finding v1.0..."
set "FRAME_BODY_1=  Target Repository: %REPO_OWNER%/%REPO_NAME%"
set "FRAME_BODY_2=  Destination: %TARGET_DIR%"
set "FRAME_BODY_3=        [AVIS] Writing files..."
call :DRAW_PROGRESS 95
set "FRAME_BAR_COL=%BLUE%"
call :RENDER_FRAME

for /f "usebackq tokens=1,2 delims=|" %%A in (`powershell -Command "$json = Get-Content '%OUTPUT_FILE%' | ConvertFrom-Json; $json.manifest_layout.PSObject.Properties.Value | ForEach-Object { $_ } | ForEach-Object { $_.source + '|' + $_.target }" 2^>nul`) do (
    set "SRC_FILE=%%A"
    set "TGT_FILE=%%B"

    for %%F in ( "%TARGET_DIR%\!TGT_FILE!" ) do (
        if not exist "%%~dpF" mkdir "%%~dpF"
    )

    set "FILE_URL=https://raw.githubusercontent.com/%REPO_OWNER%/%REPO_NAME%/main/v1.0/!SRC_FILE!"

    if /i "%SELECTED_DL%" == "powershell" (
        powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '!FILE_URL!' -OutFile '%TARGET_DIR%\!TGT_FILE!'"
    ) else (
        curl -f -s -L -k "!FILE_URL!" -o "%TARGET_DIR%\!TGT_FILE!"
    )
)

if exist "%OUTPUT_FILE%" move /y "%OUTPUT_FILE%" "%TARGET_DIR%\" >nul 2>&1

:: ============================================================
:: PHASE 4: APPLICATION HANDOFF
:: ============================================================
set "FRAME_PHASE=[AVIS] Finding installer"
set "FRAME_STATUS=[AVIS] Launcher has reported success"
call :DRAW_PROGRESS 100
set "FRAME_BAR_COL=%GREEN%"
call :RENDER_FRAME

cd /d "%TARGET_DIR%"

echo.
if exist "install.bat" (
    echo %GREEN%  [AVIS SEARCH]%RST% %WHITE% AVIS HAS VALIDATED SUCCESS%RST%
    echo %BLUE%  [AVIS EXEC]%RST% %GOLD%Running installer...%RST%
    echo.
    timeout /t 2 >nul
    cmd /c install.bat
) else (
    echo %GRAD3%  [AVIS FAILURE]%RST% %WHITE%The installer files are missing install.bat%RST%
    pause
)

echo.
echo %GRAD1%  ====================================================================================%RST%
echo %GRAD2%  ╔══════════════════════════════════════════════════════════════════════════════════╗%RST%
echo %GRAD2%  ║%GOLD%            The eclipse is here, Program installed successfully                   %GRAD2%║%RST%
echo %GRAD2%  ║%BLUE%                        MERCWAR SYSTEMS • DARK-COM-2                              %GRAD2%║%RST%
echo %GRAD2%  ╚══════════════════════════════════════════════════════════════════════════════════╝%RST%
echo %GRAD1%  ====================================================================================%RST%
echo.

echo %WHITE%  Installation sequence finished. Continuing to persistent prompt...%RST%
echo.

endlocal
:: Forces the command-line session to persist instead of closing the terminal window
exit /b 0

