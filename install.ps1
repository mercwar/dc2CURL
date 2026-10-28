<#
.SYNOPSIS
    dc2URL Root Staging Loader (Flicker-Free with Readable Delays)
#>
[CmdletBinding()]
param (
    [string]$sound = $env:SOUND_MODE
)

$ErrorActionPreference = 'Stop'
[Net.SecurityProtocolType]::Tls12

# Resolve sound status safely, checking parameter, global scope, and environment variables
$SoundVal = "off"
if ($sound -eq "on" -or $global:sound -eq "on" -or $env:SOUND_MODE -eq "on") { 
    $SoundVal = "on" 
}

# Configure Window Title & Dimensions for Clean Presentation
$host.UI.RawUI.WindowTitle = "dc2url Launcher v1.0"
try {
    $host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(100, 40)
    $host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(100, 40)
} catch {}

# Strictly lowercase URL for Linux/Apache case-sensitivity compliance
$RepoUrl = "https://mercwar01.byethost3.com/darkcom2/launcher.bat"
$TempInstaller = "$env:TEMP\dc2_install_$([Guid]::NewGuid().ToString().Substring(0,8)).bat"

Clear-Host
Write-Host "====================================================================================" -ForegroundColor DarkGray
Write-Host "     E C L I P S E    I N S T A L L E R    ■    D C 2 U R L    K E R N E L" -ForegroundColor Cyan
Write-Host "     Stargate 2 Quasar 2" -ForegroundColor Cyan
Write-Host "====================================================================================" -ForegroundColor DarkGray
Write-Host "  Mercwar Stargate  technology" -ForegroundColor DarkYellow
Write-Host "  Status: Contacting server..." -ForegroundColor Gray
Write-Host "====================================================================================" -ForegroundColor DarkGray
Write-Host ""

# TRIGGER SOUND DIRECTLY IN POWERSHELL IF ENABLED
if ($SoundVal -eq "on") {
    Write-Host "  [SYSTEM] Turning network subsystem stream sound ON..." -ForegroundColor Cyan
    $MidiUrl = "https://raw.githubusercontent.com/mercwar/dc2url/main/sound/transformers.mid"
    $MidiFile = "$env:TEMP\transformers.mid"
    try {
        $dc2check = Get-Command dc2url -ErrorAction SilentlyContinue
        if ($dc2check) {
            dc2url -o "$MidiFile" "$MidiUrl"
        } else {
            (New-Object System.Net.WebClient).DownloadFile($MidiUrl, $MidiFile)
        }
        if (Test-Path $MidiFile) {
            Write-Host "  [SUCCESS] Playing Transformers theme song..." -ForegroundColor Green
            Start-Process $MidiFile
        }
    } catch {
        Write-Host "  [WARNING] Could not stream MIDI asset." -ForegroundColor DarkYellow
    }
} else {
    Write-Host "  [SYSTEM] Audio disabled." -ForegroundColor DarkGray
}
Write-Host ""

Write-Host "  [AVIS] Searching for installation gateway" -ForegroundColor Yellow
Write-Host "  [AVIS] » Target Source : " -NoNewline -ForegroundColor DarkGray
Write-Host "$RepoUrl" -ForegroundColor White
Write-Host "  [AVIS] » Target Output : " -NoNewline -ForegroundColor DarkGray
Write-Host "$TempInstaller" -ForegroundColor White
Write-Host ""
Write-Host "  [AVIS] Connecting to gateway via dc2url..." -ForegroundColor Cyan

# Fetch payload using lowercase dc2url output flag (-o) or standard WebClient fallback
try {
    $dc2check = Get-Command dc2url -ErrorAction SilentlyContinue
    if ($dc2check) {
        dc2url -o "$TempInstaller" "$RepoUrl"
    } else {
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($RepoUrl, $TempInstaller)
    }

    if (-not (Test-Path $TempInstaller) -or (Get-Item $TempInstaller).Length -eq 0) {
        throw "Downloaded payload is empty or missing."
    }
}
catch {
    Write-Host ""
    Write-Host "  [AVIS ERROR] Download failed: $_" -ForegroundColor Red
    Pause
    exit 1
}

Write-Host "  [AVIS SUCCESS] Payload secured on disk." -ForegroundColor Green
Write-Host ""

# Brief pause so the user can read the screen output
Write-Host "  [AVIS ECLIPSE] Searching for Cyborg Launcher..." -ForegroundColor DarkGray
Start-Sleep -Seconds 3

Write-Host ""
Write-Host "  [AVIS] Calling Portal Installer" -ForegroundColor Yellow
Write-Host "  [ECLIPSE] » AVIS REPORTED SUCCESS..." -ForegroundColor DarkGray
Write-Host "====================================================================================" -ForegroundColor DarkGray
Write-Host ""

Start-Sleep -Milliseconds 600

# Execute the downloaded batch script natively
Start-Process -FilePath "cmd.exe" -ArgumentList @("/c", $TempInstaller) -Wait -NoNewWindow

# Cleanup
if (Test-Path $TempInstaller) {
    Remove-Item $TempInstaller -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "  [ECLIPSE] dc2url will be visible in your add/remove programs after the registration." -ForegroundColor Green
Write-Host "  [ECLIPSE] Auto updates are not supported at this time, you may run this irm or launcher at any time to update dc2url." -ForegroundColor Green
Write-Host "====================================================================================" -ForegroundColor DarkGray
