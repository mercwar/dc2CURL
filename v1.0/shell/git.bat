@echo off
set "REPO_URL=https://github.com"
set "TEMP_CLONE_DIR=%TEMP%\dc2url_network_scratch"
set "INI_FILE=%TEMP%\dc2url_install.ini"

where git >nul 2>&1
if !errorlevel! neq 0 (
    echo [WARNING] Git CLI was not found installed on this operating system.
    echo ------------------------------------------------------------
    echo To install Git natively using Windows Package Manager, do this:
    echo  1. Open a separate Command Prompt window.
    echo  2. Copy-paste and run this command:
    echo     winget install --id Git.Git -e --source winget
    echo  3. Once the setup finishes, restart this installer windows layout.
    echo ------------------------------------------------------------
    echo.
    if exist "!INI_FILE!" del /f /q "!INI_FILE!"
    pause
    exit /b
)

if exist "%TEMP_CLONE_DIR%" rd /s /q "%TEMP_CLONE_DIR%"

echo [INFO] Initializing secure down-streaming of source repository matrix to temp folder...
git clone "%REPO_URL%" "%TEMP_CLONE_DIR%"
if %errorlevel% neq 0 (
    echo [ERROR] Git cloning transaction failed. Check internet link connections.
    if exist "!INI_FILE!" del /f /q "!INI_FILE!"
    pause
    exit /b
)

set "SOURCE_ROOT=%TEMP_CLONE_DIR%\v1.0"
if not exist "%SOURCE_ROOT%\install.bat" (
    echo [ERROR] Target 'install.bat' deployment controller was not found inside downloaded branch tree!
    rd /s /q "%TEMP_CLONE_DIR%"
    if exist "!INI_FILE!" del /f /q "!INI_FILE!"
    pause
    exit /b
)

echo [INFO] Handing off control to cloned repository assets...
cd /d "%SOURCE_ROOT%"
call install.bat --headless

:: Cascade focus directly back to original script thread context execution path maps
cd /d "%~dp0"
if exist "%TEMP_CLONE_DIR%" rd /s /q "%TEMP_CLONE_DIR%"
