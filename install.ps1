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
Write-Host "  MERCWAR SYSTEMS // FIREGEM TECHNOLOGY" -ForegroundColor DarkYellow
Write-Host "  STATUS: Initializing secure download stream..." -ForegroundColor Gray
Write-Host "====================================================================================" -ForegroundColor DarkGray
Write-Host ""

Write-Host "  [ 01 // MANIFEST ACQUISITION ]" -ForegroundColor Yellow
Write-Host "   » Target Source : " -NoNewline -ForegroundColor DarkGray
Write-Host "$RepoUrl" -ForegroundColor White
Write-Host "   » Target Output : " -NoNewline -ForegroundColor DarkGray
Write-Host "$TempInstaller" -ForegroundColor White
Write-Host ""
Write-Host "  [INFO] Establishing TLS handshake and downloading launcher payload..." -ForegroundColor Cyan

# Silent download stream
try {
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($RepoUrl, $TempInstaller)
}
catch {
    Write-Host ""
    Write-Host "  [CRITICAL ERROR] Download failed: $_" -ForegroundColor Red
    Pause
    exit 1
}

Write-Host "  [SUCCESS] Payload secured on disk." -ForegroundColor Green
Write-Host ""

# Brief pause so the user can actually read the screen output
Write-Host "  [INFO] Verifying checksum and preparing handoff..." -ForegroundColor DarkGray
Start-Sleep -Seconds 2

Write-Host ""
Write-Host "  [ 02 // APPLICATION HANDOFF ]" -ForegroundColor Yellow
Write-Host "   » Transferring execution control to interactive launcher..." -ForegroundColor DarkGray
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
Write-Host "  [COMPLETE] Deployment sequence finished." -ForegroundColor Green
Write-Host "====================================================================================" -ForegroundColor DarkGray
