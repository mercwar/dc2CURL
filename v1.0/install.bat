@echo off
setlocal EnabledelayedExpansion
echo ============================================================
echo               dc2URL :: MAIN INSTALLATION SUITE
echo ============================================================
echo.

:: 1. Capture Active Folder Environment Context
set "ROOT_DIR=%~dp0"
if "!ROOT_DIR!"=="" set "ROOT_DIR=%cd%\"

set "INI_FILE=%TEMP%\dc2url_install.ini"

:: 2. MICROSOFT WINDOWS OS ENVIRONMENT TRACKING LAYER
for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v dc2url_path 2^>nul') do set "EXISTING_PATH=%%B"

if not "!EXISTING_PATH!"=="" (
    if exist "!EXISTING_PATH!\darkcom2.exe" (
        :: Dynamically strip the trailing exec folder mapping to identify root deployment context
        set "CLEAN_ROOT=!EXISTING_PATH:\exec=!"
        
        :: Safely determine protocol handler validity mapping inside the windows layer
        set "PROTOCOL_STATUS=Not Registered"
        reg query "HKLM\Software\Classes\dc2URL" >nul 2>&1 && set "PROTOCOL_STATUS=Active (System Context)"
        reg query "HKCU\Software\Classes\dc2URL" >nul 2>&1 && set "PROTOCOL_STATUS=Active (User Context)"

        echo [DETECTED] Pre-existing Installation Found on Microsoft Windows OS
        echo ------------------------------------------------------------
        echo   Installation Directory : !CLEAN_ROOT!
        echo   Binaries Subdirectory  : !EXISTING_PATH!
        echo   Active Target Binary   : darkcom2.exe
        echo   URI Protocol Status    : !PROTOCOL_STATUS!
        echo ------------------------------------------------------------
        echo.
        echo To proceed with a fresh configuration, you must uninstall first.
        set /p "UI_CHOICE=Would you like to execute the uninstaller now? [Y/N]: "
        if /i "!UI_CHOICE!"=="Y" (
            if exist "!ROOT_DIR!uninstall.bat" (
                echo [INFO] Invoking uninstallation lifecycle...
                call "!ROOT_DIR!uninstall.bat" --from-installer
                exit /b
            ) else (
                if exist "!EXISTING_PATH!\uninstall.bat" (
                    echo [INFO] Invoking uninstallation from target footprint...
                    call "!EXISTING_PATH!\uninstall.bat" --from-installer
                    exit /b
                ) else (
                    echo [ERROR] uninstall.bat was not found in this directory context.
                    pause
                    exit /b
                )
            )
        )
        echo [INFO] Aborting installation pipeline to prevent folder conflicts.
        goto end
    )
)

:: 3. Intercept headless loop parameter flags passed from git.bat
if "%~1"=="--headless" (
    if exist "!INI_FILE!" (
        echo [INFO] Headless Token Verified. Resuming deployment...
        goto parse_ini
    )
)

:: 4. Delegate user interface tracker selections down into the shell folder context
if exist "!ROOT_DIR!shell\menu.bat" (
    call "!ROOT_DIR!shell\menu.bat"
    exit /b
) else (
    echo [ERROR] Critical file component 'shell\menu.bat' is missing from the workspace layout!
    pause
    exit /b
)

:parse_ini
for /f "usebackq tokens=1,2 delims==" %%A in ("!INI_FILE!") do (
    if "%%A"=="TargetDir" set "TARGET_DIR=%%B"
)

:deploy
:: Strip trailing spaces safely from destination directory strings
for /l %%l in (1,1,100) do if "!TARGET_DIR:~-1!"==" " set "TARGET_DIR=!TARGET_DIR:~0,-1!"

:: Invoke file copier modular blocks out of the shell directory layout
if exist "!ROOT_DIR!shell\copy.bat" (
    call "!ROOT_DIR!shell\copy.bat" "!TARGET_DIR!"
) else (
    echo [ERROR] Critical file module 'shell\copy.bat' was not found!
    pause
    exit /b
)

:: Invoke registry protocol handler modifications out of the shell directory layout
if exist "!ROOT_DIR!shell\reg.bat" (
    call "!ROOT_DIR!shell\reg.bat" "!TARGET_DIR!"
) else (
    echo [ERROR] Critical setup script 'shell\reg.bat' was not found!
    pause
    exit /b
)

:: Mirror a local tracking copy of the uninstaller into the user's selected path context root
if exist "!ROOT_DIR!uninstall.bat" (
    xcopy /Y "!ROOT_DIR!uninstall.bat" "!TARGET_DIR!\" >nul 2>&1
)

echo.
echo ============================================================
echo  CONFIGURATION LIFECYCLE COMPLETED SUCCESSFULLY
echo ============================================================
echo Final execution folder matches: !TARGET_DIR!
echo The global 'dc2url' command is now active across the system.

:end
if exist "!INI_FILE!" del /f /q "!INI_FILE!"
pause
