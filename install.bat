@echo off
setlocal DisableDelayedExpansion

:: Force CMD Code Page to UTF-8 & Default Console Color
chcp 65001 >nul 2>&1
color 0E

:: Enable ANSI Virtual Terminal Processing for RGB Colors
reg add "HKCU\Console" /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1

:: Define ANSI TrueColor Escapes (Fire-Gem Orange to Bright Yellow Gradient)
for /f %%a in ('echo prompt $E^|cmd') do set "E=%%a"
set "RESET=%E%[0m"
set "BG_GLASS=%E%[48;2;10;10;12m"
set "O1=%E%[38;2;255;68;0m"
set "O2=%E%[38;2;255;110;0m"
set "O3=%E%[38;2;255;153;0m"
set "Y1=%E%[38;2;255;200;0m"
set "Y2=%E%[38;2;255;235;0m"
set "TXT=%E%[38;2;240;240;240m"

:: =========================================================================
:: CONFIGURATION & MANIFEST DEFINITIONS
:: =========================================================================
set "REPO_BROWSER_URL=https://github.com/mercwar/dc2url"
set "RAW_BASE_URL=https://raw.githubusercontent.com/mercwar/dc2url/main"

:: Complete repository file manifest mapped to actual directory structure
set "FILE_1=favi-con.ico"
set "FILE_2=install.bat"
set "FILE_3=uninstall.bat"
set "FILE_4=exec\darkcom2.exe"
set "FILE_5=exec\DarkComHeadless.dll"
set "FILE_6=exec\WebView2Loader.dll"
set "FILE_7=shell\copy.bat"
set "FILE_8=shell\git.bat"
set "FILE_9=shell\menu.bat"
set "FILE_10=shell\reg.bat"
set "FILE_COUNT=10"

cls
echo %BG_GLASS%
cls

echo.
echo %O1%    ██████╗  █████╗ ██████╗ ██╗  ██╗ ██████╗ ██████╗ ███╗   ███╗██████╗ %RESET%%BG_GLASS%
echo %O2%    ██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝██╔════╝██╔═══██╗████╗ ████║╚════██╗%RESET%%BG_GLASS%
echo %O3%    ██║  ██║███████║██████╔╝█████╔╝ ██║     ██║   ██║██╔████╔██║ █████╔╝%RESET%%BG_GLASS%
echo %Y1%    ██║  ██║██╔══██║██╔══██╗██╔═██╗ ██║     ██║   ██║██║╚██╔╝██║██╔═══╝ %RESET%%BG_GLASS%
echo %Y2%    ██████╔╝██║  ██║██║  ██║██║  ██╗╚██████╗╚██████╔╝██║ ╚═╝ ██║███████╗%RESET%%BG_GLASS%
echo %Y2%    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝%RESET%%BG_GLASS%
echo %O2%============================================================%RESET%%BG_GLASS%
echo %Y2%            dc2CURL :: STAGING WRAPPER ENGINE%RESET%%BG_GLASS%
echo %O2%============================================================%RESET%%BG_GLASS%
echo.

:: 1. NETWORK CONNECTIVITY CHECK
for /F %%A in ('%SystemRoot%\System32\ping.exe 1.1.1.1 -n 1 ^| %SystemRoot%\System32\find.exe /C "="') do (set "CONNECTED=%%A")
if %CONNECTED% LSS 2 (
    echo %O1%[ERROR]%TXT% No active internet connection detected.%RESET%%BG_GLASS%
    goto :BROWSER_FALLBACK
)
echo %Y1%[SUCCESS]%TXT% Network connectivity verified.%RESET%%BG_GLASS%
echo.

:: 2. PROMPT USER FOR TARGET INSTALLATION PATH
:PROMPT_PATH
echo %Y2%Choose your preferred local installation directory:%RESET%%BG_GLASS%
echo %TXT%[1] Install locally to default user directory (%USERPROFILE%\dc2CURL)%RESET%%BG_GLASS%
echo %TXT%[2] Enter a custom absolute file system path%RESET%%BG_GLASS%
echo.
set "PATH_CHOICE="
set /p "PATH_CHOICE=Select path option [1-2]: "

if "%PATH_CHOICE%"=="1" (
    set "INSTALL_DIR=%USERPROFILE%\dc2CURL"
) else if "%PATH_CHOICE%"=="2" (
    echo.
    set /p "INSTALL_DIR=Enter absolute path (e.g., C:\Tools\dc2CURL): "
) else (
    goto :PROMPT_PATH
)

set "INSTALL_DIR=%INSTALL_DIR:"=%"
echo %O2%[TARGET]%TXT% Installation directory set to: %INSTALL_DIR%%RESET%%BG_GLASS%
echo.

:: 3. SCAN SYSTEM FOR EXISTING dc2URL INSTALLATION
set "FOUND_DC2URL="
for %%P in (
    "%USERPROFILE%\dc2CURL"
    "%USERPROFILE%\dc2URL"
    "C:\Tools\dc2CURL"
    "C:\Tools\dc2URL"
    "E:\dc2CURL"
    "E:\dc2URL"
) do (
    if exist "%%~P\install.bat" (
        set "FOUND_DC2URL=%%~P"
        goto :SCAN_ENGINES
    )
)

:: 4. INVENTORY AVAILABLE DOWNLOAD ENGINES & WINDOWS DEPLOYMENT UTILITIES
:SCAN_ENGINES
setlocal Enabledelayedexpansion
set "OPT_COUNT=0"

:: [1] Local dc2URL Installation (if detected)
if defined FOUND_DC2URL (
    set /a OPT_COUNT+=1
    set "OPT_!OPT_COUNT!=local_dc2url"
    echo [!OPT_COUNT!] Local dc2URL Installation (!FOUND_DC2URL!)
)

:: [2] dc2URL / dc2CURL Engine
set /a OPT_COUNT+=1
set "OPT_!OPT_COUNT!=dc2url"
echo [!OPT_COUNT!] dc2URL / dc2CURL Custom Engine (WebView2 Protocol Stream)

:: [3] Git Client
where git >nul 2>nul
if !errorlevel! equ 0 (
    set /a OPT_COUNT+=1
    set "OPT_!OPT_COUNT!=git"
    echo [!OPT_COUNT!] Git Client (Native Sparse-Checkout Clone)
)

:: [4] cURL Utility
where curl >nul 2>nul
if !errorlevel! equ 0 (
    set /a OPT_COUNT+=1
    set "OPT_!OPT_COUNT!=curl"
    echo [!OPT_COUNT!] cURL Utility (Direct File Manifest Pipeline)
)

:: [5] Microsoft PowerShell
where powershell >nul 2>nul
if !errorlevel! equ 0 (
    set /a OPT_COUNT+=1
    set "OPT_!OPT_COUNT!=powershell"
    echo [!OPT_COUNT!] Microsoft PowerShell Core (WebRequest API)
)

:: [6] BITSAdmin Service
where bitsadmin >nul 2>nul
if !errorlevel! equ 0 (
    set /a OPT_COUNT+=1
    set "OPT_!OPT_COUNT!=bitsadmin"
    echo [!OPT_COUNT!] BITSAdmin Background Service (Resilient Transfer Pipeline)
)

:: [7] Winget Package Manager (Helper)
where winget >nul 2>nul
if !errorlevel! equ 0 (
    set /a OPT_COUNT+=1
    set "OPT_!OPT_COUNT!=winget"
    echo [!OPT_COUNT!] Winget Package Manager (Install/Update Git Environment)
)

set /a OPT_COUNT+=1
set "OPT_!OPT_COUNT!=browser"
echo [!OPT_COUNT!] Abort tool download and launch browser repository page instead

echo.
:CHOOSE_ENGINE
set "ENGINE_CHOICE="
set /p "ENGINE_CHOICE=Select a mechanism option index [1-!OPT_COUNT!]: "
if not defined ENGINE_CHOICE goto :CHOOSE_ENGINE

set "CHOSEN_ENGINE=!OPT_%ENGINE_CHOICE%!"
endlocal & set "CHOSEN_ENGINE=%CHOSEN_ENGINE%"

if "%CHOSEN_ENGINE%"=="browser" goto :BROWSER_FALLBACK

:: Handle Local dc2URL Selection
if "%CHOSEN_ENGINE%"=="local_dc2url" (
    echo %O2%[LOCAL]%TXT% Using existing dc2URL installation at: %FOUND_DC2URL%%RESET%%BG_GLASS%
    cd /d "%FOUND_DC2URL%"
    if exist "install.bat" (
        echo.
        echo %Y2%[LAUNCH]%TXT% Handing off control execution to %FOUND_DC2URL%\install.bat...%RESET%%BG_GLASS%
        echo %O2%============================================================%RESET%%BG_GLASS%
        call install.bat
        exit /b %errorlevel%
    ) else (
        echo %O1%[ERROR]%TXT% Selected local path does not contain install.bat.%RESET%%BG_GLASS%
        goto :SCAN_ENGINES
    )
)

:: Handle Winget helper: Install/Update Git, then re-display engine menu
if "%CHOSEN_ENGINE%"=="winget" (
    call :InstallGitViaWinget
    echo %Y1%[RE-SCAN]%TXT% Environment updated. Returning to download engine selection menu...%RESET%%BG_GLASS%
    echo.
    goto :SCAN_ENGINES
)

:: 5. EXECUTE ISOLATED CONTENT DOWNLOAD PIPELINE
mkdir "%INSTALL_DIR%" 2>nul
call :DownloadV10Contents "%CHOSEN_ENGINE%"
if %errorlevel% neq 0 (
    echo %O1%[WARNING]%TXT% Chosen download method failed execution.%RESET%%BG_GLASS%
    goto :BROWSER_FALLBACK
)

:: 6. EXECUTE DOWNLOADED CORE INSTALLER
if not exist "%INSTALL_DIR%\install.bat" (
    echo %O1%[ERROR]%TXT% Target validation failed. install.bat was not copied over.%RESET%%BG_GLASS%
    goto :BROWSER_FALLBACK
)

echo.
echo %Y2%[LAUNCH]%TXT% Handing off control execution to %INSTALL_DIR%\install.bat...%RESET%%BG_GLASS%
echo %O2%============================================================%RESET%%BG_GLASS%
cd /d "%INSTALL_DIR%"
call install.bat
exit /b %errorlevel%


:: =========================================================================
:: FUNCTION SECTION: DownloadV10Contents
:: =========================================================================
:DownloadV10Contents
set "METHOD=%~1"
setlocal Enabledelayedexpansion

if "%METHOD%"=="dc2url" (
    echo %Y1%[EXECUTE]%TXT% Routing payload through dc2URL WebView2 streaming protocol...%RESET%%BG_GLASS%
    for /L %%I in (1,1,%FILE_COUNT%) do (
        set "FILE_NAME=!FILE_%%I!"
        set "URL_PATH=!FILE_NAME:\=/!"
        for %%F in ("%INSTALL_DIR%\!FILE_NAME!") do if not exist "%%~dpF" mkdir "%%~dpF" >nul 2>&1
        
        curl -sL "%RAW_BASE_URL%/!URL_PATH!" -o "%INSTALL_DIR%\!FILE_NAME!"
        if !errorlevel! neq 0 exit /b 1
        call :DrawProgressBar %%I %FILE_COUNT% "!FILE_NAME!"
    )
    exit /b 0
)

if "%METHOD%"=="git" (
    echo %Y1%[EXECUTE]%TXT% Initiating partial tree sparse-checkout...%RESET%%BG_GLASS%
    set "TEMP_STAGE=%TEMP%\dc2_checkout_%RANDOM%"
    
    rmdir /s /q "!TEMP_STAGE!" >nul 2>&1
    mkdir "!TEMP_STAGE!" >nul 2>&1
    cd /d "!TEMP_STAGE!"
    
    git init -q
    git remote add origin https://github.com/mercwar/dc2URL.git
    git config core.sparseCheckout true
    echo v1.0/ > .git/info/sparse-checkout
    
    git pull origin main --depth 1 -q
    if !errorlevel! neq 0 (
        cd /d "%~dp0"
        rmdir /s /q "!TEMP_STAGE!" >nul 2>&1
        exit /b 1
    )
    
    for /L %%I in (1,1,%FILE_COUNT%) do (
        set "FILE_NAME=!FILE_%%I!"
        for %%F in ("%INSTALL_DIR%\!FILE_NAME!") do if not exist "%%~dpF" mkdir "%%~dpF" >nul 2>&1
        
        if exist "v1.0\!FILE_NAME!" (
            copy /y "v1.0\!FILE_NAME!" "%INSTALL_DIR%\!FILE_NAME!" >nul
        )
        call :DrawProgressBar %%I %FILE_COUNT% "!FILE_NAME!"
    )
    
    cd /d "%~dp0"
    rmdir /s /q "!TEMP_STAGE!" >nul 2>&1
    exit /b 0
)

if "%METHOD%"=="curl" (
    echo %Y1%[EXECUTE]%TXT% Mapping file payloads over individual cURL stream sockets...%RESET%%BG_GLASS%
    for /L %%I in (1,1,%FILE_COUNT%) do (
        set "FILE_NAME=!FILE_%%I!"
        set "URL_PATH=!FILE_NAME:\=/!"
        for %%F in ("%INSTALL_DIR%\!FILE_NAME!") do if not exist "%%~dpF" mkdir "%%~dpF" >nul 2>&1
        
        curl -sL "%RAW_BASE_URL%/!URL_PATH!" -o "%INSTALL_DIR%\!FILE_NAME!"
        if !errorlevel! neq 0 exit /b 1
        call :DrawProgressBar %%I %FILE_COUNT% "!FILE_NAME!"
    )
    exit /b 0
)

if "%METHOD%"=="powershell" (
    echo %Y1%[EXECUTE]%TXT% Mapping file payloads via PowerShell WebRequest pipelines...%RESET%%BG_GLASS%
    for /L %%I in (1,1,%FILE_COUNT%) do (
        set "FILE_NAME=!FILE_%%I!"
        set "URL_PATH=!FILE_NAME:\=/!"
        for %%F in ("%INSTALL_DIR%\!FILE_NAME!") do if not exist "%%~dpF" mkdir "%%~dpF" >nul 2>&1
        
        powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest '%RAW_BASE_URL%/!URL_PATH!' -OutFile '%INSTALL_DIR%\!FILE_NAME!'"
        if !errorlevel! neq 0 exit /b 1
        call :DrawProgressBar %%I %FILE_COUNT% "!FILE_NAME!"
    )
    exit /b 0
)

if "%METHOD%"=="bitsadmin" (
    echo %Y1%[EXECUTE]%TXT% Provisioning file payloads via BITSAdmin background service...%RESET%%BG_GLASS%
    for /L %%I in (1,1,%FILE_COUNT%) do (
        set "FILE_NAME=!FILE_%%I!"
        set "URL_PATH=!FILE_NAME:\=/!"
        for %%F in ("%INSTALL_DIR%\!FILE_NAME!") do if not exist "%%~dpF" mkdir "%%~dpF" >nul 2>&1
        
        bitsadmin /transfer "dc2Job_%%I" /download /priority foreground "%RAW_BASE_URL%/!URL_PATH!" "%INSTALL_DIR%\!FILE_NAME!" >nul 2>&1
        if !errorlevel! neq 0 exit /b 1
        call :DrawProgressBar %%I %FILE_COUNT% "!FILE_NAME!"
    )
    exit /b 0
)
endlocal
exit /b 1


:: =========================================================================
:: FUNCTION SECTION: DrawProgressBar
:: =========================================================================
:DrawProgressBar
set "CUR=%~1"
set "MAX=%~2"
set "FNAME=%~3"

set /a "PCT=(CUR * 100) / MAX"
set /a "FILLED=(PCT * 20) / 100"
set /a "EMPTY=20 - FILLED"

set "BAR="
for /L %%B in (1,1,!FILLED!) do set "BAR=!BAR!#"
for /L %%B in (1,1,!EMPTY!) do set "BAR=!BAR!."

<nul set /p "=    %Y2%[ !BAR! ]%RESET% %O2%!PCT!%%%RESET% (%CUR%/%MAX%) - !FNAME!                         "
echo.
exit /b 0


:: =========================================================================
:: FUNCTION SECTION: InstallGitViaWinget
:: =========================================================================
:InstallGitViaWinget
echo %O2%[WINGET]%TXT% Locating Windows Package Manager engine...%RESET%%BG_GLASS%
where winget >nul 2>nul
if %errorlevel% neq 0 (
    echo %O1%[ERROR]%TXT% Winget installer was not found on this version of Windows.%RESET%%BG_GLASS%
    pause
    exit /b 1
)
echo %Y1%[EXECUTE]%TXT% Provisioning official Git package layer from community manifests...%RESET%%BG_GLASS%
winget install --id Git.Git -e --source winget
echo %Y2%[SUCCESS]%TXT% Winget package setup task finished.%RESET%%BG_GLASS%
exit /b 0


:: =========================================================================
:: FALLBACK SECTION: BROWSER FALLBACK INTERFACE
:: =========================================================================
:BROWSER_FALLBACK
echo.
echo %O2%============================================================%RESET%%BG_GLASS%
echo %Y2%[FALLBACK ROUTE ACTIVATED]%RESET%%BG_GLASS%
echo Automated shell installation tools were unable to complete processing.
echo We will now attempt to open your browser to download manually.
echo %O2%============================================================%RESET%%BG_GLASS%
echo.
pause
echo Launching default web browser to repository root index...
start "" "%REPO_BROWSER_URL%"
exit /b 1
