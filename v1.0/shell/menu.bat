@echo off
:: Resolve environment references relative to parent location contexts
if "%ROOT_DIR%"=="" (
    set "ROOT_DIR=%~dp0..\"
)
set "INI_FILE=%TEMP%\dc2url_install.ini"

echo [SELECT INSTALLATION MODE]
echo ------------------------------------------------------------
echo  1. Network Route (Ignore local files, clone repo via git.bat)
echo  2. Local Route   (Verify and deploy files already on this system)
echo ------------------------------------------------------------
echo.
set /p "CHOICE=Select an option [1-2]: "

if "%CHOICE%"=="1" goto setup_network
if "%CHOICE%"=="2" goto verify_local
echo [ERROR] Invalid selection. Please type 1 or 2.
echo.
goto menu

:setup_network
net session >nul 2>&1
if %errorlevel% equ 0 ( set "HARDCODED_ROOT=%ProgramFiles%\dc2URL" ) else ( set "HARDCODED_ROOT=%LOCALAPPDATA%\dc2URL" )

echo.
echo Target windows directory default: !HARDCODED_ROOT!
set /p "NET_PATH=Enter directory path to install repository files to (Or press ENTER for default): "
if "%NET_PATH%"=="" ( set "TARGET_DIR=!HARDCODED_ROOT!" ) else ( set "TARGET_DIR=%NET_PATH%" )

:: Strip trailing whitespace properties
for /l %%l in (1,1,100) do if "!TARGET_DIR:~-1!"==" " set "TARGET_DIR=!TARGET_DIR:~0,-1!"

:: Create the persistent transaction file block
if exist "!INI_FILE!" del /f /q "!INI_FILE!"
echo [InstallationConfig] > "!INI_FILE!"
echo TargetDir=!TARGET_DIR! >> "!INI_FILE!"
echo SourceMode=NetworkCloned >> "!INI_FILE!"

if exist "!ROOT_DIR!shell\git.bat" (
    call "!ROOT_DIR!shell\git.bat"
    exit /b
) else (
    echo [ERROR] Network script tool 'shell\git.bat' is missing from repository dependencies!
    pause
    exit /b
)

:verify_local
set "MISSING_FILES=0"
if not exist "!ROOT_DIR!exec\darkcom2.exe" ( echo [MISSING] exec\darkcom2.exe & set "MISSING_FILES=1" )
if not exist "!ROOT_DIR!exec\DarkComHeadless.dll" ( echo [MISSING] exec\DarkComHeadless.dll & set "MISSING_FILES=1" )
if not exist "!ROOT_DIR!exec\WebView2Loader.dll" ( echo [MISSING] exec\WebView2Loader.dll & set "MISSING_FILES=1" )
if not exist "!ROOT_DIR!echo.bat" ( echo [MISSING] echo.bat & set "MISSING_FILES=1" )
if not exist "!ROOT_DIR!favi-con.ico" ( echo [MISSING] favi-con.ico & set "MISSING_FILES=1" )

if "!MISSING_FILES!"=="1" (
    echo.
    echo [ERROR] Standalone installation failed because required components are missing.
    echo [TIP] Choose Option 1 instead to fetch a fresh cloning sequence bundle.
    echo.
    pause
    exit /b
)

echo [SUCCESS] All target file dependencies verified locally.

net session >nul 2>&1
if %errorlevel% equ 0 ( set "HARDCODED_ROOT=%ProgramFiles%\dc2URL" ) else ( set "HARDCODED_ROOT=%LOCALAPPDATA%\dc2URL" )

echo.
echo Target windows directory default: !HARDCODED_ROOT!
set /p "LOCAL_PATH=Enter directory path to install local files to (Or press ENTER for default): "
if "%LOCAL_PATH%"=="" ( set "TARGET_DIR=!HARDCODED_ROOT!" ) else ( set "TARGET_DIR=%LOCAL_PATH%" )

for /l %%l in (1,1,100) do if "!TARGET_DIR:~-1!"==" " set "TARGET_DIR=!TARGET_DIR:~0,-1!"

if exist "!INI_FILE!" del /f /q "!INI_FILE!"
echo [InstallationConfig] > "!INI_FILE!"
echo TargetDir=!TARGET_DIR! >> "!INI_FILE!"
echo SourceMode=StandaloneLocal >> "!INI_FILE!"

:: Locally invoke subfolder modular components directly
if exist "!ROOT_DIR!shell\copy.bat" ( call "!ROOT_DIR!shell\copy.bat" "!TARGET_DIR!" )
if exist "!ROOT_DIR!shell\reg.bat" ( call "!ROOT_DIR!shell\reg.bat" "!TARGET_DIR!" )

echo.
echo ============================================================
echo  CONFIGURATION PROCESS COMPLETED SUCCESSFULLY
echo ============================================================
echo Installed path matches: !TARGET_DIR!
if exist "!INI_FILE!" del /f /q "!INI_FILE!"
pause
