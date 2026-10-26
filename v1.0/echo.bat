@echo off
setlocal enabledelayedexpansion

set "TARGET_URL=http://mercwar01.byethost3.com/darkcom2/echo.php"
rem set "TARGET_URL=http://localhost:8080/CL2/repositories/mercwar/Dark-Com-2/echo.php"

echo ============================================================
echo  DARK-COM-2 :: ALIAS INTEGRATION VERIFICATION SUITE
echo ============================================================
echo.

:: 1. Force a clean environmental PATH block update check for cached parent handles
where dc2URL >nul 2>&1
if !errorlevel! neq 0 (
    echo [WARNING] Global registration token not mapped in parent editor cache.
    echo [INFO] Attempting to pull live registration context straight from registry...
    
    for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v dc2url_path 2^>nul') do set "REG_EXEC_DIR=%%B"
    
    if not "!REG_EXEC_DIR!"=="" (
        echo [SUCCESS] Live registration folder discovered safely: !REG_EXEC_DIR!
        set "PATH=!REG_EXEC_DIR!;%PATH%"
    ) else (
        echo [ERROR] The 'dc2URL' execution registration cannot be found on this system.
        echo [TIP] Run install.bat first to configure your system environment roots.
        goto end
    )
)

echo [TEST 1] URL First (Standard Curl Style via dc2URL registration)
echo ------------------------------------------------------------
:: FIXED: Using 'call' ensures processing control cascades back to this script
call dc2URL "%TARGET_URL%" -X POST -d "{\"action\":\"test_url_first\"}" -v

echo.
echo ============================================================
echo.

echo [TEST 2] Flags First (Alternative Curl Style via dc2URL registration)
echo ------------------------------------------------------------
call dc2URL -X POST -d "{\"action\":\"test_flags_first\"}" "%TARGET_URL%" --verbose

echo.
echo ============================================================
echo.

echo [TEST 3] Long Flags Style via dc2URL registration
echo ------------------------------------------------------------
call dc2URL --request POST --data "{\"action\":\"test_long_flags\"}" "%TARGET_URL%" --verbose

echo.
echo ============================================================
echo  SEQUENTIAL VERIFICATION: PERSISTENCE TRACKING BLOCK
echo ============================================================
echo.
echo Running back-to-back iterations via global alias...
echo.

echo Iteration #1: Sending payload...
call dc2URL --request POST --data "{\"iteration\":1}" "%TARGET_URL%" -v
echo.

echo Iteration #2: Testing value increment updates...
call dc2URL --request POST --data "{\"iteration\":2}" "%TARGET_URL%" -v
echo.

echo ============================================================
echo  ALL ALIAS REGISTRATION DIAGNOSTIC TESTS COMPLETED
echo ============================================================
:end
pause
