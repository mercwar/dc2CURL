@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"



set "GET_URL=http://httpbin.org/get?test=winhttp_fastpath"
set "POST_URL=http://httpbin.org/post"
set "BINARY_URL=http://httpbin.org/bytes/1024"
set "BINARY_OUTPUT=httpbin_binary.bin"

echo ============================================================
echo DARK-COM-2 :: WINHTTP FAST-PATH (-nojs) VERIFICATION SUITE
echo ============================================================
echo.

if exist "%BINARY_OUTPUT%" del /f /q "%BINARY_OUTPUT%"

echo [TEST 1] GET Request (WinHTTP Fast-Path)
echo ------------------------------------------------------------
dc2url.exe "%GET_URL%" -v -nojs

echo.
echo ============================================================
echo [TEST 2] POST Request with JSON Payload (WinHTTP Fast-Path)
echo ============================================================
dc2url.exe "%POST_URL%" -X POST -d "{\"action\":\"winhttp_test\",\"status\":\"active\"}" -v --nojs

echo.
echo ============================================================
echo [TEST 3] Binary Stream Download (WinHTTP Fast-Path)
echo ============================================================
echo Downloading 1024 raw bytes directly to disk...
dc2url.exe -o "%BINARY_OUTPUT%" "%BINARY_URL%" -v -nojs

echo.
if exist "%BINARY_OUTPUT%" (
    for %%I in ("%BINARY_OUTPUT%") do set "FILESIZE=%%~zI"
    echo [SUCCESS] Binary download completed successfully!
    echo [FILE] Target: %BINARY_OUTPUT%
    echo [SIZE] Bytes transferred: !FILESIZE! bytes
    
    if !FILESIZE! EQU 1024 (
        echo [VERIFICATION] Byte count matches exact expected payload size.
    ) else (
        echo [WARNING] Size mismatch. Expected 1024 bytes, got !FILESIZE! bytes.
    )
) else (
    echo [ERROR] Binary download failed. Output file was not created.
)

echo.
echo ============================================================
echo ALL WINHTTP FAST-PATH TESTS COMPLETED
echo ============================================================


set "TARGET_URL=https://mercwar01.byethost3.com/darkcom2/echo.php"
set "MIDI_OUTPUT=transformers.mid"
set "MIDI_URL=https://raw.githubusercontent.com/mercwar/dc2url/main/sound/%MIDI_OUTPUT%"

echo ============================================================
echo DARK-COM-2 :: FULL CURL-COMPATIBLE VERIFICATION SUITE
echo ============================================================
echo.

if exist "%MIDI_OUTPUT%" del /f /q "%MIDI_OUTPUT%"

echo [TEST 1] URL First (Standard Curl Style)
echo ------------------------------------------------------------
dc2url.exe "%TARGET_URL%" -X POST -d "{\"action\":\"test_url_first\"}" -v

echo.
echo ============================================================
echo [TEST 2] Flags First (Alternative Curl Style)
echo ============================================================
dc2url.exe -X POST -d "{\"action\":\"test_flags_first\"}" "%TARGET_URL%" --verbose

echo.
echo ============================================================
echo [TEST 3] Long Flags Style
echo ============================================================
dc2url.exe --request POST --data "{\"action\":\"test_long_flags\"}" "%TARGET_URL%" --verbose

echo.
echo ============================================================
echo SEQUENTIAL VERIFICATION: PERSISTENCE TRACKING BLOCK
echo ============================================================
echo.
echo Iteration #1: Sending payload...
dc2url.exe --request POST --data "{\"iteration\":1}" "%TARGET_URL%" -v
echo.

echo Iteration #2: Testing value increment updates...
dc2url.exe --request POST --data "{\"iteration\":2}" "%TARGET_URL%" -v
echo.

echo ============================================================
echo BINARY DOWNLOAD TEST: WINHTTP FAST-PATH (-nojs)
echo ============================================================
echo Downloading canonical MIDI asset via dc2url.exe -o flag...
dc2url.exe -o "%MIDI_OUTPUT%" "%MIDI_URL%" -v

echo.
if exist "%MIDI_OUTPUT%" (
    for %%I in ("%MIDI_OUTPUT%") do set "FILESIZE=%%~zI"
    echo [SUCCESS] Binary download completed successfully!
    echo [FILE] Target: %MIDI_OUTPUT%
    echo [SIZE] Bytes transferred: !FILESIZE! bytes
    
    if !FILESIZE! GTR 1000 (
        echo [VERIFICATION] File size is valid. Launching audio playback test...
        :: Passing the file directly to start triggers the system's default MIDI player
        start "" "%MIDI_OUTPUT%"
    ) else (
        echo [WARNING] File size is suspiciously small. Verify redirect response stream.
    )
) else (
    echo [ERROR] Binary download failed. Output file was not created.
)


echo.
echo ============================================================
echo ALL API DIAGNOSTICS AND BINARY TESTS COMPLETED
echo ============================================================
pause
