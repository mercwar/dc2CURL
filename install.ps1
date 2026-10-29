<#
.SYNOPSIS
    dc2URL Root Staging Loader (Strict dc2url Detection & Interactive Menu)
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
$SetupUrl = "https://raw.githubusercontent.com/mercwar/dc2URL/main/setup.bat"
$TempInstaller = "$env:TEMP\dc2_install_$([Guid]::NewGuid().ToString().Substring(0,8)).bat"

Clear-Host
Write-Host "====================================================================================" -ForegroundColor DarkGray
Write-Host "     E C L I P S E    I N S T A L L E R    ■    D C 2 U R L    K E R N E L" -ForegroundColor Cyan
Write-Host "====================================================================================" -ForegroundColor DarkGray
Write-Host "  Mercwar Stargate technology" -ForegroundColor DarkYellow
Write-Host "  Status: System scan initialized..." -ForegroundColor Gray
Write-Host "====================================================================================" -ForegroundColor DarkGray
Write-Host ""

# Strict check for dc2url using 'where.exe'
$dc2urlDetected = $false
foreach ($t in @("dc2url")) {
    $null = where.exe $t 2>&1
    if ($LASTEXITCODE -eq 0) {
        $dc2urlDetected = $true
        break
    }
}

$targetUrl = $RepoUrl
$modeType = "Launcher"

if ($dc2urlDetected) {
    Write-Host "  [AVIS DETECT] dc2url is currently installed on this system." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Select an option:" -ForegroundColor White
    Write-Host "    [1] Install Eclipse (Downloads & runs setup.bat directly)" -ForegroundColor Cyan
    Write-Host "    [2] Continue (Proceeds with standard dc2url launcher update)" -ForegroundColor Gray
    Write-Host "    [3] Exit (Abort installation)" -ForegroundColor Red
    Write-Host ""
    
    $choice = Read-Host "  >>> SELECT OPTION [1-3]"
    
    if ($choice -eq "1") {
        $targetUrl = $SetupUrl
        $modeType = "Eclipse Setup"
        $TempInstaller = "$env:TEMP\eclipse_setup_$([Guid]::NewGuid().ToString().Substring(0,8)).bat"
        Write-Host ""
        Write-Host "  [AVIS] Eclipse mode selected. Bypassing launcher..." -ForegroundColor Cyan
    } elseif ($choice -eq "3" -or $choice -eq "ext" -or $choice -eq "exit") {
        Write-Host ""
        Write-Host "  [AVIS] Operation aborted by user. Exiting." -ForegroundColor Red
        exit 0
    } else {
        Write-Host ""
        Write-Host "  [AVIS] Continuing with standard launcher update..." -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "  [AVIS] Searching for installation gateway" -ForegroundColor Yellow
Write-Host "  [AVIS] » Target Mode   : " -NoNewline -ForegroundColor DarkGray
Write-Host "$modeType" -ForegroundColor White
Write-Host "  [AVIS] » Target Source : " -NoNewline -ForegroundColor DarkGray
Write-Host "$targetUrl" -ForegroundColor White
Write-Host "  [AVIS] » Target Output : " -NoNewline -ForegroundColor DarkGray
Write-Host "$TempInstaller" -ForegroundColor White
Write-Host ""
Write-Host "  [AVIS] Connecting to gateway..." -ForegroundColor Cyan

# Silent download stream
try {
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($targetUrl, $TempInstaller)
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
Write-Host "  [AVIS ECLIPSE] Searching for Cyborg Installer..." -ForegroundColor DarkGray
Start-Sleep -Seconds 3

Write-Host ""
Write-Host "  [AVIS] Calling Portal Installer" -ForegroundColor Yellow
Write-Host "  [ECLIPSE] » AVIS REPORTED SUCCESS..." -ForegroundColor DarkGray
Write-Host "====================================================================================" -ForegroundColor DarkGray
Write-Host ""

Start-Sleep -Milliseconds 600

# Execute the downloaded script interactively without screen flashing
Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$TempInstaller`"" -Wait -NoNewWindow

# Cleanup
if (Test-Path $TempInstaller) {
    Remove-Item $TempInstaller -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "  [ECLIPSE] dc2url will be visible in your add/remove programs after the registration." -ForegroundColor Green
Write-Host "  [ECLIPSE] Auto updates are not supported at this time, you may run this irm or launcher at any time to update." -ForegroundColor Green
Write-Host "====================================================================================" -ForegroundColor DarkGray
