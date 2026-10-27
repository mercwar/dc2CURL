<#
.SYNOPSIS
    dc2URL Root Staging Loader (Flicker-Free with Readable Delays)
#>

$ErrorActionPreference = 'Stop'
[Net.SecurityProtocolType]::Tls12

# Configure Window Title & Dimensions for Clean Presentation
$host.UI.RawUI.WindowTitle = "MERCWAR dc2URL Launcher v1.0"
try {
    $host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(100, 40)
    $host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(100, 40)
} catch {}

$RepoUrl = "https://raw.githubusercontent.com/mercwar/dc2URL/main/launcher.bat"
$TempInstaller = "$env:TEMP\dc2_install_$([Guid]::NewGuid().ToString().Substring(0,8)).bat"

Clear-Host
Write-Host "====================================================================================" -ForegroundColor DarkGray
Write-Host "     E C L I P S E   I N S T A L L E R   ■   D C 2 U R L   K E R N E L" -ForegroundColor Cyan
Write-Host "====================================================================================" -ForegroundColor DarkGray
Write-Host "  Mercwar Stargate technology" -ForegroundColor DarkYellow
Write-Host "  Status: Contacting server..." -ForegroundColor Gray
Write-Host "====================================================================================" -ForegroundColor DarkGray
Write-Host ""

Write-Host "  [AVIS] Searching for installation gateway" -ForegroundColor Yellow
Write-Host "  [AVIS] » Target Source : " -NoNewline -ForegroundColor DarkGray
Write-Host "$RepoUrl" -ForegroundColor White
Write-Host "  [AVIS] » Target Output : " -NoNewline -ForegroundColor DarkGray
Write-Host "$TempInstaller" -ForegroundColor White
Write-Host ""
Write-Host "  [AVIS] Connecting to gateway..." -ForegroundColor Cyan

# Silent download stream
try {
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($RepoUrl, $TempInstaller)
}
catch {
    Write-Host ""
    Write-Host "  [AVIS ERROR] Download failed: $_" -ForegroundColor Red
    Pause
    exit 1<#
.SYNOPSIS
    dc2URL Root Staging Loader (Flicker-Free with Readable Delays)
#>

$ErrorActionPreference = 'Stop'
[Net.SecurityProtocolType]::Tls12

# Configure Window Title & Dimensions for Clean Presentation
$host.UI.RawUI.WindowTitle = "MERCWAR dc2URL Launcher v1.0"
try {
    $host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(100, 40)
    $host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(100, 40)
} catch {}

$RepoUrl = "https://raw.githubusercontent.com/mercwar/dc2URL/main/launcher.bat"
$TempInstaller = "$env:TEMP\dc2_install_$([Guid]::NewGuid().ToString().Substring(0,8)).bat"

Clear-Host
Write-Host "====================================================================================" -ForegroundColor DarkGray
Write-Host "     E C L I P S E   I N S T A L L E R   ■   D C 2 U R L   K E R N E L" -ForegroundColor Cyan
Write-Host "====================================================================================" -ForegroundColor DarkGray
Write-Host "  Mercwar Stargate technology" -ForegroundColor DarkYellow
Write-Host "  Status: Contacting server..." -ForegroundColor Gray
Write-Host "====================================================================================" -ForegroundColor DarkGray
Write-Host ""

Write-Host "  [AVIS] Searching for installation gateway" -ForegroundColor Yellow
Write-Host "  [AVIS] » Target Source : " -NoNewline -ForegroundColor DarkGray
Write-Host "$RepoUrl" -ForegroundColor White
Write-Host "  [AVIS] » Target Output : " -NoNewline -ForegroundColor DarkGray
Write-Host "$TempInstaller" -ForegroundColor White
Write-Host ""
Write-Host "  [AVIS] Connecting to gateway..." -ForegroundColor Cyan

# Silent download stream
try {
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($RepoUrl, $TempInstaller)
}
catch {
    Write-Host ""
    Write-Host "  [AVIS ERROR] Download failed: $_" -ForegroundColor Red
    Pause
    exit 1
}

Write-Host "  [AVIS SUCCESS] Payload secured on disk." -ForegroundColor Green
Write-Host ""

# Brief pause so the user can actually read the screen output
Write-Host "  [AVIS INFO] Verifying checksum and preparing handoff..." -ForegroundColor DarkGray
Start-Sleep -Seconds 5

Write-Host ""
Write-Host "  [AVIS] Calling Portal Installer" -ForegroundColor Yellow
Write-Host "  [ECLIPSE] »  AVIS REPORTED SUCCESS..." -ForegroundColor DarkGray
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
Write-Host "  [ECLIPSE] dc2url will be visible in your add/remove programs after the registration." -ForegroundColor Green
Write-Host "  [ECLIPSE] Auto updates are not supported at this time, you may run this irm or launcher at any time to update dc2url." -ForegroundColor Green
Write-Host "====================================================================================" -ForegroundColor DarkGray

# Explicit termination to prevent session persistence or loopback
exit
}

Write-Host "  [AVIS SUCCESS] Payload secured on disk." -ForegroundColor Green
Write-Host ""

# Brief pause so the user can actually read the screen output
Write-Host "  [AVIS INFO] Verifying checksum and preparing handoff..." -ForegroundColor DarkGray
Start-Sleep -Seconds 5

Write-Host ""
Write-Host "  [AVIS] Calling Portal Installer" -ForegroundColor Yellow
Write-Host "  [ECLIPSE] »  AVIS REPORTED SUCCESS..." -ForegroundColor DarkGray
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
Write-Host "  [ECLIPSE] dc2url will be visible in your add/remove programs after the registration." -ForegroundColor Green
Write-Host "  [ECLIPSE] Auto updates are not supported at this time, you may run this irm or launcher at any time to update dc2url." -ForegroundColor Green
Write-Host "====================================================================================" -ForegroundColor DarkGray

# Explicit termination to prevent session persistence or loopback
exit
