@echo off
setlocal enabledelayedexpansion

:: Dynamically look up the script location
set "REPO_DIR=%~dp0"
set "GLOBAL_DIR=C:\Program Files\dc2url\"
set "TARGET_URL=http://byethost3.com"

:: Determine which directory contains the compiled executable
set "EXE_PATH="
if exist "!REPO_DIR!dc2url.exe" (
    set "EXE_PATH=!REPO_DIR!dc2url.exe"
) else if exist "!GLOBAL_DIR!dc2url.exe" (
    set "EXE_PATH=!GLOBAL_DIR!dc2url.exe"
) else (
    :: Fallback to searching the system PATH environment variable
    where dc2url.exe >nul 2>nul
    if !errorlevel! equ 0 (
        set "EXE_PATH=dc2url.exe"
    )
)

echo ============================================================
echo  DARK-COM-2 :: CURL-COMPATIBLE VERIFICATION SUITE
echo ============================================================
if defined EXE_PATH (
    echo [FOUND] Using utility instance at: "!EXE_PATH!"
) else (
    echo [ERROR] dc2url.exe was not detected in local repo, Program Files, or PATH.
    goto end
)
echo.

echo [TEST 1] URL First (Standard Curl Style)
echo ------------------------------------------------------------
"!EXE_PATH!" -v "%TARGET_URL%" -m POST -d "{\"action\":\"test_url_first\"}"

echo.
echo ============================================================
echo.

echo [TEST 2] Flags First (Alternative Curl Style)
echo ------------------------------------------------------------
"!EXE_PATH!" -v -m POST -d "{\"action\":\"test_flags_first\"}" "%TARGET_URL%"

echo.
echo ============================================================
echo.

echo [TEST 3] Long Flags Style
echo ------------------------------------------------------------
"!EXE_PATH!" -v --method POST --data "{\"action\":\"test_long_flags\"}" "%TARGET_URL%"

echo.
echo ============================================================
echo  SEQUENTIAL VERIFICATION: PERSISTENCE TRACKING BLOCK
echo ============================================================
echo.
echo Running back-to-back iterations to verify system variable increments...
echo.

echo Iteration #1: Sending payload...
"!EXE_PATH!" -v --method POST --data "{\"iteration\":1}" "%TARGET_URL%"
echo.

echo Iteration #2: Testing value increment updates...
"!EXE_PATH!" -v --method POST --data "{\"iteration\":2}" "%TARGET_URL%"
echo.

echo ============================================================
echo  ALL DIAGNOSTIC AND PERSISTENCE TESTS COMPLETED
echo ============================================================

:end
pause
