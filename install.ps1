<#
.SYNOPSIS
    dc2URL Root Staging Loader (Flicker-Free with Readable Delays)
#>

$ErrorActionPreference = 'Stop'
[Net.SecurityProtocolType]::Tls12

# Configure Window Title & Dimensions for Clean Presentation
$host.UI.RawUI.WindowTitle = "MERCWAR // dc2URL Bootstrap Loader v1.0"
try {
    $host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(100, 40)
    $host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(100, 40)
} catch {}

$RepoUrl = "https://raw.githubusercontent.com/mercwar/dc2URL/main/launcher.bat"
$TempInstaller = "$env:TEMP\dc2_install_$([Guid]::NewGuid().ToString().Substring(0,8)).bat"

Clear-Host
Write-Host "====================================================================================" -ForegroundColor DarkGray
Write-Host "  // F I R E G E M   ■   D A R K - C O M - 2   //   M O D E R N   K E R N E L" -ForegroundColor Cyan
Write-Host "====================================================================================" -ForegroundColor DarkGray
Write-Host "  MERCWAR SYSTEMS // ECLIPSE TECHNOLOGY" -ForegroundColor DarkYellow
Write-Host "  STATUS: Searching for Installer..." -ForegroundColor Gray
Write-Host "====================================================================================" -ForegroundColor DarkGray
Write-Host ""

Write-Host "  [ Cyborg Data uplink ]" -ForegroundColor Yellow
Write-Host "   » Target Source : " -NoNewline -ForegroundColor DarkGray
Write-Host "$RepoUrl" -ForegroundColor White
Write-Host "   » Target Output : " -NoNewline -ForegroundColor DarkGray
Write-Host "$TempInstaller" -ForegroundColor White
Write-Host ""
Write-Host "  [Cyborg Data downlink] Establishing TLS handshake and downloading launcher payload..." -ForegroundColor Cyan

# Silent download stream
try {
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($RepoUrl, $TempInstaller)
}
catch {
    Write-Host ""
    Write-Host "  [AVIS ERROR] Downlink failed: $_" -ForegroundColor Red
    Pause
    exit 1
}

Write-Host "  [AVIS SUCCESS] Gatway Alive." -ForegroundColor Green
Write-Host ""

# Brief pause so the user can actually read the screen output
Write-Host "  [AVIS SCAN] Verifying files..." -ForegroundColor DarkGray
Start-Sleep -Seconds 5

Write-Host ""
Write-Host "  [AVIS] Installing dc2url" -ForegroundColor Yellow
Write-Host "   » Loading Registry..." -ForegroundColor DarkGray
Write-Host "====================================================================================" -ForegroundColor DarkGray
Write-Host ""

Start-Sleep -Milliseconds 600

# Execute the launcher interactively without screen flashing
Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$TempInstaller`"" -Wait -NoNewWindow

# Cleanup
if (Test-Path $TempInstaller) {
    Remove-Item $TempInstaller -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "  [AVIS] dc2url is installed and visible in your add/remove programs." -ForegroundColor Green
Write-Host "  [AVIS] You can update dc2url by running this irm or launcher.bat again." -ForegroundColor Green
Write-Host "  [AVIS] Automatic updates hare not yet available, feel free to run the irm and launcher at any time." -ForegroundColor Green
Write-Host "====================================================================================" -ForegroundColor DarkGray
