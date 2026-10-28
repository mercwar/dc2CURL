<#
.SYNOPSIS
    dc2URL Root Staging Loader
#>

param(
    [string]$Sound = "off"
)

$ErrorActionPreference = "Stop"

try {
    [Net.ServicePointManager]::SecurityProtocol = `
        [Net.SecurityProtocolType]::Tls12
} catch {}

$RepoUrl = "https://raw.githubusercontent.com/mercwar/dc2URL/main/launcher.bat"
$TempInstaller = Join-Path $env:TEMP "dc2_install_$([guid]::NewGuid().ToString('N').Substring(0,8)).bat"

Clear-Host

Write-Host "====================================================================================" -ForegroundColor DarkGray
Write-Host "     E C L I P S E   I N S T A L L E R   ■   D C 2 U R L   K E R N E L" -ForegroundColor Cyan
Write-Host "     Stargate 1 Quasar 3" -ForegroundColor Cyan
Write-Host "====================================================================================" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  [AVIS] Searching for installation gateway..." -ForegroundColor Yellow
Write-Host "  [AVIS] Connecting to gateway..." -ForegroundColor Cyan
Write-Host ""

try {
    Invoke-WebRequest `
        -Uri $RepoUrl `
        -OutFile $TempInstaller `
        -UseBasicParsing

    Write-Host "  [AVIS SUCCESS] Payload secured on disk." -ForegroundColor Green
}
catch {
    Write-Host ""
    Write-Host "  [AVIS ERROR] Download failed:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Pause
    exit 1
}

Start-Sleep 2

Write-Host ""
Write-Host "  [AVIS ECLIPSE] Searching for Cyborg Launcher..." -ForegroundColor DarkGray

Start-Sleep 2

Write-Host ""
Write-Host "  [AVIS] Calling Portal Installer" -ForegroundColor Yellow
Write-Host ""

Start-Process `
    -FilePath "cmd.exe" `
    -ArgumentList "/c call `"$TempInstaller`" $Sound" `
    -Wait `
    -NoNewWindow

if (Test-Path $TempInstaller) {
    Remove-Item $TempInstaller -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "  [ECLIPSE] Installation sequence complete." -ForegroundColor Green
Write-Host "====================================================================================" -ForegroundColor DarkGray
