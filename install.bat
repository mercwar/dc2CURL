@echo off
setlocal enabledelayedexpansion

:: =========================================================================
:: CONFIGURATION & MANIFEST DEFINITIONS
:: =========================================================================
set "REPO_BROWSER_URL=https://github.com"
set "RAW_BASE_URL=https://githubusercontent.com"

:: Complete repository file manifest for manual streaming engines
set "FILE_1=darkcom2.exe"
set "FILE_2=DarkComHeadless.dll"
set "FILE_3=WebView2Loader.dll"
set "FILE_4=echo.bat"
set "FILE_5=favi-con.ico"
set "FILE_6=install.bat"
set "FILE_COUNT=6"

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

:: 3. INVENTORY AVAILABLE DOWNLOAD ENGINES
:SCAN_ENGINES
set "OPT_COUNT=0"
set "HAS_GIT=0"

where git >nul 2>nul
if !errorlevel! equ 0 (
    set /a OPT_COUNT+=1
    set "OPT_!OPT_COUNT!=git"
    set "HAS_GIT=1"
    echo [!OPT_COUNT!] Git Client (Native Sparse-Checkout Clone)
)

where curl >nul 2>nul
if !errorlevel! equ 0 (
    set /a OPT_COUNT+=1
    set "OPT_!OPT_COUNT!=curl"
    echo [!OPT_COUNT!] cURL Utility (Direct File Manifest Pipeline)
)

where powershell >nul 2>nul
if !errorlevel! equ 0 (
    set /a OPT_COUNT+=1
    set "OPT_!OPT_COUNT!=powershell"
    echo [!OPT_COUNT!] Microsoft PowerShell Core (WebRequest API)
)

if !HAS_GIT! equ 0 (
    set /a OPT_COUNT+=1
    set "OPT_!OPT_COUNT!=install_git"
    echo [!OPT_COUNT!] * Install Git client automatically now via Winget *
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
if "%CHOSEN_ENGINE%"=="install_git" (
    call :InstallGitViaWinget
    goto :SCAN_ENGINES
)

:: 4. EXECUTE ISOLATED CONTENT DOWNLOAD PIPELINE
mkdir "%INSTALL_DIR%" 2>nul
call :DownloadV10Contents "%CHOSEN_ENGINE%"
if !errorlevel! neq 0 (
    echo [WARNING] Chosen download method failed execution.
    goto :BROWSER_FALLBACK
)

:: 5. EXECUTE DOWNLOADED CORE INSTALLER
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

if "%METHOD%"=="git" (
    echo [EXECUTE] Initiating partial tree sparse-checkout...
    set "TEMP_STAGE=%TEMP%\dc2_checkout"
    rmdir /s /q "!TEMP_STAGE!" 2>nul
    mkdir "!TEMP_STAGE!"
    cd /d "!TEMP_STAGE!"
    
    git init -q
    git remote add origin https://github.com
    git config core.sparseCheckout true
    echo v1.0/>> .git/info/sparse-checkout
    git pull origin main --depth 1 -q
    
    if exist "v1.0" (
        xcopy /y /e "v1.0\*" "%INSTALL_DIR%\" >nul
        cd /d "%~dp0"
        rmdir /s /q "!TEMP_STAGE!" 2>nul
        exit /b 0
    )
    exit /b 1
)

if "%METHOD%"=="curl" (
    echo [EXECUTE] Mapping file payloads over individual cURL stream sockets...
    for /L %%I in (1,1,%FILE_COUNT%) do (
        set "FILE_NAME=!FILE_%%I!"
        echo   -- Downloading: !FILE_NAME!
        curl -sL "%RAW_BASE_URL%/!FILE_NAME!" -o "%INSTALL_DIR%\!FILE_NAME!"
        if !errorlevel! neq 0 exit /b 1
    )
    exit /b 0
)

if "%METHOD%"=="powershell" (
    echo [EXECUTE] Mapping file payloads via PowerShell WebRequest pipelines...
    for /L %%I in (1,1,%FILE_COUNT%) do (
        set "FILE_NAME=!FILE_%%I!"
        echo   -- Down-streaming: !FILE_NAME!
        powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest '%RAW_BASE_URL%/!FILE_NAME!' -OutFile '%INSTALL_DIR%\!FILE_NAME!'"
        if !errorlevel! neq 0 exit /b 1
    )
    exit /b 0
)
exit /b 1


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
echo [SUCCESS] Installation routine wrapped. Re-scanning platform frameworks...
echo.
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
