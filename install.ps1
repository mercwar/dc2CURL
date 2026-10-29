<#
.SYNOPSIS
    dc2URL Root Staging Loader (Registry-Backed Persistence)
#>
[CmdletBinding()]
param (
    [string]$sound = ""
)

$ErrorActionPreference = 'Stop'
[Net.SecurityProtocolType]::Tls12

# Fallback to environment variable if parameter was dropped by iex pipeline execution
if ([string]::IsNullOrEmpty($sound) -and -not [string]::IsNullOrEmpty($env:sound)) {
    $sound = $env:sound
}

# Clean, single lowercase sound validation
$SoundVal = "off"
if ($sound -eq "on") { 
    $SoundVal = "on" 
}

# --- REGISTER SOUND PREFERENCE IN WINDOWS REGISTRY ---
$RegPath = "HKCU:\Software\Eclipse\Launcher"
try {
    if (-not (Test-Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
    }
    Set-ItemProperty -Path $RegPath -Name "sound" -Value $SoundVal -Type String
} catch {
    # Fallback to reg.exe if PowerShell provider fails
    cmd.exe /c "reg add "HKCU\Software\Eclipse\Launcher" /v sound /t REG_SZ /d "$SoundVal" /f >nul 2>&1"
}

# Configure Window Title & Dimensions for Clean Presentation
$host.UI.RawUI.WindowTitle = "dc2URL Launcher v1.0"
try {
    $host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(100, 40)
    $host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(100, 40)
} catch {}

# Routed through PHP downlink handler to securely bypass extension blocking
# $RepoUrl = "https://mercwar01.byethost3.com/darkcom2/downlink.php?file=launcher.bat"
 $RepoUrl = "https://github.com/mercwar/dc2url/raw/refs/heads/main/launcher.bat"

$TempInstaller = "$env:TEMP\dc2_install_$([Guid]::NewGuid().ToString().Substring(0,8)).bat"

Clear-Host
Write-Host "====================================================================================" -ForegroundColor DarkGray
Write-Host "     E C L I P S E    I N S T A L L E R    ■    D C 2 U R L    K E R N E L" -ForegroundColor Cyan
Write-Host "     Stargate 3 Quasar 1" -ForegroundColor Cyan
Write-Host "====================================================================================" -ForegroundColor DarkGray
Write-Host "  Mercwar Stargate  technology" -ForegroundColor DarkYellow
Write-Host "  Status: Contacting server..." -ForegroundColor Gray
Write-Host "====================================================================================" -ForegroundColor DarkGray
Write-Host ""

if ($SoundVal -eq "on") {
    Write-Host "  [SYSTEM] Audio enabled. Registry key [Eclipse\Launcher] updated." -ForegroundColor Green
} else {
    Write-Host "  [SYSTEM] Audio disabled. Registry key [Eclipse\Launcher] updated." -ForegroundColor DarkGray
}
Write-Host ""

Write-Host "  [AVIS] Searching for installation gateway" -ForegroundColor Yellow
Write-Host "  [AVIS] » Target Source : " -NoNewline -ForegroundColor DarkGray
Write-Host "$RepoUrl" -ForegroundColor White
Write-Host "  [AVIS] » Target Output : " -NoNewline -ForegroundColor DarkGray
Write-Host "$TempInstaller" -ForegroundColor White
Write-Host ""
Write-Host "  [AVIS] Connecting to gateway via dc2url..." -ForegroundColor Cyan

# Fetch payload and validate it isn't an HTML error page
try {
    $dc2check = Get-Command dc2url -ErrorAction SilentlyContinue
    if ($dc2check) {
        curl -o "$TempInstaller" "$RepoUrl"
    } else {
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($RepoUrl, $TempInstaller)
    }

    if (-not (Test-Path $TempInstaller) -or (Get-Item $TempInstaller).Length -eq 0) {
        throw "Downloaded payload is empty or missing."
    }

    # Inspect file content to ensure it's a batch script and not an HTML error/404 page
    $FileHeader = Get-Content $TempInstaller -TotalCount 3 -ErrorAction SilentlyContinue | Out-String
    if ($FileHeader -match "<!DOCTYPE|<html>|<html") {
        throw "Server returned an HTML response instead of raw script content. Check downlink.php or file path."
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
