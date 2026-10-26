<#
.SYNOPSIS
    dc2URL Root Staging Loader (PowerShell irm / iex target)
#>

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$RepoUrl = "https://raw.githubusercontent.com/mercwar/dc2URL/main/install.bat"
$TempInstaller = "$env:TEMP\dc2_install_$([Guid]::NewGuid().ToString().Substring(0,8)).bat"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "               dc2URL :: BOOTSTRAP LOADER                   " -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "[INFO] Downloading staging wrapper engine from GitHub..." -ForegroundColor Yellow

Invoke-WebRequest -Uri $RepoUrl -OutFile $TempInstaller

Write-Host "[INFO] Launching interactive staging wrapper..." -ForegroundColor Green
Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$TempInstaller`"" -Wait -NoNewWindow

if (Test-Path $TempInstaller) {
    Remove-Item $TempInstaller -Force -ErrorAction SilentlyContinue
}
