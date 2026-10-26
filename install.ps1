<#
.SYNOPSIS
    dc2URL Root Staging Loader (PowerShell irm / iex target)
#>

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Virtual Terminal Sequence Definitions (TrueColor RGB Match)
$RST   = "$([char]27)[0m"
$GRAD1 = "$([char]27)[38;2;255;102;0m"
$GRAD3 = "$([char]27)[38;2;255;77;166m"
$GOLD  = "$([char]27)[38;2;255;215;0m"
$BLUE  = "$([char]27)[38;2;65;175;255m"
$ICE   = "$([char]27)[38;2;155;225;255m"
$MUTED = "$([char]27)[38;2;115;125;145m"
$WHITE = "$([char]27)[38;2;240;240;250m"

$RepoUrl = "https://raw.githubusercontent.com/mercwar/dc2URL/main/install.bat"
$TempInstaller = "$env:TEMP\dc2_install_$([Guid]::NewGuid().ToString().Substring(0,8)).bat"

Clear-Host
Write-Host ""
Write-Host "${GRAD1}  ────────────────────────────────────────────────────────────────────────────────────"
Write-Host "   ${GOLD}// ${WHITE}F I R E G E M   ${MUTED}■   ${GRAD3}D A R K - C O M - 2   ${MUTED}//   ${ICE}B O O T S T R A P   L O A D E R"
Write-Host "${GRAD1}  ────────────────────────────────────────────────────────────────────────────────────"
Write-Host "   ${MUTED}» ${BLUE}STAGE: ${WHITE}00 // INITIALIZATION PIPELINE"
Write-Host "   ${MUTED}» ${GOLD}ACTION: ${WHITE}Downloading staging wrapper engine from GitHub..."
Write-Host "${GRAD1}  ────────────────────────────────────────────────────────────────────────────────────${RST}"

Invoke-WebRequest -Uri $RepoUrl -OutFile $TempInstaller

Write-Host ""
Write-Host "   ${MUTED}» ${BLUE}STATUS: ${WHITE}Payload acquired."
Write-Host "   ${MUTED}» ${GOLD}ACTION: ${WHITE}Handing context over to interactive staging wrapper..."
Write-Host ""

Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$TempInstaller`"" -Wait -NoNewWindow

if (Test-Path $TempInstaller) {
    Remove-Item $TempInstaller -Force -ErrorAction SilentlyContinue
}
