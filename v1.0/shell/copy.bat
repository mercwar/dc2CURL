@echo off
set "TARGET_DIR=%~1"
:: Pull directory tree reference data relative to root folder location context
set "SRC_DIR=%~dp0..\"

echo [INFO] Provisioning application folders at: !TARGET_DIR!
if not exist "!TARGET_DIR!" mkdir "!TARGET_DIR!"
if not exist "!TARGET_DIR!\exec" mkdir "!TARGET_DIR!\exec"
if not exist "!TARGET_DIR!\images" mkdir "!TARGET_DIR!\images"

echo [INFO] Synchronizing application binaries and support assets...
xcopy /Y "!SRC_DIR!echo.bat" "!TARGET_DIR!\" >nul 2>&1
xcopy /Y "!SRC_DIR!favi-con.ico" "!TARGET_DIR!\" >nul 2>&1
if exist "!SRC_DIR!readme.MD" xcopy /Y "!SRC_DIR!readme.MD" "!TARGET_DIR!\" >nul 2>&1

:: Copy image asset files safely
xcopy /Y /E "!SRC_DIR!images\*.*" "!TARGET_DIR!\images\" >nul 2>&1

:: Move compiled execution core folder contents
xcopy /Y /E "!SRC_DIR!exec\*.*" "!TARGET_DIR!\exec\" >nul
if %errorlevel% neq 0 (
    echo [ERROR] Critical File sync failed. Check directory access rights.
    pause
    exit /b
)
echo [SUCCESS] Copy operations finalized.
