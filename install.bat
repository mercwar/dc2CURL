@echo off
setlocal enabledelayedexpansion

:: =========================================================================
:: CONFIGURATION & MANIFEST DEFINITIONS
:: =========================================================================
set "REPO_BROWSER_URL=https://github.com/mercwar/dc2URL"
set "RAW_BASE_URL=https://raw.githubusercontent.com/mercwar/dc2URL/main/v1.0"

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

echo =========================================================================
echo               dc2CURL Staging Wrapper Engine
echo =========================================================================
echo.

:: 1. NETWORK CONNECTIVITY CHECK
for /F %%A in ('%SystemRoot%\System32\ping.exe 1.1.1.1 -n 1 ^| %SystemRoot%\System32\find.exe /C "="') do (set "CONNECTED=%%A")
if !CONNECTED! LSS 2 (
    echo [ERROR] No active internet connection detected.
    goto :BROWSER_FALLBACK
)
echo [SUCCESS] Network connectivity verified.
echo.

:: 2. PROMPT USER FOR TARGET INSTALLATION PATH
:PROMPT_PATH
echo Choose your preferred local installation directory:
echo [1] Install locally to default user directory (%USERPROFILE%\dc2CURL)
echo [2] Enter a custom absolute file system path
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
echo [TARGET] Installation directory set to: %INSTALL_DIR%
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

if "%CHOSEN_ENGINE%"=="browser" goto :BROWSER_FALLBACK

:: Handle Local dc2URL Selection
if "%CHOSEN_ENGINE%"=="local_dc2url" (
    echo [LOCAL] Using existing dc2URL installation at: %FOUND_DC2URL%
    cd /d "%FOUND_DC2URL%"
    if exist "install.bat" (
        echo.
        echo [LAUNCH] Handing off control execution to %FOUND_DC2URL%\install.bat...
        echo =========================================================================
        call install.bat
        exit /b !errorlevel!
    ) else (
        echo [ERROR] Selected local path does not contain install.bat.
        goto :SCAN_ENGINES
    )
)

:: Handle Winget helper: Install/Update Git, then re-display engine menu
if "%CHOSEN_ENGINE%"=="winget" (
    call :InstallGitViaWinget
    echo [RE-SCAN] Environment updated. Returning to download engine selection menu...
    echo.
    goto :SCAN_ENGINES
)

:: 5. EXECUTE ISOLATED CONTENT DOWNLOAD PIPELINE
mkdir "%INSTALL_DIR%" 2>nul
call :DownloadV10Contents "%CHOSEN_ENGINE%"
if !errorlevel! neq 0 (
    echo [WARNING] Chosen download method failed execution.
    goto :BROWSER_FALLBACK
)

:: 6. EXECUTE DOWNLOADED CORE INSTALLER
if not exist "%INSTALL_DIR%\install.bat" (
    echo [ERROR] Target validation failed. install.bat was not copied over.
    goto :BROWSER_FALLBACK
)

echo.
echo [LAUNCH] Handing off control execution to %INSTALL_DIR%\install.bat...
echo =========================================================================
cd /d "%INSTALL_DIR%"
call install.bat
exit /b %errorlevel%


:: =========================================================================
:: FUNCTION SECTION: DownloadV10Contents
:: =========================================================================
:DownloadV10Contents
set "METHOD=%~1"

if "%METHOD%"=="dc2url" (
    echo [EXECUTE] Routing payload through dc2URL WebView2 streaming protocol...
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
    echo [EXECUTE] Initiating partial tree sparse-checkout...
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
    echo [EXECUTE] Mapping file payloads over individual cURL stream sockets...
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
    echo [EXECUTE] Mapping file payloads via PowerShell WebRequest pipelines...
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
    echo [EXECUTE] Provisioning file payloads via BITSAdmin background service...
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

<nul set /p "=   [ !BAR! ] !PCT%%! (!CUR!/!MAX!) - !FNAME!                       "
echo.
exit /b 0


:: =========================================================================
:: FUNCTION SECTION: InstallGitViaWinget
:: =========================================================================
:InstallGitViaWinget
echo [WINGET] Locating Windows Package Manager engine...
where winget >nul 2>nul
if !errorlevel! neq 0 (
    echo [ERROR] Winget installer was not found on this version of Windows.
    pause
    exit /b 1
)
echo [EXECUTE] Provisioning official Git package layer from community manifests...
winget install --id Git.Git -e --source winget
echo [SUCCESS] Winget package setup task finished.
exit /b 0


:: =========================================================================
:: FALLBACK SECTION: BROWSER FALLBACK INTERFACE
:: =========================================================================
:BROWSER_FALLBACK
echo.
echo =========================================================================
echo [FALLBACK ROUTE ACTIVATED]
echo Automated shell installation tools were unable to complete processing.
echo We will now attempt to open your browser to download manually.
echo =========================================================================
echo.
pause
echo Launching default web browser to repository root index...
start "" "%REPO_BROWSER_URL%"
exit /b 1